##############################################################################
# Basys 3 Constraints File for 128-Tap FIR Filter Project
# Board: Digilent Basys 3 (Artix-7 XC7A35T-1CPG236C)
# Author: Auto-generated for Basys 3 FPGA
##############################################################################

## Clock Signal (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Reset Signal (Center Button - BTNC)
set_property PACKAGE_PIN U18 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## Switch for Frequency Selection (SW0)
set_property PACKAGE_PIN V17 [get_ports sw0]
set_property IOSTANDARD LVCMOS33 [get_ports sw0]

## UART TX Pin (USB-UART Interface)
set_property PACKAGE_PIN A18 [get_ports uart_tx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]

##############################################################################
# Timing Constraints
##############################################################################

## Clock Groups (if needed for different clock domains)
# set_clock_groups -asynchronous -group [get_clocks sys_clk_pin]

## Input Delay Constraints
set_input_delay -clock [get_clocks sys_clk_pin] -min 2.0 [get_ports rst_n]
set_input_delay -clock [get_clocks sys_clk_pin] -max 4.0 [get_ports rst_n]
set_input_delay -clock [get_clocks sys_clk_pin] -min 2.0 [get_ports sw0]
set_input_delay -clock [get_clocks sys_clk_pin] -max 4.0 [get_ports sw0]

## Output Delay Constraints
set_output_delay -clock [get_clocks sys_clk_pin] -min 1.0 [get_ports uart_tx_pin]
set_output_delay -clock [get_clocks sys_clk_pin] -max 3.0 [get_ports uart_tx_pin]

##############################################################################
# Additional Constraints for Better Performance
##############################################################################

## Configuration and Bitstream Settings
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## False Path Constraints (for asynchronous inputs)
set_false_path -from [get_ports rst_n] -to [all_registers]
set_false_path -from [get_ports sw0] -to [all_registers]

##############################################################################
# Optional: Additional Basys 3 pins for future expansion
##############################################################################

## Additional Switches (commented out - not used in current design)
# set_property PACKAGE_PIN V16 [get_ports sw1]
# set_property IOSTANDARD LVCMOS33 [get_ports sw1]
# set_property PACKAGE_PIN W16 [get_ports sw2]
# set_property IOSTANDARD LVCMOS33 [get_ports sw2]

## LEDs for debugging (commented out - not used in current design)
# set_property PACKAGE_PIN U16 [get_ports led0]
# set_property IOSTANDARD LVCMOS33 [get_ports led0]
# set_property PACKAGE_PIN E19 [get_ports led1]
# set_property IOSTANDARD LVCMOS33 [get_ports led1]

##############################################################################
# End of Constraints File
##############################################################################