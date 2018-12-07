`timescale 1ns / 1ps

module Ctrl(
	input wire rst,
	input wire[31:0] CurrentPC,

	// Stall Control
	input wire PCWriteEN,
    input wire PCClear,
    input wire IFIDWriteEN,
    input wire IFIDClear,
    input wire IDEXWriteEN,
    input wire IDEXClear,
    input wire EXMEMWriteEN,
    input wire EXMEMClear,
    input wire MEMWBWriteEN,
    input wire MEMWBClear,

	// Exc Types
	input wire ExcSyscall,
	input wire ExcEret,
	input wire ExcDelay,

	// CP0 Contents
	input wire[31:0] CP0EBASE,
	input wire[31:0] CP0STATUS,
	input wire[31:0] CP0CAUSE,
	input wire[31:0] CP0EPC,

	// Exception PC
	output reg[31:0] ExcPC,
	// generate new pc
	output reg[31:0] FinalPC,
	// output reg flush,	
	output reg PCFlush,
	output reg IFIDFlush,
	output reg IDEXFlush,
	output reg EXMEFlush,
	output reg MEWBFlush,
	// output reg we
	output reg PCWE,
	output reg IFIDWE,
	output reg IDEXWE,
	output reg EXMEWE,
	output reg MEWBWE,

	output reg CP0WE,
	output reg[2:0] ExcepType
);

wire[31:0] pc;
// in this module, we decide whether to change cp0:
// if an exception already happens, neglect everything
// else, pass the exception information to cp0

// delayslot or not
assign pc = ExcDelay ? CurrentPC - 4:CurrentPC;



// five registers
// ebase,

// status,
// status[12]: IM4 : 1 = not masking syscall
// status[1]: Exception level. 1 = exception happens
// status[0]: interrupt enable. 1 = enables syscall

// cause
// cause[31]: BD: DelaySlot
// cause[12]: IP4: if interrupt happens
// cause[6:2]: ExcCode: indicates the kind of exception
// 00000: Int Interruption
// 01000: Sys Syscall

// epc

always @ (*) begin
	if(rst == 1'b1) begin
		PCFlush <= 1;
		IFIDFlush <= 1;
		IDEXFlush <= 1;
		EXMEFlush <= 1;
		MEWBFlush <= 1;
		PCWE <= 1;
        IFIDWE <= 1;
        IDEXWE <= 1;
        EXMEWE <= 1;
        MEWBWE <= 1;
		ExcPC <= 32'b0;
	end
	else begin
        // stall control
        PCFlush = PCClear;
        IFIDFlush = IFIDClear;
        IDEXFlush = IDEXClear;
        EXMEFlush = EXMEMClear;
        MEWBFlush = MEMWBClear;
        PCWE = PCWriteEN;
        IFIDWE = IFIDWriteEN;
        IDEXWE = IDEXWriteEN;
        EXMEWE = EXMEMWriteEN;
        MEWBWE = MEMWBWriteEN;
        CP0WE = 0;
        // where inst is wrong
        ExcPC = pc;
        // discover an interrupt
        if (ExcSyscall == 1 || ExcEret == 1) begin
        	// handle it
        	if(CP0STATUS[1] == 0) begin
        		CP0WE = 1;
        		ExcepType = {ExcSyscall, ExcEret, ExcDelay};
        		PCFlush = 1;
		        IFIDFlush = 1;
		        IDEXFlush = 1;
		        EXMEFlush = 1;
		        MEWBFlush = 1;
		        if (ExcEret == 1) begin
		        	FinalPC = CP0EPC;
		        end
		        else begin
		        	FinalPC = CP0EBASE;
		        end
        	end
        end
	end
end

endmodule