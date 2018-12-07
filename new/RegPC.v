`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/30 06:29:29
// Design Name: 
// Module Name: RegPC
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


module RegPC(
    input wire clk,
    input wire rst,
    input wire clr,
    input wire writeEN,

    input wire PCControl,
    input wire[31:0] ExceptionPC,
    input wire[31:0] PCInput,
    output wire[31:0] PCOutput
    );

reg[31:0] PC;

assign PCOutput=PC;

always@(posedge clk or posedge rst) begin    
    if (rst) begin
        PC <= 0;
    end else begin
        if (clr) begin
            if(PCControl) begin
                PC <= ExceptionPC;
            end
            else begin
                PC <= 0;
            end
        end else if (writeEN) begin
            PC <= PCInput;
        end
    end
end

endmodule
