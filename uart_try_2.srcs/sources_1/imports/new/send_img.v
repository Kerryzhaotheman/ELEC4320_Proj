`timescale 1ns / 1ps

module send_img(
    input clk,
    input reset,
    input tx_btn,
    input tx_complete,
    output reg [13:0] pixel_inx,
    output reg transmit // triggers the transmitter to transmit 
    );
    
    reg tx_btn_pressed = 0;
    reg [13:0] clk_count = 0;
    reg [2:0] sender_state = 0; // 000: idle; 001: next byte tx start; 010: pull high transmit signal; 011: waiting for tx_complete; 
                                //100: tx_complete signal pulled high; 101: tx_complete signal pulled low; 110: last pixel transmitted;
    
    always @(posedge clk)
    begin
        if (reset) begin
            pixel_inx <= 0;
            tx_btn_pressed <= 0;
            sender_state <= 0;
            clk_count <= 0;
        end 
        else begin
            if (tx_btn && ~tx_btn_pressed) begin // tx_btn pressed
                sender_state <= 3'b111;
                tx_btn_pressed <= 1;
            end
            case (sender_state)
                3'b111 : begin
                    clk_count <= clk_count + 1;
                    if (clk_count >= 1000) begin // put some delay 
                        clk_count <= 0;
                        pixel_inx <= 0;
                        sender_state <= 3'b010; // start tx first byte 
                    end
                    else begin 
                        sender_state <= 3'b111;
                    end
                    end
                3'b001 : begin // state: next byte tx start 
                    pixel_inx <= pixel_inx + 1'b1;
                    if (pixel_inx >= 9999) begin
                        sender_state <= 3'b110; // last pixel transmitted
                    end
                    else begin
                        sender_state <= 3'b010; // go pull high transmit signal
                    end
                    end
                3'b010 : begin
                    clk_count <= clk_count + 1;
                    if (clk_count >= 10500) begin
                        transmit <= 0;
                        clk_count <= 0;
                        sender_state <= 3'b011; // go wait for tx_complete signal 
                    end
                    else begin
                        transmit <= 1;
                        sender_state <= 3'b010;
                    end
                    end
                3'b011 : begin // state: waiting for tx_complete
                    if (tx_complete) begin
                        sender_state <= 3'b100; // go to next byte tx start 
                    end
                    else begin
                        sender_state <= 3'b011; // keep waiting for tx_complete
                    end
                    end
                3'b100 : begin // waiting for tx_complete signal to go low 
                    if (tx_complete) begin
                        sender_state <= 3'b100; // keep waiting tx_complete to go low
                    end
                    else begin
                        sender_state <= 3'b101; // go get some delay before tx next byte
                    end
                    end
                3'b101 : begin // delay some time to start next byte tx
                    clk_count <= clk_count + 1;
                    if (clk_count >= 1000) begin // put some delay 
                        clk_count <= 0;
                        sender_state <= 3'b001; // start tx next byte 
                    end
                    else begin 
                        sender_state <= 3'b101;
                    end
                    end
                3'b110 : begin // state: last pixel transmitted
                    sender_state = 3'b110; // endless loop
                    end
                default : ;
            endcase
        end
    end

endmodule

