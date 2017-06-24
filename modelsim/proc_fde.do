onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_proc_fde/clk
add wave -noupdate /testbench_proc_fde/reset
add wave -noupdate -divider FETCH
add wave -noupdate /testbench_proc_fde/fetch_inst/pc_next
add wave -noupdate /testbench_proc_fde/fetch_inst/pc
add wave -noupdate /testbench_proc_fde/fetch_inst/instr
add wave -noupdate -divider DECODE
add wave -noupdate /testbench_proc_fde/decode_inst/instr_int
add wave -noupdate /testbench_proc_fde/decode_inst/rdaddr_a
add wave -noupdate /testbench_proc_fde/decode_inst/rdaddr_b
add wave -noupdate /testbench_proc_fde/decode_inst/regfile_dataa
add wave -noupdate /testbench_proc_fde/decode_inst/regfile_datab
add wave -noupdate /testbench_proc_fde/decode_inst/exec_op
add wave -noupdate -divider EXEC
add wave -noupdate /testbench_proc_fde/exec_inst/op_int
add wave -noupdate /testbench_proc_fde/exec_inst/result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {109810 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 203
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {242528 ps}
