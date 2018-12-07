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
	output reg MEWBWE
);

wire[31:0] pc;

// delayslot or not
assign pc = ExcDelay ? CurrentPC - 4:CurrentPC;

// stall control
assign PCFlush = PCClear;
assign IFIDFlush = IFIDClear;
assign IDEXFlush = IDEXClear;
assign EXMEFlush = EXMEMClear;
assign MEWBFlush = MEMWBClear;
assign PCWE = PCWriteEN;
assign IFIDWE = IFIDWriteEN;
assign IDEXWE = IDEXWriteEN;
assign EXMEWE = EXMEMWriteEN;
assign MEWBWE = MEMWBWriteEN;

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
		ExcPC <= 32'b0;
	end
	else begin
		CP0CAUSE[31] <= ExcDelay;
		// Interrupt 4
		if (CP0STATUS[12] == 1 && CP0CAUSE[12] == 1 && CP0STATUS[1:0] == 2'b01) begin
			// you can interrupt
		end
		// Syscall
		else if (ExcSyscall == 1) begin
			// you can syscall
		end
		// Eret
		else if (ExcEret == 1) begin
			// you can eret
		end
	end
end

endmodule