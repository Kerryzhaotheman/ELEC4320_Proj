## CLOCK
set_property PACKAGE_PIN W5 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]

## UART TX & RX
set_property PACKAGE_PIN A18 [get_ports {TxD}]
set_property IOSTANDARD LVCMOS33 [get_ports {TxD}]

set_property PACKAGE_PIN B18 [get_ports {RxD}]
set_property IOSTANDARD LVCMOS33 [get_ports {RxD}]

## Buttons
#set_property PACKAGE_PIN V17 [get_ports {data[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data[0]}]

#set_property PACKAGE_PIN V16 [get_ports {data[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data[1]}]

#set_property PACKAGE_PIN W16 [get_ports {data[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data[2]}]

#set_property PACKAGE_PIN W17 [get_ports {data[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {data[3]}]

#set_property PACKAGE_PIN W15 [get_ports {data[4]}] 
#set_property IOSTANDARD LVCMOS33 [get_ports {data[4]}]

#set_property PACKAGE_PIN V15 [get_ports {data[5]}] 
#set_property IOSTANDARD LVCMOS33 [get_ports {data[5]}]

#set_property PACKAGE_PIN W14 [get_ports {data[6]}] 
#set_property IOSTANDARD LVCMOS33 [get_ports {data[6]}]

#set_property PACKAGE_PIN W13 [get_ports {data[7]}] 
#set_property IOSTANDARD LVCMOS33 [get_ports {data[7]}]

set_property PACKAGE_PIN W19 [get_ports {reset}]
set_property IOSTANDARD LVCMOS33 [get_ports {reset}]

set_property PACKAGE_PIN U18 [get_ports {tx_btn}]
set_property IOSTANDARD LVCMOS33 [get_ports {tx_btn}]

#set_property PACKAGE_PIN U18 [get_ports {transmit}]
#set_property IOSTANDARD LVCMOS33 [get_ports {transmit}]

## LEDs
set_property PACKAGE_PIN L1 [get_ports {blinking_led}]
set_property IOSTANDARD LVCMOS33 [get_ports {blinking_led}]

set_property PACKAGE_PIN P1 [get_ports {uart_tx_blink}]
set_property IOSTANDARD LVCMOS33 [get_ports {uart_tx_blink}]