`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2021 08:25:47 PM
// Design Name: 
// Module Name: led_blink
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_blink(
    input clk,
    output led_1
    );
    
    reg [31:0] counter = 0;
    reg led_1 = 0;
    
    always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter >= 100000000)
        begin
            led_1 <= ~led_1;
            counter <= 0;
        end
    end
    
endmodule
