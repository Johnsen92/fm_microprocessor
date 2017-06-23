onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_proc_fd/clk
add wave -noupdate /testbench_proc_fd/reset
add wave -noupdate -divider FETCH
add wave -noupdate /testbench_proc_fd/fetch_inst/pc
add wave -noupdate /testbench_proc_fd/fetch_inst/pc_next
add wave -noupdate /testbench_proc_fd/instr
add wave -noupdate -divider DECODE
add wave -noupdate /testbench_proc_fd/decode_inst/instr_int
add wave -noupdate -expand -group {instr_int aliases} /testbench_proc_fd/decode_inst/op
add wave -noupdate -expand -group {instr_int aliases} /testbench_proc_fd/decode_inst/rd
add wave -noupdate -expand -group {instr_int aliases} /testbench_proc_fd/decode_inst/rs
add wave -noupdate -expand -group {instr_int aliases} /testbench_proc_fd/decode_inst/rt
add wave -noupdate -expand -group {instr_int aliases} /testbench_proc_fd/decode_inst/imm
add wave -noupdate -expand -group {instr_int aliases} /testbench_proc_fd/decode_inst/addr
add wave -noupdate /testbench_proc_fd/decode_inst/regfile_dataa
add wave -noupdate /testbench_proc_fd/decode_inst/regfile_datab
add wave -noupdate /testbench_proc_fd/decode_inst/rdaddr_b
add wave -noupdate /testbench_proc_fd/decode_inst/rdaddr_a
add wave -noupdate /testbench_proc_fd/exec_op
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30180 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 126
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
WaveRestoreZoom {0 ps} {270528 ps}
