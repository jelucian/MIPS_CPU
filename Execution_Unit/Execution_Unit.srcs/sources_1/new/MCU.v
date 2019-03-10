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
 *******************************************************************************
 *  Control Word Format
 *
 *  {pc_sel, pc_ld, pc_in, ir_ld} = 5'b00_0_0_0; 
 *  {im_cs, im_rd, im_wr} = 3'b0_0_0;
 *  {D_En, DA_sel, T_sel, HILO_ld, Y_sel} = 8'b0_00_0_0_000; FS = 5'h0;
 *  {dm_cs, dm_rd, dm_wr} = 3'b0_0_0;
 *
 *******************************************************************************/
module MCU(sys_clk, reset, intr, c, n, z, v, IR, int_ack);
    input sys_clk, reset, intr;
    input c, n, z, v;
    input [31:0] IR;
    output int_ack;
    
    reg int_ack;
    
    //state assignments
    parameter 
     RESET  = 00,  FETCH  = 01,  DECODE = 02,
     ADD    = 10,  ADDU   = 11,  AND    = 12, OR    = 13, NOR   = 14,
     ORI    = 20,  LUI    = 21,  LW     = 22, SW    = 23,
     WB_alu = 30,  WB_imm = 31,  WB_Din = 32, WB_hi = 22, WB_lo = 34, WB_mem = 35,
     INTR_1 = 501, INTR_2 = 502, INTR_3  = 503,
     BREAK  = 510, ILLEGAL_OP = 511;
    
    //state register
    reg [8:0] state;
    
    //Control Unit Finite State Machine
    always @ (posedge sys_clk, posedge reset) 
      if(reset)
          begin
            //control word
            state = RESET;//next state is RESET state
          end
      else
        case(state)
          FETCH:
            if(int_ack == 0 & intr == 1)
              begin//new interrupt pending
                //control word to "deassert" everyting
                state = INTR_1;
              end
            else
              begin//no pending interrupt
                if(int_ack == 1 & intr == 0) int_ack = 1'b0;
                //IR <- iM[PC]; PC <- PC + 4
                state = DECODE;
              end
            
          RESET:
            begin
                // $sp <- ALU_OUT(32'h3FC)
                state = FETCH;
            end
        
          DECODE:
            begin
                @(negedge sys_clk)
                if( IR[31:26] == 6'h00)//R-Type Instruction
                  begin//RS <- $rs; RT <- $rt
                    //control word
                    case(IR[5:0])//function code
                      6'h0D  : state = BREAK;
                      6'h20  : state = ADD;
                      default: state = ILLEGAL_OP;  
                    endcase
                  end//end of R-Type format
                else
                  begin//I or J type format
                    //control word
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
              state = WB_alu;
            end
        
          ORI:
            begin
              //ALU_OUT <- RS($rs) | {16'h0, RT[15:0]}
              state = WB_imm;
            end
          LUI:
            begin
              //ALU_OUT <- {RT[15:0], 16'h0}
              state = WB_imm;
            end
        
          SW:
            begin
              //ALU_OUT <- RS($rs) + RT(se_16), RT <- $rt
              state = WB_mem;
            end
        
          WB_alu:
            begin
              //R[rd] <- ALU_OUT
              state = FETCH;
            end
        
          WB_imm:
            begin
              //R[rt] <- ALU_OUT
              state = FETCH;
            end
        
          WB_mem:
            begin
              //M[ ALU_OUT($rs+se_16) ] <- RT($rt)
              state = FETCH;
            end
        
          BREAK:
            begin
              $display("BREAK INSTRUCTION FETCHED %t", $time);
              $display("R e g i s t e r s   A f t e r   B r e a k");
              $display(" ");
              //Dump_Registers
              $display(" ");
              //$display("time = %t M[3F0] = %h", $time,
                //        {Execution_Unit_TB.dMem.M[12'h3F0],
                //         Execution_Unit_TB.dMem.M[12'h3F1],
                //         Execution_Unit_TB.dMem.M[12'h3F2],
                //         Execution_Unit_TB.dMem.M[12'h3F3]} );
              $finish;
            end
        
          ILLEGAL_OP:
            begin
              $display("ILLEGAL OPCODE FETCH %t", $time);
              //Dump_Registers;
              //Dump_PC_and_IR;
            end
        
          INTR_1:
            begin
              //PC gets address of interrupt vector, PC saved in $ra
              //ALU_OUT <- 0x3FC, R[$ra] <- PC
              state = INTR_2;
            end
        
          INTR_2:
            begin
              //Read Address of ISR into D_In
              //D_in <- dMem( [ALU_OUT(0x3FC)]
              state = INTR_3;
            end
        
          INTR_3:
            begin
              //Relead PC with Address of ISR; ack the intr; goto FETCH
              //PC <- D_in( dMem[0x3FC] ), int_ack <- 1
              state = FETCH;
            end
        
        endcase//end of FSM

endmodule;
