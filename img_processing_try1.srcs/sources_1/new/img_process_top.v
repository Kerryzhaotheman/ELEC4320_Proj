`timescale 1ns / 1ps

module img_process_top(
    clk,
    reset,
    process_trig,
    TxD,
    blinking_led
    );
    
    input clk, reset, process_trig;
    output TxD, blinking_led;
    
    wire process_finished;
    wire [13:0] pixel_inx; // address bus used by the filter to access ROM
    wire [7:0] data_in;
    wire [13:0] out_inx; // address bus used by the filter to store processed image in BRAM
    wire [7:0] data_out;
    wire [7:0] processed_data_out;
    wire transmit;
    reg [1:0] clk25_count = 0;
    reg clk_25MHz = 1;
    reg clk_cnt = 0;
    wire [13:0] sender_inx; // address bus used by the sender to access processed image in BRAM
    reg [13:0] ram_inx = 0; // address bus leading out from the bram
//    reg [13:0] out_inx_reg, sender_inx_reg, ram_inx_reg;
    
always @ (posedge clk) begin
    clk25_count <= clk25_count + 1;
    if (clk25_count >= 3) begin
        clk_25MHz <= ~clk_25MHz;
        clk25_count <= 0;
    end
end

always @ (posedge clk) begin
    if (process_finished) begin
        ram_inx <= sender_inx;
    end else begin
        ram_inx <= out_inx;
    end
end

median_filter median_filter(
        .clk(clk_25MHz),
        .reset(reset),
        .process_trig(process_trig),
        .data_in(data_in),
        .pixel_inx(pixel_inx),
        .out_inx(out_inx),
        .data_out(data_out),
        .process_finished(process_finished)
    );
    
bram_img_rom IMGROM(
        .clka(clk),
        .addra(pixel_inx),
        .douta(data_in),
        .ena(1)
    );

bram_output_img IMGOUT(
        .addra(ram_inx),
        .clka(clk),
        .dina(data_out),
        .douta(processed_data_out),
        .ena(1),
        .wea(~process_finished)
    );

send_img sender(
        .clk(clk),
        .reset(reset),
        .tx_btn(process_finished),
        .tx_complete(tx_complete),
        .pixel_inx(sender_inx),
        .transmit(transmit)
    );

uart_transmitter uart_transmitter(
        .clk(clk),
        .reset(reset),
        .transmit(transmit),
        .data(processed_data_out),
        .TxD(TxD),
        .clear(tx_complete)
    );
    
led_blink led_blinker(
        .clk(clk),
        .led_1(blinking_led)
    );
    
endmodule
