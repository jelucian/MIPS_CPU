`timescale 1ns / 1ps
/********************************************************************************
 *
 * Author:   Jesus Luciano & Rosswell Tiongco
 * Filename: Integer_Datapath.v
 * Date:     2/25/2019
 * Version:  2.0
 * 
 * Notes:    Module connects register file and ALU, and ties additional control
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
 *******************************************************************************/
module Integer_Datapath(clk, reset, S_Addr, FS, HILO_ld, D_En, D_Addr, T_Addr,
                        DT, T_Sel, C, V, N, Z, DY, PC_in, Y_Sel, ALU_OUT, D_OUT,
                        DA_sel);
    
    input        clk, reset, HILO_ld, D_En, T_Sel,DA_sel;
    input [2:0]  Y_Sel;
    input [4:0]  S_Addr, FS, D_Addr, T_Addr;
    input [31:0] DT, DY, PC_in;
   
    output             C, V, N, Z;
    output      [31:0] D_OUT;
    output wire [31:0] ALU_OUT;
    
    wire [ 4:0] DA_mux;
    
    wire [31:0] REG_FILE_S, REG_FILE_T, T_MUX,
                Y_hi, Y_lo, HI_out, LO_out,
                RS_out, RT_out, ALU_reg_out, D_in_out;
                
    //DA-mux for Regfile Write Address
    //Selects between rd and rt as source for write address
    //1 = rt, 0 = rd
    assign DA_mux = (DA_sel) ? T_Addr : D_Addr;
    
    //T-MUX
    assign T_MUX = (T_Sel) ? REG_FILE_T : DT;    
    
    //Y-MUX
    assign ALU_OUT = (Y_Sel == 3'b100) ? HI_out      :
                     (Y_Sel == 3'b011) ? LO_out      :
                     (Y_Sel == 3'b010) ? ALU_reg_out :
                     (Y_Sel == 3'b001) ? D_in_out    :
                                         PC_in       ;
                                         
    //module reg32(clk, reset, ld, D, Q);
    reg32      HI(.clk(clk), .reset(reset), .ld(HILO_ld), 
                  .D(Y_hi), .Q(HI_out) );
    reg32      LO(.clk(clk), .reset(reset), .ld(HILO_ld), 
                  .D(Y_lo), .Q(LO_out) );
    
    //ALU_OUT, D_in, RS, RT alwayy load value every clock cycle, load is set to 1
    reg32 ALU_Out(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(Y_lo), .Q(ALU_reg_out)  );
    reg32    D_in(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(DY)  , .Q(D_in_out)     );
    
    reg32      RS(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(REG_FILE_S), .Q(RS_out) );
    reg32      RT(.clk(clk), .reset(reset), .ld(1'b1), 
                  .D(T_MUX), .Q(D_OUT)       );
    
    //module alu_32(S, T, FS, C, V, N, Z, Y_hi, Y_lo);
    alu_32 ALU(.S(RS_out), .T(D_OUT), .FS(FS),
               .C(C), .V(V), .N(N), .Z(Z),
               .Y_hi(Y_hi), .Y_lo(Y_lo) );

    //module regfile32(clk, reset, S, T, D, S_Addr, T_Addr, D_Addr, D_En);
    regfile32 REG_FILE(.clk(clk), .reset(reset), .S(REG_FILE_S),
                       .T(REG_FILE_T), .D(ALU_OUT), .S_Addr(S_Addr),
                       .T_Addr(T_Addr),.D_Addr(D_Addr), .D_En(D_En) );
                                
endmodule