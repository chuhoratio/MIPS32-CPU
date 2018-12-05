`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Jia Minglin
// 
// Create Date: 2018/11/30 04:01:06
// Design Name: 
// Module Name: Controller
// Project Name: MIPS32 Computer
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


module Controller(
	input wire[31:0] Instruction,
	
	output reg[1:0] ExResultSelect,
	output reg RegWrite,
	output reg MemRead,
	output reg MemWrite,
	output reg[1:0] BranchType,
	output reg[1:0] JumpType,
	output reg[5:0] RegSrcA,
	output reg[5:0] RegSrcB,
	output reg[5:0] RegDest,
	output reg ALUSrc,
	output reg MemToReg,
	output reg[1:0] MemReadSelect,
	output reg MemWriteSelect,
	output reg IsMOVZ,
	output reg[3:0] ALUOp,

	// CP0
	output reg CP0WE,
	output reg[4:0] CP0WAddr,
	output reg CP0RE,
	output reg[4:0] CP0RAddr,

	// Exception
	output reg ExcSyscall
	);
	
always@(*)begin
	case (Instruction[31:26])
		6'b010000:
		begin
			case (Instruction[25:21])
				5'b0://MFC0
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b01,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[15:11], 1'b0,Instruction[15:11], 1'b0,Instruction[20:16],1'b0,1'b0,2'b0,1'b0,1'b0,4'b0};
				end
				5'b00100://MTC0
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b0,1'b0,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[20:16], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'b0};
				end
			endcase
			case (Instruction[25:0])
				26'b10000000000000000000011000://ERET
				begin
					;
				end
		end
		6'b0:begin
			case (Instruction[5:0])
				6'b001100://Syscall
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b0,1'b0,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[20:16], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'b0};
				end
				6'b100001://ADDU
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b0,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'h3};
				end
				6'b100100://AND
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'h4};
				end
				6'b001000://JR
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b00,1'b0,1'b0,1'b0,2'b0,2'b10, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,5'b0,1'b0,1'b0,2'b0,1'b0,1'b0,4'h0};
				end
				6'b100101://OR
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'h5};
				end
				6'b000000://SLL
				begin
					if(Instruction!=0)
                        begin
                            {ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
                            {2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[20:16], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b1,1'b0,2'b0,1'b0,1'b0,4'h8};
                        end
                    else
                        begin
                            {ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
                            {2'b00,1'b0,1'b0,1'b0,2'b0,2'b0, 1'b0,5'b0, 1'b0,5'b0, 1'b0,5'b0,1'b0,1'b0,2'b0,1'b0,1'b0,4'h0};
                        end
				end
				6'b000010://SRL
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[20:16], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b1,1'b0,2'b0,1'b0,1'b0,4'h9};
				end
				6'b100110://XOR
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'h6};
				end
				6'b000011://SRA
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[20:16], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b1,1'b0,2'b0,1'b0,1'b0,4'ha};
				end
				6'b100111://NOR
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'h7};
				end
				6'b001010://MOVZ
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
					{2'b10,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[20:16], 1'b0,Instruction[25:21], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b1,4'hc};
				end
			endcase
		end
		6'b001001 ://ADDIU
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,Instruction[20:16],1'b1,1'b0,2'b0,1'b0,1'b0,4'h3};
		end
		6'b001100 ://ANDI 
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,Instruction[20:16],1'b1,1'b0,2'b0,1'b0,1'b0,4'h4};
		end
		6'b000100 ://BEQ 
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b0,1'b0,1'b0,2'b1,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,5'b0,1'b1,1'b0,2'b0,1'b0,1'b0,4'h0};
		end
		6'b000111 ://BGTZ 
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b0,1'b0,1'b0,2'b11,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,5'b0,1'b1,1'b0,2'b0,1'b0,1'b0,4'h0};
		end
		6'b000101 ://BNE 
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b0,1'b0,1'b0,2'b10,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,5'b0,1'b1,1'b0,2'b0,1'b0,1'b0,4'h0};
		end
		6'b000010 ://J 
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b0,1'b0,1'b0,2'b0,2'b1, 1'b0,5'b0, 1'b0,5'b0, 1'b0,5'b0,1'b0,1'b0,2'b0,1'b0,1'b0,4'h0};
		end
		6'b000011 ://JAL
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b11,1'b1,1'b0,1'b0,2'b0,2'b1, 1'b0,5'b0, 1'b0,5'b0, 1'b0,5'b11111,1'b0,1'b0,2'b0,1'b0,1'b0,4'h0};
		end
		6'b100000 ://LB 
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b1,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,Instruction[20:16],1'b1,1'b1,2'b1,1'b0,1'b0,4'h3};
		end
		6'b001111 ://LUI
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,5'b0, 1'b0,5'b0, 1'b0,Instruction[20:16],1'b1,1'b0,2'b0,1'b0,1'b0,4'hd};
		end
		6'b100011 ://LW
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b1,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,Instruction[20:16],1'b1,1'b1,2'b0,1'b0,1'b0,4'h3};
		end
		6'b001101 ://ORI
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,Instruction[20:16],1'b1,1'b0,2'b0,1'b0,1'b0,4'h5};
		end
		6'b101000 ://SB
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b0,1'b0,1'b1,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,5'b0,1'b1,1'b0,2'b0,1'b1,1'b0,4'h3};
		end
		6'b101011 ://SW
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b0,1'b0,1'b1,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,5'b0,1'b1,1'b0,2'b0,1'b0,1'b0,4'h3};
		end
		6'b001110 ://XORI 
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,Instruction[20:16],1'b1,1'b0,2'b0,1'b0,1'b0,4'h6};
		end
		6'b100100 ://LBU
		begin
			{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			{2'b00,1'b1,1'b1,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[25:21], 1'b0,Instruction[20:16],1'b1,1'b1,2'b10,1'b0,1'b0,4'h3};
		end
		6'b011100:begin
			case (Instruction[5:0])
				6'b100000://CLZ
				begin
					{ExResultSelect,RegWrite,MemRead,MemWrite,BranchType[1:0],JumpType[1:0],RegSrcA[5:0],RegSrcB[5:0],RegDest[5:0],ALUSrc,MemToReg,MemReadSelect,MemWriteSelect,IsMOVZ,ALUOp[3:0]}=
			        {2'b00,1'b1,1'b0,1'b0,2'b0,2'b0, 1'b0,Instruction[25:21], 1'b0,Instruction[20:16], 1'b0,Instruction[15:11],1'b0,1'b0,2'b0,1'b0,1'b0,4'hb};
				end
			endcase
		end
		default:;
	endcase;
end


// CPO RW RELATED
always@(*)begin
	case (Instruction[31:26])
		6'b010000:
		begin
			case (Instruction[25:21])
				5'b0://MFC0
				begin
					CP0RE = 1;
					CP0RAddr = Instruction[15:11];
					CP0WE = 0;
					CP0WAddr = 0;
				end
				5'b00100://MTC0
				begin
					CP0RE = 0;
					CP0RAddr = 0;
					CP0WE = 1;
					CP0WAddr = Instruction[15:11];
				end
				default:
				begin
					CP0RE = 0;
					CP0RAddr = 0;
					CP0WE = 0;
					CP0WAddr = 0;
				end
			endcase
		end
		default:
		begin
			CP0RE = 0;
			CP0RAddr = 0;
			CP0WE = 0;
			CP0WAddr = 0;
		end
	endcase
end

// Exception And Interruption
always @(*) begin
	// syscall happens
	if (Instruction[31:26] == 6'b0 && Instruction[5:0] == 6'b001100) begin
		ExcSyscall = 1;
	end
	else begin
		ExcSyscall = 0;
	end
end
endmodule