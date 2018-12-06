`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/30 06:29:29
// Design Name: 
// Module Name: RegMEMWB
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


module RegMEMWB(
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

    input wire[31:0] MemReadDataInput,
    input wire[31:0] EXResultInput,
    input wire[5:0] RegDestInput,
    
    input wire RegWriteInput,
    input wire MemToRegInput,
    
    output wire[31:0] MemReadDataOutput,    
    output wire[31:0] EXResultOutput,
    output wire[5:0] RegDestOutput,
    
    output wire RegWriteOutput,
    output wire MemToRegOutput
    );

reg[31:0] MemReadData;
reg[31:0] EXResult;
reg[5:0] RegDest;

reg RegWrite;
reg MemToReg;

// CP0 write data
reg CP0WE;
reg[4:0] CP0WAddr;
reg[31:0] CP0WData;

assign MemReadDataOutput=MemReadData;
assign EXResultOutput=EXResult;
assign RegDestOutput=RegDest;

assign RegWriteOutput=RegWrite;
assign MemToRegOutput=MemToReg;

// CP0: WRITE
assign CP0WEOutput = CP0WE;
assign CP0WAddrOutput = CP0WAddr;
assign CP0WDataOutput = CP0WData;

always@(posedge clk or posedge rst) begin
    if (rst) begin

        MemReadData<=0;
        EXResult<=0;
        RegDest<=0;
        
        RegWrite<=0;
        MemToReg<=0;

        // CP0: WRITE
        CP0WE <= 0;
        CP0WAddr <= 0;
        CP0WData <= 0;
    end else begin
        if (clr) begin

            MemReadData<=0;
            EXResult<=0;
            RegDest<=0;
            
            RegWrite<=0;
            MemToReg<=0;

            // CP0: WRITE
            CP0WE <= 0;
            CP0WAddr <= 0;
            CP0WData <= 0;
        end else if (writeEN) begin

            MemReadData<=MemReadDataInput;
            EXResult<=EXResultInput;
            RegDest<=RegDestInput;
            
            RegWrite<=RegWriteInput;
            MemToReg<=MemToRegInput;

            // CP0: WRITE
            CP0WE <= CP0WEInput;
            CP0WAddr <= CP0WDataInput;
            CP0WData <= CP0WDataInput;
        end
    end
end

endmodule
