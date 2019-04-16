`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano
 * Filename: alu_32.v
 * Date:     1/22/2019
 * Version:  1.0
 * 
 * Notes:1.0 Arithmetic Logic Unit with two 32-bit inputs and a 5-bit function 
 *           select input which selects between 28 operations to output to its
 *           2 32-bit outputs as well as 4 status flags, (C) Carry, (V) Overflow
 *           (N) Negative, and (Z) Zero.
 *       1.1 Added shift amount input, shamt, as well as instantiating shift 
 *           module to handle shifts
 *
 *******************************************************************************/
module alu_32(S, T, FS, C, V, N, Z, Y_hi, Y_lo, shamt);

    //delcare inputs
    input  [31:0]  S, T;
    input  [ 4:0] FS, shamt;
    
    //delcare outputs
    output [31:0] Y_hi, Y_lo;
    output        N, Z, V, C;
    
    //wires for outputs of MIPS_32, MPY_32 and DIV_32 ALUs
    wire [31:0] main_Y_hi, main_Y_lo,
                 div_Y_hi,  div_Y_lo,
                 mpy_Y_hi,  mpy_Y_lo,
                shft_Y_hi, shft_Y_lo;
    //flag outputs of MIPS_32            
    wire        main_V,    main_C,
                shft_V,    shft_C;
    
    //main alu instantiation with explicit port mapping
    MIPS_32 main_alu(.S(S), .T(T), .FS(FS), .V(main_V), .C(main_C),
                     .Y_hi(main_Y_hi),      .Y_lo(main_Y_lo) );
                    
    //division module instantiated with explicit port mapping
    //module yields 32 bit quotient and 32 bit remainder
    DIV_32   div_alu(.S(S), .T(T), .Y_hi(div_Y_hi), .Y_lo(div_Y_lo) );
    
    //multiplication module instantiated with explicit port mapping
    //module yields 64 bit output
    MPY_32   mpy_alu(.S(S), .T(T), .Y_hi(mpy_Y_hi), .Y_lo(mpy_Y_lo) );
    
    SHIFT  shift_alu(.T(T), .FS(FS), .shamt(shamt), .V(shft_V), .C(shft_C),
                     .Y_hi(shft_Y_hi), .Y_lo(shft_Y_lo) );

    //4to1 mux for Y_hi and Y_lo outputs  
    assign {Y_hi,Y_lo} = (FS == 5'h1E) ? { mpy_Y_hi,  mpy_Y_lo} :
                         (FS == 5'h1F) ? { div_Y_hi,  div_Y_lo} :
                         (FS == 5'h0C  |
                          FS == 5'h0D  |
                          FS == 5'h0E) ? {shft_Y_hi, shft_Y_lo} :
                                         {main_Y_hi, main_Y_lo} ;
                                          
    //all status flags controlled by 3to1 mux
                        //multiplication
    assign {C,V,N,Z} = (FS == 5'h1E) ? {2'bx, Y_hi[31], ({Y_hi, Y_lo} == 64'h0)} :
                        //division, flags determined by quotient only
                       (FS == 5'h1F) ? {2'bx, Y_lo[31], (      {Y_lo} == 32'h0)} :
                       //negative flag always zero for unsigned cases
                       //addu
                       (FS == 5'h03) ? {main_C, main_V,    1'b0,(Y_lo == 32'h0)} :
                       //subu
                       (FS == 5'h05) ? {main_C, main_V,    1'b0,(Y_lo == 32'h0)} :
                       //shift cases
                       (FS == 5'h0C  |
                        FS == 5'h0D  |
                        FS == 5'h0E) ? {shft_C, shft_V, Y_lo[31],(Y_lo == 32'h0)}: 
                        //all other cases                                            
                                       {main_C, main_V, Y_lo[31],(Y_lo == 32'h0)};
    
 
endmodule