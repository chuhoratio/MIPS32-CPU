`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/30 06:16:58
// Design Name: 
// Module Name: CPU
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


module CPU(
    input wire clk,
    input wire rst,
    output wire[31:0] InstAddress,
    input wire[31:0] InstInput,
    output wire[31:0] MemAddress,
    input wire[31:0] MemReadData,
    output wire[31:0] MemWriteData,
    output wire MemReadEN,
    output wire MemWriteEN,
    output wire[1:0] MemReadSelect,
    output wire MemWriteSelect,
    
    input wire[31:0] SW,
    output wire[15:0] LED
    );

//Before IF
wire[31:0] PC;

//IF-ID
wire[31:0] IFIDNPC;
wire[31:0] IFIDInstruction;

//ID-EX
wire[31:0] IDEXNPC;

wire[5:0] IDEXRegSrcA;
wire[5:0] IDEXRegSrcB;
wire[5:0] IDEXRegDest;

wire[31:0] IDEXRegDataA;
wire[31:0] IDEXRegDataB;

wire[31:0] IDEXExtendImm;

wire[3:0] IDEXALUOp;
wire IDEXALUSrc;
wire[1:0] IDEXEXResultSelect;

wire IDEXMemRead;
wire IDEXMemWrite;
wire[1:0] IDEXBranchType;
wire[1:0] IDEXJumpType;
wire[1:0] IDEXMemReadSelect;
wire IDEXMemWriteSelect;

wire IDEXRegWrite;
wire IDEXMemToReg;

wire IDEXIsMOVZ;

//EX-MEM
wire[31:0] EXMEMEXResult;
wire[5:0] EXMEMRegDest;
wire[31:0] EXMEMRegDataB;

wire EXMEMMemRead;
wire EXMEMMemWrite;
wire[1:0] EXMEMBranchType;
wire[1:0] EXMEMJumpType;
wire[1:0] EXMEMMemReadSelect;
wire EXMEMMemWriteSelect;

wire EXMEMRegWrite;
wire EXMEMMemToReg;

//MEM-WB
wire[31:0] MEMWBMemReadData;
wire[31:0] MEMWBEXResult;
wire[5:0] MEMWBRegDest;

wire MEMWBRegWrite;
wire MEMWBMemToReg;

wire[31:0] NewPC;

wire PCclr;
wire PCwriteEN;
//assign PCclr=0;
//assign PCwriteEN=1;
RegPC RegPC_c(
    .clk(clk),
    .rst(rst),
    .clr(PCclr),
    .writeEN(PCwriteEN),
    
    .PCInput(NewPC),
    
    .PCOutput(PC)
);

assign InstAddress=PC;

//Adder32
wire[31:0] IFNPC;

Adder32 PCAdder(
    .InputA(PC),
    .InputB(4),
    .Output(IFNPC)
);

//assign NewPC=IFNPC;

wire IFIDclr;
wire IFIDwriteEN;
//assign IFIDclr=0;
//assign IFIDwriteEN=1;

RegIFID RegIFID_c(
    .clk(clk),
    .rst(rst),
    .clr(IFIDclr),
    .writeEN(IFIDwriteEN),
    
    .NPCInput(IFNPC),
    .InstructionInput(InstInput),
    
    .NPCOutput(IFIDNPC),
    .InstructionOutput(IFIDInstruction)
);

//TODO:Extender
wire[31:0] IDExtendImm;

Extender Extender_c(
    .PC(IFNPC-4),
    .Instruction(IFIDInstruction),
    .ExtendImm(IDExtendImm)
);


//Controller
wire[1:0] IDEXResultSelect;
wire IDRegWrite;
wire IDMemRead;
wire IDMemWrite;
wire[1:0] IDBranchType;
wire[1:0] IDJumpType;
wire[5:0] IDRegSrcA;
wire[5:0] IDRegSrcB;
wire[5:0] IDRegDest;
wire IDALUSrc;
wire IDMemToReg;
wire[1:0] IDMemReadSelect;
wire IDMemWriteSelect;
wire IDIsMOVZ;
wire[3:0] IDALUOp;

wire CP0WE;
wire[4:0] CP0WAddr;
wire CP0RE;
wire[4:0] CP0RAddr;
// Exc Type
wire ExcSyscall;
wire ExcEret;

Controller Controller_c(
    .Instruction(IFIDInstruction),
    .ExResultSelect(IDEXResultSelect),
    .RegWrite(IDRegWrite),
    .MemRead(IDMemRead),
    .MemWrite(IDMemWrite),
    .BranchType(IDBranchType),
    .JumpType(IDJumpType),
    .RegSrcA(IDRegSrcA),
    .RegSrcB(IDRegSrcB),
    .RegDest(IDRegDest),
    .ALUSrc(IDALUSrc),
    .MemToReg(IDMemToReg),
    .MemReadSelect(IDMemReadSelect),
    .MemWriteSelect(IDMemWriteSelect),
    .IsMOVZ(IDIsMOVZ),
    .ALUOp(IDALUOp),

    .CP0WE(CP0WE),
    .CP0WAddr(CP0WAddr),
    .CP0RE(CP0RE),
    .CP0RAddr(CP0RAddr),

    .ExcSyscall(ExcSyscall),
    .ExcEret(ExcEret)
);

wire[31:0] CP0Data;

wire[31:0] cpebase;
wire[31:0] cpstatus;
wire[31:0] cpcause;
wire[31:0] cpepc;

//CP0
CP0 CP0_C(
    // inputs
    .clk(clk),
    .rst(rst),
    .raddr(CP0RAddr),   // Addr to read
    .syscall(0),        // 外部硬件中断输入
    .we(WBCP0WE),             // write enable
    .waddr(WBCP0WAddr),          // Addr to write
    .wdata(WBCP0WData),          // Data to write

    // outputs
    .data(CP0Data),      // Data Read
    // five registers
    .ebase(cpebase),
    .status(cpstatus),
    // status[28]: CP0 useable or not; 1 = cp0 can be used
    // status[15:8]: block syscall or not; 1 means handle syscall
    // status[1]: Exception level. 1 = shows if exception happens
    // status[0]: interrupt enable. 1 = enables syscall
    .cause(cpcause),     // cause
    // cause[31]: if exception happens at Branch DelaySlot
    // cause[15:8]: if interrupt happens
    // cause[6:2]: indicates the kind of exception
    //  000: Int Interruption
    //  8: Sys Syscall
    //  10: RI Undetermined Exception
    //  12: Overflow
    //  13: Trap: if something traps it selt
    .epc(cpepc)       // epc
);

//TODO:RegisterFile
wire[31:0] IDRegDataA;
wire[31:0] IDRegDataB;
wire[31:0] WBWriteData; //WriteBack

RegisterFile RegisterFile_c(
    .clk(clk),
    //input
    .ReadRegA(IDRegSrcA),
    .ReadRegB(IDRegSrcB),
    .NPCInput(IFIDNPC),
    
    //output
    .ReadDataA(IDRegDataA),
    .ReadDataB(IDRegDataB),
    
    //input
    .RegWrite(MEMWBRegWrite),
    .WriteReg(MEMWBRegDest),
    .WriteData(WBWriteData)
);


//HazardUnit
wire IDHazardHappen;

HazardUnit HazardUnit_c(
    .IDEXMemRead(IDEXMemRead),
    .IDEXRegDest(IDEXRegDest),
    .IDRegSrcA(IDRegSrcA),
    .IDRegSrcB(IDRegSrcB),
    .HazardHappen(IDHazardHappen)
);


wire IDEXclr;
wire IDEXwriteEN;
//assign IDEXclr=0;
//assign IDEXwriteEN=1;
wire[31:0] EXCP0RData;
wire[4:0] EXCP0RAddr;

wire EXCP0WE;
wire[4:0] EXCP0WAddr;
wire[31:0] EXCP0WData;
// Exc Types
wire EXSyscall;
wire ExEret;
wire ExDelay;

// CP0 CONTENTS
wire[31:0] exstatus;
wire[31:0] excause;
wire[31:0] exebase;
wire[31:0] exepc;

RegIDEX RegIDEX_c(
    .clk(clk),
    .rst(rst),
    .clr(IDEXclr),
    .writeEN(IDEXwriteEN),

    // CP0Data: read
    .CP0DataInput(CP0Data),
    .CP0DataOutput(EXCP0RData),
    .CP0RAddrInput(CP0RAddr),
    .CP0RAddrOutput(EXCP0RAddr),
    // CP0 write data
    .CP0WEInput(CP0WE),
    .CP0WAddrInput(CP0WAddr),
    .CP0WDataInput(IDRegDataA),
    .CP0WEOutput(EXCP0WE),
    .CP0WAddrOutput(EXCP0WAddr),
    .CP0WDataOutput(EXCP0WData),
    
    // Exp Type
    .ExcSyscallInput(ExcSyscall),
    .ExcEretInput(ExcEret),
    .ExcSyscallOutput(EXSyscall),
    .ExcEretOutput(ExEret),

    // DelaySlot
    .BranchDS(IDEXBranchType),
    .JumpDS(IDEXJumpType),
    .IsDSOutput(ExDelay),

    // CP0 Contents
    .EbaseInput(cpebase),
    .EpcInput(cpepc),
    .StatusInput(cpstatus),
    .CauseInput(cpcause),
    .EbaseOutput(exebase),
    .EpcOutput(excause),
    .StatusOutput(exstatus),
    .CauseOutput(excause),

    .NPCInput(IFIDNPC),
        
    .RegSrcAInput(IDRegSrcA),
    .RegSrcBInput(IDRegSrcB),
    .RegDestInput(IDRegDest),
    
    .RegDataAInput(IDRegDataA),
    .RegDataBInput(IDRegDataB),
    
    .ExtendImmInput(IDExtendImm),
    
    .ALUOpInput(IDALUOp),
    .ALUSrcInput(IDALUSrc),
    .EXResultSelectInput(IDEXResultSelect),
    
    .MemReadInput(IDMemRead),
    .MemWriteInput(IDMemWrite),
    .BranchTypeInput(IDBranchType),
    .JumpTypeInput(IDJumpType),
    .MemReadSelectInput(IDMemReadSelect),
    .MemWriteSelectInput(IDMemWriteSelect),
    
    .RegWriteInput(IDRegWrite),
    .MemToRegInput(IDMemToReg),
    
    .IsMOVZInput(IDIsMOVZ),
    
    .NPCOutput(IDEXNPC),
        
    .RegSrcAOutput(IDEXRegSrcA),
    .RegSrcBOutput(IDEXRegSrcB),
    .RegDestOutput(IDEXRegDest),
    
    .RegDataAOutput(IDEXRegDataA),
    .RegDataBOutput(IDEXRegDataB),
    
    .ExtendImmOutput(IDEXExtendImm),
    
    .ALUOpOutput(IDEXALUOp),
    .ALUSrcOutput(IDEXALUSrc),
    .EXResultSelectOutput(IDEXEXResultSelect),
    
    .MemReadOutput(IDEXMemRead),
    .MemWriteOutput(IDEXMemWrite),
    .BranchTypeOutput(IDEXBranchType),
    .JumpTypeOutput(IDEXJumpType),
    .MemReadSelectOutput(IDEXMemReadSelect),
    .MemWriteSelectOutput(IDEXMemWriteSelect),
    
    .RegWriteOutput(IDEXRegWrite),
    .MemToRegOutput(IDEXMemToReg),
    
    .IsMOVZOutput(IDEXIsMOVZ)
);

//ForwardUnit
wire[1:0] EXForwardA;
wire[1:0] EXForwardB;
//assign EXForwardA=0;
//assign EXForwardB=0;

ForwardUnit ForwardUnit_c(
    // input
    .EXMEMRegWrite(EXMEMRegWrite),
    .MEMWBRegWrite(MEMWBRegWrite),
    .EXMEMRegDest(EXMEMRegDest),
    .MEMWBRegDest(MEMWBRegDest),
    .IDEXRegSrcA(IDEXRegSrcA),
    .IDEXRegSrcB(IDEXRegSrcB),
    
    // output
    .ForwardA(EXForwardA),
    .ForwardB(EXForwardB)
);


//Select RegA and RegB
wire[31:0] EXRegA;
wire[31:0] EXRegB;

Selector32_4to1 EXRegASelector(
    .InputA(IDEXRegDataA),
    .InputB(EXMEMEXResult),
    .InputC(WBWriteData),
    .InputD(0),
    .Control(EXForwardA),
    .Output(EXRegA)
);
Selector32_4to1 EXRegBSelector(
    .InputA(IDEXRegDataB),
    .InputB(EXMEMEXResult),
    .InputC(WBWriteData),
    .InputD(0),
    .Control(EXForwardB),
    .Output(EXRegB)
);


//Select ALUSrc
wire[31:0] EXInputB;

Selector32_2to1 EXInputBSelector(
    .InputA(EXRegB),
    .InputB(IDEXExtendImm),
    .Control(IDEXALUSrc),
    .Output(EXInputB)
);

//ALU
wire[31:0] EXOutput;

ALU ALU_c(
    .ALUOp(IDEXALUOp),
    .InputA(EXRegA),
    .InputB(EXInputB),
    .Output(EXOutput)
);


wire[31:0] EXCP0FData;
wire[31:0] fnstatus;
wire[31:0] fncause;
wire[31:0] fnepc;
wire[31:0] fnebase;
// CP0 Selector
EXCP0Forward EXCP0ForwardUnit(
    // Used for MFC0
    .ERead(EXCP0RData),
    .MWrite(MEMCP0WData),
    .WWrite(WBCP0WData),
    .RAddr(EXCP0RAddr),
    .MEMWAddr(MEMCP0WAddr),
    .WBWAddr(WBCP0WAddr),

    // Write Enables
    .MEMWE(MEMCP0WE),
    .WBWE(WBCP0WE),
    // Used for pushing forward CP0 contents
    // ebase, epc, status, cause
    .EbaseInput(exebase),
    .EpcInput(exepc),
    .StatusInput(exstatus),
    .CauseInput(excause),
    .EbaseOutput(fnebase),
    .EpcOutput(fnepc),
    .StatusOutput(fnstatus),
    .CauseOutput(fncause),

    .OutputData(EXCP0FData)
);

//Select EXResult
wire[31:0] EXEXResult;

Selector32_4to1 EXEXResultSelector(
    .InputA(EXOutput),
    .InputB(EXCP0FData),    // IF MOVE FROM CP0 TO A GENERAL REG
    .InputC(EXInputB),
    .InputD(IDEXNPC+4),
    .Control(IDEXEXResultSelect),
    .Output(EXEXResult)
);


//MOVZController
wire EXRegWrite;

MOVZController MOVZController_c(
    .EXResult(EXOutput),
    .IsMOVZ(IDEXIsMOVZ),
    .OldRegWrite(IDEXRegWrite),
    .NewRegWrite(EXRegWrite)
);

//Calculate BranchPC
wire[31:0] EXBranchPC;

Adder32 BranchPCAdder(
    .InputA(IDEXNPC),
    .InputB(IDEXExtendImm),
    .Output(EXBranchPC)
);


//BranchSelector
wire[1:0] EXBranchSelect;
wire EXBranchHappen;

BranchSelector BranchSelector_c(
    // input
    .BranchType(IDEXBranchType),
    .JumpType(IDEXJumpType),
    .EXRegA(EXRegA),
    .EXRegB(EXRegB),
    
    // output
    .BranchSelect(EXBranchSelect),
    .BranchHappen(EXBranchHappen)
);


//Select NewPC

Selector32_4to1 NewPCSelector(
    .InputA(IFNPC),
    .InputB(EXBranchPC),
    .InputC(EXRegA),
    .InputD(IDEXExtendImm),
    .Control(EXBranchSelect),
    .Output(NewPC)
);


wire EXMEMclr;
wire EXMEMwriteEN;
//assign EXMEMclr=0;
//assign EXMEMwriteEN=1;

// CP0 WIRES
wire MEMCP0WE;
wire[4:0] MEMCP0WAddr;
wire[31:0] MEMCP0WData;
// EXC WIRES
wire MEMSyscall;
wire MEMEret;
wire MEMDelay;
// PC
wire[31:0] MEMPC;
// CP0 Registers
wire[31:0] memstatus;
wire[31:0] memcause;
wire[31:0] memepc;
wire[31:0] memebase;

RegEXMEM RegEXMEM_c(
    .clk(clk),
    .rst(rst),
    .clr(EXMEMclr),
    .writeEN(EXMEMwriteEN),
    
    // CP0 write data
    .CP0WEInput(EXCP0WE),
    .CP0WAddrInput(EXCP0WAddr),
    .CP0WDataInput(EXCP0WData),
    .CP0WEOutput(MEMCP0WE),
    .CP0WAddrOutput(MEMCP0WAddr),
    .CP0WDataOutput(MEMCP0WData),

    // Exc Type
    .ExcSyscallInput(EXSyscall),
    .ExcSyscallOutput(MEMSyscall),
    .ExcEretInput(ExEret),
    .ExcEretOutput(MEMEret),
    .ExcDsInput(ExDelay),
    .ExcDsOutput(MEMDelay),

    .EXResultInput(EXEXResult),
    .RegDestInput(IDEXRegDest),
    .RegDataBInput(EXRegB),

    // Current PC
    .PCInput(IDEXNPC - 4),
    .PCOutput(MEMPC),

    // CP0 Contents
    .EbaseInput(fnebase),
    .EpcInput(fnepc),
    .StatusInput(fnstatus),
    .CauseInput(fncause),
    .EbaseOutput(memebase),
    .EpcOutput(memcause),
    .StatusOutput(memstatus),
    .CauseOutput(memcause),
    
    .MemReadInput(IDEXMemRead),
    .MemWriteInput(IDEXMemWrite),
    .BranchTypeInput(IDEXBranchType),
    .JumpTypeInput(IDEXJumpType),
    .MemReadSelectInput(IDEXMemReadSelect),
    .MemWriteSelectInput(IDEXMemWriteSelect),
    
    .RegWriteInput(EXRegWrite),
    .MemToRegInput(IDEXMemToReg),
    
    .EXResultOutput(EXMEMEXResult),
    .RegDestOutput(EXMEMRegDest),
    .RegDataBOutput(EXMEMRegDataB),
    
    .MemReadOutput(EXMEMMemRead),
    .MemWriteOutput(EXMEMMemWrite),
    .BranchTypeOutput(EXMEMBranchType),
    .JumpTypeOutput(EXMEMJumpType),
    .MemReadSelectOutput(EXMEMMemReadSelect),
    .MemWriteSelectOutput(EXMEMMemWriteSelect),
    
    .RegWriteOutput(EXMEMRegWrite),
    .MemToRegOutput(EXMEMMemToReg)
);

Ctrl Ctrl_CP0(
    .rst(rst),
    .CurrentPC(MEMPC),

    // Exc Types
    .ExcSyscall(MEMSyscall),
    .ExcEret(MEMEret),
    .ExcDelay(MEMDelay),

    // CP0 Contents
    .CP0EBASE(memebase),
    .CP0STATUS(memstatus),
    .CP0CAUSE(memcause),
    .CP0EPC(memepc),

    // Exception PC
    .ExcPC(),
    // flush   
    .PCFlush(),
    .IFIDFlush(),
    .IDEXFlush(),
    .EXMEFlush(),
    .MEWBFlush()
);

assign MemAddress=EXMEMEXResult;
assign MemWriteData=EXMEMRegDataB;

assign MemReadEN=EXMEMMemRead;
assign MemWriteEN=EXMEMMemWrite;
//assign MemReadEN=0;
//assign MemWriteEN=0;

assign MemReadSelect=EXMEMMemReadSelect;
assign MemWriteSelect=EXMEMMemWriteSelect;

wire MEMWBclr;
wire MEMWBwriteEN;
//assign MEMWBclr=0;
//assign MEMWBwriteEN=1;

wire WBCP0WE;
wire[4:0] WBCP0WAddr;
wire[31:0] WBCP0WData;

RegMEMWB RegMEMWB_c(
    .clk(clk),
    .rst(rst),
    .clr(MEMWBclr),
    .writeEN(MEMWBwriteEN),
    
    // CP0 write data
    .CP0WEInput(MEMCP0WE),
    .CP0WAddrInput(MEMCP0WAddr),
    .CP0WDataInput(MEMCP0WData),
    .CP0WEOutput(WBCP0WE),
    .CP0WAddrOutput(WBCP0WAddr),
    .CP0WDataOutput(WBCP0WData),

    .MemReadDataInput(MemReadData),
    .EXResultInput(EXMEMEXResult),
    .RegDestInput(EXMEMRegDest),
    
    .RegWriteInput(EXMEMRegWrite),
    .MemToRegInput(EXMEMMemToReg),
     
    .MemReadDataOutput(MEMWBMemReadData),
    .EXResultOutput(MEMWBEXResult),
    .RegDestOutput(MEMWBRegDest),
    
    .RegWriteOutput(MEMWBRegWrite),
    .MemToRegOutput(MEMWBMemToReg)
);


//Select WriteData

Selector32_2to1 WBWriteDataSelector(
    .InputA(MEMWBEXResult),
    .InputB(MEMWBMemReadData),
    .Control(MEMWBMemToReg),
    .Output(WBWriteData)
);


//StallUnit

StallUnit StallUnit_c(
    .BranchHappen(EXBranchHappen),
    .HazardHappen(IDHazardHappen),
    .PCWriteEN(PCwriteEN),
    .PCClear(PCclr),
    .IFIDWriteEN(IFIDwriteEN),
    .IFIDClear(IFIDclr),
    .IDEXWriteEN(IDEXwriteEN),
    .IDEXClear(IDEXclr),
    .EXMEMWriteEN(EXMEMwriteEN),
    .EXMEMClear(EXMEMclr),
    .MEMWBWriteEN(MEMWBwriteEN),
    .MEMWBClear(MEMWBclr)
);


assign LED= //(SW==0) ? IDALUOp:
            //(SW==1) ? IDRegSrcA:
            //(SW==2) ? IDRegSrcB:
            //(SW==3) ? IDRegDest:
            (SW==4) ? {IDBranchType,IDJumpType}:
            (SW==5) ? {IDEXResultSelect,IDRegWrite,IDMemToReg,IDMemRead,IDMemWrite}:
            (SW==6) ? {IDALUSrc,IDIsMOVZ,IDMemWriteSelect,IDMemReadSelect}:
            
            (SW==7) ? IFNPC[15:0]:
            (SW==8) ? IFNPC[31:16]:
            (SW==9) ? InstInput[15:0]:
            (SW==10) ? InstInput[31:16]:
            
            //(SW==11) ? IDExtendImm[15:0]:
            //(SW==12) ? IDExtendImm[31:16]:
            
            (SW==13) ? IDRegDataA[15:0]:
            (SW==14) ? IDRegDataA[31:16]:
            (SW==15) ? IDRegDataB[15:0]:
            (SW==16) ? IDRegDataB[31:16]:
            (SW==17) ? EXRegA[15:0]:
            (SW==18) ? EXRegA[31:16]:
            (SW==19) ? EXRegB[15:0]:
            (SW==20) ? EXRegB[31:16]:
            (SW==21) ? EXInputB[15:0]:
            (SW==22) ? EXInputB[31:16]:
            //(SW==23) ? EXOutput[15:0]:
            //(SW==24) ? EXOutput[31:16]:
            (SW==25) ? EXEXResult[15:0]:
            (SW==26) ? EXEXResult[31:16]:
            (SW==27) ? EXRegWrite:
            //(SW==28) ? EXBranchPC[15:0]:
            //(SW==29) ? EXBranchPC[31:16]:
            (SW==30) ? {EXForwardA,EXForwardB,EXBranchSelect,EXBranchHappen,IDHazardHappen}:
            (SW==31) ? NewPC[15:0]:
            (SW==32) ? NewPC[31:16]:
            (SW==33) ? WBWriteData[15:0]:
            (SW==34) ? WBWriteData[31:16]:
            /*
            (SW==35) ? MemReadData:
            (SW==36) ? EXMEMMemRead:
            (SW==37) ? EXMEMEXResult[15:0]:
            (SW==38) ? EXMEMEXResult[31:0]:
            */
            (SW==64) ? cpebase[15:0]:
            (SW==65) ? cpebase[31:16]:
            (SW==66) ? cpstatus[15:0]:
            (SW==67) ? cpstatus[31:16]:
            (SW==68) ? cpcause[15:0]:
            (SW==69) ? cpcause[31:16]:
            (SW==70) ? cpepc[15:0]:
            (SW==71) ? cpepc[31:16]:
            0;

endmodule