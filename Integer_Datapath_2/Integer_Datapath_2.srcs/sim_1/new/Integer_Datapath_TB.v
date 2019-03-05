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
                       .Address(ALU_OUT),.D_In(IDP_D_OUT), .D_Out(MEM_D_OUT) );

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
        //load memory
        $readmemh("dMem_Lab4.mem", dut_mem.M);

        $display(" ( 1 )  -  I n i t i a l  C o n t e n t s   o f   R e g i s t e r s");
        Reg_Dump();

        //Initial Values @ zero
        @(negedge clk)
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;

            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //************************************************************//
        //a) $r1 <- $r3 | $r4
        //RS <- R[$r3], RT <- R[$r4]
        @(negedge clk);
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00011_00100;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;

            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //ALU_OUT <- RS($r3) | RS($r4)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_01001_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r1] <- ALU_OUT(#r3|$r4)
        @(negedge clk); // $r3 <- shr $r4
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00001_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;
        //************************************************************//
        //b) $r2 <- $r1 - $r14
        //RS <- R[$r1], RT <- R[$r14]
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00001_01110;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //ALU_OUT <- RS($r1) - RT($r14)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00100_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r2] <- ALU_OUT($r1 - $r14)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00010_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //************************************************************//
        //c) $r3 <- shr $r4
        //RT <- R[$r4]
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00100;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //ALU_OUT <- shr RT($r4)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_01100_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r3] <- ALU_OUT(shr $r4)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00011_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //************************************************************//
        //d) $r4 <- shl $r5
        //RT <- R[$r5]
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00001_00101;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //ALU_OUT <- shl RT($r5)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_01110_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r4] <- ALU_OUT(shl $r5)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00100_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //************************************************************//
        //e) {$r6, $r5} <- $r15/$r14
        //RS <- R[$r15], RT <- R[$r14]
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_01111_01110;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //HI <- RS($r15) % RT($r14), LO <- RS($r15) / RT($r14)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_11111_1_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r6] <- HI
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00110_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_100;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r5] <- LO
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00101_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_011;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;



        //************************************************************//
        //f) {$r8, $r7} <- $r11*0xFFFF_FFFB
        //RS <- R[$r11], RT <- 0xFFFF_FFFB
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_01011_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //HI <- RS($r11) * RT(0xFFFF_FFFB), LO <- RS($r11) * RT(0xFFFF_FFFB)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_11110_1_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r8] <- HI
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_100;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r7] <- LO
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_00111_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_011;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //************************************************************//
        //g) $r12 <- M[r15]
        //RT <- R[$r15]
        @(negedge clk);
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_01111;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;

            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //ALU_OUT <- RT($r15)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00001_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //D_in <- DY
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b1_1_0;

        //R[$r12] <- D_in
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01100_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_001;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //************************************************************//
        //h) $r11 <- $r0 nor $r11
        //RS <- R[$r0], RT <- R[$r11]
        @(negedge clk);
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_01011;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;

            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //ALU_OUT <- RS($r0) nor RS($r11)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_01011_0_000;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

        //R[$r11] <- ALU_OUT(#r0nor$r11)
        @(negedge clk);
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01011_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;


    //************************************************************//
    //i) $r10 <- $r0 - $r10
    //RS <- R[$r0], RT <- R[$r10]
    @(negedge clk);
        //Integer Datapath Control
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_01010;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;

        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

    //ALU_OUT <- RS($r0) - RS($r10)
    @(negedge clk);
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00100_0_000;
        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

    //R[$r10] <- ALU_OUT($r0-$r10)
    @(negedge clk);
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01010_00000_00000;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

    //************************************************************//
    //j) $r9 <- $r10 + $r11
    //RS <- R[$r10], RT <- R[$r11]
    @(negedge clk);
        //Integer Datapath Control
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_01010_01011;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;

        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

    //ALU_OUT <- RS($r10) + RS($r11)
    @(negedge clk);
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00010_0_000;
        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

    //R[$r9] <- ALU_OUT($r10+$r11)
    @(negedge clk);
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01001_00000_00000;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_010;
        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;


    //************************************************************//
    //k) $r13 <- 0x1001_00C0
    //R[$r13] <- PC_in(0x1001_00C0)
    @(negedge clk);
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b1_01101_00000_00000;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;
        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;


    //************************************************************//
    //l) M[$r14] <- $r12
    //RT <- R[$r14]
    @(negedge clk);
        //Integer Datapath Control
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_01100;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b1_00000_0_000;

        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

    //ALU_OUT <- RT($r14); RT <-($r12)
    @(negedge clk);
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_01100;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00001_0_000;
        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;

    //M[ALU_OUT($r14)] <- RT($r12)
    @(negedge clk);
        { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
        { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00001_0_010;
        //Integer Datapath Constants
          DT    = 32'hFFFF_FFFB;
          PC_in = 32'h1001_00C0;

        //Data Memory Control
        { dm_cs, dm_rd, dm_wr } = 3'b1_0_1;

        @(negedge clk);
        $display(" (2) - F i n a l  C o n t e n t s  o f  M e m o r y ");
        $display(" ");
        Reg_Dump;
        $finish;



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

    task Mem_Dump();//Display all of memory
    begin
        for(i = 0; i < 4096; i = i + 4)//loop through all contents of memory
        begin
            @(negedge clk);
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_Sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;

            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;

             //Address = i;
            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b1_1_0;

            @(posedge clk);
            #1//wait 1 time unit to display contents
            $display("Memory Address: %h | Data: %h",i, MEM_D_OUT);

        end
    end
    endtask


endmodule
