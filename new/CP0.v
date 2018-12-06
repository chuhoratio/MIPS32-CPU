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
	output reg[31:0] ebase,
	output reg[31:0] status,
	// status[12]: IM4 - 1 for not masking syscall
    // status[1]: Exception level. 1 = shows if exception happens
    // status[0]: interrupt enable. 1 = enables syscall
	output reg[31:0] cause,		// cause
	// cause[31]: BD: DelaySlot
    // cause[12]: IP4: if interrupt happens
    // cause[6:2]: ExcCode: indicates the kind of exception
    // 00000: Int Interruption
    // 01000: Sys Syscall
	output reg[31:0] epc,		// epc
);

// write CP0
always @(posedge clk) begin
	// reset
	if (rst == 1'b1) begin
		ebase <= 32'b0;
		status <= 32'b00010000000000000000000000000000;
		cause <= 32'b0;
		epc <= 32'b0;
	end
	// functions
	else begin
		// get the syscall
		cause[7:2] <= syscall[5:0];
		// if write enable
		if(we == 1'b1) begin
			case(waddr)
				// count
				5'b01001: begin
					ebase <= wdata;
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
				data <= ebase;
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