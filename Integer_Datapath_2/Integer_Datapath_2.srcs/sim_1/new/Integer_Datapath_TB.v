`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: Integer_Datapath_TB.v
 * Date:     2/25/2019
 * Version:  1.0
 * 
 * Notes:    Testbench
 *
 *******************************************************************************/
module Integer_Datapath_TB();
    //IDP I/O
    reg         clk, reset, HILO_ld, D_En, T_Sel;
    reg   [2:0] Y_Sel;
    reg   [4:0] S_Addr, D_Addr, T_Addr, FS;
    reg  [31:0] DT, DY, PC_in;
    
    wire        C, V, N, Z;
    wire [31:0] ALU_OUT, IDP_D_OUT;
    
    //Memory I/O
    reg         dm_cs, dm_wr, dm_rd;
    
    wire [31:0] MEM_D_OUT;
    
    //integer for looping in Reg_Dump task
    integer i;

    //module Integer_Datapath(clk, reset, S_Addr, FS, HILO_ld, D_En, D_Addr, 
    //                        T_Addr, DT, T_Sel, C, V, N, Z, DY, PC_in, 
    //                        Y_Sel, ALU_OUT, D_OUT);

    Integer_Datapath dut(.clk(clk), .reset(reset), .S_Addr(S_Addr), .FS(FS),
                        .HILO_ld(HILO_ld), .D_En(D_En), .D_Addr(D_Addr),
                        .T_Addr(T_Addr), .DT(DT), .T_Sel(T_Sel), .C(C), .V(V),
                        .N(N), .Z(Z), .DY(MEM_D_OUT), .PC_in(PC_in), 
                        .Y_Sel(Y_Sel), .ALU_OUT(ALU_OUT), .D_OUT(IDP_D_OUT) );
    
    //module Data_Memory(clk, dm_cs, dm_wr, dm_rd, Address, D_In, D_Out);
                    
    Data_Memory dut_mem(.clk(clk), .dm_cs(dm_cs), .dm_wr(dm_wr), .dm_rd(dm_rd),
                        .Address(ALU_OUT), .D_In(IDP_D_OUT), .D_Out(MEM_D_OUT) );                   
    
    always #5 clk = ~clk;
    
    initial begin
        $timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds
        //initial clock and reset values
          clk = 1'b0;
        reset = 1'b0;
        
        //assert and deassert reset
        @(negedge clk)
            reset = 1'b1;
        @(negedge clk)
            reset = 1'b0;
       
       //load register file
       $readmemh("IntReg_Lab4.mem", dut.REG_FILE.reg32);
       //load
       $readmemh("dMem_Lab4.mem", dut_mem.M);
       
       $display(" ( 1 )  -  I n i t i a l   C o n t e n t s   o f   M e m o r y");
        Reg_Dump();
        
        @(negedge clk)
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;
            
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;
            
            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;
            
            
    end
    
    task Reg_Dump(); 
    begin
       for(i = 0; i < 16; i = i + 1) 
       begin
            @(negedge clk)
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = {11'b0_00000_00000, i};
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;
           
            //Integer Datapath Constants
             DT    = 32'hFFFF_FFFB;
             PC_in = 32'h1001_00C0;
           
            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;
            
            @(posedge clk)
            #1//wait one time unit to display changed values of registers
            $display("Time = %t | Register [%d] = %h", $time, i, dut.REG_FILE_T);
            
       end
    end
    endtask
    

endmodule
