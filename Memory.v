`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/11/30 02:11:33
// Design Name: 
// Module Name: Memory
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


module Memory(
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
    output wire[3:0] ext_ram_BE
    );

reg[1:0] run_state;

reg ctrl;
wire succ;
reg[2:0] mode;

reg[31:0] in_data;
wire[31:0] out_data;
reg[19:0] in_addr;

wire uart_r_ok,uart_w_ok;

reg[2:0] state;

reg[31:0] BufferData1;
reg[31:0] BufferData2;
assign InstInput=BufferData1;
assign MemReadData=BufferData2;

reg[3:0] BE;
assign ram_BE=BE;
assign ext_ram_BE=BE;

assign CPUclk = (state == 5);
//assign LEDOut = {1'b0,mode,1'b0,state,BufferData1[7:0]};
//assign LEDOut = BufferData1[31:16];
assign LEDOut= (SW==0) ? BufferData2[15:0]:
               (SW==1) ? BufferData2[31:16]:
               (SW==2) ? MemAddress[15:0]:
               (SW==3) ? MemAddress[31:16]:
               0;

always@(posedge clk or posedge rst) begin
    if (rst == 1) begin
        state <= 0;
        run_state <= 0;
    end else begin
        case (state)
            0:begin //pre
                if (!debug) begin
                    if (MemReadEN | MemWriteEN) begin
                        state <= 1;
                    end else if (succ) begin
                        state <= 3;
                    end
                end else begin
                    if (run_state==0) begin
                        if (run_ctrl) begin
                            run_state <= 1;
                            if (MemReadEN | MemWriteEN) begin
                                state <= 1;
                            end else if (succ) begin
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
                case (MemAddress)
                    32'hBFD003F8:begin
                        mode <= {2'b0,MemReadEN};
                        in_data <= MemWriteData;
                        if (succ) begin
                            ctrl <= succ;
                        end else begin
                            ctrl <= succ;
                            state <= 2;
                        end
                    end
                    32'hBFD003FC:begin
                        BufferData2 <= {30'b0,uart_r_ok,uart_w_ok};
                        state <= 3;
                    end
                    default:begin
                        mode <= {MemAddress[22],1'b1,MemReadEN};
                        if (MemWriteSelect) begin
                            case (MemAddress[1:0])
                                0:begin
                                    in_data <= {24'h0,MemWriteData[7:0]};
                                    BE <= 4'b1110;
                                end
                                1:begin
                                    in_data <= {16'h0,MemWriteData[7:0],8'h0};
                                    BE <= 4'b1101;
                                end
                                2:begin
                                    in_data <= {8'h0,MemWriteData[7:0],16'h0};
                                    BE <= 4'b1011;
                                end
                                3:begin
                                    in_data <= {MemWriteData[7:0],24'h0};
                                    BE <= 4'b0111;
                                end
                            endcase
                        end else begin
                            in_data <= MemWriteData;
                            BE <= 0;
                        end
                        in_addr <= MemAddress[21:2];
                        if (succ) begin
                            ctrl <= succ;
                        end else begin
                            ctrl <= succ;
                            state <= 2;
                        end
                    end
                endcase
            end
            2:begin //rw_wait
                if (succ) begin
                    if (MemReadSelect == 0) begin
                        BufferData2 <= out_data;
                    end else begin
                        case (MemAddress[1:0])
                            0:begin
                                BufferData2 <= MemReadSelect[0] ? $signed(out_data[7:0]) : out_data[7:0];
                            end
                            1:begin
                                BufferData2 <= MemReadSelect[0] ? $signed(out_data[15:8]) : out_data[15:8];
                            end
                            2:begin
                                BufferData2 <= MemReadSelect[0] ? $signed(out_data[23:16]) : out_data[23:16];
                            end
                            3:begin
                                BufferData2 <= MemReadSelect[0] ? $signed(out_data[31:24]) : out_data[31:24];
                            end
                        endcase
                    end
                    BE <= 0;
                    state <= 3;
                end else begin
                    ctrl <= succ;
                end
            end
            3:begin //ins_start
                mode <= {InstAddress[22],2'b11};
                in_addr <= InstAddress[21:2];
                if (succ) begin
                    ctrl <= succ;
                end else begin
                    ctrl <= succ;
                    state <= 4;
                end
            end
            4:begin //ins_wait
                if (succ) begin
                    BufferData1 <= out_data;
                    state <= 5;
                end else begin
                    ctrl <= succ;
                end
            end
            5:begin
                state <= 0;
            end
            default:begin
                state <= 0;
            end
        endcase
    end
end

Ctrl_SRAM_UART controller(
    .uart_rdn(uart_rdn),
    .uart_wrn(uart_wrn),
    .uart_dataready(uart_dataready),
    .uart_tbre(uart_tbre),
    .uart_tsre(uart_tsre),

    .ram_data(ram_data),
    .ram_addr(ram_addr),
    .ram_CE(ram_CE),
    .ram_OE(ram_OE),
    .ram_WE(ram_WE),
    
    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_CE(ext_ram_CE),
    .ext_ram_OE(ext_ram_OE),
    .ext_ram_WE(ext_ram_WE),
    
    .clk(clk),
    .rst(rst),
    .ctrl(ctrl),
    .mode(mode),
    .in(in_data),
    .in_addr(in_addr),
    .out(out_data),
    .succ(succ),
    .uart_r_ok(uart_r_ok),
    .uart_w_ok(uart_w_ok)
);


endmodule
