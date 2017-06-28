onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_fmuc/clk
add wave -noupdate /testbench_fmuc/reset
add wave -noupdate -divider REGISTERS
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/regfile_inst/regfile
add wave -noupdate -format Analog-Step -height 80 -max 1.0 -min -1.0 /testbench_fmuc/in_r
add wave -noupdate -format Analog-Step -height 80 -max 1.0 -min -1.0 /testbench_fmuc/sine
add wave -noupdate -divider FETCH
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/start
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/done
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/jmp
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/jmp_addr
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/instr
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/pc
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/pc_next
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/jmp_pc
add wave -noupdate /testbench_fmuc/fmuc_inst/fetch/imem_instr
add wave -noupdate -divider DECODE
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/start
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/done
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/instr_int
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/rdaddr_b
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/rdaddr_a
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/regfile_dataa
add wave -noupdate /testbench_fmuc/fmuc_inst/decode/regfile_datab
add wave -noupdate -expand /testbench_fmuc/fmuc_inst/decode/exec_op
add wave -noupdate -divider EXEC
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/start
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/done
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/result
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/writeback
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/rd
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/jmp
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/adc_rddata
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/dac_wrdata
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/dac_valid
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/op_int
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/alu_R
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/sine_done
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/sine_result
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/sine_start
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/adc_rddata_int
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/mult_result
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/wait_start
add wave -noupdate /testbench_fmuc/fmuc_inst/exec/wait_done
add wave -noupdate -divider WRITEBACK
add wave -noupdate /testbench_fmuc/fmuc_inst/writeback/start
add wave -noupdate /testbench_fmuc/fmuc_inst/writeback/done
add wave -noupdate /testbench_fmuc/fmuc_inst/writeback/wr
add wave -noupdate /testbench_fmuc/fmuc_inst/writeback/wraddr
add wave -noupdate /testbench_fmuc/fmuc_inst/writeback/wrdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10808190000 ps} 1} {{Cursor 2} {16984830000 ps} 1} {{Cursor 3} {10659330000 ps} 1} {{Cursor 4} {11009370000 ps} 1} {{Cursor 5} {13898430000 ps} 1} {{Cursor 6} {13791590000 ps} 1} {{Cursor 7} {13922410000 ps} 1}
quietly wave cursor active 7
configure wave -namecolwidth 127
configure wave -valuecolwidth 101
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {9814126394 ps} {17246072634 ps}
