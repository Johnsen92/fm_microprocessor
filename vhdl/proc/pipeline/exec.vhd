library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pipeline_package.all;
use work.sine_cordic_constants.all;

entity exec is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;
        -- for top
        start           : in  std_logic;
        done            : out std_logic;
        -- for operations
        op              : in  EXEC_OP_T;
        result          : out REG_DATA_T;
        writeback       : out std_logic;
        rd              : out REG_ADDR_T;
        jmp             : out std_logic;
        -- interface with ADC/DAC
        adc_rddata      : in  REG_DATA_T;
        dac_wrdata      : out REG_DATA_T;
        dac_valid       : out std_logic
    );
end exec;

architecture rtl of exec is
    component alu is
        port (
            op  : in  ALU_OP_T;
            A   : in  REG_DATA_T;
            B   : in  REG_DATA_T;
            R   : out REG_DATA_T;
            V   : out std_logic
        );
    end component;
    
    component mult2 is
        generic (
            DATA_WIDTH  : integer := 8
        );
        port (
            dataa   : in std_logic_vector(DATA_WIDTH-1 downto 0);
            datab   : in std_logic_vector(DATA_WIDTH-1 downto 0);
            result  : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    component sine_cordic is
        generic (
            INPUT_DATA_WIDTH    : integer := 8;
            OUTPUT_DATA_WIDTH   : integer := 8;
            INTERNAL_DATA_WIDTH : integer := 14;
            ITERATION_COUNT     : integer := 12
        );
        port (
            reset               : in std_logic;
            clk                 : in std_logic;
            beta                : in std_logic_vector(INPUT_DATA_WIDTH-1 downto 0);
            start               : in std_logic;
            done                : out std_logic;
            result              : out std_logic_vector(OUTPUT_DATA_WIDTH-1 downto 0)
        );
    end component;
	
	component wait_unit is
    generic (
        DATA_WIDTH  : integer := 11
    );
	port (
        clk         : in std_logic;
        reset       : in std_logic;
        wait_cycles : in std_logic_vector(DATA_WIDTH-1 downto 0);
        start       : in std_logic;
        done        : out std_logic
	);
	end component;
    
    signal op_int       : EXEC_OP_T;
    signal alu_A        : REG_DATA_T;
    signal alu_B        : REG_DATA_T;
    signal alu_R        : REG_DATA_T;
    signal alu_V        : std_logic;

    -- internal signals
    signal zero_int, neg_int, ovf_int   : std_logic := '0';
	signal zero_reg, neg_reg, ovf_reg   : std_logic := '0';
	signal zero_reg_next, neg_reg_next, ovf_reg_next   : std_logic := '0';
	signal done_int						: std_logic := '0';
    
    -- sine signals
    signal sine_done        : std_logic;
    signal sine_result      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sine_start       : std_logic;
    
    -- adc signals
    signal adc_rddata_int   : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- mult signals
    signal mult_result      : std_logic_vector(DATA_WIDTH-1 downto 0);
	
	-- wait signals
	signal wait_cycles		: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal wait_start		: std_logic;
	signal wait_done		: std_logic;
	
begin
    writeback <= op_int.writeback;
    rd <= op_int.rd;
	done <= done_int;

    -- instances
    alu_inst : alu
        port map (
            op => op_int.alu_op,
            A => alu_A,
            B => alu_B,
            R => alu_R,
            V => alu_V
        );    

    sine_inst : sine_cordic
        generic map(
            INPUT_DATA_WIDTH    => DATA_WIDTH, 
            OUTPUT_DATA_WIDTH   => DATA_WIDTH,
            INTERNAL_DATA_WIDTH => DATA_WIDTH,
            ITERATION_COUNT     => CORDIC_ITERATIONS
        )
        port map (
            reset   => reset,
            clk     => clk,
            beta    => op_int.dataa,
            start   => sine_start,
            done    => sine_done,
            result  => sine_result
        );
        
    mult_inst : mult2
        generic map(
            DATA_WIDTH => DATA_WIDTH
        )
        port map(
            dataa    => op_int.dataa,
            datab    => op_int.datab,
            result   => mult_result
        );
		
	wait_int : wait_unit
		generic map(
			DATA_WIDTH => DATA_WIDTH
		)
		port map(
			clk			=> clk,
			reset		=> reset,
			wait_cycles	=> wait_cycles,
			start		=> wait_start,
			done		=> wait_done
		);
    
    start_daemon : process(start, op_int.special_op)
    begin
        sine_start <= '0';
        wait_start <= '0';
        if(start = '1') then
            if(op_int.special_op = SPECIAL_SIN) then
                sine_start <= '1';
            elsif(op_int.special_op = SPECIAL_WAIT) then
                wait_start <= '1';
            end if;
        end if;
    end process;
    
    -- output process
    exec_output : process (
        op_int, 
        alu_R, 
        alu_V, 
        adc_rddata_int, 
        mult_result, 
        sine_result, 
        sine_done, 
        wait_done, 
        zero_int, 
        ovf_int,
        start
    )
    begin
        -- ALU inputs
        if op_int.use_imm = '1' then
            alu_B <= std_logic_vector(resize(signed(op_int.imm), REG_DATA_T'length));
        else
            alu_B <= op_int.datab;
        end if;
        alu_A <= op_int.dataa;
        
        -- status flags
        if(alu_R = std_logic_vector(to_signed(0, REG_DATA_T'length))) then -- TODO make const DATA_ZERO
            zero_int <= '1';
        else
            zero_int <= '0';
        end if;
        neg_int <= alu_R(alu_R'high) and not alu_V;
        ovf_int <= alu_V;
        
        -- result multiplexer
        if(op_int.special_op /= SPECIAL_NOP) then
            case op_int.special_op is
                when SPECIAL_ADC_IN => result <= adc_rddata_int;
                when SPECIAL_MUL    => result <= mult_result;
                when SPECIAL_SIN    => result <= sine_result;
                when others         => result <= (others => '0');
            end case;
        elsif(op_int.jmp_op /= JMP_NOP) then
            result <= std_logic_vector(resize(unsigned(op_int.addr), REG_DATA_T'length));
        elsif(op_int.alu_op /= ALU_NOP) then
            result <= alu_R;
        elsif(op_int.use_imm = '1') then
            result <= std_logic_vector(resize(signed(op_int.imm), REG_DATA_T'length));
        else
            result <= op_int.datab;
        end if;

		-- wait cycle count multiplexer
		if(op_int.use_imm = '1') then
			wait_cycles <= std_logic_vector(resize(signed(op_int.imm), REG_DATA_T'length));
		else
			wait_cycles <= op_int.dataa;
		end if;
		
        -- done flag multiplexer
        if(op_int.special_op = SPECIAL_SIN) then
            done_int <= sine_done;
		elsif(op_int.special_op = SPECIAL_WAIT) then
			done_int <= wait_done;
        else
            done_int <= start;
        end if;
        
        -- adc operation
        dac_wrdata <= op_int.dataa;
        dac_valid <= '0';
        if(op_int.special_op = SPECIAL_DAC_OUT) then
            dac_valid <= '1';
        end if;
        
        -- jump unit
        case op_int.jmp_op is
            when JMP_NOP => jmp <= '0';
            when JMP_JC =>  jmp <= ovf_reg;
            when JMP_JNC => jmp <= not ovf_reg;
            when JMP_JMP => jmp <= '1';
            when JMP_JZ =>  jmp <= zero_reg;
            when JMP_JNZ => jmp <= not zero_reg;
			when JMP_JN => 	jmp <= neg_reg;
			when JMP_JNN => jmp <= not neg_reg;
            when others =>  jmp <= '0';
        end case;
    end process exec_output;

    -- synch process
    exec_sync: process (clk, reset)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                op_int          <= EXEC_NOP;
                adc_rddata_int  <= (others => '0');
            else
                op_int          <= op;
                adc_rddata_int  <= adc_rddata;
				if(done_int = '1') then
					zero_reg_next 	<= zero_int;
					ovf_reg_next 	<= ovf_int;
					neg_reg_next 	<= neg_int;
				end if;
				
				if(start = '1') then
					zero_reg		<= zero_reg_next;
					ovf_reg			<= ovf_reg_next;
					neg_reg			<= neg_reg_next;
				end if;
            end if;
        end if;
    end process exec_sync;
end rtl;
