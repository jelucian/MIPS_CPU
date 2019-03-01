`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano
 * Filename: regfile32_TB.v
 * Date:     2/5/2019
 * Version:  1.0
 * 
 * Notes:    Module contains 3 sections, 
 *           (1) - load register file with data from external file and regdump
 *           (2) - modify each register in register file
 *           (3) - regdump newly written contents of memory
 *
 *******************************************************************************/
module regfile32_TB();
    reg         clk, reset, D_En;
    reg  [ 4:0] S_Addr, T_Addr, D_Addr;
    reg  [31:0] D;
    
    wire [31:0] S, T;//output

    //module regfile32(clk, reset, S, T, D, S_Addr, T_Addr, D_Addr, D_En);
    regfile32 dut(.clk(clk), .reset(reset), .S(S), .T(T), .D(D),
                  .S_Addr(S_Addr), .T_Addr(T_Addr), .D_Addr(D_Addr),
                  .D_En(D_En) );
             
    //10 ns clock
    always #5 clk = ~clk;
    
    integer i;
    initial begin
        $timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds
        
        $display("*********************************************************");
        $display("**       CECS 440 - Lab 2 Register File Testbench      **");
        $display("*********************************************************");
        
        //set default values to all inputs and outputs
        //assert reset
        clk = 1'b0;
        reset = 1'b1;
        D_En = 1'b0;
        S_Addr = 5'b0;
        T_Addr = 5'b0;
        D_Addr = 5'b0;
        D = 32'h0;
        //wait 1 clock cycle to deassert reset
        @(negedge clk);
        reset = 1'b0;
        @(negedge clk);
        
        //read contents of memory file and load into register file registers
        $readmemh("IntReg_Lab2.mem", dut.reg32);
                
        $display(" ");
        $display(" ( 1 )   -   I n i t i a l   R e g d u m p    ");
        $display(" ");
        
        //display contents of all registers
        regdump;
       
        $display(" ");
        $display(" ( 2 )   -   W r i t i n g   t o   M e m o r y     ");
        
        //enable writing to regfile
        @(negedge clk)
            D_En = 1'b1;
         
        //write to all registers in reg file, $r0 should NOT change    
        for(i = 0; i < 32; i = i + 1) begin
            @(negedge clk);
            D_Addr = i;
            D = ((~i) << 8) + (-65536 * i) + i;
            
        end    
        
        
        //disable writing to regfile
        @(negedge clk)
                D_En = 1'b0;        
        
        $display(" ");
        $display(" ( 3 )   -   F i n a l   R e g d u m p      ");
        $display(" ");        
        
        //display all contents of memory with newly written values
        regdump;
        
        $finish;
    
    end
    
    /*  Task displays all contents of register file
     *  
     */
    task regdump;
         for(i = 0; i < 16; i = i + 1) begin
               //S displays registers 0-15
               //T displays registers 16-31
               @(negedge clk);            
               S_Addr = i;
               T_Addr = S_Addr + 16;
               
               //wait 1 time unit to display contents
               @(posedge clk);
               #1
               $display("Time: %t  | S_Addr = %d  S = %h  |  T_Addr = %d T = %h", 
                         $time, S_Addr, S, T_Addr, T);
           end
    endtask;
    
    
endmodule
