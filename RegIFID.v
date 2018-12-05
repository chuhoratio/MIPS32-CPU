`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/30 06:29:29
// Design Name: 
// Module Name: RegIFID
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


module RegIFID(
    input wire clk,
    input wire rst,
    input wire clr,
    input wire writeEN,
    
    input wire[31:0] InstructionInput,
    input wire[31:0] NPCInput,
    
    output wire[31:0] InstructionOutput,
    output wire[31:0] NPCOutput
    );
    
reg[31:0] NPC;
reg[31:0] Instruction;

assign NPCOutput=NPC;
assign InstructionOutput=Instruction;

always@(posedge clk or posedge rst) begin
    if (rst) begin
        NPC <= 0;
        Instruction <= 0;
    end else begin
        if (clr) begin
            NPC <= 0;
            Instruction <= 0;
        end else if (writeEN) begin
            NPC <= NPCInput;
            Instruction <= InstructionInput;
        end
    end
end
    
endmodule
