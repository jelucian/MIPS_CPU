`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: MCU.v
 * Date:     3/9/2019
 * Version:  1.1
 * 
 * Notes:    MIPS Control Unit is a Moore FSM that outputs all control signals
 *           to the Datapath, Instruction and Memory Modules
 *           Interrupt State
 *
 *       1.0 Module contains states for FETCH, RESET, DECODE, ADD, ORI, LUI, 
 *           SW, WB_alu, WB_imm, WB_mem, BREAK, ILLEGAL_OP, INTR_1, INTR_2
 *           INTR_3
 *
 *       1.1 Module modified with more states.
 *
 *       1.2 Module now contains flags register. Each state updated flags
 *           with either same state or the flags input from the IDP's ALU
 *
 *       1.3 Module now executes all instructions other than enhanced
 *
 *       1.4 Added io control signal to control whether or not io memory is
 *           begin written/read and to control dataflow into the D_in register
 *           by selecting between io_out and dmem_out
 *
 *       1.5 Added IO module chip select signal, io_cs, and a stack control 
 *           signal that chooses the output of the regfile in the IDP
 *
 *       1.6 Expanded interrupt and return from interrupt states
 *
 *       1.7 Made the flags register an output, and also added a flags input
 *           for return from interrupt states 
 *
 *******************************************************************************
 *  Control Word Format
 *  @(negedge sys_clk)
 *  {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
 *  {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
 *  {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = 5'h0;
 *  {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
 *  {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
 *  state = next_state; {IE, N, Z, V, C} = {IE, N, Z, V, C};
 *
 *
 *******************************************************************************/
module MCU(sys_clk, reset, intr, c, n, z, v, IR, int_ack, pc_sel, pc_ld, pc_inc,
           ir_ld, im_cs, im_rd, im_wr, D_En, DA_sel, T_sel, HILO_ld, Y_sel,
           dm_cs, dm_rd, dm_wr, FS, S_Addr, T_Addr, D_Addr, shamt, io_rd, io_wr,
           io_cs, stack, flags_out, flags_in);
           
    input        sys_clk, reset, intr, c, n, z, v;
    input [31:0] IR;
    //control signals as outputs
    output reg       pc_ld, pc_inc, ir_ld, im_cs, im_rd, im_wr, D_En, 
                     HILO_ld, dm_cs, dm_rd, dm_wr, int_ack, io_cs, stack;
    output reg [1:0] pc_sel, DA_sel;
    output reg [2:0] Y_sel, T_sel;
    output reg [4:0] FS, S_Addr, T_Addr, D_Addr, shamt, flags_in;
    
    //using IO
    output reg io_rd, io_wr;
    
    //present state flags
    reg IE, N, Z, V, C;
    //flags output
    output wire [4:0] flags_out;
    
    //flags output is always equal to present state of flags
    assign flags_out = {IE, N, Z, V, C};
    
    integer i;
    
    //state assignments
    parameter 
     RESET = 00, FETCH = 01, DECODE= 02,
     ADD   = 10, ADDU  = 11, AND   = 12, DIV   = 13, JR_1  = 14, MFHI  = 15,
     MFLO  = 16, MULT  = 17, NOR   = 18, OR    = 19, SETIE = 20, SLL   = 21,
     SLT   = 22, SLTU  = 23, SRA   = 24, SRL   = 25, SUB   = 26, SUBU  = 27,
     XOR   = 28, ADDI  = 29, ANDI  = 30, BEQ_1 = 31, BLEZ_1= 32, BNE_1 = 33,
     LUI   = 34, LW_1  = 35, ORI   = 36, SLTI  = 37, SLTIU = 38, SW    = 39,
     XORI  = 40, J     = 41, JAL   = 42,INPUT_1= 43,OUTPUT_1=44, RETI_1= 45,
     WB_alu= 50, WB_imm= 51, WB_Din= 52, WB_hi = 53, WB_lo = 54, WB_mem= 55,
     JR_2  = 60, LW_2  = 61, WB_lw = 62, BEQ_2 = 63, BLEZ_2= 64, BNE_2 = 65,
     BGTZ_1= 66, BGTZ_2= 67, RETI_2= 68, RETI_3= 69, RETI_4= 70, RETI_5=71,
     RETI_6= 72, RETI_7= 73, RETI_8= 74,
     INPUT_2=80, WB_INPUT=81,OUTPUT_2=82,
     INTR_1=501, INTR_2=502, INTR_3=503, INTR_4=504, INTR_5=505, INTR_6=506,
     INTR_7=507, INTR_8=508,
     BREAK =510, ILLEGAL_OP = 511;
     
    parameter    pass_s_ = 5'h00,   pass_t_  = 5'h01,   add_   = 5'h02,
                 addu_   = 5'h03,   sub_     = 5'h04,   subu_  = 5'h05,
                 slt_    = 5'h06,   sltu_    = 5'h07,   and_   = 5'h08,
                 or_     = 5'h09,   xor_     = 5'h0A,   nor_   = 5'h0B,
                 srl_    = 5'h0C,   sra_     = 5'h0D,   sll_   = 5'h0E,
                 andi_   = 5'h16,   ori_     = 5'h17,   lui_   = 5'h18,
                 xori_   = 5'h19,   inc_     = 5'h0F,   inc4_  = 5'h10,
                 dec_    = 5'h11,   dec4_    = 5'h12,   zeros_ = 5'h13,
                 ones_   = 5'h14,   sp_init_ = 5'h15,   no_op_ = 5'h00,
                 div_    = 5'h1F,   mult_    = 5'h1E;
               
    //state register
    reg [8:0] state;
    
    //Control Unit Finite State Machine
    always @ (posedge sys_clk, posedge reset) begin
     if(reset)
        begin
          //reset state control word
          {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
          {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
          {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sp_init_;
          {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;  {io_cs, io_rd, io_wr} = 3'b0_0_0;
          {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
          state = RESET; {IE, N, Z, V, C} = {IE, N, Z, V, C};
        end
     else 
      begin
        @(negedge sys_clk);
        case(state)
          FETCH: begin
            //Dump_Reg;
            //Dump_dMem;
            //Dump_IO;
            if(int_ack == 0 & intr == 1)
              begin//new interrupt pending
                //control word to "deassert" everyting
                {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
                {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = 5'h0;
                {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
                state = INTR_1; {IE, N, Z, V, C} = {IE, N, Z, V, C}; 
                $display("T = %t | State = FETCH  | Next State = INTR_1 | PC = %h | IR = %h",
                         $time, CPU_IU.PC_out, CPU_IU.IR_out);
              end
            else
              begin//no pending interrupt
                if(int_ack == 1 & intr == 0) int_ack = 1'b0;
                //IR <- iM[PC]; PC <- PC + 4
                //@(negedge sys_clk)
                {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_1_1; 
                {im_cs, im_rd, im_wr} = 3'b1_1_0; stack = 1'b0;
                {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
                {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
                {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
                state = DECODE; {IE, N, Z, V, C} = {IE, N, Z, V, C};
                $display("T = %t | State = FETCH  | Next State = DECODE | PC = %h | IR = %h",
                         $time, CPU_IU.PC_out, CPU_IU.IR_out);
              end
          end
            
          RESET:
            begin
                //PC <- 32'h0, Reg($sp) <- ALU_Out(3FC), int_ack<-0, {IE, N, Z, V, C} <- 5'b0
                {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
                {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_11_000_0_010; FS = no_op_;
                {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
                {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
                state = FETCH; int_ack = 0; {IE, N, Z, V, C} = 5'h0;
                $display("T = %t | State = RESET  | Next State = FETCH  | PC = %h | IR = %h",
                         $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
        
          DECODE:
            begin
                //@(negedge sys_clk);
                if( IR[31:26] == 6'h00 || IR[31:26] == 6'h04 || IR[31:26] == 6'h05)
                //R-Type Instruction or BEQ or BNE
                  begin//RS <- $rs; RT <- $rt
                    {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                    {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
                    {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
                    {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
                    {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
                    if(IR[31:26] == 6'h04)//test for BEQ
                        state = BEQ_1;
                    else if(IR[31:26] == 6'h05)//test for BNE
                        state = BNE_1;
                    else//select based on function code
                      case(IR[5:0])//function code
                        6'h00  : state = SLL;
                        6'h02  : state = SRL;
                        6'h03  : state = SRA;
                        6'h08  : state = JR_1;
                        6'h0D  : state = BREAK;
                        6'h10  : state = MFHI;
                        6'h12  : state = MFLO;
                        6'h18  : state = MULT;
                        6'h1A  : state = DIV; 
                        6'h20  : state = ADD;
                        6'h21  : state = ADDU;
                        6'h22  : state = SUB;
                        6'h23  : state = SUBU;
                        6'h24  : state = AND;
                        6'h25  : state = OR;
                        6'h26  : state = XOR;
                        6'h27  : state = NOR;
                        6'h2A  : state = SLT;
                        6'h2B  : state = SLTU;
                        6'h1F  : state = SETIE;
                        default: state = ILLEGAL_OP;  
                      endcase
                    {IE, N, Z, V, C} = {IE, N, Z, V, C};
                    $display("T = %t | State = DECODE | Next State = R-Type | PC = %h | IR = %h",
                             $time, CPU_IU.PC_out, CPU_IU.IR_out);
                  end//end of R-Type format
                else
                  begin//I or J type format
                    //RS <- $rs; RT <- DT(se_16)
                    {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
                    {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
                    {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_001_0_000; FS = no_op_;
                    {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
                    {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
                    case(IR[31:26])
                      6'h02  : state = J;
                      6'h03  : state = JAL;
                      6'h06  : state = BLEZ_1;
                      6'h07  : state = BGTZ_1;
                      6'h08  : state = ADDI;
                      6'h0A  : state = SLTI;
                      6'h0B  : state = SLTIU;
                      6'h0C  : state = ANDI;
                      6'h0D  : state = ORI;
                      6'h0E  : state = XORI;
                      6'h0F  : state = LUI;
                      6'h1C  : state = INPUT_1;
                      6'h1D  : state = OUTPUT_1;
                      6'h1E  : state = RETI_1;
                      6'h23  : state = LW_1;
                      6'h2B  : state = SW;
                      default: state = ILLEGAL_OP;
                    endcase
                    {IE, N, Z, V, C} = {IE, N, Z, V, C};
                    $display("T = %t | State = DECODE | Next State =I/J-Type| PC = %h | IR = %h",
                             $time, CPU_IU.PC_out, CPU_IU.IR_out);
                  end//end of I or J format
            end//end of DECODE
    
          ADD:
            begin
              //ALU_OUT <- RS($rs) + RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = ADD    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          ADDU:
            begin
              //ALU_OUT <- RS($rs) + RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = addu_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = ADDU   | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
        
          AND:
            begin
              //ALU_OUT <- RS($rt) & RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = and_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = AND    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          DIV:
            begin
              //HI <- RS($rs) % RT($rt), LO <- RS($rs) / RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_1_000; FS = div_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = DIV    | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end

          JR_1:
            begin
              //ALU_OUT <- RS($rs)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = pass_s_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = JR_2; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = JR_1   | Next State = JR_2   | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          JR_2:
            begin
              //PC <- ALU_OUT($rs)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = JR_2   | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end 
             
          MFHI:
            begin
              //Reg($rd) <- HI
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_00_000_0_100; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = MFHI   | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          MFLO:
            begin
              //Reg($rd) <- LO
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_00_000_0_011; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = MFLO   | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end  
                      
          MULT:
            begin
              //{HI, LO} <- RS($rs) * RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_1_000; FS = mult_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = MULT   | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end 
            
          NOR:
            begin
              //ALU_OUT <- !( RS($rs) | RT($rt) )
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = nor_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = NOR    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end 
            
          OR:
            begin
              //ALU_OUT <- RS($rs) | RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = or_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = OR     | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end  
          
          SETIE:
            begin
              //IE <- 1'b1
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; #1 {IE, N, Z, V, C} = {1'b1, N, Z, V, C};
              $display("T = %t | State = SETIE  | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          SLL:
            begin
              //ALU_OUT <- RT($rt) << shamt
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sll_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SLL    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          SLT:
            begin
              //if( RS($rs) < RT($rt) ) 
              //    ALU_OUT <- 1
              //else
              //    ALU_OUT <- 0
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = slt_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SLT    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          SLTU:
            begin
              //if( RS($rs) < RT($rt) ) 
              //    ALU_OUT <- 1
              //else
              //    ALU_OUT <- 0
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sltu_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SLTU   | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end 
             
          SRA:
            begin
              //ALU_OUT <- RT($rt) >> shamt
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sra_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SRA    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          SRL:
            begin
              //ALU_OUT <- RT($rt) >> shamt
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = srl_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SRL    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          SUB:
            begin
              //ALU_OUT <- RS($rs) - RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sub_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SUB    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
             
          SUBU:
            begin
              //ALU_OUT <- RS($rs) - RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = subu_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SUBU   | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end  
          
          XOR:
            begin
              //ALU_OUT <- RS($rs) ^ RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = xor_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_alu; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = XOR    | Next State = WB_alu | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end  
          
          ADDI:
            begin
              //ALU_OUT <- RS($rs) + RT(se_16)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = ADDI   | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end                         
          
          ANDI:
            begin
              //ALU_OUT <- RS($rs) & RT(se_16)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = andi_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = ANDI   | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end

          BEQ_1:
            begin
              //ALU_OUT <- RS($rs) - RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sub_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = BEQ_2; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = BEQ_1  | Next State = BEQ_2  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end

          BEQ_2:
            begin
              //if(Z == 1) PC <- PC + {se_16[29:0], 2'b00}
              pc_sel = 2'b00;//PC plus branch offset
              pc_ld  = Z;
              { pc_inc, ir_ld} = 2'b0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = BEQ_2  | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          BLEZ_1:
            begin
              //ALU_OUT <- RS($rs), update flags register
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = pass_s_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = BLEZ_2; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = BLEZ_1 | Next State = BLEZ_2 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          BLEZ_2:
            begin
              //if(Z = 1 | N = 1) PC <- PC + {se_16[29:0], 2'b00}
               pc_sel = 2'b00;
               pc_ld  = (Z | N);
              {pc_inc, ir_ld} = 2'b0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = BLEZ_2 | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end  
            
          BNE_1:
            begin
              //ALU_OUT <- RS($rs) - RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sub_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = BNE_2; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = BNE_1  | Next State = BNE_2  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end    
                  
          BNE_2:
            begin
              //if( Z == 0) PC <- PC + {se_16[29:0], 2'b00}
              pc_ld = ~Z;
              {pc_sel, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = BNE_2  | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end

          BGTZ_1:
            begin
              //ALU_OUT <- RS($rs)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = pass_s_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = BGTZ_2; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = BGTZ_1 | Next State = BGTZ_2 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          BGTZ_2:
            begin
              //if(Z != 0 & N != 0) PC <- PC + {SE_16{29:0}, 2'b00}
               pc_sel = 2'b00;
               pc_ld  = (~Z & ~N);//must be non negative and not zero
              {pc_inc, ir_ld} = 2'b0_0;  stack = 1'b0;
              {im_cs, im_rd, im_wr} = 3'b0_0_0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = BGTZ_2 | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          LUI:
            begin
              //ALU_OUT <- {RT[15:0], 16'h0}
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = lui_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = LUI    | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          LW_1:
            begin
              //ALU_OUT <- RS($rs) + RT(se_16)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = LW_2; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = LW_1   | Next State = LW_2   | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          LW_2:
            begin
              //D_in <- M[ALU_OUT($rs + se_16)]
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_1_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_lw; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = LW_2   | Next State = WB_lw   | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
                                      
          WB_lw:
            begin
              //Reg($rt) <- Din(M[$rs + se_16])
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_01_000_0_001; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = WB_lw  | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
                                
          ORI:
            begin
              //ALU_OUT <- RS($rs) | {16'h0, RT[15:0]}
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = ori_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = ORI    | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          SLTI:
            begin
              //ALU_OUT <- (RS($rs) < RT(se_16)) ? 1 : 0
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = slt_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SLTI   | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          SLTIU:
            begin
              //ALU_OUT <- (RS($rs) < RT(se_16)) ? 1 : 0
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = sltu_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; #1 {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = SLTIU  | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
                      
          SW:
            begin
              //ALU_OUT <- RS($rs) + RT(se_16), RT <- $rt
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_mem; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = SW     | Next State = WB_mem | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          XORI:
            begin
              //ALU_OUT <- RS($rs) ^ RT(se_16)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = xori_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_imm; {IE, N, Z, V, C} = {IE, n, z, v, c};
              $display("T = %t | State = XORI   | Next State = WB_imm | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          J:
            begin
              //PC <- {PC[31:28], IR[25:0], 2'b00}
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b01_1_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = J      | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          JAL:
            begin
              //PC <- {PC[31:28], IR[25:0], 2'b00}, Reg($ra) <- PC
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b01_1_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_10_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = JAL    | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          INPUT_1:
            begin
              //ALU_OUT <- RS($rs) + RT(se_16)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = INPUT_2; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INPUT_1| Next State = INPUT_2| PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          INPUT_2:
            begin
              //D_in <- IO[ALU_OUT($rs + se_16) ]
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b1_1_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = WB_INPUT; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INPUT_2| Next State =WB_INPUT| PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
                        
          WB_INPUT:
            begin
              //Reg($rt) <- D_in
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_01_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State =WB_INPUT| Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          OUTPUT_1:
            begin
              //ALU_OUT <- RS($rs) + RT(se_16), RT <- $rt
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = add_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = OUTPUT_2; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State =OUTPUT_1| Next State =OUTPUT_2| PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          OUTPUT_2:
            begin
              //IO[ ALU_OUT($rs + se_16) ] <- RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b1_0_1;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State =OUTPUT_2| Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end  
          
          WB_alu:
            begin
              //R[rd] <- ALU_OUT
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = WB_alu | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
                       
            end
        
          WB_imm:
            begin
              //R[rt] <- ALU_OUT
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_01_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = WB_imm | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
        
          WB_mem:
            begin
              //M[ ALU_OUT($rs + se_16) ] <- RT($rt)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_0_1; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = WB_mem | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
        
          BREAK:
            begin
              $display("BREAK INSTRUCTION FETCHED %t", $time);
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = 5'h0;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {IE, N, Z, V, C} = {IE, N, Z, V, C};
              Dump_Reg;
              Dump_dMem;
              Dump_IO;
              $finish;
            end
        
          ILLEGAL_OP:
            begin
              $display("ILLEGAL OPCODE FETCH %t | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = 5'h0;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              {IE, N, Z, V, C} = {IE, N, Z, V, C};
              Dump_Reg; 
              Dump_dMem;
              $finish;
            end
          
          RETI_1:
            begin
              //RS <- $sp
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b1;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = RETI_2; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = RETI_1 | Next State = RETI_2 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          RETI_2:
            begin
              //ALU_OUT <- RS($sp)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = pass_s_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = RETI_3; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = RETI_2 | Next State = RETI_3 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          RETI_3:
            begin
              //D_in <- dMem[ALU_OUT($sp)], RS <- Reg($sp)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b1;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_1_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = RETI_4; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = RETI_3 | Next State = RETI_4 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end

          RETI_4:
            begin
              //flags <- D_in, ALU_OUT <- RS($sp) + 4
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_001; FS = inc4_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = RETI_5; #1 {IE, N, Z, V, C} = flags_in;
              $display("T = %t | State = RETI_4 | Next State = RETI_5 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          RETI_5:
            begin
              //RS <- ALU_OUT($sp + 4), D_in <- dMem[ALU_OUT($sp + 4)]
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_100_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_1_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = RETI_6; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = RETI_5 | Next State = RETI_6 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
          RETI_6:
            begin
              //ALU_OUT <- RS($sp + 4) + 4, PC <- D_in
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_001; FS = inc4_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = RETI_7; #1 {IE, N, Z, V, C} = flags_in;
              $display("T = %t | State = RETI_6 | Next State = RETI_7 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end

          RETI_7:
            begin
              //Reg($sp) <- ALU_OUT ($sp + 8)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_11_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = RETI_7 | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          INTR_1:
            begin
              //RS <- Reg($sp)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b1;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_000; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = INTR_2; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INTR_1 | Next State = INTR_2 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
        
          INTR_2:
            begin
              //ALU_OUT <- RS($sp) - 4, RT <- PC
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_010_0_000; FS = dec4_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = INTR_3; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INTR_2 | Next State = INTR_3 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          INTR_3:
            begin
              //dMem[ALU_OUT($sp - 4)] <- RT(PC), RS <- ALU_OUT($sp - 4)
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_100_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_0_1; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = INTR_4; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INTR_3 | Next State = INTR_4 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
            
        
          INTR_4:
            begin
              //ALU_OUT <- RS($sp - 4) - 4, RT <- {27'b0, flags}
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_011_0_000; FS = dec4_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = INTR_5; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INTR_4 | Next State = INTR_5 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          INTR_5:
            begin
              //dMem[ALU_OUT($sp - 8)] <- RT(flags), Reg($sp) <- ALU_OUT($sp - 8), ALU_OUT <- 0x3FC
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b1_11_000_0_010; FS = sp_init_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_0_1; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = INTR_6; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INTR_5 | Next State = INTR_6 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end 
                       
          INTR_6:
            begin
              //D_in <- dMem[ALU_OUT(0x3FC)]
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b00_0_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_010; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b1_1_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = INTR_7; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INTR_6 | Next State = INTR_7 | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
            end
          
          INTR_7:
            begin
              //PC <- D_in( dMem[0x3FC] ), int_ack <- 1
              {pc_sel, pc_ld, pc_inc, ir_ld} = 5'b10_1_0_0; 
              {im_cs, im_rd, im_wr} = 3'b0_0_0; stack = 1'b0;
              {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 10'b0_00_000_0_001; FS = no_op_;
              {dm_cs, dm_rd, dm_wr} = 3'b0_0_0; {io_cs, io_rd, io_wr} = 3'b0_0_0;
              {S_Addr, T_Addr, D_Addr, shamt} = { IR[26:21], IR[20:16], IR[15:11], IR[10:6] };
              state = FETCH; {IE, N, Z, V, C} = {IE, N, Z, V, C};
              $display("T = %t | State = INTR_7 | Next State = FETCH  | PC = %h | IR = %h",
                       $time, CPU_IU.PC_out, CPU_IU.IR_out);
              int_ack = 1;
              Dump_Reg;
            end
        
        endcase//end of FSM
      end
    end//eng always block

    //Dumps Contents of Register File
    task Dump_Reg;
      begin
        $display(" ");
        $display("D i s p l a y i n g   C o n t e n t s   o f   R e g f i l e");
        for(i = 0; i < 16; i = i + 1) 
        begin
            $display("R [ %d ]   =   %h    |   R [ %d ]   =   %h",
                     i[5:0]        , Integer_Datapath.REG_FILE.reg32[i   ],
                     i[5:0] + 5'd16, Integer_Datapath.REG_FILE.reg32[i+16]);
        end
      end
    endtask
    
    //Dump Memory Contents - 0xC0 -> 0xFF
    task Dump_dMem;
    begin
        $display(" ");
        $display("D i s p l a y i n g   C o n t e n t s   o f   D a t a   M e m o r y");
        for(i = 32'h3C0; i < 12'h400; i = i + 4)
          begin
             $display("d M e m [ %h ]   =   %h%h%h%h",i[11:0],
                      dMem.M[i  ], dMem.M[i+1], 
                      dMem.M[i+2], dMem.M[i+3] ); 
          end
    end
    endtask
    
    //Dump IO Memory Contents - 0xC0 -> 0xFF
    task Dump_IO;
    begin
        $display(" ");
        $display("D i s p l a y i n g   C o n t e n t s   o f   I O   M e m o r y");
        for(i = 32'hC0; i < 12'h100; i = i + 4)
                  begin
                     $display("i M e m [ %h ]   =   %h",i[9:0],IO.M[i[9:0]] ); 
                  end
    end
    endtask
    
    

endmodule
