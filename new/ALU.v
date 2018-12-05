// 0000		输出0
// 0001		输出InputA
// 0010		输出InputB
// 0011		ADD
// 0100		AND
// 0101		OR
// 0110		XOR
// 0111		NOR
// 1000		SLL
// 1001		SRL
// 1010		SRA
// 1011		CLZ
// 1100		MOVZ(if SrcA is zero, output 1, else output 0)
// 1101		LUI(output=SrcB[15:0] || 16’b0)

module ALU(
	input wire[3:0] ALUOp,
	input wire[31:0] InputA,
	input wire[31:0] InputB,
	output wire[31:0] Output
	);

wire [31:0]ans0000;	// output 0
wire [31:0]ans0001;	// output InputA
wire [31:0]ans0010;	// output InputB
wire [31:0]ans0011;	// add
wire [31:0]ans0100;	// and
wire [31:0]ans0101; // or
wire [31:0]ans0110; // xor
wire [31:0]ans0111; // nor
wire [31:0]ans1000; // sll
wire [31:0]ans1001; // srl
wire [31:0]ans1010; // sra
wire [31:0]ans1011; // clz
wire [31:0]ans1100; // movz
wire [31:0]ans1101; // lui

wire [31:0]ans000;	// 0 or InputA
wire [31:0]ans001;	// InputB or add
wire [31:0]ans010;	// and or or
wire [31:0]ans011;	// xor or nor
wire [31:0]ans100;	// sll or srl
wire [31:0]ans101;	// sra or clz
wire [31:0]ans110;	// movz or lui

wire [31:0]ans00;
wire [31:0]ans01;
wire [31:0]ans10;
wire [31:0]ans11;

wire [31:0]ans0;
wire [31:0]ans1;

assign ans0000 = 0;
assign ans0001 = InputA;
assign ans0010 = InputB;
assign ans0011 = InputA + InputB;
assign ans0100 = InputA & InputB;
assign ans0101 = InputA | InputB;
assign ans0110 = InputA ^ InputB;
assign ans0111 = ~(InputA | InputB);
assign ans1000 = InputA << InputB[4:0];
assign ans1001 = InputA >> InputB[4:0];
assign ans1010 = ($signed(InputA)) >>> InputB[4:0];
assign ans1011 = InputA[31] ? 32'b0:(InputA[30] ? 32'b1:(InputA[29] ? 32'b10:(InputA[28] ? 32'b11:(InputA[27] ? 32'b100:(InputA[26] ? 32'b101:(InputA[25] ? 32'b110:(InputA[24] ? 32'b111:(InputA[23] ? 32'b1000:(InputA[22] ? 32'b1001:(InputA[21] ? 32'b1010:(InputA[20] ? 32'b1011:(InputA[19] ? 32'b1100:(InputA[18] ? 32'b1101:(InputA[17] ? 32'b1110:(InputA[16] ? 32'b1111:(InputA[15] ? 32'b10000:(InputA[14] ? 32'b10001:(InputA[13] ? 32'b10010:(InputA[12] ? 32'b10011:(InputA[11] ? 32'b10100:(InputA[10] ? 32'b10101:(InputA[9] ? 32'b10110:(InputA[8] ? 32'b10111:(InputA[7] ? 32'b11000:(InputA[6] ? 32'b11001:(InputA[5] ? 32'b11010:(InputA[4] ? 32'b11011:(InputA[3] ? 32'b11100:(InputA[2] ? 32'b11101:(InputA[1] ? 32'b11110:(InputA[0] ? 32'b11111:32'b100000)))))))))))))))))))))))))))))));
assign ans1100 = (InputA==32'b0) ? 32'b1:32'b0 ;
assign ans1101 = {InputB[15:0],16'b0};
// count leading zeros; move conditionally on zero, lui not added

// 1st level multi selector
assign ans000 = ALUOp[0] ? ans0001:ans0000;
assign ans001 = ALUOp[0] ? ans0011:ans0010;
assign ans010 = ALUOp[0] ? ans0101:ans0100;
assign ans011 = ALUOp[0] ? ans0111:ans0110;
assign ans100 = ALUOp[0] ? ans1001:ans1000;
assign ans101 = ALUOp[0] ? ans1011:ans1010;
assign ans110 = ALUOp[0] ? ans1101:ans1100;

// 2nd level
assign ans00 = ALUOp[1] ? ans001:ans000;
assign ans01 = ALUOp[1] ? ans011:ans010;
assign ans10 = ALUOp[1] ? ans101:ans100;
assign ans11 = ans110;

// 3rd level
assign ans0 = ALUOp[2] ? ans01:ans00;
assign ans1 = ALUOp[2] ? ans11:ans10;

// finally
assign Output = ALUOp[3] ? ans1:ans0;

endmodule