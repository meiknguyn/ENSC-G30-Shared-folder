# ModelSim Compilation Script
vlib Work

# Compile DUTs
vcom -93 ../SourceCode/DUT/FullAdder.vhd
vcom -93 ../SourceCode/DUT/Adder.vhd

# Compile TBs
vcom -93 ../SourceCode/TB/tb_adder_baseline.vhd
vcom -93 ../SourceCode/TB/tb_adder_ripple.vhd
vcom -93 ../SourceCode/TB/tb_adder_csa.vhd

echo "Compilation complete."
