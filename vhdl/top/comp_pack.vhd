--------------------------------------------------------------------------------
--
--                _     ___ ____        _          _                
--               | |   |_ _/ ___|      | |    __ _| |__   ___  _ __ 
--               | |    | |\___ \ _____| |   / _` | '_ \ / _ \| '__|
--               | |___ | | ___) |_____| |__| (_| | |_) | (_) | |   
--               |_____|___|____/      |_____\__,_|_.__/ \___/|_|   
--
--
--                               LIS - Laborübung
--
--------------------------------------------------------------------------------
--
--                              Copyright (C) 2005-2014
--
--                      ICT - Institute of Computer Technology    
--                    TU Vienna - Technical University of Vienna
--
--------------------------------------------------------------------------------
--
--  NAME:           Components Package
--  UNIT:           comp_pack
--  VHDL:           Package
--
--  Author:         nachtnebel
--
--------------------------------------------------------------------------------
--
--  Description:
--
--    All entities of design in component form in one package.
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.sine_cordic_constants.all;
use work.pipeline_package.all;

package comp_pack is
  
  attribute syn_black_box : boolean;
  attribute syn_noprune : boolean;

  component top is
  port (
    sysclk_i        : in  std_logic;  	-- system clock, 50 MHz

    -- LCD Interface
    lcd_db_io       : inout std_logic_vector(7 downto 0);
    lcd_rs_o        : out std_logic;
    lcd_en_o        : out std_logic;
    lcd_rw_o        : out std_logic;

    -- Push Buttons
    btn_east_i      : in  std_logic;
    btn_north_i     : in  std_logic;
    btn_south_i     : in  std_logic;
    btn_west_i      : in  std_logic;

    -- Rotary Knob (ROT)
    rot_center_i    : in  std_logic;
    rot_a_i         : in  std_logic;
    rot_b_i         : in  std_logic;

    -- Mechanical Switches
    switch_i        : in  std_logic_vector(3 downto 0);

    -- LEDs
    led_o           : out std_logic_vector(7 downto 0);

    -- External SPI Interface to ADC, DAC and Amplifier
    spi_clk_o       : out std_logic;
    spi_dat_o       : out std_logic;
    
    ad_conv_o       : out std_logic;
    adc_dat_i       : in  std_logic;

    dac_clr_n_o     : out std_logic;
    dac_cs_n_o      : out std_logic;
    dac_dat_i       : in  std_logic;

    amp_shdn_o      : out std_logic;
    amp_cs_n_o      : out std_logic;
    amp_dat_i       : in  std_logic
  );
  end component top;

  component spi_ifc is
  port (
    clk_i       : in std_logic;
    reset_n_i   : in std_logic;

    -- Internal Parallel ADC, DAC Interfaces

    adc_ch1_o       : out std_logic_vector (13 downto 0);
    adc_ch1_valid_o : out std_logic;

    adc_ch2_o       : out std_logic_vector (13 downto 0);
    adc_ch2_valid_o : out std_logic;
    adc_ch2_ch_o    : out std_logic_vector (2 downto 0);

    dac_ch1_i       : in std_logic_vector (11 downto 0);
    dac_ch1_valid_i : in std_logic;

    dac_ch2_i       : in std_logic_vector (11 downto 0);
    dac_ch2_valid_i : in std_logic;

    dac_ch3_i       : in std_logic_vector (11 downto 0);
    dac_ch3_valid_i : in std_logic;

    dac_ch4_i       : in std_logic_vector (11 downto 0);
    dac_ch4_valid_i : in std_logic;

    dac_ready_o     : out std_logic;

    amp_ch1_i       : in std_logic_vector (3 downto 0);
    amp_ch2_i       : in std_logic_vector (3 downto 0);

    -- External SPI Interface to ADC, DAC and Amplifier

    spi_clk_o   : out std_logic;
    spi_dat_o   : out std_logic;
    
    ad_conv_o   : out std_logic;
    adc_dat_i   : in  std_logic;

    dac_clr_n_o : out std_logic;
    dac_cs_n_o  : out std_logic;
    dac_dat_i   : in  std_logic;

    amp_shdn_o  : out std_logic;
    amp_cs_n_o  : out std_logic;
    amp_dat_i   : in  std_logic
  );
  end component spi_ifc;

  component lcd_core is
  port (
    clk_i          : in  std_logic;
    reset_n_i      : in  std_logic;

    lcd_cs_i       : in  std_logic;
    lcd_data_i     : in  std_logic_vector (7 downto 0);

    lcd_data_o     : out std_logic_vector (7 downto 0);
    lcd_rs_o       : out std_logic;
    lcd_en_o       : out std_logic;
    lcd_rw_o       : out std_logic
  );
  end component lcd_core;

  component lcd_fifo is
  port (
    clk    : in  std_logic;
    rst_n  : in  std_logic;
    
    wr_en  : in  std_logic;
    din    : in  std_logic_vector (7 downto 0);

    rd_en  : in  std_logic;
    dout   : out std_logic_vector (7 downto 0);

    full   : out std_logic;
    empty  : out std_logic
  );
  end component lcd_fifo;

  component lcd_display is
  port
  (
    clk_i          : in  std_logic;
    reset_n_i      : in  std_logic;

    lcd_cs_o       : out std_logic;
    lcd_data_o     : out std_logic_vector (7 downto 0)
  );
  end component lcd_display;
   
  component reset is
  port (
    clk_i      : in  std_logic;
    async_i    : in  std_logic;

    reset_o    : out std_logic;
    reset_n_o  : out std_logic
  );
  end component reset;

    component fmuc is
    port (
        clk         	: in std_logic;
        reset       	: in std_logic;
        adc_rddata      : in REG_DATA_T;
        dac_wrdata      : out REG_DATA_T;
        dac_valid      	: out std_logic
    );
	end component;

	 
	 component adc_dac is
    port (
		adc_rddata_in	: in ADC_DATA_T;
		dac_wrdata_in	: in REG_DATA_T;
		dac_valid_in	: in std_logic;
		adc_rddata_out	: out REG_DATA_T;
		dac_wrdata_out	: out DAC_DATA_T;
		dac_valid_out	: out std_logic
    );
	end component;

  -----------------------------------------------------------------------------
  --  Spartan-3A Device Components
  -----------------------------------------------------------------------------

  component BUFG
  port (
    O : out std_ulogic;
    I : in std_ulogic
  );
  end component BUFG;

  attribute syn_black_box of BUFG : component is TRUE;

  -----------------------------------------------------------------------------
  --  Spartan-3A Device DNA
  -----------------------------------------------------------------------------

  component DNA_PORT is
  generic (
    SIM_DNA_VALUE : bit_vector := X"000000000000000"
  );
  port(
    DOUT   : out std_ulogic;

    CLK    : in  std_ulogic;
    DIN    : in  std_ulogic;
    READ   : in  std_ulogic;
    SHIFT  : in  std_ulogic
  );
  end component;

  attribute syn_black_box of DNA_PORT : component is TRUE;
  attribute syn_noprune of DNA_PORT   : component is TRUE;  

end comp_pack;
