`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano and Rosswell Tiongco
 * Filename: regfile32.v
 * Date:     1/28/2019
 * Version:  1.0
 * 
 * Notes:    Register file contains 32 registers, each 32 bits wide
 *           reset sets $r0 to zero, which cannot be overwritten
 *           Module contains 2 32-bit outputs, S and T, which output the 
 *           contents of the register specified by S_Addr and T_Addr
 *           D_Addr specifies the register to overwrite with input data 
 *           specified by D
 *
 *******************************************************************************/
module regfile32(clk, reset, S, T, D, S_Addr, T_Addr, D_Addr, D_En);
   
    input         clk, reset, D_En;
    input   [4:0] S_Addr, T_Addr, D_Addr;
    input  [31:0] D;
    
    output [31:0] S, T;
    
    //create 2 dimensional array of 32 registers each 32 bits wide
    reg    [31:0] reg32 [0:31];
    
    //read uses 2 cts assign statements, asynchronous   
    assign S = reg32[S_Addr];
    assign T = reg32[T_Addr];
    
    //write behavioral, sensitive to clk and reset, synchronous    
    always @ (posedge clk, posedge reset) begin
        if(reset)//assign register $r0 to zero, all others are uninitialized
            reg32[0] <= 32'h0;
        else begin
            //only write if write enable is active and address is not zero
            if(D_En == 1'b1 && D_Addr > 5'b0)
                reg32[D_Addr] <= D;
            else
                reg32[D_Addr] <= reg32[D_Addr];

        end
    end
    
endmodule
