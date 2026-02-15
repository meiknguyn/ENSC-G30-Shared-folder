create_clock -name virt_clk -period 30.0 [get_ports {A[*]}]
set_input_delay 0 -clock virt_clk [get_ports {A[*] B[*] Cin}]
set_output_delay 0 -clock virt_clk [get_ports {S[*] Cout Ovfl}]