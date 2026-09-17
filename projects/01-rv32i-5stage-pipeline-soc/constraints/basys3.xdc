## ==============================================================================
## Basys3 Master Constraints File for hazard_with_csr_interrupt
## Target Module: rv32I_fpga_top
## ==============================================================================

## Clock signal (100 MHz On-Board Oscillator)
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Push Buttons
## Center Button (btnC) -> External Interrupt (Trigger to btn_debounce -> ext_irq)
set_property PACKAGE_PIN U18 [get_ports btnC]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnC]

## Top Button (btnU) -> System Synchronous Reset (Active-High)
set_property PACKAGE_PIN T18 [get_ports btnU]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnU]

## 16 LEDs (gpio[15:0])
set_property PACKAGE_PIN U16 [get_ports {gpio[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN E19 [get_ports {gpio[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property PACKAGE_PIN U19 [get_ports {gpio[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[2]}]
set_property PACKAGE_PIN V19 [get_ports {gpio[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[3]}]
set_property PACKAGE_PIN W18 [get_ports {gpio[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[4]}]
set_property PACKAGE_PIN U15 [get_ports {gpio[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[5]}]
set_property PACKAGE_PIN U14 [get_ports {gpio[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[6]}]
set_property PACKAGE_PIN V14 [get_ports {gpio[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[7]}]
set_property PACKAGE_PIN V13 [get_ports {gpio[8]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[8]}]
set_property PACKAGE_PIN V3 [get_ports {gpio[9]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[9]}]
set_property PACKAGE_PIN W3 [get_ports {gpio[10]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[10]}]
set_property PACKAGE_PIN U3 [get_ports {gpio[11]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[11]}]
set_property PACKAGE_PIN P3 [get_ports {gpio[12]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[12]}]
set_property PACKAGE_PIN N3 [get_ports {gpio[13]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[13]}]
set_property PACKAGE_PIN P1 [get_ports {gpio[14]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[14]}]
set_property PACKAGE_PIN L1 [get_ports {gpio[15]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {gpio[15]}]

## 4-Digit 7 Segment Display (Active-Low)
## Cathodes (seg[6:0]: a ~ g)
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

## Decimal Point (dp)
set_property PACKAGE_PIN V7 [get_ports dp]							
	set_property IOSTANDARD LVCMOS33 [get_ports dp]

## Digit Anodes (an[3:0]: AN0 ~ AN3)
set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

## USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports RsRx]						
	set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
set_property PACKAGE_PIN A18 [get_ports RsTx]						
	set_property IOSTANDARD LVCMOS33 [get_ports RsTx]
