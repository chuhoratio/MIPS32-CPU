`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/30 17:12:56
// Design Name: 
// Module Name: SRAM
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


module SRAM(address,data,isread,clk,enable_low_work);
inout   wire[31:0]   data;
input   wire[19:0]   address;
input   wire         isread;
input  	wire   		 clk;
input  	wire   		 enable_low_work;
always@(posedge clk)begin
    if(!enable_low_work)begin
        if(isread)begin
            
        end
    end
end



endmodule
