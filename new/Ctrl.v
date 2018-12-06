`timescale 1ns / 1ps

module Ctrl(
	input wire rst,
	input wire[31:0] CurrentPC,

	// Exc Types
	input wire ExcSyscall,
	input wire ExcEret,
	input wire ExcDelay,

	// CP0 Contents
	input wire[31:0] CP0EBASE,
	input wire[31:0] CP0STATUS,
	input wire[31:0] CP0CAUSE,
	input wire[31:0] CP0EPC,

	input wire stallreq_from_id,
	input wire stallreq_from_ex,

	// Exception PC
	output reg[31:0] ExcPC,
	// output reg flush,	
	output reg PCFlush,
	output reg IFIDFlush,
	output reg IDEXFlush,
	output reg EXMEFlush,
	output reg MEWBFlush
);

wire[31:0] pc;

// data preparation
// delayslot or not
assign pc = ExcDelay ? CurrentPC - 4:CurrentPC;

// five registers
// ebase,

// status,
// status[12]: IM4 - 1 for not masking syscall
// status[1]: Exception level. 1 = shows if exception happens
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