`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jia Minglin
// 
// Create Date: 2018/11/30 21:05:20
// Design Name: 
// Module Name: RegisterFile
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

module RegisterFile(

    input wire clk,
    input wire [5:0]ReadRegA,
    input wire [5:0]ReadRegB,
    input wire [31:0]NPCInput,
    //input
    input wire [5:0]WriteReg,
    input wire [31:0]WriteData,
    input wire RegWrite,
    
    //output
    output reg [31:0]ReadDataA,
    output reg [31:0]ReadDataB
    
    );
reg [31:0] registers [0:31];
always @(*)begin
    if(ReadRegA[5]==0)
        ReadDataA<=registers[ReadRegA];
    else begin
        if(ReadRegA[4:0]==0)
            ReadDataA<=NPCInput;
        else begin
            ReadDataA<=0;
        end
    end

    if(ReadRegB[5]==0)
        ReadDataB<=registers[ReadRegB];
    else begin
        if(ReadRegB[4:0]==0)
            ReadDataB<=NPCInput;
        else begin
            ReadDataB<=0;
        end
    end
end

always@(negedge clk)begin
    if(RegWrite)
        if(WriteReg[5]==0)
            if(WriteReg[4:0]==0)
                ;
            else begin
                registers[WriteReg]<=WriteData;
            end
        else begin
        end
    else
        ;
end
endmodule
