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
    
    input         clk, dm_cs, dm_wr, dm_rd;
    input  [31:0] Address, D_In;
    
    output [31:0] D_Out;
    
    reg     [7:0] M [4095:0]; //4096x8 Memory
    
    wire [11:0] mem_addr;
    assign mem_addr = Address[11:0];
    
    //synchronous write
    always @ (posedge clk)
        //chip select and write must be asserted in order for memory to
        //be written to
        if(dm_cs & dm_wr)
                    {M[mem_addr], M[mem_addr+1],
         M[mem_addr+2], M[mem_addr+3]} <= D_In;
            //4 bytes get 32 bit data in
//            {M[Address[11:0]], M[Address[11:0]+1],
//            M[Address[11:0]+2], M[Address[11:0]+3]} <= D_In;
    
    //asynchronous read
    //chip select and read must be asserted in order to read contents of memory
    //4 bytes are read simultaneously
    assign D_Out = (dm_cs & dm_rd) ?
                    {M[mem_addr  ], M[mem_addr+1],
                     M[mem_addr+2], M[mem_addr+3]} : 32'hz;
 //                  {M[Address[11:0]], M[Address[11:0]+1],
 //                   M[Address[11:0]+2], M[Address[11:0]+3]} : 32'hz;
    
endmodule
