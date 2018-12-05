`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jia Minglin
// 
// Create Date: 2018/12/01 17:28:59
// Design Name: 
// Module Name: Extender
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

module Extender(
	input wire[31:0]PC,
	input wire[31:0]Instruction,
	output reg[31:0]ExtendImm//16bit: signExtend;others:sign extend
    );

function [31:0] ZeroExtend_5to32; 
   input wire[4:0]InImm;
   begin
		ZeroExtend_5to32={27'b000000000000000000000000000,InImm};
	end
endfunction

function [31:0] Extend_26to32; 
   input wire[25:0]InImm;
   input wire[31:0]PC;
   begin
		Extend_26to32={PC[31:28],InImm,2'b00};
	end
endfunction

function [31:0] ZeroExtend_16to32; 
   input wire[15:0]InImm;
	begin
		ZeroExtend_16to32={16'b0000000000000000,InImm};
	end
endfunction

function [31:0] SignExtend_16to32; 
   input wire[15:0]InImm;
	begin
		if (InImm[15]==0) begin
			SignExtend_16to32={16'b0000000000000000,InImm};
		end
		else begin
			SignExtend_16to32={16'b1111111111111111,InImm};
		end
	end
endfunction

function [31:0] ShiftLeft2_SignExtend_16to32; 
   input wire[15:0]InImm;
	begin
		if (InImm[15]==0) begin
			ShiftLeft2_SignExtend_16to32={14'b00000000000000,InImm,2'b00};
		end
		else begin
			ShiftLeft2_SignExtend_16to32={14'b11111111111111,InImm,2'b00};
		end
	end
endfunction

always @(*) begin
	case (Instruction[31:26])
		6'b000000:begin
			case (Instruction[5:0])
				6'b000000,6'b000010,6'b000011:ExtendImm<=ZeroExtend_5to32(Instruction[10:6]);//SLL,SRL,SRA
				default:ExtendImm<=0;
			endcase
		end
		6'b000100,6'b000111,6'b000101:
		//BEQ,BGTZ,BNE
		begin
			ExtendImm<=ShiftLeft2_SignExtend_16to32(Instruction[15:0]);
		end
		6'b001001,6'b100000,6'b100011,6'b101000,6'b101011,6'b100100:
		//ADDIU,LB,LW,SB,SW,LBU
		begin
			ExtendImm<=SignExtend_16to32(Instruction[15:0]);
		end
		6'b001100,6'b001111,6'b001101,6'b001110:
		//ANDI,LUI,ORI,XORI
		begin
			ExtendImm<=ZeroExtend_16to32(Instruction[15:0]);
		end
		6'b000010,6'b000011 ://J,JAL
		begin
			ExtendImm<=Extend_26to32(Instruction[25:0],PC[31:0]);
		end
		default:ExtendImm<=0;
	endcase;
end
endmodule
