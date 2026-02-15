onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL SIGNALS}
add wave -noupdate -radix hexadecimal /A
add wave -noupdate -radix hexadecimal /B
add wave -noupdate /Cin
add wave -noupdate -radix hexadecimal /S
add wave -noupdate /Cout
add wave -noupdate /Ovfl
add wave -noupdate -divider {VERIFICATION}
add wave -noupdate -radix decimal /measurement_index
add wave -noupdate -radix hexadecimal /S_expected
add wave -noupdate /Cout_expected
add wave -noupdate /Ovfl_expected
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
WaveRestoreZoom {0 ps} {100 ns}
