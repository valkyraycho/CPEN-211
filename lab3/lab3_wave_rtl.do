onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_lab3/SW
add wave -noupdate /tb_lab3/HEX0
add wave -noupdate /tb_lab3/HEX1
add wave -noupdate /tb_lab3/HEX2
add wave -noupdate /tb_lab3/HEX3
add wave -noupdate /tb_lab3/HEX4
add wave -noupdate /tb_lab3/HEX5
add wave -noupdate /tb_lab3/clk
add wave -noupdate /tb_lab3/rst_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {1 ns}
