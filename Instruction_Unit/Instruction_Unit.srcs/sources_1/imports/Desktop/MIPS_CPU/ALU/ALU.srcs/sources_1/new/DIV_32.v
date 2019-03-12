`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano and Rosswell Tiongco
 * Filename: DIV_32.v
 * Date:     1/22/2019
 * Version:  1.0
 * 
 * Notes:    ALU module that outputs the quotient and remainder of its two 
 *           inputs as 2 32 bit outputs
 *
 *******************************************************************************/

module DIV_32(S, T, Y_hi, Y_lo);
 
     //delcare inputs and outputs
     input      [31:0]  S, T;
     output reg [31:0] Y_hi, Y_lo;
     
     //delacre integers
     integer int_S, int_T;
     
     always @(*) begin
        //cast inputs as integers to allow for division calculation
        int_S = S;
        int_T = T;
        //high 32 bits are set to remainder
        Y_hi = int_S % int_T;
        //low  32 bits are set to quotient
        Y_lo = int_S / int_T;
     end
     
endmodule