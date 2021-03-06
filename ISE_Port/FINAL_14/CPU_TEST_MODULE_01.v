`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: CPU_TEST_MODULE_01.v
 * Date:     4/1/2019
 * Version:  1.0
 * 
 * Notes:    Testbench file for testing iM and dM module #1
 *
 *******************************************************************************/

module CPU_TEST_MODULE_01;

	// Inputs
	reg clk;
	reg reset;
	wire intr;
	wire [31:0] dm_out;
	wire [31:0] io_out;

	// Outputs
	wire inta;
	wire dm_cs;
	wire dm_wr;
	wire dm_rd;
	wire [31:0] dm_address;
	wire [31:0] dm_d_in;
	wire io_rd;
	wire io_wr;
	wire io_cs;
	
	integer i;

	// Instantiate the Unit Under Test (UUT)
	MIPS_CPU CPU(.clk(clk), .reset(reset), .intr(intr), .inta(inta), 
                 .dm_cs(dm_cs), .dm_rd(dm_rd), .dm_wr(dm_wr), .dm_address(dm_address),
                 .dm_d_in(dm_d_in), .dm_out(dm_out), .io_rd(io_rd), .io_out(io_out),
                 .io_wr(io_wr), .io_cs(io_cs) );
    Memory  dMem(.clk(clk), .cs(dm_cs), .rd(dm_rd), .wr(dm_wr), .Address(dm_address),
                .D_In(dm_d_in), .D_Out(dm_out) );
    IO    io_mod(.clk(clk), .intr(intr), .inta(inta), .io_address(dm_address),
                 .io_d_in(dm_d_in), .io_out(io_out), .io_rd(io_rd), .io_wr(io_wr), 
                 .io_cs(io_cs) );

	always #5 clk = ~clk;
    
    initial 
      begin
        //Display time in nanoseconds
        $timeformat(-9, 1, " ps", 9);
        
        //initialize iMem
		  $display("readmemh imem");
        $readmemh("iM_01.mem", CPU.Instruction_Unit.IM.M);
        //initialize dMem
		  $display("readmemh dmem");
        $readmemh("dM_01.mem", CPU_TEST_MODULE_01.dMem.M);
        
		  $display("finished readmemh's");
        clk = 0;
        reset = 0;
        @(negedge clk)
        reset = 1;
        @(negedge clk)
        reset = 0;
        
        for(i = 0; i < 10000; i=i+1)
            @(negedge clk);
        
        $display("ERROR: REACHED END OF TESTBENCH LOOP");
        //Dump Registers and Memory if there is an error
        CPU.Control_Unit.Dump_Reg;
        CPU.Control_Unit.Dump_dMem;
        
      end
      
endmodule
