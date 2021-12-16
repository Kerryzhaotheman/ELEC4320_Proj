`timescale 1ns / 1ps

module sobel_filter(
    clk,
    reset,
    process_trig,
    data_in,
    pixel_inx,
    out_inx,
    data_out,
    in_process,
    process_finished
    );
    
    input clk, reset, process_trig;
    input [7:0] data_in; // data read from original img
    output reg [13:0] pixel_inx; // inx to access original img 
    output reg [7:0] data_out; // data to write output img
    output reg [13:0] out_inx = 0; // inx to write output img
    output reg in_process = 0;
    output reg process_finished = 0;
    
    reg [4:0] process_state;
    reg [7:0] window[8:0];
    reg [4:0] window_inx;
    reg signed [31:0] Gx_mask[8:0]; // Gx mask
    reg signed [31:0] Gy_mask[8:0]; // Gy mask
    reg signed [31:0] Gx, Gy; // Gx pixel, Gy pixel
    reg [3:0] i,j;
    reg process_trig_pressed = 0;
    
    always @ (posedge clk) begin
        if (reset) begin
            process_state <= 5'd0;
            pixel_inx <= 0; data_out <= 0; out_inx <= 0;
            window[0] <= 0; window[1] <= 0; window[2] <= 0;
            window[3] <= 0; window[4] <= 0; window[5] <= 0;
            window[6] <= 0; window[7] <= 0; window[8] <= 0;
            Gx_mask[0] <= 0; Gx_mask[1] <= 0; Gx_mask[2] <= 0;
            Gx_mask[3] <= 0; Gx_mask[4] <= 0; Gx_mask[5] <= 0;
            Gx_mask[6] <= 0; Gx_mask[7] <= 0; Gx_mask[8] <= 0;
            Gy_mask[0] <= 0; Gy_mask[1] <= 0; Gy_mask[2] <= 0;
            Gy_mask[3] <= 0; Gy_mask[4] <= 0; Gy_mask[5] <= 0;
            Gy_mask[6] <= 0; Gy_mask[7] <= 0; Gy_mask[8] <= 0;
            Gx <= 0; Gy <= 0;
            window_inx <= 0; i <= 0; j <= 0;
            process_trig_pressed <= 0; in_process <= 0; process_finished <= 0;
        end
        else begin
            if (process_trig && ~process_trig_pressed) begin
                process_state <= 5'b1;
                process_trig_pressed <= 1;
                in_process <= 1;
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
                5'd6 : begin // generate Gx_mask and Gy_mask 
                    Gx_mask[0] <= window[0] * 1;
                    Gx_mask[1] <= window[1] * 0;
                    Gx_mask[2] <= window[2] * -1;
                    Gx_mask[3] <= window[3] * 2;
                    Gx_mask[4] <= window[4] * 0;
                    Gx_mask[5] <= window[5] * -2;
                    Gx_mask[6] <= window[6] * 1;
                    Gx_mask[7] <= window[7] * 0;
                    Gx_mask[8] <= window[8] * -1;
                    
                    Gy_mask[0] <= window[0] * -1;
                    Gy_mask[1] <= window[1] * -2;
                    Gy_mask[2] <= window[2] * -1;
                    Gy_mask[3] <= window[3] * 0;
                    Gy_mask[4] <= window[4] * 0;
                    Gy_mask[5] <= window[5] * 0;
                    Gy_mask[6] <= window[6] * 1;
                    Gy_mask[7] <= window[7] * 2;
                    Gy_mask[8] <= window[8] * 1;
                    
                    process_state <= 5'd11;
                    end
                5'd7 : begin // clear window[], Gx_mask[] and Gy_mask[]
                    window[0] <= 0; window[1] <= 0; window[2] <= 0;
                    window[3] <= 0; window[4] <= 0; window[5] <= 0;
                    window[6] <= 0; window[7] <= 0; window[8] <= 0;
                    Gx_mask[0] <= 0; Gx_mask[1] <= 0; Gx_mask[2] <= 0;
                    Gx_mask[3] <= 0; Gx_mask[4] <= 0; Gx_mask[5] <= 0;
                    Gx_mask[6] <= 0; Gx_mask[7] <= 0; Gx_mask[8] <= 0;
                    Gy_mask[0] <= 0; Gy_mask[1] <= 0; Gy_mask[2] <= 0;
                    Gy_mask[3] <= 0; Gy_mask[4] <= 0; Gy_mask[5] <= 0;
                    Gy_mask[6] <= 0; Gy_mask[7] <= 0; Gy_mask[8] <= 0;
                    Gx <= 0; Gy <= 0;
                    process_state <= 5'd8;
                    end
                5'd8 : begin // increment out_inx and check if bigger than 9999
                    out_inx <= out_inx + 1;
                    if (out_inx > 9999) begin
                        process_state <= 5'd10;
                    end 
                    else begin
                        process_state <= 5'd2;
                    end
                    end
                5'd10 : begin // process finished 
                    in_process <= 0;
                    process_finished <= 1;
                    end
                5'd11 : begin // add all Gx_mask to get Gx, add all Gy_mask to get Gy
                    Gx <= Gx_mask[0] + Gx_mask[1] + Gx_mask[2] + Gx_mask[3] + Gx_mask[4] + Gx_mask[5] + Gx_mask[6] + Gx_mask[7] + Gx_mask[8];
                    Gy <= Gy_mask[0] + Gy_mask[1] + Gy_mask[2] + Gy_mask[3] + Gy_mask[4] + Gy_mask[5] + Gy_mask[6] + Gy_mask[7] + Gy_mask[8];
                    process_state <= 5'd12;
                    end
                5'd12 : begin // add Gx and Gy to get data_out
                    if (Gx + Gy > 255) begin
                        data_out <= 255;
                    end else if (Gx + Gy < 0) begin
                        if (Gx + Gy < -255) begin
                            data_out <= 255;
                        end else begin
                            data_out <= -(Gx + Gy);
                        end
                    end else begin
                        data_out <= Gx + Gy;
                    end
                    process_state <= 5'd7;
                    end
                default : ;
            endcase
        end
    end
endmodule
