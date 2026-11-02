# Combo II-DLD Spartan-7; Xilinx S7 Pin Map.xlsx
# Physical board behavior is pending lab verification.
# FPGA_CLK1
set_property PACKAGE_PIN B6 [get_ports {clk_50mhz}]
# KEY01
set_property PACKAGE_PIN K4 [get_ports {rst_p}]
# DIP_SW1
set_property PACKAGE_PIN Y1 [get_ports {add_sel}]
# DAC_A_B
set_property PACKAGE_PIN G2 [get_ports {dac_a_b}]
# DAC_CSN
set_property PACKAGE_PIN E1 [get_ports {dac_csn}]
# DAC_LDACN
set_property PACKAGE_PIN F4 [get_ports {dac_ldacn}]
# DAC_WRN
set_property PACKAGE_PIN G4 [get_ports {dac_wen}]
# DAC_D0
set_property PACKAGE_PIN E3 [get_ports {dac_d[0]}]
# DAC_D1
set_property PACKAGE_PIN E5 [get_ports {dac_d[1]}]
# DAC_D2
set_property PACKAGE_PIN D2 [get_ports {dac_d[2]}]
# DAC_D3
set_property PACKAGE_PIN D5 [get_ports {dac_d[3]}]
# DAC_D4
set_property PACKAGE_PIN C2 [get_ports {dac_d[4]}]
# DAC_D5
set_property PACKAGE_PIN C4 [get_ports {dac_d[5]}]
# DAC_D6
set_property PACKAGE_PIN B1 [get_ports {dac_d[6]}]
# DAC_D7
set_property PACKAGE_PIN B3 [get_ports {dac_d[7]}]
# LED_D1
set_property PACKAGE_PIN L4 [get_ports {led_out[7]}]
# LED_D2
set_property PACKAGE_PIN M4 [get_ports {led_out[6]}]
# LED_D3
set_property PACKAGE_PIN M2 [get_ports {led_out[5]}]
# LED_D4
set_property PACKAGE_PIN N7 [get_ports {led_out[4]}]
# LED_D5
set_property PACKAGE_PIN M7 [get_ports {led_out[3]}]
# LED_D6
set_property PACKAGE_PIN M3 [get_ports {led_out[2]}]
# LED_D7
set_property PACKAGE_PIN M1 [get_ports {led_out[1]}]
# LED_D8
set_property PACKAGE_PIN N5 [get_ports {led_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports *]
create_clock -name clk_50mhz -period 20.000 [get_ports {clk_50mhz}]
