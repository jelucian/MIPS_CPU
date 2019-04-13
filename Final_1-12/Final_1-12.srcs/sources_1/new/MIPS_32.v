`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano
 * Filename: MIPS_32.v
 * Date:     1/22/2019
 * Version:  1.0
 * 
 * Notes:    This module does all operations except multiply and divide
 *           Y_lo is a function of the 2 32-bit inputs and FS
 *           Y_hi is set to all zeros for this module
 *           Status flags are set appropriately based on FS, inputs and outputs
 *           Status flags are set to 'x' if not affected by operation
 *
 *******************************************************************************/
module MIPS_32(S, T, FS, V, C, Y_hi, Y_lo);
 
     //delcare inputs
     input  [31:0]  S, T;
     input  [ 4:0] FS;
     
     //delcare outputs
     //only overflow and carry flag are computer in this module
     output reg           V,    C;
     output reg [31:0] Y_hi, Y_lo;
     
     //integer declaration for slt
     integer intS, intT;
     
     //declare parameters for instructions
     parameter PASS_S = 5'h00, PASS_T = 5'h01, ADD = 5'h02,
               ADDU= 5'h03, SUB  = 5'h04, SUBU = 5'h05,
               SLT = 5'h06, SLTU = 5'h07, AND  = 5'h08,
               OR  = 5'h09, XOR  = 5'h0A, NOR  = 5'h0B,
               SRL = 5'h0C, SRA  = 5'h0D, SLL  = 5'h0E,
               ANDI= 5'h16, ORI  = 5'h17, LUI  = 5'h18,
               XORI= 5'h19, INC  = 5'h0F, INC4 = 5'h10,
               DEC = 5'h11, DEC4 = 5'h12, ZEROS= 5'h13,
               ONES= 5'h14, SP_INIT = 5'h15;
          
     always @ (*)  // S T FS - verilog will interperet as unsigned
        case(FS)
            //arithmetic
            PASS_S : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, S};
            PASS_T : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, T};
           
            ADD    : begin//signed
                        Y_hi = 32'b0; {C, Y_lo} = S + T;
                        V = (~S[31] & ~T[31] &  Y_lo[31]) |  // pos + pos = neg
                            ( S[31] &  T[31] & ~Y_lo[31]);   // neg + neg = pos
                     end
            ADDU   : begin //unsigned
                        Y_hi = 32'b0; {C, Y_lo} = S + T;
                        V = C;//overflow set to carry for unsigned arithmetic                   
                     end         
            SUB    : begin//signed
                        Y_hi = 32'b0; {C, Y_lo} = S - T;
                        V = (~S[31] &  T[31] &  Y_lo[31]) |  // pos - neg = neg
                            ( S[31] & ~T[31] & ~Y_lo[31]);   // neg - pos = pos                      
                     end
            SUBU   : begin //sub unsigned
                        Y_hi = 32'b0; {C, Y_lo} = S - T;
                        V = C;//overflow is the same as carry
                     end
            SLT    : begin//cast both inputs as integers to yield correct result
                        Y_hi = 32'b0; {V,    C} = 2'bx;
                        intS = S; intT = T;
                        Y_lo = (intS < intT) ? 32'h1 : 32'h0;
                     end
            SLTU   : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, (S < T) ? 32'h1 : 32'h0};
            
            //logical
            AND    : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0,  S & T };
            OR     : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0,  S | T };
            XOR    : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0,  S ^ T };
            NOR    : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0,~(S | T)};
            SRL    : {V, C, Y_hi, Y_lo} = {1'bx, T[0] , 32'h0,  1'b0,  T[31:1]};
            SRA    : {V, C, Y_hi, Y_lo} = {1'bx, T[0] , 32'h0,  T[31], T[31:1]};
            SLL    : {V, C, Y_hi, Y_lo} = {1'bx, T[31], 32'h0,  T[30:0], 1'b0 };
            ANDI   : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, S & {16'h0, T[15:0]}  };
            ORI    : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, S | {16'h0, T[15:0]}  };
            LUI    : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, T[15:0], 16'h0};
            XORI   : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, S ^ {16'h0, T[15:0]}  };
            
            //other
            INC    : begin
                        Y_hi = 32'b0; {C, Y_lo} = S + 1;
                        V = ~S[31] & Y_lo[31];//pos+1=neg
                     end
            INC4   : begin
                        Y_hi = 32'b0; {C, Y_lo} = S + 4;
                        V = ~S[31] & Y_lo[31];//pos+4=neg                
                     end
            DEC    : begin
                        Y_hi = 32'b0; {C, Y_lo} = S - 1;
                        V =  S[31] &~Y_lo[31];//neg-1=pos
                     end
            DEC4   : begin
                        Y_hi = 32'b0; {C, Y_lo} = S - 4;
                        V =  S[31] &~Y_lo[31];//neg-1=pos
                     end
            ZEROS  : {V, C, Y_hi, Y_lo} = {2'bx, 64'h0};
            ONES   : {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, 32'hFFFFFFFF};
            SP_INIT: {V, C, Y_hi, Y_lo} = {2'bx, 32'h0, 32'h3FC};
            default: {V, C, Y_hi, Y_lo} = {66'h0};//set to all zeros for error
        endcase
            
endmodule