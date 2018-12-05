`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jia Minglin
// 
// Create Date: 2018/12/01 15:30:33
// Design Name: 
// Module Name: BranchSelector
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

module BranchSelector(
	input wire[1:0] BranchType,
	input wire[1:0] JumpType,
	input wire[31:0] EXRegA,
	input wire[31:0] EXRegB,

	output reg [1:0]BranchSelect,//00:PC+4 01:PC+4+offset 10:PC=RegA(JR) 11:PC=imm(J)
	output reg BranchHappen
    );

reg ShouldBranch;
reg ShouldJump;
always @(*) begin
	case (BranchType)
		0:ShouldBranch=0;
		1:ShouldBranch=EXRegA==EXRegB?1:0;
		2:ShouldBranch=EXRegA!=EXRegB?1:0;
		3:ShouldBranch=((EXRegA[31] == 0) && (EXRegA != 0)) ?1:0;
	endcase
end

always @(*) begin
	if (JumpType==0)
		ShouldJump=0;
	else 
		ShouldJump=1;
end

always @(*) begin
	if(ShouldJump || ShouldBranch)
		BranchHappen=1;
	else
		BranchHappen=0;
end

always @(*) begin//00:PC+4 01:PC+4+offset 10:PC=to RegA(JR) 11:(J)to imm
	if (!BranchHappen) begin
		BranchSelect=0;
	end
	else begin
		if(BranchType!=0)
			BranchSelect=1;
		else begin
			if (JumpType==1) begin
				BranchSelect=3;
			end
			else begin
				BranchSelect=2;
			end
		end
	end
end

endmodule
