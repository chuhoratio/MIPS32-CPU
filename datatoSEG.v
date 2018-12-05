`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/30 16:38:16
// Design Name: 
// Module Name: datatoSEG
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


module datatoSEG(address,data,showaddress,ledbits);
input   wire[31:0]   data;
input   wire[19:0]   address;
input   wire         showaddress;
output  reg[15:0]   ledbits;
always@(data or address or showaddress) begin
    if(showaddress)begin
        ledbits<=address[15:0];
    end
    else begin
        ledbits<=data[15:0];
    end
end
endmodule
