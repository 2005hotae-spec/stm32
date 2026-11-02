# Combo II-DLD Spartan-7; Xilinx S7 Pin Map.xlsx
# Physical board behavior is pending lab verification.
# FPGA_CLK1
set_property PACKAGE_PIN B6 [get_ports {clk_50mhz}]
# KEY01
set_property PACKAGE_PIN K4 [get_ports {left_button}]
# KEY02
set_property PACKAGE_PIN N8 [get_ports {rst_p}]
# KEY03
set_property PACKAGE_PIN N4 [get_ports {right_button}]
# SERVO_CTRL
set_property PACKAGE_PIN AA22 [get_ports {servo}]
set_property IOSTANDARD LVCMOS33 [get_ports *]
create_clock -name clk_50mhz -period 20.000 [get_ports {clk_50mhz}]
