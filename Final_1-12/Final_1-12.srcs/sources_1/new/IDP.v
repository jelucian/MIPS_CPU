`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: IDP.v
 * Date:     2/25/2019
 * Version:  1.2
 * 
 * Notes:1.0 Module connects register file and ALU, and ties additional control
 *           signals. 2 multiplexers are used to select ALU_OUT and the second 
 *           input to the RT register. 
 * 
 *           Two of the new resgisters, HI and LO, are used to store the output 
 *           of the ALU module.
 *           
 *           RS and RT register load the data output form the register file 
 *           after every clock cycle and feed it to the ALU.
 *           
 *           The ALU_Out register loads the data output from the ALU after 
 *           every clock cycle. 
 *            
 *           The D_in register loads the DY input after every clock cycle
 * 
 *       1.1 Added DA_mux to select between D_Addr and T_Addr for the write 
 *           address of the regfile, controlled by new DA_sel signal
 *
 *       1.2 Increased size of DA_sel to select between more inputs to the
 *           DA_mux
 *
 *       1.3 Added mux to D_in input controlled by io_rd signal that selects
 *           between io_out and dmem_out. Expanded T_MUX to now select between
 *           the flags, SE_16, T output of the Regfile, and the PC
 *
 *       1.4 Added flags input and flags output. S_MUX added that selects between
 *           the regfile output and the ALU_OUT output
 *
 *******************************************************************************/
module IDP(clk, reset, S_Addr, FS, HILO_ld, D_En, D_Addr, T_Addr,
                        DT, T_Sel, C, V, N, Z, DY, PC_in, Y_Sel, ALU_OUT, D_OUT,
                        DA_Sel, shamt, io_rd, io_out, stack, flags_in, flags_out);
    
    input         clk, reset, HILO_ld, D_En, io_rd, stack;
    input [ 1:0]  DA_Sel;
    input [ 2:0]  Y_Sel, T_Sel;
    input [ 4:0]  S_Addr, FS, D_Addr, T_Addr, shamt, flags_in;
    input [31:0]  DT, DY, PC_in, io_out;
   
    output             C, V, N, Z;
    output      [ 4:0] flags_out;
    output      [31:0] D_OUT;
    output wire [31:0] ALU_OUT;
    
    wire [ 4:0] DA_mux, stack_mux;
    
    wire [31:0] REG_FILE_S, REG_FILE_T, T_MUX, S_MUX,
                Y_hi, Y_lo, HI_out, LO_out,
                RS_out, RT_out, ALU_reg_out, D_in_out;
    
    wire [31:0] mem_in;
                
    //DA-mux for Regfile Write Address
    //Selects between rd and rt as source for write address
    assign DA_mux = (DA_Sel == 2'b11) ? 5'h1D ://Reg 29
                    (DA_Sel == 2'b10) ? 5'h1F ://Reg 31
                    (DA_Sel == 2'b01) ? T_Addr:
                                        D_Addr;//Default
    
    //S-MUX
    assign S_MUX = (T_Sel == 3'b100) ? ALU_OUT   ://Y_Mux output
                                       REG_FILE_S;//Regfile
    
    //T-MUX
    assign T_MUX = (T_Sel == 3'b011) ? {26'b0, flags_in}://flags_in
                   (T_Sel == 3'b010) ? PC_in            ://PC
                   (T_Sel == 3'b001) ? DT               ://SE_16
                                       REG_FILE_T       ;//Regfile
    
    //Y-MUX
    assign ALU_OUT = (Y_Sel == 3'b100) ? HI_out      ://HI register
                     (Y_Sel == 3'b011) ? LO_out      ://Lo register
                     (Y_Sel == 3'b010) ? ALU_reg_out ://ALU_OUT register
                     (Y_Sel == 3'b001) ? D_in_out    ://D_in register
                                         PC_in       ;//PC
    
    //IO-Mux - selects between io memory out (1) and data memory (0)
    assign mem_in = (io_rd) ? io_out : DY;          
    
    //stack mux selects between S_Addr input and the stack pointer as the     
    //output to the RS register
    assign stack_mux = (stack) ? 5'h1D : S_Addr;
    
    //strip lower 5 bits out Y-Mux output for flags
    assign flags_out = ALU_OUT[4:0];
                                         
    //module reg32(clk, reset, ld, D, Q);
    reg32      HI(.clk(clk), .reset(reset), .ld(HILO_ld), 
                  .D(Y_hi), .Q(HI_out) );
    reg32      LO(.clk(clk), .reset(reset), .ld(HILO_ld), 
                  .D(Y_lo), .Q(LO_out) );
    
    //ALU_OUT, D_in, RS, RT alwayy load value every clock cycle, load is set to 1
    reg32 ALU_Out(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(Y_lo), .Q(ALU_reg_out)  );
    reg32    D_in(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(mem_in)  , .Q(D_in_out)     );
    reg32      RS(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(S_MUX), .Q(RS_out) );
    reg32      RT(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(T_MUX), .Q(D_OUT)       );
    
    //module alu_32(S, T, FS, C, V, N, Z, Y_hi, Y_lo);
    alu_32 ALU(.S(RS_out), .T(D_OUT), .FS(FS),
               .C(C), .V(V), .N(N), .Z(Z),
               .Y_hi(Y_hi), .Y_lo(Y_lo), .shamt(shamt) );

    //module regfile32(clk, reset, S, T, D, S_Addr, T_Addr, D_Addr, D_En);
    regfile32 REG_FILE(.clk(clk), .reset(reset), .S(REG_FILE_S),
                       .T(REG_FILE_T), .D(ALU_OUT), .S_Addr(stack_mux),
                       .T_Addr(T_Addr),.D_Addr(DA_mux), .D_En(D_En) );
                                
endmodule