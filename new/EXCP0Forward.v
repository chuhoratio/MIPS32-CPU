`timescale 1ns / 1ps

module EXCP0Forward (
	input wire[31:0] ERead,
	input wire[31:0] MWrite,
	input wire[31:0] WWrite,
	input wire[4:0] RAddr,
	input wire[4:0] MEMWAddr,
	input wire[4:0] WBWAddr,

	// Write Enables
    input wire MEMWE,
    input wire WBWE,

    // Used for pushing forward CP0 contents
    // ebase, epc, status, cause
    input wire[31:0] EbaseInput,
    input wire[31:0] EpcInput,
    input wire[31:0] StatusInput,
    input wire[31:0] CauseInput,
    output reg[31:0] EbaseOutput,
    output reg[31:0] EpcOutput,
    output reg[31:0] StatusOutput,
    output reg[31:0] CauseOutput,

	output reg[31:0] OutputData
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

always @ (*) begin
	if ( MEMWE == 1 ) begin
		case (MEMWAddr)
			// ebase
			5'b01111: begin
				EbaseOutput <= MWrite;
			end
			// status:
			5'b01100: begin
				StatusOutput <= MWrite;
			end
			// cause:
			5'b01101: begin
				CauseOutput <= MWrite;
			end
			// epc:
			5'b01110: begin
				EpcOutput <= MWrite;
			end
		endcase
	end
	else if ( WBWE == 1 ) begin
		case (WBWAddr)
			// ebase
			5'b01111: begin
				EbaseOutput <= WWrite;
			end
			// status:
			5'b01100: begin
				StatusOutput <= WWrite;
			end
			// cause:
			5'b01101: begin
				CauseOutput <= WWrite;
			end
			// epc:
			5'b01110: begin
				EpcOutput <= WWrite;
			end
		endcase
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
