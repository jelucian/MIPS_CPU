`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano
 * Filename: Integer_Datapath.v
 * Date:     1/29/2019
 * Version:  1.0
 * 
 * Notes:    Module connects register file and ALU, and ties additional control
 *           signals. New resgister, HI and LO, are used to store the output of
 *           the ALU module and 2 multiplexers are used to select ALU_OUT and
 *           the second input to the ALU
 *
 *******************************************************************************/
module Integer_Datapath(clk, reset, S_Addr, FS, HILO_ld, D_En, D_Addr, T_Addr,
                        DT, T_Sel, C, V, N, Z, DY, PC_in, Y_Sel, ALU_OUT, D_OUT);
    
    input        clk, reset, HILO_ld, D_En, T_Sel;
    input [2:0]  Y_Sel;
    input [4:0]  S_Addr, FS, D_Addr, T_Addr;
    input [31:0] DT, DY, PC_in;
   
    output             C, V, N, Z;
    output      [31:0] D_OUT;
    output wire [31:0] ALU_OUT;
    
    wire [31:0] REG_FILE_S, REG_FILE_T,
                Y_hi, Y_lo, HI_out, LO_out;
    
    //T-MUX
    assign D_OUT = (T_Sel) ? REG_FILE_T : DT;    
    
    //Y-MUX
    assign ALU_OUT = (Y_Sel == 3'b100) ? HI_out :
                     (Y_Sel == 3'b011) ? LO_out :
                     (Y_Sel == 3'b010) ? Y_lo   :
                     (Y_Sel == 3'b001) ? DY     :
                                         PC_in  ;
                                         
    //module reg32(clk, reset, ld, D, Q);
    reg32 HI(.clk(clk), .reset(reset), .ld(HILO_ld), .D(Y_hi), .Q(HI_out) );
    reg32 LO(.clk(clk), .reset(reset), .ld(HILO_ld), .D(Y_lo), .Q(LO_out) );
    
    //module alu_32(S, T, FS, C, V, N, Z, Y_hi, Y_lo);
    alu_32 ALU(.S(REG_FILE_S), .T(D_OUT), .FS(FS),
               .C(C), .V(V), .N(N), .Z(Z),
               .Y_hi(Y_hi), .Y_lo(Y_lo) );

    //module regfile32(clk, reset, S, T, D, S_Addr, T_Addr, D_Addr, D_En);
    regfile32 REG_FILE(.clk(clk), .reset(reset), .S(REG_FILE_S),
                       .T(REG_FILE_T), .D(ALU_OUT), .S_Addr(S_Addr),
                       .T_Addr(T_Addr),.D_Addr(D_Addr), .D_En(D_En) );
                                
endmodule
