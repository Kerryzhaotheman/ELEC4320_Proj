`timescale 1ns / 1ps

module median_filter(
    clk,
    reset,
    process_trig,
    data_in,
    pixel_inx,
    out_inx,
    data_out,
    process_finished
    );
    
    input clk, reset, process_trig;
    input [7:0] data_in; // data read from original img
    output reg [13:0] pixel_inx; // inx to access original img 
    output reg [7:0] data_out; // data to write output img
    output reg [13:0] out_inx = 0; // inx to write output img
    output reg process_finished = 0;
//    reg [13:0] clk_count;
    reg [4:0] process_state;
    reg [7:0] window[8:0];
    reg [4:0] window_inx;
    reg [7:0] temp;
    reg [3:0] i,j;
    reg process_trig_pressed = 0;
    
    always @ (posedge clk) begin
        if (reset) begin
            process_state <= 5'd0;
            pixel_inx <= 0; data_out <= 0; out_inx <= 0;
            window[0] <= 0; window[1] <= 0; window[2] <= 0;
            window[3] <= 0; window[4] <= 0; window[5] <= 0;
            window[6] <= 0; window[7] <= 0; window[8] <= 0;
            window_inx <= 0; temp <= 0; i <= 0; j <= 0;
            process_trig_pressed <= 0; process_finished <= 0;
        end
        else begin
            if (process_trig && ~process_trig_pressed) begin
                process_state <= 5'b1;
                process_trig_pressed <= 1;
            end
            case (process_state)
                5'd1 : begin
                    out_inx <= 0;
                    process_state <= 5'd2;
                    end
                5'd2 : begin
                    window_inx <= 0;
                    process_state <= 5'd3;
                    end
                5'd3 : begin // determine which pixel to access
                    if (out_inx < 100 || out_inx % 100 == 0 || out_inx %100 == 99 || out_inx >= 9900) begin
                        pixel_inx <= 0;
                        process_state <= 5'd9; // go to special handle edge condition state
                    end
                    else begin
                        case (window_inx)
                            0 : pixel_inx <= out_inx - 101;
                            1 : pixel_inx <= out_inx - 100;
                            2 : pixel_inx <= out_inx - 99;
                            3 : pixel_inx <= out_inx - 1;
                            4 : pixel_inx <= out_inx ;
                            5 : pixel_inx <= out_inx + 1;
                            6 : pixel_inx <= out_inx + 99;
                            7 : pixel_inx <= out_inx + 100;
                            8 : pixel_inx <= out_inx + 101;
                            default : pixel_inx <= 0;
                        endcase
                        process_state <= 5'd4;
                    end
                    end
                5'd4 : begin // load data_in into window[window_inx]
                    window[window_inx] <= data_in;
                    process_state <= 5'd5;
                    end
                5'd9 : begin //handling edge condition
                    window[window_inx] <= 0;
                    process_state <= 5'd5;
                    end
                5'd5 : begin // increment window_inx and check if window is fully filled
                    window_inx <= window_inx + 1;
                    if (window_inx >= 9) begin
                        process_state <= 5'd6; // go process the window 
                        window_inx <= 0;
                    end
                    else begin
                        process_state <= 5'd3;
                    end
                    end
                5'd6 : begin // median filter processing kernel
                    if (window[j] > window[j + 1]) begin 
                        temp <= window[j]; // swap
                        window[j] <= window[j + 1];
                        window[j + 1] <= temp;
                    end
                    j <= j + 1;
                    if (j >= 7) begin
                        process_state <= 5'd11;
                        j <= 0;
                    end else begin
                        process_state <= 5'd6;
                    end
                    end
                5'd7 : begin // clear window[]
                    window[0] <= 0; window[1] <= 0; window[2] <= 0;
                    window[3] <= 0; window[4] <= 0; window[5] <= 0;
                    window[6] <= 0; window[7] <= 0; window[8] <= 0;
                    process_state <= 5'd8;
                    end
                5'd8 : begin
                    out_inx <= out_inx + 1;
                    if (out_inx > 9999) begin
                        process_state <= 5'd10;
                    end 
                    else begin
                        process_state <= 5'd2;
                    end
                    end
                5'd10 : begin
                        process_finished <= 1;
                    end
                5'd11 : begin // state to increment i and check if it's bigger than 9
                        i <= i + 1;
                        if (i >= 7) begin
                            data_out <= window[4];
                            process_state <= 5'd7;
                            i <= 0; 
                            j <= 0;
                        end else begin
                            process_state <= 5'd6;
                        end
                    end
                default : ;
            endcase
        end
    end
endmodule

