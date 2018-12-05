// CP0 REGISTER FILE

module CP0(
	// inputs
	input wire rst,
	input wire clk,
	input wire[4:0] raddr,		// Addr to read
	input wire[5:0] syscall,	// 外部硬件中断输入
	input wire we,				// write enable
	input wire[5:0] waddr,		// Addr to write
	input wire[31:0] wdata,		// Data to write

	// outputs
	output reg[31:0] data,		// Data Read
	// five registers
	output reg[31:0] count,		// clock counter 
	output reg[31:0] compare,	// has a set number to compare with clock counter 
	output reg[31:0] status,
	// status[28]: CP0 useable or not; 1 = cp0 can be used
	// status[15:8]: block syscall or not; 1 means handle syscall
	// status[1]: Exception level. 1 = shows if exception happens
	// status[0]: interrupt enable. 1 = enables syscall
	output reg[31:0] cause,		// cause
	// cause[31]: if exception happens at Branch DelaySlot
	// cause[15:8]: if interrupt happens
	// cause[6:2]: indicates the kind of exception
	//	000: Int Interruption
	//	8: Sys Syscall
	//	10: RI Undetermined Exception
	//	12: Overflow
	//	13: Trap: if something traps it selt
	output reg[31:0] epc,		// epc
	output reg timeset			// if a time-set syscall happens
);

// write CP0
always @(posedge clk) begin
	// reset
	if (rst == 1'b1) begin
		count <= 32'b0;
		compare <= 32'b0;
		status <= 32'b00010000000000000000000000000000;
		cause <= 32'b0;
		epc <= 32'b0;
		timeset <= 1'b0;
	end
	// functions
	else begin
		// count adds 1 every cycle
		// TODO: what if it overflows
		count <= count + 1;
		// get the syscall
		cause[7:2] <= syscall[5:0];
		// when compare != 0 && count == compare
		if(compare != 32'b0 && count == compare) begin
			// time-set int happens
			timeset <= 1'b1;
		end
		// if write enable
		if(we == 1'b1) begin
			case(waddr)
				// count
				5'b01001: begin
					count <= wdata;
				end
				// compare
				5'b01011: begin
					compare <= wdata;
					// when writes this, time interrupt don't happen
					timeset <= 1'b0;
				end
				// status:
				5'b01100: begin
					status <= wdata;
				end
				// cause:
				5'b01101: begin
					cause[9:8] <= data[9:8];
					cause[23:22] <= data[23:22];
				end
				// epc:
				5'b01110: begin
					epc <= wdata;
				end
			endcase
		end
	end
end

// read CP0
always @(*) begin
	if (rst == 1'b1) begin
		// reset
		data <= 32'b0;
	end
	else begin
		case(raddr)
			// count
			5'b01001: begin
				data <= count
			end
			// compare
			5'b01011: begin
				data <= compare;
			end
			// status:
			5'b01100: begin
				data <= status;
			end
			// cause:
			5'b01101: begin
				data <= cause;
			end
			// epc:
			5'b01110: begin
				data <= epc;
			end
		endcase
	end
end

endmodule