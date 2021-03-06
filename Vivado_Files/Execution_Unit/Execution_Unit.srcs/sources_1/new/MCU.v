`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: MCU.v
 * Date:     3/9/2019
 * Version:  1.0
 * 
 * Notes:    MIPS Control Unit is a Moore FSM that outputs all control signals
 *           to the Datapath, Instruction and Memory Modules
 *           Interrupt State
 *
 *       1.0 Module contains states for FETCH, RESET, DECODE, ADD, ORI, LUI, 
 *           SW, WB_alu, WB_imm, WB_mem, BREAK, ILLEGAL_OP, INTR_1, INTR_2
 *           INTR_3
 *
 *******************************************************************************
 *  Control Word Format
 *  @(negedge sys_clk)
 *  {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
 *  {im_cs, im_rd, im_wr} = 3'b0_0_0;
 *  {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
 *  {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
 *  {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
 *
 *******************************************************************************/
module MCU(sys_clk, reset, intr, c, n, z, v, IR, int_ack, pc_sel, pc_ld, pc_inc,
           ir_ld, im_cs, im_rd, im_wr, D_En, DA_sel, T_sel, HILO_ld, Y_sel,
           dm_cs, dm_rd, dm_wr, FS, S_Addr, T_Addr, D_Addr);
           
    input        sys_clk, reset, intr, c, n, z, v;
    input [31:0] IR;
    //control signals as outputs
    output reg       pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr, D_En, T_sel, 
                     HILO_ld, dm_cs, dm_rd, dm_wr, int_ack;
    output reg [1:0] pc_sel, DA_sel;
    output reg [2:0] Y_sel;
    output reg [4:0] FS, S_Addr, T_Addr, D_Addr;
    
    integer i;
    
    //state assignments
    parameter 
     RESET  = 00,  FETCH  = 01,  DECODE = 02,
     ADD    = 10,  ADDU   = 11,  AND    = 12, OR    = 13, NOR   = 14,
     ORI    = 20,  LUI    = 21,  LW     = 22, SW    = 23,
     WB_alu = 30,  WB_imm = 31,  WB_Din = 32, WB_hi = 22, WB_lo = 34, WB_mem = 35,
     INTR_1 = 501, INTR_2 = 502, INTR_3  = 503,
     BREAK  = 510, ILLEGAL_OP = 511;
     
    parameter    pass_s_ = 5'h00,   pass_t_  = 5'h01,   add_   = 5'h02,
                 addu_   = 5'h03,   sub_     = 5'h04,   subu_  = 5'h05,
                 slt_    = 5'h06,   sltu_    = 5'h07,   and_   = 5'h08,
                 or_     = 5'h09,   xor_     = 5'h0A,   nor_   = 5'h0B,
                 srl_    = 5'h0C,   sra_     = 5'h0D,   sll_   = 5'h0E,
                 andi_   = 5'h16,   ori_     = 5'h17,   lui_   = 5'h18,
                 xori_   = 5'h19,   inc_     = 5'h0F,   inc4_  = 5'h10,
                 dec_    = 5'h11,   dec4_    = 5'h12,   zeros_ = 5'h13,
                 ones_   = 5'h14,   sp_init_ = 5'h15,   no_op_ = 5'h00;
               
    //state register
    reg [8:0] state;
    
    //Control Unit Finite State Machine
    always @ (posedge sys_clk, posedge reset)
      if(reset)
          begin
            //reset state control word
            @(negedge sys_clk)
            {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
            {im_cs, im_rd, im_wr} = 3'b0_0_0;
            {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = no_op_;
            {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
            {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
            state = RESET;//next state is RESET state
          end
      else
        case(state)
          FETCH:
            if(int_ack == 0 & intr == 1)
              begin//new interrupt pending
                //control word to "deassert" everyting
                @(negedge sys_clk)
                {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                {im_cs, im_rd, im_wr} = 3'b0_0_0;
                {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
                {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
                state = INTR_1;
              end
            else
              begin//no pending interrupt
                if(int_ack == 1 & intr == 0) int_ack = 1'b0;
                //IR <- iM[PC]; PC <- PC + 4
                @(negedge sys_clk);
                {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_1_1; 
                {im_cs, im_rd, im_wr} = 3'b1_1_0;
                {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = no_op_;
                {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
                {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
                state = DECODE;
              end
            
          RESET:
            begin
                //PC <- 32'h0
                //$sp <- ALU_Out(3FC)
                //int_ack<-0
                @(negedge sys_clk)
                {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                {im_cs, im_rd, im_wr} = 3'b0_0_0;
                {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_11_0_0_010; FS = no_op_;
                {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
                {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
                state = FETCH;
                int_ack = 0;
            end
        
          DECODE:
            begin
                @(negedge sys_clk);
                if( IR[31:26] == 6'h00)//R-Type Instruction
                  begin//RS <- $rs; RT <- $rt
                    {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                    {im_cs, im_rd, im_wr} = 3'b0_0_0;
                    {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = no_op_;
                    {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
                    {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
                    case(IR[5:0])//function code
                      6'h0D  : state = BREAK; 
                      6'h20  : state = ADD;
                      default: state = ILLEGAL_OP;  
                    endcase
                  end//end of R-Type format
                else
                  begin//I or J type format
                    //RS <- $rs; RT <- DT(se_16)
                    {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                    {im_cs, im_rd, im_wr} = 3'b0_0_0;
                    {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_1_0_000; FS = no_op_;
                    {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
                    {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
                    case(IR[31:26])
                      6'h0D  : state = ORI;
                      6'h0F  : state = LUI;
                      6'h2B  : state =  SW;
                      default: state = ILLEGAL_OP;
                    endcase
                  end//end of I or J format
            end//end of DECODE
    
          ADD:
            begin
              //ALU_OUT <- RS($rs) + RT($rt)
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = WB_alu;
            end
        
          ORI:
            begin
              //ALU_OUT <- RS($rs) | {16'h0, RT[15:0]}
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = ori_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = WB_imm;
            end
            
          LUI:
            begin
              //ALU_OUT <- {RT[15:0], 16'h0}
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = lui_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = WB_imm;
            end
        
          SW:
            begin
              //ALU_OUT <- RS($rs) + RT(se_16), RT <- $rt
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = WB_mem;
            end
        
          WB_alu:
            begin
              //R[rd] <- ALU_OUT
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_00_0_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = FETCH;
            end
        
          WB_imm:
            begin
              //R[rt] <- ALU_OUT
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_01_0_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = FETCH;
            end
        
          WB_mem:
            begin
              //M[ ALU_OUT($rs + se_16) ] <- RT($rt)
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_0_1;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = FETCH;
            end
        
          BREAK:
            begin
              $display("BREAK INSTRUCTION FETCHED %t", $time);
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              $display(" ");
              Dump_Reg;
              $display(" ");
              $display("D a t a   M e m o r y   a f t e r   B r e a k");
              Dump_dMem;
              $display(" ");
              $finish;
            end
        
          ILLEGAL_OP:
            begin
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              Dump_Reg;
              //Dump_PC_and_IR;
            end
        
          INTR_1:
            begin
              //PC gets address of interrupt vector, PC saved in $ra
              //ALU_OUT <- 0x3FC, R[$ra] <- PC
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b1_10_0_0_000; FS = sp_init_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = INTR_2;
            end
        
          INTR_2:
            begin
              //Read Address of ISR into D_In
              //D_in <- dMem( [ALU_OUT(0x3FC)]
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_1_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = INTR_3;
            end
        
          INTR_3:
            begin
              //Relead PC with Address of ISR; ack the intr; goto FETCH
              //PC <- D_in( dMem[0x3FC] ), int_ack <- 1
              @(negedge sys_clk)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_001; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr} = { IR[26:21], IR[20:16], IR[15:11] };
              state = FETCH;
              int_ack = 1;
            end
        
        endcase//end of FSM

    //Dumps Contents of Register File
    task Dump_Reg;
    begin
        $display(" ");
        $display("D i s p l a y i n g   C o n t e n t s   o f   R e g f i l e");
        for(i = 0; i < 16; i = i + 1) 
        begin
            $display("R[%d] = %h",i[5:0], Integer_Datapath.REG_FILE.reg32[i]);
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
            Data_Memory.M[i+2], Data_Memory.M[i+3] ); 
        
    end
    endtask

endmodule
