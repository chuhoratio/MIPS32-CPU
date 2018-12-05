`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/30 06:29:29
// Design Name: 
// Module Name: RegEXMEM
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


module RegEXMEM(
    input wire clk,
    input wire rst,
    input wire clr,
    input wire writeEN,
    
    // CP0 write data
    input wire CP0WEInput,
    input wire[4:0] CP0WAddrInput,
    input wire[31:0] CP0WDataInput,
    output wire CP0WEOutput,
    output wire[4:0] CP0WAddrOutput,
    output wire[31:0] CP0WDataOutput,

    // Exc Type
    input wire ExcSyscallInput,
    output wire ExcSyscallOutput,

    input wire[31:0] EXResultInput,
    input wire[5:0] RegDestInput,
    input wire[31:0] RegDataBInput,
    
    input wire MemReadInput,
    input wire MemWriteInput,
    input wire[1:0] BranchTypeInput,
    input wire[1:0] JumpTypeInput,
    input wire[1:0] MemReadSelectInput,
    input wire MemWriteSelectInput,
    
    input wire RegWriteInput,
    input wire MemToRegInput,
    
    output wire[31:0] EXResultOutput,
    output wire[5:0] RegDestOutput,
    output wire[31:0] RegDataBOutput,
    
    output wire MemReadOutput,
    output wire MemWriteOutput,
    output wire[1:0] BranchTypeOutput,
    output wire[1:0] JumpTypeOutput,
    output wire[1:0] MemReadSelectOutput,
    output wire MemWriteSelectOutput,
    
    output wire RegWriteOutput,
    output wire MemToRegOutput
    );

reg[31:0] EXResult;
reg[5:0] RegDest;
reg[31:0] RegDataB;

reg MemRead;
reg MemWrite;
reg[1:0] BranchType;
reg[1:0] JumpType;
reg[1:0] MemReadSelect;
reg MemWriteSelect;

reg RegWrite;
reg MemToReg;

assign EXResultOutput=EXResult;
assign RegDestOutput=RegDest;
assign RegDataBOutput=RegDataB;

assign MemReadOutput=MemRead;
assign MemWriteOutput=MemWrite;
assign BranchTypeOutput=BranchType;
assign JumpTypeOutput=JumpType;
assign MemReadSelectOutput=MemReadSelect;
assign MemWriteSelectOutput=MemWriteSelect;

assign RegWriteOutput=RegWrite;
assign MemToRegOutput=MemToReg;

// CP0: WRITE
assign CP0WEOutput = CP0WEInput;
assign CP0WAddrOutput = CP0WAddrInput;
assign CP0WDataOutput = CP0WDataInput;

// Exc Type
assign ExcSyscallOutput = ExcSyscallInput;

always@(posedge clk or posedge rst) begin
    if (rst) begin

        EXResult<=0;
        RegDest<=0;
        RegDataB<=0;
        
        MemRead<=0;
        MemWrite<=0;
        BranchType<=0;
        JumpType<=0;
        MemReadSelect<=0;
        MemWriteSelect<=0;
        
        RegWrite<=0;
        MemToReg<=0;
    end else begin
        if (clr) begin

            EXResult<=0;
            RegDest<=0;
            RegDataB<=0;
            
            MemRead<=0;
            MemWrite<=0;
            BranchType<=0;
            JumpType<=0;
            MemReadSelect<=0;
            MemWriteSelect<=0;
            
            RegWrite<=0;
            MemToReg<=0;
        end else if (writeEN) begin

            EXResult<=EXResultInput;
            RegDest<=RegDestInput;
            RegDataB<=RegDataBInput;
            
            MemRead<=MemReadInput;
            MemWrite<=MemWriteInput;
            BranchType<=BranchTypeInput;
            JumpType<=JumpTypeInput;
            MemReadSelect<=MemReadSelectInput;
            MemWriteSelect<=MemWriteSelectInput;
            
            RegWrite<=RegWriteInput;
            MemToReg<=MemToRegInput;
        end
    end
end

endmodule
