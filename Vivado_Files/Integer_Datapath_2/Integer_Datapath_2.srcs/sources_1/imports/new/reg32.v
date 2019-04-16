`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano and Rosswell Tiongco
 * Filename: reg32.v
 * Date:     2/14/2019
 * Version:  1.0
 * 
 * Notes:    Structural implementation of a 32-bit register
 *           Output Q changes only on the rising edge of a clock and if the
 *           load input is asserted, otherwise it stays the same
 *
 *******************************************************************************/
module reg32(clk, reset, ld, D, Q);
    input             clk, reset, ld;
    input      [31:0] D;
    
    output reg [31:0] Q;
    
    always @(posedge clk, posedge reset)
        if(reset)
            Q <= 32'h0;
        else
            //output changes only is ld is asserted
            if(ld)
                Q <= D;
            else
                Q <= Q;
    
endmodule
