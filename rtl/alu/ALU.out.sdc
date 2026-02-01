## Generated SDC file "ALU.out.sdc"

## Copyright (C) 2025  Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Altera and sold by Altera or its authorized distributors.  Please
## refer to the Altera Software License Subscription Agreements 
## on the Quartus Prime software download page.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 24.1std.0 Build 1077 03/04/2025 SC Lite Edition"

## DATE    "Sun Oct 12 01:02:09 2025"

##
## DEVICE  "5CGXFC7C7F23C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {data_rdata[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {instr_data[31]}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  2.000 [get_ports {reset}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_addr[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_wdata[31]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {data_we}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {instr_addr[31]}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set False path
#**************************************************************

set_false_path -to [get_ports {instr_addr[*] data_addr[*] data_wdata[*] data_we}]



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
