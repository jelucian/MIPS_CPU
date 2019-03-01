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
    wire clk;

    initial begin
        
        @(negedge clk)
            //Integer Datapath Control
            { D_En, D_Addr, S_Addr, T_Addr } = 16'b0_00000_00000_00000;
            { T_sel, FS, HILO_ld, Y_Sel }    = 10'b0_00000_0_000;
            
            //Integer Datapath Constants
              DT    = 32'hFFFF_FFFB;
              PC_in = 32'h1001_00C0;
            
            //Data Memory Control
            { dm_cs, dm_rd, dm_wr } = 3'b0_0_0;
            
    end

endmodule
