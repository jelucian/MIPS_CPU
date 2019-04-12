`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: MIPS_CPU_TB01.v
 * Date:     4/1/2019
 * Version:  1.0
 * 
 * Notes:    Test instantiates iMem and dMem with memory modules 01 and steps
 *           through the instructions
 *
 *******************************************************************************/ 
module MIPS_CPU_TB01();
    //inputs
    reg clk, reset, intr;
    //outputs
    wire inta;
    //vairable for looping
    integer i;
    
    MIPS_CPU main(.clk(clk), .reset(reset), .intr(intr), .inta(inta) );
    
    always #5 clk = ~clk;
    
    initial begin
        //Display time in nanoseconds
        $timeformat(-9, 1, " ps", 9);
        //initialize iMem
        $readmemh("iM_01.mem", main.Instruction_Unit.IM.M);
        //initialize dMem
        $readmemh("dM_01.mem", main.Data_Memory.M);
        
        clk = 0;
        reset = 0;
        @(negedge clk)
        reset = 1;
        @(negedge clk)
        reset = 0;
        
        for(i = 0; i < 10000; i=i+1)
            @(negedge clk);
        
        $display("ERROR: REACHED END OF TESTBENCH LOOP");
        
//module MIPS_CPU(clk, reset, intr, inta);
    end
endmodule
