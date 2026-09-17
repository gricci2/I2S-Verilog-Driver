`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 06:28:49 PM
// Design Name: 
// Module Name: i2s2_tb
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


module i2s2_tb();

logic       reset;
logic       clk;
logic       sclk;
logic       lrck;
logic       i2s_data;
logic       sready;

logic [23:0]mdata_out;
logic       mvalid;
logic       mchannel;

localparam DURATION = 100000;

always #5 begin
    clk = ~clk;
end

initial begin
    sready = 1;
    i2s_data = 0;
    reset = 0;
    clk = 0;
    sclk = 0;
    lrck = 0;
    #100
    reset = 1;
    #10
    reset = 0;
end

always #10 begin
    i2s_data = ~i2s_data;
end

initial begin
    #DURATION
    $finish;
end

i2s2 dut (
    .reset(reset),
    .clk(clk),
    .i2s_sdout(i2s_data),
    .sready(sready),
    .i2s_sclk(sclk),
    .i2s_lrck(lrck),
    .mdata_out(mdata_out),
    .msample_valid(mvalid),
    .msample_channel(mchannel)
);

endmodule
