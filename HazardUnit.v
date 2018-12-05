`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jia Minglin
// 
// Create Date: 2018/12/01 21:25:32
// Design Name: 
// Module Name: HazardUnit
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

module HazardUnit(
	input wire IDEXMemRead,
	input wire [5:0]IDEXRegDest,
	input wire [5:0]IDRegSrcA,
	input wire [5:0]IDRegSrcB,
	output reg HazardHappen
);
always @(*) begin
	HazardHappen<=IDEXMemRead && (IDEXRegDest==IDRegSrcA || IDEXRegDest==IDRegSrcB);
end
endmodule
