`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jia Minglin
// 
// Create Date: 2018/12/01 21:58:13
// Design Name: 
// Module Name: ForwardUnit
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

module ForwardUnit(
    input wire EXMEMRegWrite,
    input wire MEMWBRegWrite,
    input wire [5:0]EXMEMRegDest,
    input wire [5:0]MEMWBRegDest,
    input wire [5:0]IDEXRegSrcA,
    input wire [5:0]IDEXRegSrcB,
    
    output reg [1:0]ForwardA,//00:data from register 01:last EXResult 10:data to write in WB 11:0
    output reg [1:0]ForwardB
);

always @(*) begin
	ForwardA=0;
	ForwardB=0;
	if(EXMEMRegWrite)begin
		if(EXMEMRegDest==IDEXRegSrcA)
			ForwardA=1;
		if(EXMEMRegDest==IDEXRegSrcB)
			ForwardB=1;
	end
	if(MEMWBRegWrite)begin
		if(MEMWBRegDest==IDEXRegSrcA && ForwardA==0)
			ForwardA=2;
		if(MEMWBRegDest==IDEXRegSrcB && ForwardB==0)
			ForwardB=2;
	end
end
endmodule
