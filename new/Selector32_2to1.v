`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/30 19:43:11
// Design Name: 
// Module Name: Selector32_2to1
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

module Selector32_2to1(
	input wire[31:0]InputA,
	input wire[31:0]InputB,
	input wire Control,
	output reg[31:0]Output
    );
always @(*) begin
	case (Control)
		0:Output<=InputA;
		1:Output<=InputB;
	endcase
end
endmodule
