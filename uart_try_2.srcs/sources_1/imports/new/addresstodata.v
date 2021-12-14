`timescale 1ns / 1ps

module addresstodata(
    input clk,
    input [13:0] address,
    output reg [7:0] data
    );

always @ (posedge clk) begin
    case (address)
        0 : data <= 8'h23;
        1 : data <= 8'h24;
        2 : data <= 8'h25;
        3 : data <= 8'h26;
        4 : data <= 8'h27;
        5 : data <= 8'h28;
        6 : data <= 8'h29;
        7 : data <= 8'h2a;
        8 : data <= 8'h2b;
        9 : data <= 8'h2c;
        default : data <= 8'h17;
    endcase
end
    
endmodule
