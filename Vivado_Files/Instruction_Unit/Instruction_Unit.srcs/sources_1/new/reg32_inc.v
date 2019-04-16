`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano and Rosswell Tiongco
 * Filename: reg32.v
 * Date:     3/5/2019
 * Version:  1.0
 * 
 * Notes:    Structural implementation of a 32-bit register with an increment
 *           and load signal. Output Q increases by 4 only when the inc signal
 *           is asserted. Out Q changes to the input of D only when the load 
 *           signal is asserted. All other combinations of inputs results in
 *           Q staying the same.
 *          
 *******************************************************************************/
module reg32_inc(clk, reset, ld, inc, D, Q);
    input             clk, reset, ld, inc;
    input      [31:0] D;
    
    output reg [31:0] Q;
    
    always @(posedge clk, posedge reset)
        if(reset)
            Q <= 32'h0;
        else
            case({ld, inc})//output only changes based on ld and inc inputs
                2'b0_1 : Q <= Q + 4;//inc
                2'b1_0 : Q <= D;    //load
                default: Q <= Q;
            endcase
    
endmodule
