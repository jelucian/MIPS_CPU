`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: Memory.v
 * Date:     2/25/2019
 * Version:  1.0
 * 
 * Notes:    4096x8 Byte Addressable Memory
 *
 *******************************************************************************/
module Memory(clk, cs, wr, rd, Address, D_In, D_Out);
    
    input         clk, cs, wr, rd;
    input  [31:0] Address, D_In;
    
    output [31:0] D_Out;
    
    reg     [7:0] M [4095:0]; //4096x8 Memory
    
    wire [11:0] mem_addr;
    //use only 12 least significant bits of input
    assign mem_addr = Address[11:0];
    
    //synchronous write
    always @ (posedge clk)
        //chip select and write must be asserted in order for memory to
        //be written to
        if(cs & wr)
                    {M[mem_addr], M[mem_addr+1],
         M[mem_addr+2], M[mem_addr+3]} <= D_In;

    
    //asynchronous read
    //chip select and read must be asserted in order to read contents of memory
    //4 bytes are read simultaneously
    assign D_Out = (cs & rd) ?
                    {M[mem_addr  ], M[mem_addr+1],
                     M[mem_addr+2], M[mem_addr+3]} : 32'hz;

    
endmodule
