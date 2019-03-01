`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano
 * Filename: Integer_Datapath_TB.v
 * Date:     2/7/2019
 * Version:  1.0
 * 
 * Notes:    Testbench verifies the operation of the Integer_Datapath module
 *           by setting values in the register file and sequencing through a
 *           series of microinstructions that modify data in the register file
 *
 *******************************************************************************/
module Integer_Datapath_TB();
 
   reg clk, reset, HILO_ld, D_En, T_Sel;
   reg [2:0] Y_Sel;
   reg [4:0] S_Addr, FS, D_Addr, T_Addr;
   reg [31:0] DT, DY, PC_in;
   
   wire C, V, N, Z;
   wire [31:0] ALU_OUT;
   wire [31:0] D_OUT;
   
   integer i;

   //module Integer_Datapath(clk, reset, S_Addr, FS, HILO_ld, D_En, D_Addr, 
                           //T_Addr, DT, T_Sel, C, V, N, Z, DY, PC_in, Y_Sel, 
                           //ALU_OUT, D_OUT);
    Integer_Datapath dut(.clk(clk), .reset(reset), .S_Addr(S_Addr), .FS(FS), 
                         .HILO_ld(HILO_ld), .D_En(D_En), .D_Addr(D_Addr),
                         .T_Addr(T_Addr), .DT(DT), .T_Sel(T_Sel), 
                         .C(C), .V(V), .N(N), .Z(Z), .DY(DY), .PC_in(PC_in), 
                         .Y_Sel(Y_Sel), .ALU_OUT(ALU_OUT), .D_OUT(D_OUT));
    //10 ns clock                  
    always #5 clk = ~clk;
    
    initial begin
        $timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds
        clk = 0;
        reset = 1'b0;
        
        //initialize register file with contents of memory file
        $readmemh("IntReg_Lab3.mem", dut.REG_FILE.reg32);
       
       
        
        //assert and deassert reset
        @(negedge clk)
        reset = 1'b1;
        @(negedge clk)
        reset = 1'b0;
        
        //IDP Constants
        DT    = 32'hFFFF_FFFB;
        DY    = 32'hABCD_EF01;
        PC_in = 32'h1001_00C0;
        
        $display(" ");
        $display(" ( 1 ) - I n i t i a l  C o n t e n t s  o f  M e m o r y");
        $display(" ");
        Reg_Dump;
        
        //D_En  : 1=reg32 write : 0 = reg32 don't write
        //T_Sel : 1=REG_FILE_T  : 0 = DT
        //Y_Sel  
        // 000 : PC_in
        // 001 : DY
        // 010 : Y_lo
        // 011 : LO
        // 100 : HI
        
        
        //a
        @(negedge clk); // $r1 <- $r3 | $r4
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00001_00011_00100;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_01001_0_010;
            
            //IDP Constants
            DT    = 32'hFFFF_FFFB;
            DY    = 32'hABCD_EF01;
            PC_in = 32'h1001_00C0;
        //b
        @(negedge clk); // $r2 <- $r1 - $r14
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00010_00001_01110;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00100_0_010;
            //IDP Constants
            DT    = 32'hFFFF_FFFB;
            DY    = 32'hABCD_EF01;
            PC_in = 32'h1001_00C0;
            
        //c
        @(negedge clk); // $r3 <- shr $r4
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00011_00000_00100;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_01100_0_010;
            //IDP Constants
            DT    = 32'hFFFF_FFFB;
            DY    = 32'hABCD_EF01;
            PC_in = 32'h1001_00C0;    
                
        //d            
        @(negedge clk); // $r4 <- shl $r5
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00100_00000_00101;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_01110_0_010;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //e {r6, r5 } <- r15 / r14
        //e1    
        @(negedge clk); // {HI, LO} <- r15 / r14
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_01111_01110;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_11111_1_000;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //e2    
        @(negedge clk); // r6 <- HI
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00110_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_100;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //e3          
        @(negedge clk); // r5 <- LO
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00101_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_011;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //f {r8, r7} <- r11 * 0xFFFF_FFFB
        //f1    
        @(negedge clk); // {HI, LO} <- r11 * DT
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_01011_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_11110_1_000;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //f2                     
        @(negedge clk); // r8 <- HI
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_100;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //f3            
        @(negedge clk); // r7 <- LO
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00111_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_011;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //g    
        @(negedge clk); // $r12 <- DY
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01100_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_001;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //h    
        @(negedge clk); // $r11 <- $r0 nor $r11
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01011_00000_01011;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_01011_0_010;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //i          
        @(negedge clk); // $r10 <- $r0 - $r10
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01010_00000_01010;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00100_0_010;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //j    
        @(negedge clk); // $r9 <- $r10 + $r11
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01001_01010_01011;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00010_0_010;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
        //k                     
        @(negedge clk); // $r13 <- PC_in
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01101_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;
             //IDP Constants
             DT    = 32'hFFFF_FFFB;
             DY    = 32'hABCD_EF01;
             PC_in = 32'h1001_00C0;
             
            @(negedge clk);
            $display(" (2) - F i n a l  C o n t e n t s  o f  M e m o r y ");
            $display(" ");
            Reg_Dump;
        
        $finish;
    end
    
    //show all contents of memory
    task Reg_Dump; 
        begin
            for(i = 0; i < 16; i = i + 1) begin
                //ALU_OUT gets reg32[0:15]
                @(negedge clk);
                {D_En, D_Addr,S_Addr, T_Addr} = {6'b0_00000, i[4:0], 5'b00000};
                //T not used, FS = PASS_S, no HILO load, Y_Sel chooses Y_lo
                {T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
                //IDP Constants
                DT    = 32'hFFFF_FFFB;
                DY    = 32'hABCD_EF01;
                PC_in = 32'h1001_00C0;
                @(posedge clk);
                #1 //wait 1 time unit after clock pulse to display results
                $display("Time: %t  | Register[%d] = %h", 
                                     $time, S_Addr, ALU_OUT);    
                end
            $display(" ");
        end
    endtask;    

endmodule
