`timescale 1ns / 1ps

module img_process_tb(

    );
    
reg clk, reset, process_trig;
wire TxD, blinking_led;

img_process_top processing(
    .clk(clk),
    .reset(reset),
    .process_trig(process_trig),
    .TxD(TxD),
    .blinking_led(blinking_led)
    );
    
always 
begin
    clk= 1; #5; 
    clk= 0; #5;// 10ns periodend
end
    
initial
begin
    reset = 1; 
    process_trig = 0; #100;
    reset = 0;  #100;
    process_trig = 1; #10000;
    process_trig = 0; #13600000;
    $finish;
end
endmodule
