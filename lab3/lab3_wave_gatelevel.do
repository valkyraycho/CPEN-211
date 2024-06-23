onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /tb_lab3_gate/SW
add wave -noupdate /tb_lab3_gate/HEX0
add wave -noupdate /tb_lab3_gate/HEX1
add wave -noupdate /tb_lab3_gate/HEX2
add wave -noupdate /tb_lab3_gate/HEX3
add wave -noupdate /tb_lab3_gate/HEX4
add wave -noupdate /tb_lab3_gate/HEX5
add wave -noupdate /tb_lab3_gate/clk
add wave -noupdate /tb_lab3_gate/rst_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {133 ps} {259 ps}
