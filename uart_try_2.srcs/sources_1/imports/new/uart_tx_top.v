`timescale 1ns / 1ps

module uart_tx_top(
    input clk,
    input reset,
    input tx_btn,
    output TxD,
    output blinking_led
    );

    wire [7:0] data;
    wire tx_complete; // transmitter tells people that it has transmitted a byte 
    wire transmit; // command the transmitter to transmit a byte
    wire [13:0] pixel_inx;
//    reg [17:0] clk_cnt = 0;
//    reg clk_500 = 0;
    
//    always @ (posedge clk) begin
//        clk_cnt <= clk_cnt + 1;
//        if (clk_cnt >= 199999) begin
//            clk_cnt <= 0;
//            clk_500 <= ~clk_500;
//        end
//    end

    send_img sender(
        .clk(clk),
        .reset(reset),
        .tx_btn(tx_btn),
        .tx_complete(tx_complete),
        .pixel_inx(pixel_inx),
        .transmit(transmit)
    );

//    assign reset = 1'b0;
    uart_transmitter uart_transmitter(
        .clk(clk),
        .reset(reset),
        .transmit(transmit),
        .data(data),
        .TxD(TxD),
        .clear(tx_complete)
    );

    led_blink led_blinker(
        .clk(clk),
        .led_1(blinking_led)
    );

    blk_mem_gen_0 BRAMROM(
        .clka(clk),
        .addra(pixel_inx),
        .douta(data),
        .ena(1)
    );

//    addresstodata addresstodata(
//        .clk(clk),
//        .address(pixel_inx),
//        .data(data)
//    );

    assign uart_rx_blink = ~TxD;
endmodule
