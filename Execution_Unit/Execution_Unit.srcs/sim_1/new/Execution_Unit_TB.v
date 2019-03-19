`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: Execution_Unit_TB.v
 * Date:     3/9/2019
 * Version:  1.0
 * 
 * Notes:    Module Instantiates Control Unit, Instruction Unit, Datapath, and
 *           Data Memory, and provides a system clock and lets the control unit
 *           read instruction and data memory to execute instructions
 *
 *
 *******************************************************************************/
module Execution_Unit_TB();
    //inputs
    reg clk, reset, intr;
    
    //IDP wires
    wire        c, n, z, v, HILO_ld, D_En, T_Sel;
    wire [ 1:0] DA_Sel;
    wire [ 2:0] Y_Sel;    
    wire [ 4:0] FS;
    wire [31:0] ALU_OUT, IDP_D_OUT;
    
    //IU wires
    wire        im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld;
    wire [ 1:0] pc_sel;
    wire [31:0] IR_out, PC_out, SE_16;
    
    //Data Memory wires
    wire        dm_cs, dm_wr, dm_rd;
    wire [31:0] dM_out;
    
    //Control Unit outputs
    wire        int_ack;
    
    //task variable
    integer i;
    
    //Module Instantiations
    MCU Control_Unit(.sys_clk(clk), .reset(reset), .intr(intr), .c(c), .n(n),
    .z(z), .v(v), .IR(IR_out), .int_ack(int_ack), .pc_sel(pc_sel), .pc_ld(pc_ld),
    .pc_inc(pc_inc), .ir_ld(ir_ld), .im_cs(im_cs), .im_rd(im_rd), .im_wr(im_wr),
    .D_En(D_En), .DA_sel(DA_Sel), .T_sel(T_Sel), .HILO_ld(HILO_ld), 
    .Y_sel(Y_Sel), .dm_cs(dm_cs), .dm_rd(dm_rd), .dm_wr(dm_wr), .FS(FS) );
    
    CPU_IU Instruction_Unit(.clk(clk), .reset(reset), .im_cs(im_cs), 
    .im_wr(im_wr), .im_rd(im_rd), .pc_ld(pc_ld), .pc_inc(pc_inc), 
    .ir_ld(ir_ld), .PC_in(ALU_OUT), .PC_out(PC_out), .IR_out(IR_out),
    .SE_16(SE_16), .pc_sel(pc_sel) );
    
    Integer_Datapath IDP(.clk(clk), .reset(reset), .S_Addr(IR_out[25:21]), .FS(FS), 
    .HILO_ld(HILO_ld), .D_En(D_En), .D_Addr(IR_out[15:11]), .T_Addr(IR_out[20:16]), .DT(SE_16), 
    .T_Sel(T_Sel), .C(c), .V(v), .N(n), .Z(z), .DY(dM_out), .PC_in(PC_out), 
    .Y_Sel(Y_Sel), .ALU_OUT(ALU_OUT), .D_OUT(IDP_D_OUT), .DA_Sel(DA_Sel) );
    
    Memory Data_Memory(.clk(clk), .cs(dm_cs), .wr(dm_wr), .rd(dm_rd), 
    .Address(ALU_OUT), .D_In(IDP_D_OUT), .D_Out(dM_out) );
    
    //establish clock signal
    always #5 clk = ~clk;
    
    initial 
    begin
        //Display time in nanoseconds
        $timeformat(-9, 1, " ps", 9);   
        clk = 0;
        reset = 0;
        intr = 0;
  
        
        //initialize Data and Instruction Memory
        $readmemh("dMem_Lab6.mem", Data_Memory.M);
        $readmemh("iMem_Lab6.mem", Instruction_Unit.IM.M);
        
        @(negedge clk);
        reset = 1;
        @(negedge clk);
        reset = 0;
        
        for(i = 0; i < 200; i = i + 1)
        begin
            @(negedge clk);
            //$display("T = %t | IR_out: %h", $time, Instruction_Unit.IR_out);
        end
        Dump_Reg;
        Dump_dMem;
        $finish;
        //@(negedge clk);
        //Dump_Reg;
        //Dump_dMem;
        
    end
    
    //Dumps Contents of Register File
    task Dump_Reg;
    begin
        $display(" ");
        $display("D i s p l a y i n g   C o n t e n t s   o f   R e g f i l e");
        for(i = 0; i < 16; i = i + 1) 
        begin
            $display("R[%d] = %h",i[5:0], IDP.REG_FILE.reg32[i]);
        end
    end
    endtask
    //Display Memory Contents - 0x3FC
    task Dump_dMem;
    begin
        i = 32'h3F0;
        $display(" ");
        $display("dMem[%h] = 0x%h%h%h%h",i[11:0],
            Data_Memory.M[i  ], Data_Memory.M[i+1], 
            Data_Memory.M[i+2], Data_Memory.M[i+3]); 
        
    end
    endtask
  
endmodule
