`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: CPU_EU_TB.v
 * Date:     3/5/2019
 * Version:  1.0
 * 
 * Notes:    Testbench that instantiates Instruction Unit, Integer Datapath and
 *           Data Memory and uses control words to guide data from instruction
 *           memory, to the register file, to data memory
 *
 *******************************************************************************/
module CPU_EU_TB();
    //instruction unit
    reg clk, reset, im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld;
    reg [31:0] PC_in;
    wire [31:0] PC_out, IR_out, SE_16;
    
    //IDP
    reg D_En, DA_sel, T_Sel, HILO_ld;
    reg [2:0] Y_Sel;
    wire C, V, N, Z;
    
    wire [31:0] IDP_ALU_OUT, IDP_D_OUT;
    
    //Memory
    reg dm_cs, dm_rd, dm_wr;
    wire [31:0] MEM_out;

    integer i;
    
    //Module Instantiation
    //Instruction Unit
    CPU_IU uut(.clk(clk), .reset(reset), .im_cs(im_cs), .im_wr(im_wr), 
               .im_rd(im_rd), .pc_ld(pc_ld), .pc_inc(pc_inc), .ir_ld(ir_ld),
               .PC_in(IDP_ALU_OUT), .PC_out(PC_out), .IR_out(IR_out),
               .SE_16(SE_16) );

    //Integer Datapath
    Integer_Datapath IDP(.clk(clk), .reset(reset), .S_Addr(IR_out[25:21]),
                         .FS(IR_out[31:27]), .HILO_ld(HILO_ld), .D_En(D_En),
                         .D_Addr(IR_out[15:11]), .T_Addr(IR_out[20:16]), 
                         .DT(SE_16), .T_Sel(T_Sel), .C(C), .V(V), .N(N), .Z(Z),
                         .DY(MEM_out), .PC_in(PC_out), .Y_Sel(Y_Sel), 
                         .ALU_OUT(IDP_ALU_OUT), .D_OUT(IDP_D_OUT),
                         .DA_sel(DA_sel) );
    //Data Memory 
    Memory Data_Memory(.clk(clk), .cs(dm_cs), .wr(dm_wr), .rd(dm_rd),
                       .Address(IDP_ALU_OUT), .D_In(IDP_D_OUT),
                       .D_Out(MEM_out) );
                        
    //10 ns clock                       
    always #5 clk = ~clk;
    
    initial begin
        $timeformat(-9, 1, " ps", 9);    //Display time in nanoseconds

    
        //assert and deassert reset
        clk = 0;
        reset = 0;
        @(negedge clk)
        reset = 1;
        @(negedge clk)
        reset = 0;
        
        //initialize memories
        $readmemh("IntReg_Lab5.mem", IDP.REG_FILE.reg32);
        $readmemh("dMem_Lab5.mem", Data_Memory.M);
        $readmemb("iMem_Lab5.mem", uut.IM.M);
        
        $display(" ");
        $display("R e g f i l e   I n i t i a l   C o n t e n t s ");
        $display(" ");
        Reg_Dump;
        
        //*******************************************************************/
        //a)$r1 <- $r3 | $r4 (logical)
        @(negedge clk)//IR<-iM[PC], PC <- PC+4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//RS <- $r3, RT <-$r4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//ALU_Out <- RS($r3) | RT($r4)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//$r1 <- ALU_Out(r3 | r4)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_1_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        //*******************************************************************/
        //b)$r2 <- $r1 - $r14
        @(negedge clk)//RTL
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//RS <- $r1, RT <- $r14
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//ALU_Out <- RS(r3) - RT(r14)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//$r14 <- ALU_Out(r1 | r14)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;   
        //*******************************************************************
        //c)$r3 <- SHR $r4
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//RT <- $r4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//ALU_Out <- RT(SHR r4)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//$r3 <- ALU_Out(SHR r4)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        //*******************************************************************/
        //d)$r4 <- SHL $r5
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//RT <- $r5
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//ALU_Out <- SHL RT(r5)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//$r4 <- ALU_Out(SHL r5)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        //*******************************************************************/
        //e){$r6, $r5} <- $r15 / $r14
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//RS <- $r15, RT <- $r14
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//LO <- RS(r15)/RT(r14), HI <- RS(r15)%RT(r14)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_1_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4 // gets $rd for $r8
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        @(negedge clk)//$r6 <- HI
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_100;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4 // gets $rd for $r7
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//$r5 <- LO
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_011;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        //*******************************************************************/
        //f){$r8, $r7} <- $r11 * 0xFFFFFFFB
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;   
        @(negedge clk)//RS <- $r11, RT <- DT(SE_16)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_1_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//HILO <- RS(r11)/RT(0xFFFFFFFB)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_1_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4 // gets $rd for $r8
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//$r8 <- HI
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_100;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4 // gets $rd for $r7
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//$r7 <- LO
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_011;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        //*******************************************************************/
        //g)$r12 <- M[$r15 + 0]
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//RS <- $r15, RT <- IR[15:0]
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_1_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        @(negedge clk)//ALU_Out <- RS($r15) + RT(IR[15:0])
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//D_in <- M[r15 + IR[15:0]]
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b1_1_0;    
        @(negedge clk)//$r12 <- D_in
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_1_0_0_001;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        //*******************************************************************/
        //h)$r11 <- $r0 NOR $r11
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//RS <- $r0, RT <- $r11
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//ALU_Out <- RS(r0) | RT(r11)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;   
        @(negedge clk)//$r11 <- ALU_Out(r0 NOR r11)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        //*******************************************************************/
        //i)$r10 <- $r0 - $r10
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//RS <- $r0, RT <- $r10
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//ALU_Out <- RS($r0) - RT(r10)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        @(negedge clk)//$r10 <- ALU_Out($r0 - r10)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        //*******************************************************************/
        //j)$r9 <- $r10 + $r11
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        @(negedge clk)//RS <- $r10, RT <- $r11
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//ALU_Out <- RS(r10) + RT(r11)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        @(negedge clk)//$r9 <- ALU_Out(r10 + r11)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b1_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;        
        //*******************************************************************/
        //k)M[$r14 + 0] <- $r12
        @(negedge clk)//IR <- iM[PC], PC <- PC + 4
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_1_1_1_1_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//RS <- $r14, RT <- IR[15:0]
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_1_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;    
        @(negedge clk)//ALU_Out <- RT(r14 + IR[15:0]), RT <- $r12
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        @(negedge clk)//M[$r14+0] <- ALU_Out(r12)
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_010;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b1_0_1; 
        @(negedge clk);//Final clock to finish final instruction    
        
        $display(" ");
        $display("R e g f i l e   F i n a l   C o n t e n t s");
        Reg_Dump;
        
        $display(" ");
        $display("d M e m o r y   F i n a l   C o n t e n t s");
        dMem_Dump;
        $finish;
    
                
    end
    task dMem_Dump();
    begin
            #10
            $display("Time = %t | dMem [%h] = %h %h %h %h", $time, 12'hff8,
            Data_Memory.M[12'hff8],Data_Memory.M[12'hff9],
            Data_Memory.M[12'hffa],Data_Memory.M[12'hffb]);
    end
    endtask
    
    task Reg_Dump();//display contents of register file   
    begin
        for(i = 0; i < 16; i = i + 1)
        begin
            #10
            $display("Time = %t | Register [%h] = %h",
                      $time,i[3:0],IDP.REG_FILE.reg32[i]);
        end
    end
    endtask
 

endmodule
