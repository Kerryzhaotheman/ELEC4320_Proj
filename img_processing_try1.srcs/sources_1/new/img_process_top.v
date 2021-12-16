`timescale 1ns / 1ps

module img_process_top(
    clk,
    reset,
    median_trig,
    sobel_trig,
    TxD,
    blinking_led
    );
    
    input clk, reset, median_trig, sobel_trig;
    output TxD, blinking_led;
    
    wire median_process_finished, sobel_process_finished; 
    reg process_finished = 0;
    wire median_in_process, sobel_in_process;
    wire [13:0] median_pixel_inx; // address bus used by the median filter to access ROM
    wire [13:0] sobel_pixel_inx; // address bus used by the sobel filter to access ROM
    reg [13:0] rom_inx = 0; // address bus leading out from the ROM
    wire [7:0] data_in;
    wire [13:0] median_out_inx; // address bus used by the median filter to store processed image in BRAM
    wire [13:0] sobel_out_inx; // address bus used by the sobel filter to store processed image in BRAM
    wire [7:0] median_data_out; // data bus used by the median filter to BRAM
    wire [7:0] sobel_data_out; // data bus used by the sobel filter to BRAM
    reg [7:0] data_out; // data_in bus leading out from the BRAM
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
    if (~(median_in_process || sobel_in_process)) begin
        ram_inx <= sender_inx;
        rom_inx <= 0;
        data_out <= 0;
    end else begin
        if (median_in_process) begin
            ram_inx <= median_out_inx;
            data_out <= median_data_out;
            rom_inx <= median_pixel_inx;
        end else if (sobel_in_process) begin
            ram_inx <= sobel_out_inx;
            data_out <= sobel_data_out;
            rom_inx <= sobel_pixel_inx;
        end
    end
    
    if (median_process_finished || sobel_process_finished) begin
        process_finished <= 1;
    end else begin
        process_finished <= 0;
    end
end

median_filter median_filter(
        .clk(clk_25MHz),
        .reset(reset),
        .process_trig(median_trig),
        .data_in(data_in),
        .pixel_inx(median_pixel_inx),
        .out_inx(median_out_inx),
        .data_out(median_data_out),
        .in_process(median_in_process),
        .process_finished(median_process_finished)
    );

sobel_filter sobel_filter(
        .clk(clk_25MHz),
        .reset(reset),
        .process_trig(sobel_trig),
        .data_in(data_in),
        .pixel_inx(sobel_pixel_inx),
        .out_inx(sobel_out_inx),
        .data_out(sobel_data_out),
        .in_process(sobel_in_process),
        .process_finished(sobel_process_finished)
    );
    
bram_img_rom IMGROM(
        .clka(clk),
        .addra(rom_inx),
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
