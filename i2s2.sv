`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 05:10:53 PM
// Design Name: 
// Module Name: i2s2
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


module i2s2(
    input logic         reset,
    input logic         clk,
    input logic         i2s_sdout,
    input logic         sready,
    
    output logic        i2s_mclk,
    output logic        i2s_sclk,
    output logic        i2s_lrck,
    output logic [23:0] mdata_out,      //comment if ILA is being used
    output logic        msample_valid,  //comment if ILA is being used
    output logic        msample_channel //comment if ILA is being used
    );
    
    
//    logic [23:0] mdata_out;           //uncomment if ILA is being used
//    logic        msample_valid;
//    logic        msample_channel;
    
    logic clk_locked;                  
    
    logic [1:0] sclk_count;
    logic [7:0] lrck_count;
    
    
    
    logic [1:0] reset_sync;
    logic       i2s_reset;
    always_ff @(posedge i2s_mclk or posedge reset) begin
        if(reset) begin
            reset_sync <= 2'b11;
        end
        else begin
            reset_sync <= {reset_sync[0], 1'b0};
        end
    end
    assign i2s_reset = reset_sync[1];
    
    
    logic [1:0] locked_sync;
    logic       mmcm_lock;
    always_ff @ (posedge i2s_mclk) begin
        if(i2s_reset) begin
            locked_sync <= 2'b00;
        end
        else begin
            locked_sync <= {locked_sync[0], clk_locked};
        end
    end
    assign mmcm_lock = locked_sync[1];
    
    
    
    
    always_ff @ (posedge i2s_mclk) begin
        if(i2s_reset || !mmcm_lock) begin
            sclk_count <= 0;
            lrck_count <= 0;
            i2s_sclk <= 0;
            i2s_lrck <= 0;
        end
        else begin
            if(sclk_count == 2'b11) begin
                sclk_count <= 0;
                i2s_sclk <= ~i2s_sclk;
            end
            else begin
                sclk_count <= sclk_count + 1;
            end
        
            if(lrck_count == 8'b11111111) begin
                lrck_count <= 0;
                i2s_lrck <= ~i2s_lrck;
            end
            else begin
                lrck_count <= lrck_count + 1;
            end
        end
    end
    
    logic       sclk_falling;
    assign sclk_falling = (sclk_count == 2'b11) && (i2s_sclk == 1);
    
    logic       lrck_change;
    assign lrck_change = (lrck_count == 8'b11111111);
    
    
    typedef enum logic [3:0] {
        HALT,
        WAIT_ONE,
        READ
    } states;
    
    states next_state = HALT;
    states current_state = HALT;
    
    always_comb begin
        next_state = current_state;
        case(current_state)
            HALT: begin
                if(!i2s_reset && mmcm_lock) begin
                    next_state = WAIT_ONE;
                end
                else begin
                    next_state = HALT;
                end
            end
            WAIT_ONE: begin
                if(i2s_reset || !mmcm_lock) begin
                    next_state = HALT;
                end
                else if (sclk_falling && lrck_change) begin
                    next_state = WAIT_ONE;
                end
                else if(sclk_falling) begin
                    next_state = READ;
                end
                else begin
                    next_state = WAIT_ONE;
                end
            end
            READ: begin
                if(i2s_reset || !mmcm_lock) begin
                    next_state = HALT;
                end
                else if (lrck_change) begin
                    next_state = WAIT_ONE;
                end
            end
        endcase
    end
    logic [23:0]    shift_r;
    logic [4:0]     shift_count;
    always_ff @ (posedge i2s_mclk) begin
        current_state <= next_state;
        case (current_state)
            HALT: begin
                shift_r <= shift_r;
                shift_count <= 0;
                msample_valid <= 0;
            end
            WAIT_ONE: begin
                shift_r <= shift_r;
                shift_count <= 0;
                if(sclk_falling && !lrck_change) begin
                    shift_r <= {shift_r[22:0], i2s_sdout};
                    shift_count <= shift_count + 1;
                end
                
                if(sready && msample_valid) begin
                    msample_valid <= 0;
                end
            end
            READ: begin
                if(shift_count > 23) begin
                    shift_r <= shift_r;
                end
                else if (sclk_falling) begin
                    if (shift_count == 23) begin
                        mdata_out <= {shift_r[22:0], i2s_sdout};
                        msample_channel <= i2s_lrck;
                        msample_valid <= 1;
                        shift_r <= {shift_r[22:0], i2s_sdout};
                        shift_count <= shift_count + 1;
                    end
                    else begin
                    shift_r <= {shift_r[22:0], i2s_sdout};
                    shift_count <= shift_count + 1;
                    end
                end
                else begin
                    shift_r <= shift_r;
                end
                
                
                if(sready && msample_valid && shift_count != 23) begin
                    msample_valid <= 0;
                end
            end
        endcase
    end
    
    i2s_clk_wiz i2s_clk (
        .clk_out1(i2s_mclk),
        .reset(reset),
        .locked(clk_locked),
        .clk_in1(clk)
    );
    
//    ila_0 ILA_inst (
//        .clk(i2s_mclk),
//        .probe0({i2s_sclk, i2s_lrck, i2s_sdout}),
//        .probe1(mdata_out),
//        .probe2({clk_locked, msample_channel, msample_valid}),
//        .probe3(shift_count),
//        .probe4(current_state)
//    );
endmodule
