`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: CPU_EU_TB.v
 * Date:     3/5/2019
 * Version:  1.0
 * 
 * Notes:    
 *
 *
 *
 *
 *******************************************************************************/
module CPU_EU_TB();
    //instruction unit
    reg clk, reset, im_cs, im_wr, im_rd, pc_ld, pc_inc, ir_ld;
    reg [31:0] PC_in;
    wire [31:0] PC_out, IR_out, SE_16;
    
    //IDP
    reg D_En, DA_sel, T_Sel, HILO_ld, Y_Sel;
    wire C, V, N, Z;
    
    wire [31:0] IDP_ALU_OUT, IDP_D_OUT;
    
    //Memory
    reg dm_cs, dm_rd, dm_wr;
    wire [31:0] MEM_out;

    //Module Instantiation
    //Instruction Unit
    CPU_IU uut(.clk(clk), .reset(reset), .im_cs(im_cs), .im_wr(im_wr), 
               .im_wr(im_wr), .pc_ld(pc_ld), .pc_inc(pc_inc), .ir_ld(ir_ld),
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
        
        //Control word default to zeros
        
        @(negedge clk)//RTL
        //Instruction Unit Control
            {pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr} = 6'b0_0_0_0_0_0;
        
        //Datapath Control
            {D_En, DA_sel, T_Sel, HILO_ld, Y_Sel} = 7'b0_0_0_0_000;
        
        //Data Memory Control
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
        
        
    end
    task Reg_Dump(); 
    begin
        
    end
    endtask
 

endmodule
