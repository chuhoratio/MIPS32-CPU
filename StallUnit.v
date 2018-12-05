`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/01 22:51:32
// Design Name: 
// Module Name: StallUnit
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


module StallUnit(
	input wire BranchHappen,
    input wire HazardHappen,
    output reg PCWriteEN,
    output reg PCClear,
    output reg IFIDWriteEN,
    output reg IFIDClear,
    output reg IDEXWriteEN,
    output reg IDEXClear,
    output reg EXMEMWriteEN,
    output reg EXMEMClear,
    output reg MEMWBWriteEN,
    output reg MEMWBClear,
    output reg BothBranchAndHazard
    );
always @(*) begin
	PCWriteEN=1;
	IFIDWriteEN=1;
	IDEXWriteEN=1;
	EXMEMWriteEN=1;
	MEMWBWriteEN=1;
	PCClear=0;
	IFIDClear=0;
	IDEXClear=0;
	EXMEMClear=0;
	MEMWBClear=0;
	BothBranchAndHazard=0;
	if(BranchHappen)begin
		if(HazardHappen)
			BothBranchAndHazard=1;
		else begin
			IFIDClear=1;
		end
	end
	else if(HazardHappen)begin
		IFIDWriteEN=0;
		IDEXClear=1;
		PCWriteEN=0;
	end
end
endmodule
