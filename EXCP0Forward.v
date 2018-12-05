`timescale 1ns / 1ps

module EXCP0Forward (
	input wire[31:0] ERead,
	input wire[31:0] MWrite,
	input wire[31:0] WWrite,
	input wire[4:0] RAddr,
	input wire[4:0] MEMWAddr,
	input wire[4:0] WBWAddr,

	output wire[31:0] OutputData
);

always @(*) begin
	if (RAddr == MEMWAddr) begin
		OutputData <= MWrite;
	end
	else if (RAddr == WBWAddr) begin
		OutputData <= WWrite;
	end
	else begin
		OutputData <= ERead;
	end
end

endmodule

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
