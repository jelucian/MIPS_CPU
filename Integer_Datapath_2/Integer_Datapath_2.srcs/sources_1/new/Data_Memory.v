`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: Data_Memory.v
 * Date:     2/25/2019
 * Version:  1.0
 * 
 * Notes:    4096x8 Byte Addressable Memory
 *
 *******************************************************************************/
module Data_Memory(clk, dm_cs, dm_wr, dm_rd, Address, D_In, D_Out);
    
    input clk, dm_cs, dm_wr, dm_rd;
    input [31:0] Address, D_In;
    
    output [31:0] D_Out;
    
    reg [4095:0] memory [7:0]; //4096x8 Memory
    
    

endmodule
