`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: MIPS_CPU.v
 * Date:     3/21/2019
 * Version:  1.0
 * 
 * Notes:1.0 Module Instantiates Control Unit, Instruction Unit, Datapath, and
 *           Data Memory
 
 *       1.1 Modified for final implmentation. Removed data memory, added signal
 *           as outputs for data memory and io memory
 *
 *******************************************************************************/
module MIPS_CPU(clk, reset, intr, inta, dm_cs, dm_wr, dm_rd, dm_address, 
                dm_d_in, dm_out, io_rd, io_wr, io_out, io_cs);
    //inputs
    input      clk, reset, intr;

    //IDP wires and outputs
    wire        c, n, z, v, HILO_ld, D_En, stack;
    wire [ 1:0] DA_Sel;
    wire [ 2:0] Y_Sel, T_Sel;    
    wire [ 4:0] FS, S_Addr, T_Addr, D_Addr, shamt, flags_in, flags_out;

    //IU wires
    wire        im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld;
    wire [ 1:0] pc_sel;
    wire [31:0] IR_out, PC_out, SE_16;

    //Data Memory wires
    output wire        dm_cs, dm_wr, dm_rd;
    output wire [31:0] dm_d_in, dm_address;
    
    input [31:0] dm_out;

    //Control Unit outputs
    output       inta;
    
    //IO memory/intrrupt inputs/outputs
    input [31:0] io_out;
    output wire  io_rd, io_wr, io_cs;
  
    //Module Instantiations
    MCU Control_Unit(.sys_clk(clk), .reset(reset), .intr(intr), .c(c), .n(n),
    .z(z), .v(v), .IR(IR_out), .int_ack(inta), .pc_sel(pc_sel), .pc_ld(pc_ld),
    .pc_inc(pc_inc), .ir_ld(ir_ld), .im_cs(im_cs), .im_rd(im_rd), .im_wr(im_wr),
    .D_En(D_En), .DA_sel(DA_Sel), .T_sel(T_Sel), .HILO_ld(HILO_ld), 
    .Y_sel(Y_Sel), .dm_cs(dm_cs), .dm_rd(dm_rd), .dm_wr(dm_wr), .FS(FS),
    .S_Addr(S_Addr), .T_Addr(T_Addr), .D_Addr(D_Addr), .shamt(shamt),
    .io_rd(io_rd), .io_wr(io_wr), .io_cs(io_cs), .stack(stack),
    .flags_out(flags_out), .flags_in(flags_in) );

    CPU_IU Instruction_Unit(.clk(clk), .reset(reset), .im_cs(im_cs), 
    .im_wr(im_wr), .im_rd(im_rd), .pc_ld(pc_ld), .pc_inc(pc_inc), 
    .ir_ld(ir_ld), .PC_in(dm_address), .PC_out(PC_out), .IR_out(IR_out),
    .SE_16(SE_16), .pc_sel(pc_sel) );

    Integer_Datapath IDP(.clk(clk), .reset(reset), .S_Addr(S_Addr), .FS(FS), 
    .HILO_ld(HILO_ld), .D_En(D_En), .D_Addr(D_Addr), .T_Addr(T_Addr), .DT(SE_16), 
    .T_Sel(T_Sel), .C(c), .V(v), .N(n), .Z(z), .DY(dm_out), .PC_in(PC_out), 
    .Y_Sel(Y_Sel), .ALU_OUT(dm_address), .D_OUT(dm_d_in), .DA_Sel(DA_Sel), 
    .shamt(shamt), .io_rd(io_rd), .io_out(io_out), .stack(stack),
    .flags_in(flags_out), .flags_out(flags_in) );

endmodule
