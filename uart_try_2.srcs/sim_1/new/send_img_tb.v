`timescale 1ns / 1ps

module send_img_tb(

    );
    
reg clk, reset, tx_btn;
wire TxD, clear, blinker;

uart_tx_top send_lena(
    .clk(clk),
    .reset(reset),
    .tx_btn(tx_btn),
    .TxD(TxD),
    .blinking_led(blinker)
    );
    
always 
begin
    clk= 1; #5; 
    clk= 0; #5;// 10ns periodend
end
    
initial
begin
    reset = 1; #100;
    reset = 0;  #100;
    tx_btn = 1; #1000000;
    $finish;
end
endmodule
