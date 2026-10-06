// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Mon Jul  6 16:06:54 2026
// Host        : LAPTOP-TTJ7O25R running 64-bit major release  (build 9200)
// Command     : write_verilog -mode funcsim -nolib -force -file
//               E:/Formation_FPGA_Expleo/FPGA_Core_Z7/FPGA_Cora_Z7/tp2_compteur/tp2_compteur.sim/sim_1/synth/func/xsim/tb_counter_func_synth.v
// Design      : counter_unit
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* NotValidForBitStream *)
module counter_unit
   (clk,
    resetn,
    restart,
    led_out,
    count);
  input clk;
  input resetn;
  input restart;
  output led_out;
  output [27:0]count;

  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire [27:0]count;
  wire [27:0]count_OBUF;
  wire \cpt_reg[27]_i_10_n_0 ;
  wire \cpt_reg[27]_i_2_n_0 ;
  wire \cpt_reg[27]_i_4_n_0 ;
  wire \cpt_reg[27]_i_5_n_0 ;
  wire \cpt_reg[27]_i_6_n_0 ;
  wire \cpt_reg[27]_i_7_n_0 ;
  wire \cpt_reg[27]_i_8_n_0 ;
  wire \cpt_reg[27]_i_9_n_0 ;
  wire \cpt_reg_reg[12]_i_2_n_0 ;
  wire \cpt_reg_reg[12]_i_2_n_1 ;
  wire \cpt_reg_reg[12]_i_2_n_2 ;
  wire \cpt_reg_reg[12]_i_2_n_3 ;
  wire \cpt_reg_reg[16]_i_2_n_0 ;
  wire \cpt_reg_reg[16]_i_2_n_1 ;
  wire \cpt_reg_reg[16]_i_2_n_2 ;
  wire \cpt_reg_reg[16]_i_2_n_3 ;
  wire \cpt_reg_reg[20]_i_2_n_0 ;
  wire \cpt_reg_reg[20]_i_2_n_1 ;
  wire \cpt_reg_reg[20]_i_2_n_2 ;
  wire \cpt_reg_reg[20]_i_2_n_3 ;
  wire \cpt_reg_reg[24]_i_2_n_0 ;
  wire \cpt_reg_reg[24]_i_2_n_1 ;
  wire \cpt_reg_reg[24]_i_2_n_2 ;
  wire \cpt_reg_reg[24]_i_2_n_3 ;
  wire \cpt_reg_reg[27]_i_3_n_2 ;
  wire \cpt_reg_reg[27]_i_3_n_3 ;
  wire \cpt_reg_reg[4]_i_2_n_0 ;
  wire \cpt_reg_reg[4]_i_2_n_1 ;
  wire \cpt_reg_reg[4]_i_2_n_2 ;
  wire \cpt_reg_reg[4]_i_2_n_3 ;
  wire \cpt_reg_reg[8]_i_2_n_0 ;
  wire \cpt_reg_reg[8]_i_2_n_1 ;
  wire \cpt_reg_reg[8]_i_2_n_2 ;
  wire \cpt_reg_reg[8]_i_2_n_3 ;
  wire [27:1]data0;
  wire led_out;
  wire led_out_OBUF;
  wire led_reg_i_1_n_0;
  wire [27:0]p_0_in;
  wire resetn;
  wire resetn_IBUF;
  wire restart;
  wire restart_IBUF;
  wire [3:2]\NLW_cpt_reg_reg[27]_i_3_CO_UNCONNECTED ;
  wire [3:3]\NLW_cpt_reg_reg[27]_i_3_O_UNCONNECTED ;

  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  OBUF \count_OBUF[0]_inst 
       (.I(count_OBUF[0]),
        .O(count[0]));
  OBUF \count_OBUF[10]_inst 
       (.I(count_OBUF[10]),
        .O(count[10]));
  OBUF \count_OBUF[11]_inst 
       (.I(count_OBUF[11]),
        .O(count[11]));
  OBUF \count_OBUF[12]_inst 
       (.I(count_OBUF[12]),
        .O(count[12]));
  OBUF \count_OBUF[13]_inst 
       (.I(count_OBUF[13]),
        .O(count[13]));
  OBUF \count_OBUF[14]_inst 
       (.I(count_OBUF[14]),
        .O(count[14]));
  OBUF \count_OBUF[15]_inst 
       (.I(count_OBUF[15]),
        .O(count[15]));
  OBUF \count_OBUF[16]_inst 
       (.I(count_OBUF[16]),
        .O(count[16]));
  OBUF \count_OBUF[17]_inst 
       (.I(count_OBUF[17]),
        .O(count[17]));
  OBUF \count_OBUF[18]_inst 
       (.I(count_OBUF[18]),
        .O(count[18]));
  OBUF \count_OBUF[19]_inst 
       (.I(count_OBUF[19]),
        .O(count[19]));
  OBUF \count_OBUF[1]_inst 
       (.I(count_OBUF[1]),
        .O(count[1]));
  OBUF \count_OBUF[20]_inst 
       (.I(count_OBUF[20]),
        .O(count[20]));
  OBUF \count_OBUF[21]_inst 
       (.I(count_OBUF[21]),
        .O(count[21]));
  OBUF \count_OBUF[22]_inst 
       (.I(count_OBUF[22]),
        .O(count[22]));
  OBUF \count_OBUF[23]_inst 
       (.I(count_OBUF[23]),
        .O(count[23]));
  OBUF \count_OBUF[24]_inst 
       (.I(count_OBUF[24]),
        .O(count[24]));
  OBUF \count_OBUF[25]_inst 
       (.I(count_OBUF[25]),
        .O(count[25]));
  OBUF \count_OBUF[26]_inst 
       (.I(count_OBUF[26]),
        .O(count[26]));
  OBUF \count_OBUF[27]_inst 
       (.I(count_OBUF[27]),
        .O(count[27]));
  OBUF \count_OBUF[2]_inst 
       (.I(count_OBUF[2]),
        .O(count[2]));
  OBUF \count_OBUF[3]_inst 
       (.I(count_OBUF[3]),
        .O(count[3]));
  OBUF \count_OBUF[4]_inst 
       (.I(count_OBUF[4]),
        .O(count[4]));
  OBUF \count_OBUF[5]_inst 
       (.I(count_OBUF[5]),
        .O(count[5]));
  OBUF \count_OBUF[6]_inst 
       (.I(count_OBUF[6]),
        .O(count[6]));
  OBUF \count_OBUF[7]_inst 
       (.I(count_OBUF[7]),
        .O(count[7]));
  OBUF \count_OBUF[8]_inst 
       (.I(count_OBUF[8]),
        .O(count[8]));
  OBUF \count_OBUF[9]_inst 
       (.I(count_OBUF[9]),
        .O(count[9]));
  LUT5 #(
    .INIT(32'h11111110)) 
    \cpt_reg[0]_i_1 
       (.I0(restart_IBUF),
        .I1(count_OBUF[0]),
        .I2(\cpt_reg[27]_i_4_n_0 ),
        .I3(\cpt_reg[27]_i_5_n_0 ),
        .I4(\cpt_reg[27]_i_6_n_0 ),
        .O(p_0_in[0]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[10]_i_1 
       (.I0(data0[10]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[10]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[11]_i_1 
       (.I0(data0[11]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[11]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[12]_i_1 
       (.I0(data0[12]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[12]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[13]_i_1 
       (.I0(data0[13]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[13]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[14]_i_1 
       (.I0(data0[14]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[14]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[15]_i_1 
       (.I0(data0[15]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[15]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[16]_i_1 
       (.I0(data0[16]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[16]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[17]_i_1 
       (.I0(data0[17]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[17]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[18]_i_1 
       (.I0(data0[18]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[18]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[19]_i_1 
       (.I0(data0[19]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[19]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[1]_i_1 
       (.I0(data0[1]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[1]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[20]_i_1 
       (.I0(data0[20]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[20]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[21]_i_1 
       (.I0(data0[21]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[21]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[22]_i_1 
       (.I0(data0[22]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[22]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[23]_i_1 
       (.I0(data0[23]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[23]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[24]_i_1 
       (.I0(data0[24]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[24]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[25]_i_1 
       (.I0(data0[25]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[25]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[26]_i_1 
       (.I0(data0[26]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[26]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[27]_i_1 
       (.I0(data0[27]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[27]));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \cpt_reg[27]_i_10 
       (.I0(count_OBUF[19]),
        .I1(count_OBUF[18]),
        .I2(count_OBUF[21]),
        .I3(count_OBUF[20]),
        .O(\cpt_reg[27]_i_10_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \cpt_reg[27]_i_2 
       (.I0(resetn_IBUF),
        .O(\cpt_reg[27]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFEF)) 
    \cpt_reg[27]_i_4 
       (.I0(count_OBUF[27]),
        .I1(count_OBUF[26]),
        .I2(count_OBUF[1]),
        .I3(\cpt_reg[27]_i_7_n_0 ),
        .I4(\cpt_reg[27]_i_8_n_0 ),
        .O(\cpt_reg[27]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \cpt_reg[27]_i_5 
       (.I0(count_OBUF[8]),
        .I1(count_OBUF[9]),
        .I2(count_OBUF[6]),
        .I3(count_OBUF[7]),
        .I4(\cpt_reg[27]_i_9_n_0 ),
        .O(\cpt_reg[27]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \cpt_reg[27]_i_6 
       (.I0(count_OBUF[16]),
        .I1(count_OBUF[17]),
        .I2(count_OBUF[14]),
        .I3(count_OBUF[15]),
        .I4(\cpt_reg[27]_i_10_n_0 ),
        .O(\cpt_reg[27]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \cpt_reg[27]_i_7 
       (.I0(count_OBUF[23]),
        .I1(count_OBUF[22]),
        .I2(count_OBUF[25]),
        .I3(count_OBUF[24]),
        .O(\cpt_reg[27]_i_7_n_0 ));
  LUT4 #(
    .INIT(16'hFFFD)) 
    \cpt_reg[27]_i_8 
       (.I0(count_OBUF[3]),
        .I1(count_OBUF[2]),
        .I2(count_OBUF[5]),
        .I3(count_OBUF[4]),
        .O(\cpt_reg[27]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \cpt_reg[27]_i_9 
       (.I0(count_OBUF[11]),
        .I1(count_OBUF[10]),
        .I2(count_OBUF[13]),
        .I3(count_OBUF[12]),
        .O(\cpt_reg[27]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[2]_i_1 
       (.I0(data0[2]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[2]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[3]_i_1 
       (.I0(data0[3]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[3]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[4]_i_1 
       (.I0(data0[4]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[5]_i_1 
       (.I0(data0[5]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[5]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[6]_i_1 
       (.I0(data0[6]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[6]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[7]_i_1 
       (.I0(data0[7]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[7]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[8]_i_1 
       (.I0(data0[8]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[8]));
  LUT6 #(
    .INIT(64'h00000000AAAAAAA8)) 
    \cpt_reg[9]_i_1 
       (.I0(data0[9]),
        .I1(\cpt_reg[27]_i_4_n_0 ),
        .I2(\cpt_reg[27]_i_5_n_0 ),
        .I3(\cpt_reg[27]_i_6_n_0 ),
        .I4(count_OBUF[0]),
        .I5(restart_IBUF),
        .O(p_0_in[9]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[0]),
        .Q(count_OBUF[0]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[10] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[10]),
        .Q(count_OBUF[10]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[11] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[11]),
        .Q(count_OBUF[11]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[12] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[12]),
        .Q(count_OBUF[12]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \cpt_reg_reg[12]_i_2 
       (.CI(\cpt_reg_reg[8]_i_2_n_0 ),
        .CO({\cpt_reg_reg[12]_i_2_n_0 ,\cpt_reg_reg[12]_i_2_n_1 ,\cpt_reg_reg[12]_i_2_n_2 ,\cpt_reg_reg[12]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(data0[12:9]),
        .S(count_OBUF[12:9]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[13] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[13]),
        .Q(count_OBUF[13]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[14] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[14]),
        .Q(count_OBUF[14]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[15] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[15]),
        .Q(count_OBUF[15]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[16] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[16]),
        .Q(count_OBUF[16]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \cpt_reg_reg[16]_i_2 
       (.CI(\cpt_reg_reg[12]_i_2_n_0 ),
        .CO({\cpt_reg_reg[16]_i_2_n_0 ,\cpt_reg_reg[16]_i_2_n_1 ,\cpt_reg_reg[16]_i_2_n_2 ,\cpt_reg_reg[16]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(data0[16:13]),
        .S(count_OBUF[16:13]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[17] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[17]),
        .Q(count_OBUF[17]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[18] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[18]),
        .Q(count_OBUF[18]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[19] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[19]),
        .Q(count_OBUF[19]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[1]),
        .Q(count_OBUF[1]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[20] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[20]),
        .Q(count_OBUF[20]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \cpt_reg_reg[20]_i_2 
       (.CI(\cpt_reg_reg[16]_i_2_n_0 ),
        .CO({\cpt_reg_reg[20]_i_2_n_0 ,\cpt_reg_reg[20]_i_2_n_1 ,\cpt_reg_reg[20]_i_2_n_2 ,\cpt_reg_reg[20]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(data0[20:17]),
        .S(count_OBUF[20:17]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[21] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[21]),
        .Q(count_OBUF[21]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[22] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[22]),
        .Q(count_OBUF[22]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[23] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[23]),
        .Q(count_OBUF[23]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[24] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[24]),
        .Q(count_OBUF[24]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \cpt_reg_reg[24]_i_2 
       (.CI(\cpt_reg_reg[20]_i_2_n_0 ),
        .CO({\cpt_reg_reg[24]_i_2_n_0 ,\cpt_reg_reg[24]_i_2_n_1 ,\cpt_reg_reg[24]_i_2_n_2 ,\cpt_reg_reg[24]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(data0[24:21]),
        .S(count_OBUF[24:21]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[25] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[25]),
        .Q(count_OBUF[25]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[26] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[26]),
        .Q(count_OBUF[26]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[27] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[27]),
        .Q(count_OBUF[27]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \cpt_reg_reg[27]_i_3 
       (.CI(\cpt_reg_reg[24]_i_2_n_0 ),
        .CO({\NLW_cpt_reg_reg[27]_i_3_CO_UNCONNECTED [3:2],\cpt_reg_reg[27]_i_3_n_2 ,\cpt_reg_reg[27]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_cpt_reg_reg[27]_i_3_O_UNCONNECTED [3],data0[27:25]}),
        .S({1'b0,count_OBUF[27:25]}));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[2]),
        .Q(count_OBUF[2]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[3]),
        .Q(count_OBUF[3]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[4]),
        .Q(count_OBUF[4]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \cpt_reg_reg[4]_i_2 
       (.CI(1'b0),
        .CO({\cpt_reg_reg[4]_i_2_n_0 ,\cpt_reg_reg[4]_i_2_n_1 ,\cpt_reg_reg[4]_i_2_n_2 ,\cpt_reg_reg[4]_i_2_n_3 }),
        .CYINIT(count_OBUF[0]),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(data0[4:1]),
        .S(count_OBUF[4:1]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[5]),
        .Q(count_OBUF[5]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[6]),
        .Q(count_OBUF[6]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[7]),
        .Q(count_OBUF[7]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[8] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[8]),
        .Q(count_OBUF[8]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \cpt_reg_reg[8]_i_2 
       (.CI(\cpt_reg_reg[4]_i_2_n_0 ),
        .CO({\cpt_reg_reg[8]_i_2_n_0 ,\cpt_reg_reg[8]_i_2_n_1 ,\cpt_reg_reg[8]_i_2_n_2 ,\cpt_reg_reg[8]_i_2_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(data0[8:5]),
        .S(count_OBUF[8:5]));
  FDCE #(
    .INIT(1'b0)) 
    \cpt_reg_reg[9] 
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(p_0_in[9]),
        .Q(count_OBUF[9]));
  OBUF led_out_OBUF_inst
       (.I(led_out_OBUF),
        .O(led_out));
  LUT6 #(
    .INIT(64'h5555555400000001)) 
    led_reg_i_1
       (.I0(restart_IBUF),
        .I1(count_OBUF[0]),
        .I2(\cpt_reg[27]_i_6_n_0 ),
        .I3(\cpt_reg[27]_i_5_n_0 ),
        .I4(\cpt_reg[27]_i_4_n_0 ),
        .I5(led_out_OBUF),
        .O(led_reg_i_1_n_0));
  FDCE #(
    .INIT(1'b0)) 
    led_reg_reg
       (.C(clk_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\cpt_reg[27]_i_2_n_0 ),
        .D(led_reg_i_1_n_0),
        .Q(led_out_OBUF));
  IBUF resetn_IBUF_inst
       (.I(resetn),
        .O(resetn_IBUF));
  IBUF restart_IBUF_inst
       (.I(restart),
        .O(restart_IBUF));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
