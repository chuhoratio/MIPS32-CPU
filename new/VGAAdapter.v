`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/05 21:50:14
// Design Name: 
// Module Name: VGAAdapter
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


module VGAAdapter(
    input wire clk,
    input wire rst,
    input wire[15:0] addr,
    input wire[7:0] in_char,
    input wire[7:0] row,
    input wire[6:0] col,
    output wire[3:0] out_char
    );

parameter n=400;
parameter c=20;

reg [7:0] RegChar [0:n-1];

integer i;
always@(posedge clk or posedge rst) begin
    if (rst) begin
        for (i=0; i<n; i=i+1) begin
            RegChar[i] <= 0;
        end
    end else begin
        if (addr < n) begin
            RegChar[addr] <= in_char;
        end
    end
end

assign out_char=((row < c) & (col < c)) ? RegChar[row * c + col] : 0;

endmodule
