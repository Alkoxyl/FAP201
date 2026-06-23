//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.01 Education (64-bit) 
//Created Time: 2026-06-23 21:58:19
create_clock -name i_Clk -period 10 -waveform {0 5} [get_ports {i_Clk}]
