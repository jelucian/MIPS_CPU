`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano
 * Filename: MPY_32.v
 * Date:     1/22/2019
 * Version:  1.0
 * 
 * Notes:    ALU module that multiples its 2 32-bit inputs and yields a single 
 *           64-bit output.
 *
 *******************************************************************************/

module MPY_32(S, T, Y_hi, Y_lo);
 
     //delcare inputs and outputs
     input      [31:0]  S, T;
     output reg [31:0]  Y_hi, Y_lo;
     
     //declare integers
     integer int_S, int_T;
     
     always @ (*) begin
        //type cast 32 bit inputs to integers
        int_S = S;
        int_T = T;
        //multiply integers to yield 64 bit result
        {Y_hi, Y_lo} = int_S * int_T;
     end
     
endmodule
