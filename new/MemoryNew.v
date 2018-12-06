`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/04 20:37:56
// Design Name: 
// Module Name: MemoryNew
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


module MemoryNew(
    input wire clk,
    input wire rst,
    input wire run_ctrl,
    input wire debug,
    output wire CPUclk,
    input wire[31:0] SW,
    output wire[15:0] LEDOut,
    
    input wire[31:0] InstAddress,
    output wire[31:0] InstInput,
    
    input wire MemReadEN,
    input wire MemWriteEN,
    input wire[1:0] MemReadSelect,
    input wire MemWriteSelect,
    input wire[31:0] MemAddress,
    input wire[31:0] MemWriteData,
    output wire[31:0] MemReadData,
    
    output wire uart_rdn,
    output wire uart_wrn,
    input wire uart_dataready,
    input wire uart_tbre,
    input wire uart_tsre,
    
    inout wire[31:0] ram_data,
    output wire[19:0] ram_addr,
    output wire ram_CE,
    output wire ram_OE,
    output wire ram_WE,
    output wire[3:0] ram_BE,

    inout wire[31:0] ext_ram_data,
    output wire[19:0] ext_ram_addr,
    output wire ext_ram_CE,
    output wire ext_ram_OE,
    output wire ext_ram_WE,
    output wire[3:0] ext_ram_BE,
    
    output reg[15:0] vga_addr,
    output reg[7:0] vga_data
    );
    
initial begin
    vga_addr <= 0;
    vga_data <= 0;
end
    
reg[1:0] run_state;

reg[31:0] in_data;
wire[31:0] out_data;
reg[19:0] in_addr;

wire uart_r_ok,uart_w_ok;

reg[2:0] state;

initial begin
    state<=0;
end

reg[31:0] BufferData1;
reg[31:0] BufferData2;
assign InstInput=BufferData1;
//assign InstInput= InstAddress[22] ? ext_ram_data : ram_data;
assign MemReadData=BufferData2;

reg[3:0] BE;
assign ram_BE=BE;
assign ext_ram_BE=BE;

assign CPUclk = (state == 0);
//assign LEDOut = {1'b0,mode,1'b0,state,BufferData1[7:0]};
//assign LEDOut = BufferData1[31:16];

reg uartEN;
reg[6:0] uartTimer;

initial begin
    uartEN <= 1;
    uartTimer <= 0;
end

assign LEDOut= (SW==0) ? BufferData2[15:0]:
               (SW==1) ? BufferData2[31:16]:
               (SW==2) ? MemAddress[15:0]:
               (SW==3) ? MemAddress[31:16]:
               (SW==4) ? {debug,run_ctrl,run_state,CPUclk,state}:
               (SW==5) ? {uartEN,uartTimer}:
               0;

reg OE1, WE1;
reg OE2, WE2;
reg wrn, rdn;

initial begin
    OE1 <= 1;
    WE1 <= 1;
    OE2 <= 1;
    WE2 <= 1;
    wrn <= 1;
    rdn <= 1;
end

assign ram_CE=(state[0] == state[1]) ? InstAddress[22] : MemAddress[22];
assign ram_OE=OE1;
assign ram_WE=WE1;

assign ext_ram_CE=(state[0] == state[1]) ? (!InstAddress[22]) : (!MemAddress[22]);
assign ext_ram_OE=OE2;
assign ext_ram_WE=WE2;

assign uart_wrn=wrn;
assign uart_rdn=rdn;

reg[31:0] WriteData;
reg[31:0] RamReadData;
reg[31:0] ext_RamReadData;

always@(*) begin
    if (((state == 1) | (state == 2)) & MemWriteSelect) begin
        case (MemAddress[1:0])
            0:begin
                WriteData <= {24'h0,MemWriteData[7:0]};
                BE <= 4'b1110;
            end
            1:begin
                WriteData <= {16'h0,MemWriteData[7:0],8'h0};
                BE <= 4'b1101;
            end
            2:begin
                WriteData <= {8'h0,MemWriteData[7:0],16'h0};
                BE <= 4'b1011;
            end
            3:begin
                WriteData <= {MemWriteData[7:0],24'h0};
                BE <= 4'b0111;
            end
        endcase
    end else begin
        WriteData <= MemWriteData;
        BE <= 0;
    end
end

assign ram_data=((state[0] == state[1]) | MemReadEN)?32'bz:WriteData;
assign ext_ram_data=((state[0] == state[1]) | MemReadEN)?32'bz:WriteData;

assign ram_addr=(state[0] == state[1]) ? InstAddress[21:2] : MemAddress[21:2];
assign ext_ram_addr=(state[0] == state[1]) ? InstAddress[21:2] : MemAddress[21:2];
/*
wire unsignRamReadData;
wire signedRamReadData;
wire[31:0] unsignExtReadData;
wire signedExtReadData;

assign unsignRamReadData= (MemAddress[1:0] == 0) ? ram_data[7:0] :
                          (MemAddress[1:0] == 1) ? ram_data[7:0] :
                          (MemAddress[1:0] == 2) ? ram_data[7:0] :
                          (MemAddress[1:0] == 3) ? ram_data[7:0] :
                          ram_data;
assign signedRamReadData= (MemAddress[1:0] == 0) ? $signed(ram_data[7:0]) :
                          (MemAddress[1:0] == 1) ? $signed(ram_data[7:0]) :
                          (MemAddress[1:0] == 2) ? $signed(ram_data[7:0]) :
                          (MemAddress[1:0] == 3) ? ram_data[7:0] :
                          ram_data;
*/
always@(*) begin
    if (state == 2) begin
        if (MemReadSelect == 0) begin
            RamReadData <= ram_data;
            ext_RamReadData <= ext_ram_data;
        end else begin
            case (MemAddress[1:0])
                0:begin
                    RamReadData <= MemReadSelect[0] ? $signed(ram_data[7:0]) : ram_data[7:0];
                    ext_RamReadData <= MemReadSelect[0] ? $signed(ext_ram_data[7:0]) : ext_ram_data[7:0];
                end
                1:begin
                    RamReadData <= MemReadSelect[0] ? $signed(ram_data[15:8]) : ram_data[15:8];
                    ext_RamReadData <= MemReadSelect[0] ? $signed(ext_ram_data[15:8]) : ext_ram_data[15:8];
                end
                2:begin
                    RamReadData <= MemReadSelect[0] ? $signed(ram_data[23:16]) : ram_data[23:16];
                    ext_RamReadData <= MemReadSelect[0] ? $signed(ext_ram_data[23:16]) : ext_ram_data[23:16];
                end
                3:begin
                    RamReadData <= MemReadSelect[0] ? $signed(ram_data[31:24]) : ram_data[31:24];
                    ext_RamReadData <= MemReadSelect[0] ? $signed(ext_ram_data[31:24]) : ext_ram_data[31:24];
                end
            endcase
        end
    end
end

always@(posedge clk or posedge rst) begin
    if (rst == 1) begin
        state <= 0;
        run_state <= 0;
        uartEN <= 1;
        uartTimer <= 0;
    end else begin
        case (state)
            0:begin //pre
                OE1<=1; WE1<=1;
                OE2<=1; WE2<=1;
                wrn<=1; rdn<=1;
                if (uartTimer == 0) begin
                   uartEN <= 1;
                end else begin
                   uartTimer <= uartTimer - 1;
                end
                if (!debug) begin
                
                    if (MemReadEN | MemWriteEN) begin
                        state <= 1;
                    end else begin
                        state <= 3;
                    end
                
                end else begin
                    if (run_state==0) begin
                        if (run_ctrl) begin
                            run_state <= 1;
                            if (MemReadEN | MemWriteEN) begin
                                state <= 1;
                            end else begin
                                state <= 3;
                            end
                        end
                    end else if (run_state==1) begin
                        if (!run_ctrl) begin
                            run_state<=0;
                        end
                    end
                end
                
            end
            1:begin //rw_start
                if ((MemAddress == 32'hBFD003F8) & uartEN) begin
                    uartEN <= 0;
                    uartTimer <= 20;
                end
                if (MemAddress[31:16] == 16'hBF41) begin
                    if (MemWriteEN) begin
                        vga_addr <= MemAddress[15:0] - 16'h0320;
                        vga_data <= MemWriteData[7:0];
                    end
                    state <= 3;
                end else begin
                    if (MemReadEN) begin
                        case (MemAddress)
                            32'hBFD003F8:begin
                                rdn <= 0;
                                state <= 2;
                            end
                            32'hBFD003FC:begin
                                BufferData2 <= {30'b0,uart_dataready /*& uartEN*/,uart_tsre & uart_tbre /*& uartEN*/};
                                state <= 3;
                            end
                            default:begin
                                if (MemAddress[22]) begin
                                    OE2 <= 0;
                                end else begin
                                    OE1 <= 0;
                                end
                                state <= 2;
                            end
                        endcase
                    end
                    if (MemWriteEN) begin
                        case (MemAddress)
                            32'hBFD003F8:begin
                                wrn <= 0;
                                state <= 2;
                            end
                            32'hBFD003FC:begin
                                state <= 3;
                            end
                            default:begin
                                if (MemAddress[22]) begin
                                    WE2 <= 0;
                                end else begin
                                    WE1 <= 0;
                                end
                                state <= 2;
                            end
                        endcase
                    end
                end
            end
            2:begin //rw_get
                OE1<=1; WE1<=1;
                OE2<=1; WE2<=1;
                wrn<=1; rdn<=1;
                if (MemReadEN) begin
                    case (MemAddress)
                        32'hBFD003F8:begin
                            BufferData2 <= ram_data[7:0];
                            state <= 3;
                        end
                        32'hBFD003FC:begin
                            BufferData2 <= {30'b0,uart_dataready,uart_tsre & uart_tbre};
                            state <= 3;
                        end
                        default:begin
                            if (MemAddress[22]) begin
                                BufferData2 <= ext_RamReadData;
                            end else begin
                                BufferData2 <= RamReadData;
                            end
                            state <= 3;
                        end
                    endcase
                end else begin
                    state <= 3;
                end
            end
            3:begin //ins_start
                if (InstAddress[22]) begin
                    OE2 <= 0;
                end else begin
                    OE1 <= 0;
                end
                state <= 4;
                //state <= 0;
            end
            
            4:begin //ins_wait
                if (InstAddress[22]) begin
                    BufferData1 <= ext_ram_data;
                end else begin
                    BufferData1 <= ram_data;
                end
                state <= 0;
            end
            
            default:begin
                state <= 0;
            end
        endcase
    end
end

endmodule
