`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/01 17:25:00
// Design Name: 
// Module Name: Selector32_4to1
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

module Selector32_4to1(
	input wire[31:0]InputA,
	input wire[31:0]InputB,
	input wire[31:0]InputC,
	input wire[31:0]InputD,
	input wire[1:0]Control,
	output reg[31:0]Output
    );
always @(*) begin
	case (Control)
		0:Output<=InputA;
		1:Output<=InputB;
		2:Output<=InputC;
		3:Output<=InputD;
	endcase
end
endmodule

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
