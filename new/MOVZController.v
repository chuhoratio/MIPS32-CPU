`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jia Minglin
// 
// Create Date: 2018/12/01 14:53:07
// Design Name: 
// Module Name: MOVZController
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

module MOVZController(
    input wire[31:0] EXResult,
    input wire IsMOVZ,
    input wire OldRegWrite,
    output reg NewRegWrite
    );

always @(*) begin
    if(IsMOVZ)begin
        if (EXResult==0) begin
            NewRegWrite=0;
        end
        else begin
            NewRegWrite=OldRegWrite;
        end
    end
    else begin
        NewRegWrite=OldRegWrite;
    end
end

endmodule
