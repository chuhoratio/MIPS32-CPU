`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/31 09:24:47
// Design Name: 
// Module Name: Ctrl_SRAM_UART
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


module Ctrl_SRAM_UART(
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
    
    inout wire[31:0] ext_ram_data,
    output wire[19:0] ext_ram_addr,
    output wire ext_ram_CE,
    output wire ext_ram_OE,
    output wire ext_ram_WE,
    
    input wire clk,
    input wire rst,
    input wire ctrl,
    input wire[2:0] mode,
    input wire[31:0] in,
    input wire[19:0] in_addr,
    output wire[31:0] out,
    output wire succ,
    output wire uart_r_ok,
    output wire uart_w_ok
    );
 
 reg rdn, wrn;
 assign uart_rdn=rdn;
 assign uart_wrn=wrn;
 reg[31:0] data;
 assign ram_data=mode[0]?32'bz:data;
 assign ext_ram_data=mode[0]?32'bz:data;
 assign ram_addr=in_addr;
 assign ext_ram_addr=in_addr;
 reg CE, OE, WE;
 assign ram_CE=CE;
 assign ram_OE=OE;
 assign ram_WE=WE;
 reg ext_CE, ext_OE, ext_WE;
 assign ext_ram_CE=ext_CE;
 assign ext_ram_OE=ext_OE;
 assign ext_ram_WE=ext_WE;
 
 reg[31:0] res;
 //assign out[7:0]=res[7:0];
 
 reg[3:0] state;
 
 reg success;
 assign succ=success;
 /*
 assign out[11:8]=state;
 assign out[13:12]=mode;
 assign out[15]=uart_r_ok;
 assign out[14]=uart_w_ok;
 assign out[31:16]=res[31:16];
 */
 
 assign out=res;
 
 assign uart_r_ok=uart_dataready;
 assign uart_w_ok=uart_tsre & uart_tbre;
 
 always@(posedge clk or posedge rst) begin
    if (rst) begin
        success<=0;
        state<=0;
        res<=0;
        wrn<=1;
        rdn<=1;
        CE<=1; OE<=1; WE<=1;
        ext_CE<=1; ext_OE<=1; ext_WE<=1;
    end else begin
        case (mode)
            3'h0: begin  //write uart
                case (state)
                    4'h0: begin
                        //res<=0;
                        wrn<=1;
                        CE<=1; OE<=1; WE<=1;
                        ext_CE<=1; ext_OE<=1; ext_WE<=1;
                        data[7:0]<=in[7:0];
                        if (!ctrl) begin
                            state<=4'h1;
                        end
                    end
                    4'h1: begin
                        wrn<=0;
                        state<=4'h2;
                    end
                    4'h2: begin
                       wrn<=1;
                       success<=1;
                       state<=4'h5; 
                    end
                    4'h5: begin
                        if (ctrl) begin
                            success<=0;
                            state<=4'h0;
                        end else begin
                            state<=4'h5;
                        end
                    end
                    default: begin
                        state<=4'h0;
                    end
                endcase
            end
            3'h1: begin  //read uart
                case (state)
                    4'h0: begin
                        //res<=0;
                        rdn<=1;
                        CE<=1; OE<=1; WE<=1;
                        ext_CE<=1; ext_OE<=1; ext_WE<=1;
                        if (!ctrl) begin
                            state<=4'h1;
                        end
                    end
                    4'h1: begin
                        rdn<=0;
                        state<=4'h2;
                    end
                    4'h2: begin
                       rdn<=1;
                       res[7:0]<=ram_data[7:0];
                       res[31:8]<=0;
                       success<=1;
                       state<=4'h5;
                    end
                    4'h5: begin
                        if (ctrl) begin
                            success<=0;
                            state<=4'h0;
                        end else begin
                            state<=4'h5;
                        end
                    end
                    default: begin
                        state<=4'h0;
                    end
                endcase
            end
            3'h2: begin  //write sram
                case (state)
                    4'h0: begin
                        //res<=0;
                        CE<=0; OE<=1; WE<=1;
                        ext_CE<=1; ext_OE<=1; ext_WE<=1;
                        if (!ctrl) begin
                            state<=4'h1;
                        end
                    end
                    4'h1: begin
                        data<=in;
                        state<=4'h2;
                    end
                    4'h2: begin
                        WE<=0;
                        success<=1;
                        state<=4'h5;
                    end
                    4'h5: begin
                        WE<=1;
                        if (ctrl) begin
                            success<=0;
                            state<=4'h0;
                        end else begin
                            state<=4'h5;
                        end
                    end
                    default: begin
                        state<=4'h0;
                    end
                endcase
            end
            3'h3: begin  //read sram
                case (state)
                    4'h0: begin
                        //res<=0;
                        CE<=0; OE<=1; WE<=1;
                        ext_CE<=1; ext_OE<=1; ext_WE<=1;
                        if (!ctrl) begin
                            state<=4'h1;
                        end
                    end
                    4'h1: begin
                        OE<=0;
                        state<=4'h2;
                    end
                    4'h2: begin
                        OE<=1;
                        res<=ram_data;
                        success<=1;
                        state<=4'h5;
                    end
                    4'h5: begin
                        if (ctrl) begin
                            success<=0;
                            state<=4'h0;
                        end else begin
                            state<=4'h5;
                        end
                    end
                    default: begin
                        state<=4'h0;
                    end
                endcase
            end
    
            3'h6: begin  //write ext sram
                case (state)
                    4'h0: begin
                        //res<=0;
                        CE<=1; OE<=1; WE<=1;
                        ext_CE<=0; ext_OE<=1; ext_WE<=1;
                        if (!ctrl) begin
                            state<=4'h1;
                        end
                    end
                    4'h1: begin
                        data<=in;
                        state<=4'h2;
                    end
                    4'h2: begin
                        ext_WE<=0;
                        success<=1;
                        state<=4'h5;
                    end
                    4'h5: begin
                        ext_WE<=1;
                        if (ctrl) begin
                            success<=0;
                            state<=4'h0;
                        end else begin
                            state<=4'h5;
                        end
                    end
                    default: begin
                        state<=4'h0;
                    end
                endcase
            end
            3'h7: begin  //read ext sram
                case (state)
                    4'h0: begin
                        //res<=0;
                        CE<=1; OE<=1; WE<=1;
                        ext_CE<=0; ext_OE<=1; ext_WE<=1;
                        if (!ctrl) begin
                            state<=4'h1;
                        end
                    end
                    4'h1: begin
                        ext_OE<=0;
                        state<=4'h2;
                    end
                    4'h2: begin
                        ext_OE<=1;
                        res<=ext_ram_data;
                        success<=1;
                        state<=4'h5;
                    end
                    4'h5: begin
                        if (ctrl) begin
                            success<=0;
                            state<=4'h0;
                        end else begin
                            state<=4'h5;
                        end
                    end
                    default: begin
                        state<=4'h0;
                    end
                endcase
            end
        endcase
    end
 end
 
endmodule
