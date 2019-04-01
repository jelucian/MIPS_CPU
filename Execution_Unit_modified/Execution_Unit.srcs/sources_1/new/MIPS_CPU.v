`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: MIPS_CPU.v
 * Date:     3/21/2019
 * Version:  1.0
 * 
 * Notes:    Module Instantiates Control Unit, Instruction Unit, Datapath, and
 *           Data Memory
 *
 *******************************************************************************/

module MIPS_CPU(clk, reset, intr, inta);
    //inputs
    input      clk, reset, intr;
    output     inta;
    //IDP wires
    wire        c, n, z, v, HILO_ld, D_En, T_Sel;
    wire [ 1:0] DA_Sel;
    wire [ 2:0] Y_Sel;    
    wire [ 4:0] FS, S_Addr, T_Addr, D_Addr;
    wire [31:0] ALU_OUT, IDP_D_OUT;

    //IU wires
    wire        im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld;
    wire [ 1:0] pc_sel;
    wire [31:0] IR_out, PC_out, SE_16;

    //Data Memory wires
    wire        dm_cs, dm_wr, dm_rd;
    wire [31:0] dM_out;

    //Control Unit outputs
    wire        int_ack;

    //task variable
    integer     i;

    //Module Instantiations
    MCU Control_Unit(.sys_clk(clk), .reset(reset), .intr(intr), .c(c), .n(n),
    .z(z), .v(v), .IR(IR_out), .int_ack(int_ack), .pc_sel(pc_sel), .pc_ld(pc_ld),
    .pc_inc(pc_inc), .ir_ld(ir_ld), .im_cs(im_cs), .im_rd(im_rd), .im_wr(im_wr),
    .D_En(D_En), .DA_sel(DA_Sel), .T_sel(T_Sel), .HILO_ld(HILO_ld), 
    .Y_sel(Y_Sel), .dm_cs(dm_cs), .dm_rd(dm_rd), .dm_wr(dm_wr), .FS(FS),
    .S_Addr(S_Addr), .T_Addr(T_Addr), .D_Addr(D_Addr) );

    CPU_IU Instruction_Unit(.clk(clk), .reset(reset), .im_cs(im_cs), 
    .im_wr(im_wr), .im_rd(im_rd), .pc_ld(pc_ld), .pc_inc(pc_inc), 
    .ir_ld(ir_ld), .PC_in(ALU_OUT), .PC_out(PC_out), .IR_out(IR_out),
    .SE_16(SE_16), .pc_sel(pc_sel) );

    Integer_Datapath IDP(.clk(clk), .reset(reset), .S_Addr(S_Addr), .FS(FS), 
    .HILO_ld(HILO_ld), .D_En(D_En), .D_Addr(D_Addr), .T_Addr(T_Addr), .DT(SE_16), 
    .T_Sel(T_Sel), .C(c), .V(v), .N(n), .Z(z), .DY(dM_out), .PC_in(PC_out), 
    .Y_Sel(Y_Sel), .ALU_OUT(ALU_OUT), .D_OUT(IDP_D_OUT), .DA_Sel(DA_Sel) );

    Memory Data_Memory(.clk(clk), .cs(dm_cs), .wr(dm_wr), .rd(dm_rd), 
    .Address(ALU_OUT), .D_In(IDP_D_OUT), .D_Out(dM_out) );
    

endmodule
