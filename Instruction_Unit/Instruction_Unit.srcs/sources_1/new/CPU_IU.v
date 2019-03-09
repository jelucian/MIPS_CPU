`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: CPU_IU.v
 * Date:     3/5/2019
 * Version:  1.0
 * 
 * Notes:    Instruction unit which contains a Program Counter, Instruction 
 *           Memory, Instruction Register and a sign extended output for
 *           immediate instructions.
 *
 *******************************************************************************/
module CPU_IU(clk, reset, im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld, PC_in,
              PC_out, IR_out, SE_16);
              
    input         clk, reset, im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld;
    input  [31:0] PC_in;
    
    output [31:0] PC_out, IR_out, SE_16;
    
    wire   [31:0] IM_out;
    
    //module reg32_inc(clk, reset, ld, inc, D, Q);
    reg32_inc   PC(.clk(clk), .reset(reset), .ld(pc_ld), .inc(pc_inc),
                 .D(PC_in), .Q(PC_out) );

    //instruction mem
    //module Data_Memory(clk, cs, wr, rd, Address, D_In, D_Out);
    Memory IM(.clk(clk), .cs(im_cs), .wr(im_wr), .rd(im_rd),
                   .Address(PC_out), .D_In(32'h0), .D_Out(IM_out) );
    
    //module reg32(clk, reset, ld, D, Q);
    //ir
    reg32       IR(.clk(clk), .reset(reset), .ld(ir_ld), 
                   .D(IM_out), .Q(IR_out) );
    
    //sign externsion of IR for immediate values
    assign SE_16 = {{ 16{IR_out[15]}}, IR_out[15:0]};
    
    
endmodule
