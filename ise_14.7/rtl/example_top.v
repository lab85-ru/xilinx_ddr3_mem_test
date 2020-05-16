//*****************************************************************************
// (c) Copyright 2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 3.92
//  \   \         Application        : MIG
//  /   /         Filename           : example_top #.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 07:17:09 $
// \   \  /  \    Date Created       : Tue Feb 23 2010
//  \___\/\___\
//
//Device           : Spartan-6
//Design Name      : DDR/DDR2/DDR3/LPDDR 
//Purpose          : This is a template file for the design top module. This module contains 
//                   all the four memory controllers and the two infrastructures. However,
//                   only the enabled modules will be active and others inactive.
//Reference        :
//Revision History :
//*****************************************************************************
`timescale 1ns/1ps

(* X_CORE_INFO = "mig_v3_92_ddr3_s6, Coregen 14.7" , CORE_GENERATION_INFO = "ddr3_s6,mig_v3_92,{component_name=mig_39_2_ddr3, C3_MEM_INTERFACE_TYPE=DDR3_SDRAM, C3_CLK_PERIOD=3000, C3_MEMORY_PART=mt41j64m16xx-187e, C3_MEMORY_DEVICE_WIDTH=16, C3_OUTPUT_DRV=DIV6, C3_RTT_NOM=DIV2, C3_AUTO_SR=ENABLED, C3_HIGH_TEMP_SR=NORMAL, C3_PORT_CONFIG=Two 32-bit bi-directional and four 32-bit unidirectional ports, C3_MEM_ADDR_ORDER=BANK_ROW_COLUMN, C3_PORT_ENABLE=Port0, C3_INPUT_PIN_TERMINATION=CALIB_TERM, C3_DATA_TERMINATION=25 Ohms, C3_CLKFBOUT_MULT_F=2, C3_CLKOUT_DIVIDE=1, C3_DEBUG_PORT=0, INPUT_CLK_TYPE=Single-Ended, LANGUAGE=Verilog, SYNTHESIS_TOOL=Foundation_ISE, NO_OF_CONTROLLERS=1}" *)
module example_top #
(
   parameter C3_P0_MASK_SIZE           = 4,
   parameter C3_P0_DATA_PORT_SIZE      = 32,
   parameter C3_P1_MASK_SIZE           = 4,
   parameter C3_P1_DATA_PORT_SIZE      = 32,
   parameter DEBUG_EN                = 0,       
                                       // # = 1, Enable debug signals/controls,
                                       //   = 0, Disable debug signals/controls.
   parameter C3_MEMCLK_PERIOD        = 3000,       
                                       // Memory data transfer clock period
   parameter C3_CALIB_SOFT_IP        = "TRUE",       
                                       // # = TRUE, Enables the soft calibration logic,
                                       // # = FALSE, Disables the soft calibration logic.
   parameter C3_SIMULATION           = "FALSE",       
                                       // # = TRUE, Simulating the design. Useful to reduce the simulation time,
                                       // # = FALSE, Implementing the design.
   parameter C3_HW_TESTING           = "FALSE",       
                                       // Determines the address space accessed by the traffic generator,
                                       // # = FALSE, Smaller address space,
                                       // # = TRUE, Large address space.
   parameter C3_RST_ACT_LOW          = 0,       
                                       // # = 1 for active low reset,
                                       // # = 0 for active high reset.
   parameter C3_INPUT_CLK_TYPE       = "SINGLE_ENDED",       
                                       // input clock type DIFFERENTIAL or SINGLE_ENDED
   parameter C3_MEM_ADDR_ORDER       = "BANK_ROW_COLUMN",       
                                       // The order in which user address is provided to the memory controller,
                                       // ROW_BANK_COLUMN or BANK_ROW_COLUMN
   parameter C3_NUM_DQ_PINS          = 16,       
                                       // External memory data width
   parameter C3_MEM_ADDR_WIDTH       = 13,       
                                       // External memory address width
   parameter C3_MEM_BANKADDR_WIDTH   = 3        
                                       // External memory bank address width
)	

(
   output reg                                       o_led,
   output                                           calib_done,
   output                                           error,
   output                                           o_uart_tx,
   output                                           rst,

   inout  [C3_NUM_DQ_PINS-1:0]                      mcb3_dram_dq,
   output [C3_MEM_ADDR_WIDTH-1:0]                   mcb3_dram_a,
   output [C3_MEM_BANKADDR_WIDTH-1:0]               mcb3_dram_ba,
   output                                           mcb3_dram_ras_n,
   output                                           mcb3_dram_cas_n,
   output                                           mcb3_dram_we_n,
   output                                           mcb3_dram_odt,
   output                                           mcb3_dram_reset_n,
   output                                           mcb3_dram_cke,
   output                                           mcb3_dram_dm,
   inout                                            mcb3_dram_udqs,
   inout                                            mcb3_dram_udqs_n,
   inout                                            mcb3_rzq,
   inout                                            mcb3_zio,
   output                                           mcb3_dram_udm,
   input                                            c3_sys_clk,
//   input                                            c3_sys_rst_i,
   inout                                            mcb3_dram_dqs,
   inout                                            mcb3_dram_dqs_n,
   output                                           mcb3_dram_ck,
   output                                           mcb3_dram_ck_n
);
// The parameter CX_PORT_ENABLE shows all the active user ports in the design.
// For example, the value 6'b111100 tells that only port-2, port-3, port-4
// and port-5 are enabled. The other two ports are inactive. An inactive port
// can be a disabled port or an invisible logical port. Few examples to the 
// invisible logical port are port-4 and port-5 in the user port configuration,
// Config-2: Four 32-bit bi-directional ports and the ports port-2 through
// port-5 in Config-4: Two 64-bit bi-directional ports. Please look into the 
// Chapter-2 of ug388.pdf in the /docs directory for further details.
   localparam C3_PORT_ENABLE              = 6'b000001;
   localparam C3_PORT_CONFIG             =  "B32_B32_R32_R32_R32_R32";
   localparam C3_P0_PORT_MODE             =  "BI_MODE";
   localparam C3_P1_PORT_MODE             =  "NONE";
   localparam C3_P2_PORT_MODE             =  "NONE";
   localparam C3_P3_PORT_MODE             =  "NONE";
   localparam C3_P4_PORT_MODE             =  "NONE";
   localparam C3_P5_PORT_MODE             =  "NONE";
   localparam C3_CLKOUT0_DIVIDE       = 1;       
   localparam C3_CLKOUT1_DIVIDE       = 1;       
   localparam C3_CLKOUT2_DIVIDE       = 13;//16;       
   localparam C3_CLKOUT3_DIVIDE       = 6;       
   localparam C3_CLKFBOUT_MULT        = 2;       
   localparam C3_DIVCLK_DIVIDE        = 1;       
   localparam C3_ARB_ALGORITHM        = 0;       
   localparam C3_ARB_NUM_TIME_SLOTS   = 12;       
   localparam C3_ARB_TIME_SLOT_0      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_1      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_2      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_3      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_4      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_5      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_6      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_7      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_8      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_9      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_10     = 3'o0;       
   localparam C3_ARB_TIME_SLOT_11     = 3'o0;       
   localparam C3_MEM_TRAS             = 37500;       
   localparam C3_MEM_TRCD             = 13130;       
   localparam C3_MEM_TREFI            = 7800000;       
   localparam C3_MEM_TRFC             = 110000;       
   localparam C3_MEM_TRP              = 13130;       
   localparam C3_MEM_TWR              = 15000;       
   localparam C3_MEM_TRTP             = 7500;       
   localparam C3_MEM_TWTR             = 7500;       
   localparam C3_MEM_TYPE             = "DDR3";       
   localparam C3_MEM_DENSITY          = "1Gb";       
   localparam C3_MEM_BURST_LEN        = 8;       
   localparam C3_MEM_CAS_LATENCY      = 6;       
   localparam C3_MEM_NUM_COL_BITS     = 10;       
   localparam C3_MEM_DDR1_2_ODS       = "FULL";       
   localparam C3_MEM_DDR2_RTT         = "150OHMS";       
   localparam C3_MEM_DDR2_DIFF_DQS_EN  = "YES";       
   localparam C3_MEM_DDR2_3_PA_SR     = "FULL";       
   localparam C3_MEM_DDR2_3_HIGH_TEMP_SR  = "NORMAL";       
   localparam C3_MEM_DDR3_CAS_LATENCY  = 6;       
   localparam C3_MEM_DDR3_ODS         = "DIV6";       
   localparam C3_MEM_DDR3_RTT         = "DIV2";       
   localparam C3_MEM_DDR3_CAS_WR_LATENCY  = 5;       
   localparam C3_MEM_DDR3_AUTO_SR     = "ENABLED";       
   localparam C3_MEM_MOBILE_PA_SR     = "FULL";       
   localparam C3_MEM_MDDR_ODS         = "FULL";       
   localparam C3_MC_CALIB_BYPASS      = "NO";       
   localparam C3_MC_CALIBRATION_MODE  = "CALIBRATION";       
   localparam C3_MC_CALIBRATION_DELAY  = "HALF";       
   localparam C3_SKIP_IN_TERM_CAL     = 0;       
   localparam C3_SKIP_DYNAMIC_CAL     = 0;       
   localparam C3_LDQSP_TAP_DELAY_VAL  = 0;       
   localparam C3_LDQSN_TAP_DELAY_VAL  = 0;       
   localparam C3_UDQSP_TAP_DELAY_VAL  = 0;       
   localparam C3_UDQSN_TAP_DELAY_VAL  = 0;       
   localparam C3_DQ0_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ1_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ2_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ3_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ4_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ5_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ6_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ7_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ8_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ9_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ10_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ11_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ12_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ13_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ14_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ15_TAP_DELAY_VAL   = 0;       
   localparam C3_MCB_USE_EXTERNAL_BUFPLL  = 1;       
   localparam C3_SMALL_DEVICE         = "FALSE";       // The parameter is set to TRUE for all packages of xc6slx9 device
                                                       // as most of them cannot fit the complete example design when the
                                                       // Chip scope modules are enabled
   localparam C3_INCLK_PERIOD         = ((C3_MEMCLK_PERIOD * C3_CLKFBOUT_MULT) / (C3_DIVCLK_DIVIDE * C3_CLKOUT0_DIVIDE * 2));       
   localparam C3_p0_BEGIN_ADDRESS                   = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p0_DATA_MODE                       = 4'b0010;
   localparam C3_p0_END_ADDRESS                     = (C3_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000002ff;
   localparam C3_p0_PRBS_EADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffffc00;
   localparam C3_p0_PRBS_SADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p1_BEGIN_ADDRESS                   = (C3_HW_TESTING == "TRUE") ? 32'h03000000:32'h00000300;
   localparam C3_p1_DATA_MODE                       = 4'b0010;
   localparam C3_p1_END_ADDRESS                     = (C3_HW_TESTING == "TRUE") ? 32'h04ffffff:32'h000004ff;
   localparam C3_p1_PRBS_EADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'hf8000000:32'hfffff800;
   localparam C3_p1_PRBS_SADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'h03000000:32'h00000300;
   localparam C3_p2_BEGIN_ADDRESS                   = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p2_DATA_MODE                       = 4'b0010;
   localparam C3_p2_END_ADDRESS                     = (C3_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000002ff;
   localparam C3_p2_PRBS_EADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffffc00;
   localparam C3_p2_PRBS_SADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p3_BEGIN_ADDRESS                   = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p3_DATA_MODE                       = 4'b0010;
   localparam C3_p3_END_ADDRESS                     = (C3_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000002ff;
   localparam C3_p3_PRBS_EADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffffc00;
   localparam C3_p3_PRBS_SADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p4_BEGIN_ADDRESS                   = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p4_DATA_MODE                       = 4'b0010;
   localparam C3_p4_END_ADDRESS                     = (C3_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000002ff;
   localparam C3_p4_PRBS_EADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffffc00;
   localparam C3_p4_PRBS_SADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p5_BEGIN_ADDRESS                   = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p5_DATA_MODE                       = 4'b0010;
   localparam C3_p5_END_ADDRESS                     = (C3_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000002ff;
   localparam C3_p5_PRBS_EADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffffc00;
   localparam C3_p5_PRBS_SADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam DBG_WR_STS_WIDTH        = 32;
   localparam DBG_RD_STS_WIDTH        = 32;
   localparam C3_ARB_TIME0_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_0[2:0]};
   localparam C3_ARB_TIME1_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_1[2:0]};
   localparam C3_ARB_TIME2_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_2[2:0]};
   localparam C3_ARB_TIME3_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_3[2:0]};
   localparam C3_ARB_TIME4_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_4[2:0]};
   localparam C3_ARB_TIME5_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_5[2:0]};
   localparam C3_ARB_TIME6_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_6[2:0]};
   localparam C3_ARB_TIME7_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_7[2:0]};
   localparam C3_ARB_TIME8_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_8[2:0]};
   localparam C3_ARB_TIME9_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_9[2:0]};
   localparam C3_ARB_TIME10_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_10[2:0]};
   localparam C3_ARB_TIME11_SLOT  = {3'b000, 3'b000, 3'b000, 3'b000, 3'b000, C3_ARB_TIME_SLOT_11[2:0]};

  wire                              c3_sys_clk_p;
  wire                              c3_sys_clk_n;
  wire                              c3_error;
  wire                              c3_calib_done;
  wire                              c3_clk0;
  wire                              c3_rst0;
  wire                              c3_async_rst;
  wire                              c3_sysclk_2x;
  wire                              c3_sysclk_2x_180;
  wire                              c3_pll_ce_0;
  wire                              c3_pll_ce_90;
  wire                              c3_pll_lock;
  wire                              c3_mcb_drp_clk;
  wire                              c3_cmp_error;
  wire                              c3_cmp_data_valid;
  wire                              c3_vio_modify_enable;
  wire  [127:0]                                 c3_p0_error_status;
  wire  [127:0]                                 c3_p1_error_status;
  wire  [127:0]                                 c3_p2_error_status;
  wire  [127:0]                                 c3_p3_error_status;
  wire  [127:0]                                 c3_p4_error_status;
  wire  [127:0]                                 c3_p5_error_status;
  wire  [2:0]                      c3_vio_data_mode_value;
  wire  [2:0]                      c3_vio_addr_mode_value;
  wire  [31:0]                      c3_cmp_data;

reg       reset = 0;

//reg 				c3_p0_cmd_clk;
reg				c3_p0_cmd_en = 0;
reg [2:0]		c3_p0_cmd_instr = 0;
reg [5:0]		c3_p0_cmd_bl = 0;
reg [29:0]		c3_p0_cmd_byte_addr = 0;
wire 				c3_p0_cmd_empty;
wire				c3_p0_cmd_full;

//reg				c3_p0_wr_clk;
reg				c3_p0_wr_en = 0;
reg [C3_P0_MASK_SIZE-1:0]	c3_p0_wr_mask = 0;
reg [C3_P0_DATA_PORT_SIZE-1:0]	c3_p0_wr_data = 0;
wire				c3_p0_wr_full;
wire				c3_p0_wr_empty;
wire [6:0]		c3_p0_wr_count;
wire				c3_p0_wr_underrun;
wire				c3_p0_wr_error;

//reg 				c3_p0_rd_clk;
reg				c3_p0_rd_en = 0;
wire [C3_P0_DATA_PORT_SIZE-1:0]	c3_p0_rd_data;
wire				c3_p0_rd_full;
wire 				c3_p0_rd_empty;
wire [6:0]		c3_p0_rd_count;
wire				c3_p0_rd_overflow;
wire				c3_p0_rd_error;



// Infrastructure-3 instantiation
      infrastructure #
      (
         .C_INCLK_PERIOD                 (C3_INCLK_PERIOD),
         .C_RST_ACT_LOW                  (C3_RST_ACT_LOW),
         .C_INPUT_CLK_TYPE               (C3_INPUT_CLK_TYPE),
         .C_CLKOUT0_DIVIDE               (C3_CLKOUT0_DIVIDE),
         .C_CLKOUT1_DIVIDE               (C3_CLKOUT1_DIVIDE),
         .C_CLKOUT2_DIVIDE               (C3_CLKOUT2_DIVIDE),
         .C_CLKOUT3_DIVIDE               (C3_CLKOUT3_DIVIDE),
         .C_CLKFBOUT_MULT                (C3_CLKFBOUT_MULT),
         .C_DIVCLK_DIVIDE                (C3_DIVCLK_DIVIDE)
      )
      memc3_infrastructure_inst
      (

         .sys_clk_p                      (c3_sys_clk_p),  // [input] differential p type clock from board
         .sys_clk_n                      (c3_sys_clk_n),  // [input] differential n type clock from board
         .sys_clk                        (sys_clk_ibufg), // [input] single ended input clock from board
         .sys_rst                        (reset),//c3_sys_rst_i),  
         .clk0                           (c3_clk0),       // [output] user clock which determines the operating frequency of user interface ports
         .rst0                           (c3_rst0),
         .async_rst                      (c3_async_rst),
         .sysclk_2x                      (c3_sysclk_2x),
         .sysclk_2x_180                  (c3_sysclk_2x_180),
         .pll_ce_0                       (c3_pll_ce_0),
         .pll_ce_90                      (c3_pll_ce_90),
         .pll_lock                       (c3_pll_lock),
         .mcb_drp_clk                    (c3_mcb_drp_clk)
      );
   


// Controller-3 instantiation
      memc_wrapper #
      (
         .C_MEMCLK_PERIOD                (C3_MEMCLK_PERIOD),   
         .C_CALIB_SOFT_IP                (C3_CALIB_SOFT_IP),
         //synthesis translate_off
         .C_SIMULATION                   (C3_SIMULATION),
         //synthesis translate_on
         .C_ARB_NUM_TIME_SLOTS           (C3_ARB_NUM_TIME_SLOTS),
         .C_ARB_TIME_SLOT_0              (C3_ARB_TIME0_SLOT),
         .C_ARB_TIME_SLOT_1              (C3_ARB_TIME1_SLOT),
         .C_ARB_TIME_SLOT_2              (C3_ARB_TIME2_SLOT),
         .C_ARB_TIME_SLOT_3              (C3_ARB_TIME3_SLOT),
         .C_ARB_TIME_SLOT_4              (C3_ARB_TIME4_SLOT),
         .C_ARB_TIME_SLOT_5              (C3_ARB_TIME5_SLOT),
         .C_ARB_TIME_SLOT_6              (C3_ARB_TIME6_SLOT),
         .C_ARB_TIME_SLOT_7              (C3_ARB_TIME7_SLOT),
         .C_ARB_TIME_SLOT_8              (C3_ARB_TIME8_SLOT),
         .C_ARB_TIME_SLOT_9              (C3_ARB_TIME9_SLOT),
         .C_ARB_TIME_SLOT_10             (C3_ARB_TIME10_SLOT),
         .C_ARB_TIME_SLOT_11             (C3_ARB_TIME11_SLOT),
         .C_ARB_ALGORITHM                (C3_ARB_ALGORITHM),
         .C_PORT_ENABLE                  (C3_PORT_ENABLE),
         .C_PORT_CONFIG                  (C3_PORT_CONFIG),
         .C_MEM_TRAS                     (C3_MEM_TRAS),
         .C_MEM_TRCD                     (C3_MEM_TRCD),
         .C_MEM_TREFI                    (C3_MEM_TREFI),
         .C_MEM_TRFC                     (C3_MEM_TRFC),
         .C_MEM_TRP                      (C3_MEM_TRP),
         .C_MEM_TWR                      (C3_MEM_TWR),
         .C_MEM_TRTP                     (C3_MEM_TRTP),
         .C_MEM_TWTR                     (C3_MEM_TWTR),
         .C_MEM_ADDR_ORDER               (C3_MEM_ADDR_ORDER),
         .C_NUM_DQ_PINS                  (C3_NUM_DQ_PINS),
         .C_MEM_TYPE                     (C3_MEM_TYPE),
         .C_MEM_DENSITY                  (C3_MEM_DENSITY),
         .C_MEM_BURST_LEN                (C3_MEM_BURST_LEN),
         .C_MEM_CAS_LATENCY              (C3_MEM_CAS_LATENCY),
         .C_MEM_ADDR_WIDTH               (C3_MEM_ADDR_WIDTH),
         .C_MEM_BANKADDR_WIDTH           (C3_MEM_BANKADDR_WIDTH),
         .C_MEM_NUM_COL_BITS             (C3_MEM_NUM_COL_BITS),
         .C_MEM_DDR1_2_ODS               (C3_MEM_DDR1_2_ODS),
         .C_MEM_DDR2_RTT                 (C3_MEM_DDR2_RTT),
         .C_MEM_DDR2_DIFF_DQS_EN         (C3_MEM_DDR2_DIFF_DQS_EN),
         .C_MEM_DDR2_3_PA_SR             (C3_MEM_DDR2_3_PA_SR),
         .C_MEM_DDR2_3_HIGH_TEMP_SR      (C3_MEM_DDR2_3_HIGH_TEMP_SR),
         .C_MEM_DDR3_CAS_LATENCY         (C3_MEM_DDR3_CAS_LATENCY),
         .C_MEM_DDR3_ODS                 (C3_MEM_DDR3_ODS),
         .C_MEM_DDR3_RTT                 (C3_MEM_DDR3_RTT),
         .C_MEM_DDR3_CAS_WR_LATENCY      (C3_MEM_DDR3_CAS_WR_LATENCY),
         .C_MEM_DDR3_AUTO_SR             (C3_MEM_DDR3_AUTO_SR),
         .C_MEM_MOBILE_PA_SR             (C3_MEM_MOBILE_PA_SR),
         .C_MEM_MDDR_ODS                 (C3_MEM_MDDR_ODS),
         .C_MC_CALIB_BYPASS              (C3_MC_CALIB_BYPASS),
         .C_MC_CALIBRATION_MODE          (C3_MC_CALIBRATION_MODE),
         .C_MC_CALIBRATION_DELAY         (C3_MC_CALIBRATION_DELAY),
         .C_SKIP_IN_TERM_CAL             (C3_SKIP_IN_TERM_CAL),
         .C_SKIP_DYNAMIC_CAL             (C3_SKIP_DYNAMIC_CAL),
         .LDQSP_TAP_DELAY_VAL            (C3_LDQSP_TAP_DELAY_VAL),
         .UDQSP_TAP_DELAY_VAL            (C3_UDQSP_TAP_DELAY_VAL),
         .LDQSN_TAP_DELAY_VAL            (C3_LDQSN_TAP_DELAY_VAL),
         .UDQSN_TAP_DELAY_VAL            (C3_UDQSN_TAP_DELAY_VAL),
         .DQ0_TAP_DELAY_VAL              (C3_DQ0_TAP_DELAY_VAL),
         .DQ1_TAP_DELAY_VAL              (C3_DQ1_TAP_DELAY_VAL),
         .DQ2_TAP_DELAY_VAL              (C3_DQ2_TAP_DELAY_VAL),
         .DQ3_TAP_DELAY_VAL              (C3_DQ3_TAP_DELAY_VAL),
         .DQ4_TAP_DELAY_VAL              (C3_DQ4_TAP_DELAY_VAL),
         .DQ5_TAP_DELAY_VAL              (C3_DQ5_TAP_DELAY_VAL),
         .DQ6_TAP_DELAY_VAL              (C3_DQ6_TAP_DELAY_VAL),
         .DQ7_TAP_DELAY_VAL              (C3_DQ7_TAP_DELAY_VAL),
         .DQ8_TAP_DELAY_VAL              (C3_DQ8_TAP_DELAY_VAL),
         .DQ9_TAP_DELAY_VAL              (C3_DQ9_TAP_DELAY_VAL),
         .DQ10_TAP_DELAY_VAL             (C3_DQ10_TAP_DELAY_VAL),
         .DQ11_TAP_DELAY_VAL             (C3_DQ11_TAP_DELAY_VAL),
         .DQ12_TAP_DELAY_VAL             (C3_DQ12_TAP_DELAY_VAL),
         .DQ13_TAP_DELAY_VAL             (C3_DQ13_TAP_DELAY_VAL),
         .DQ14_TAP_DELAY_VAL             (C3_DQ14_TAP_DELAY_VAL),
         .DQ15_TAP_DELAY_VAL             (C3_DQ15_TAP_DELAY_VAL),
         .C_P0_MASK_SIZE                 (C3_P0_MASK_SIZE),
         .C_P0_DATA_PORT_SIZE            (C3_P0_DATA_PORT_SIZE),
         .C_P1_MASK_SIZE                 (C3_P1_MASK_SIZE),
         .C_P1_DATA_PORT_SIZE            (C3_P1_DATA_PORT_SIZE)
	)
      
      memc3_wrapper_inst
      (
         .mcbx_dram_addr                 (mcb3_dram_a), 
         .mcbx_dram_ba                   (mcb3_dram_ba),
         .mcbx_dram_ras_n                (mcb3_dram_ras_n), 
         .mcbx_dram_cas_n                (mcb3_dram_cas_n), 
         .mcbx_dram_we_n                 (mcb3_dram_we_n), 
         .mcbx_dram_cke                  (mcb3_dram_cke), 
         .mcbx_dram_clk                  (mcb3_dram_ck), 
         .mcbx_dram_clk_n                (mcb3_dram_ck_n), 
         .mcbx_dram_dq                   (mcb3_dram_dq),
         .mcbx_dram_dqs                  (mcb3_dram_dqs), 
         .mcbx_dram_dqs_n                (mcb3_dram_dqs_n), 
         .mcbx_dram_udqs                 (mcb3_dram_udqs), 
         .mcbx_dram_udqs_n               (mcb3_dram_udqs_n), 
         .mcbx_dram_udm                  (mcb3_dram_udm), 
         .mcbx_dram_ldm                  (mcb3_dram_dm), 
         .mcbx_dram_odt                  (mcb3_dram_odt), 
         .mcbx_dram_ddr3_rst             (mcb3_dram_reset_n), 
         .mcbx_rzq                       (mcb3_rzq),
         .mcbx_zio                       (mcb3_zio),
         .calib_done                     (c3_calib_done),
         .async_rst                      (c3_async_rst),
         .sysclk_2x                      (c3_sysclk_2x), 
         .sysclk_2x_180                  (c3_sysclk_2x_180), 
         .pll_ce_0                       (c3_pll_ce_0),
         .pll_ce_90                      (c3_pll_ce_90), 
         .pll_lock                       (c3_pll_lock),
         .mcb_drp_clk                    (c3_mcb_drp_clk), 
     
         // The following port map shows all the six logical user ports. However, all
	 // of them may not be active in this design. A port should be enabled to 
	 // validate its port map. If it is not,the complete port is going to float 
	 // by getting disconnected from the lower level MCB modules. The port enable
	 // information of a controller can be obtained from the corresponding local
	 // parameter CX_PORT_ENABLE. In such a case, we can simply ignore its port map.
	 // The following comments will explain when a port is going to be active.
	 // Config-1: Two 32-bit bi-directional and four 32-bit unidirectional ports
	 // Config-2: Four 32-bit bi-directional ports
	 // Config-3: One 64-bit bi-directional and two 32-bit bi-directional ports
	 // Config-4: Two 64-bit bi-directional ports
	 // Config-5: One 128-bit bi-directional port

         // User Port-0 command interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
         .p0_cmd_clk                     (c3_clk0), 
         .p0_cmd_en                      (c3_p0_cmd_en), 
         .p0_cmd_instr                   (c3_p0_cmd_instr),
         .p0_cmd_bl                      (c3_p0_cmd_bl), 
         .p0_cmd_byte_addr               (c3_p0_cmd_byte_addr), 
         .p0_cmd_full                    (c3_p0_cmd_full),
         .p0_cmd_empty                   (c3_p0_cmd_empty),
         // User Port-0 data write interface will be active only when the port is enabled in
         // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
         .p0_wr_clk                      (c3_clk0), 
         .p0_wr_en                       (c3_p0_wr_en),
         .p0_wr_mask                     (c3_p0_wr_mask),
         .p0_wr_data                     (c3_p0_wr_data),
         .p0_wr_full                     (c3_p0_wr_full),
         .p0_wr_count                    (c3_p0_wr_count),
         .p0_wr_empty                    (c3_p0_wr_empty),
         .p0_wr_underrun                 (c3_p0_wr_underrun),
         .p0_wr_error                    (c3_p0_wr_error),
         // User Port-0 data read interface will be active only when the port is enabled in
         // the port configurations Config-1, Config-2, Config-3, Config-4 and Config-5
         .p0_rd_clk                      (c3_clk0), 
         .p0_rd_en                       (c3_p0_rd_en),
         .p0_rd_data                     (c3_p0_rd_data),
         .p0_rd_empty                    (c3_p0_rd_empty),
         .p0_rd_count                    (c3_p0_rd_count),
         .p0_rd_full                     (c3_p0_rd_full),
         .p0_rd_overflow                 (c3_p0_rd_overflow),
         .p0_rd_error                    (c3_p0_rd_error),
 
         // User Port-1 command interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3 and Config-4
         .p1_cmd_clk                     (c3_clk0), 
         .p1_cmd_en                      (c3_p1_cmd_en), 
         .p1_cmd_instr                   (c3_p1_cmd_instr),
         .p1_cmd_bl                      (c3_p1_cmd_bl), 
         .p1_cmd_byte_addr               (c3_p1_cmd_byte_addr), 
         .p1_cmd_full                    (c3_p1_cmd_full),
         .p1_cmd_empty                   (c3_p1_cmd_empty),
         // User Port-1 data write interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3 and Config-4
         .p1_wr_clk                      (c3_clk0), 
         .p1_wr_en                       (c3_p1_wr_en),
         .p1_wr_mask                     (c3_p1_wr_mask),
         .p1_wr_data                     (c3_p1_wr_data),
         .p1_wr_full                     (c3_p1_wr_full),
         .p1_wr_count                    (c3_p1_wr_count),
         .p1_wr_empty                    (c3_p1_wr_empty),
         .p1_wr_underrun                 (c3_p1_wr_underrun),
         .p1_wr_error                    (c3_p1_wr_error),
         // User Port-1 data read interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2, Config-3 and Config-4
         .p1_rd_clk                      (c3_clk0), 
         .p1_rd_en                       (c3_p1_rd_en),
         .p1_rd_data                     (c3_p1_rd_data),
         .p1_rd_empty                    (c3_p1_rd_empty),
         .p1_rd_count                    (c3_p1_rd_count),
         .p1_rd_full                     (c3_p1_rd_full),
         .p1_rd_overflow                 (c3_p1_rd_overflow),
         .p1_rd_error                    (c3_p1_rd_error),
      
         // User Port-2 command interface will be active only when the port is enabled in 
         // the port configurations Config-1, Config-2 and Config-3
         .p2_cmd_clk                     (c3_clk0), 
         .p2_cmd_en                      (c3_p2_cmd_en), 
         .p2_cmd_instr                   (c3_p2_cmd_instr),
         .p2_cmd_bl                      (c3_p2_cmd_bl), 
         .p2_cmd_byte_addr               (c3_p2_cmd_byte_addr), 
         .p2_cmd_full                    (c3_p2_cmd_full),
         .p2_cmd_empty                   (c3_p2_cmd_empty),
         // User Port-2 data write interface will be active only when the port is enabled in 
         // the port configurations Config-1 write direction, Config-2 and Config-3
         .p2_wr_clk                      (c3_clk0), 
         .p2_wr_en                       (c3_p2_wr_en),
         .p2_wr_mask                     (c3_p2_wr_mask),
         .p2_wr_data                     (c3_p2_wr_data),
         .p2_wr_full                     (c3_p2_wr_full),
         .p2_wr_count                    (c3_p2_wr_count),
         .p2_wr_empty                    (c3_p2_wr_empty),
         .p2_wr_underrun                 (c3_p2_wr_underrun),
         .p2_wr_error                    (c3_p2_wr_error),
         // User Port-2 data read interface will be active only when the port is enabled in 
         // the port configurations Config-1 read direction, Config-2 and Config-3
         .p2_rd_clk                      (c3_clk0), 
         .p2_rd_en                       (c3_p2_rd_en),
         .p2_rd_data                     (c3_p2_rd_data),
         .p2_rd_empty                    (c3_p2_rd_empty),
         .p2_rd_count                    (c3_p2_rd_count),
         .p2_rd_full                     (c3_p2_rd_full),
         .p2_rd_overflow                 (c3_p2_rd_overflow),
         .p2_rd_error                    (c3_p2_rd_error),
      
         // User Port-3 command interface will be active only when the port is enabled in 
         // the port configurations Config-1 and Config-2
         .p3_cmd_clk                     (c3_clk0), 
         .p3_cmd_en                      (c3_p3_cmd_en), 
         .p3_cmd_instr                   (c3_p3_cmd_instr),
         .p3_cmd_bl                      (c3_p3_cmd_bl), 
         .p3_cmd_byte_addr               (c3_p3_cmd_byte_addr), 
         .p3_cmd_full                    (c3_p3_cmd_full),
         .p3_cmd_empty                   (c3_p3_cmd_empty),
         // User Port-3 data write interface will be active only when the port is enabled in 
         // the port configurations Config-1 write direction and Config-2
         .p3_wr_clk                      (c3_clk0), 
         .p3_wr_en                       (c3_p3_wr_en),
         .p3_wr_mask                     (c3_p3_wr_mask),
         .p3_wr_data                     (c3_p3_wr_data),
         .p3_wr_full                     (c3_p3_wr_full),
         .p3_wr_count                    (c3_p3_wr_count),
         .p3_wr_empty                    (c3_p3_wr_empty),
         .p3_wr_underrun                 (c3_p3_wr_underrun),
         .p3_wr_error                    (c3_p3_wr_error),
         // User Port-3 data read interface will be active only when the port is enabled in 
         // the port configurations Config-1 read direction and Config-2
         .p3_rd_clk                      (c3_clk0), 
         .p3_rd_en                       (c3_p3_rd_en),
         .p3_rd_data                     (c3_p3_rd_data),
         .p3_rd_empty                    (c3_p3_rd_empty),
         .p3_rd_count                    (c3_p3_rd_count),
         .p3_rd_full                     (c3_p3_rd_full),
         .p3_rd_overflow                 (c3_p3_rd_overflow),
         .p3_rd_error                    (c3_p3_rd_error),
      
         // User Port-4 command interface will be active only when the port is enabled in 
         // the port configuration Config-1
         .p4_cmd_clk                     (c3_clk0), 
         .p4_cmd_en                      (c3_p4_cmd_en), 
         .p4_cmd_instr                   (c3_p4_cmd_instr),
         .p4_cmd_bl                      (c3_p4_cmd_bl), 
         .p4_cmd_byte_addr               (c3_p4_cmd_byte_addr), 
         .p4_cmd_full                    (c3_p4_cmd_full),
         .p4_cmd_empty                   (c3_p4_cmd_empty),
         // User Port-4 data write interface will be active only when the port is enabled in 
         // the port configuration Config-1 write direction
         .p4_wr_clk                      (c3_clk0), 
         .p4_wr_en                       (c3_p4_wr_en),
         .p4_wr_mask                     (c3_p4_wr_mask),
         .p4_wr_data                     (c3_p4_wr_data),
         .p4_wr_full                     (c3_p4_wr_full),
         .p4_wr_count                    (c3_p4_wr_count),
         .p4_wr_empty                    (c3_p4_wr_empty),
         .p4_wr_underrun                 (c3_p4_wr_underrun),
         .p4_wr_error                    (c3_p4_wr_error),
         // User Port-4 data read interface will be active only when the port is enabled in 
         // the port configuration Config-1 read direction
         .p4_rd_clk                      (c3_clk0), 
         .p4_rd_en                       (c3_p4_rd_en),
         .p4_rd_data                     (c3_p4_rd_data),
         .p4_rd_empty                    (c3_p4_rd_empty),
         .p4_rd_count                    (c3_p4_rd_count),
         .p4_rd_full                     (c3_p4_rd_full),
         .p4_rd_overflow                 (c3_p4_rd_overflow),
         .p4_rd_error                    (c3_p4_rd_error),
      
         // User Port-5 command interface will be active only when the port is enabled in 
         // the port configuration Config-1
         .p5_cmd_clk                     (c3_clk0), 
         .p5_cmd_en                      (c3_p5_cmd_en), 
         .p5_cmd_instr                   (c3_p5_cmd_instr),
         .p5_cmd_bl                      (c3_p5_cmd_bl), 
         .p5_cmd_byte_addr               (c3_p5_cmd_byte_addr), 
         .p5_cmd_full                    (c3_p5_cmd_full),
         .p5_cmd_empty                   (c3_p5_cmd_empty),
         // User Port-5 data write interface will be active only when the port is enabled in 
         // the port configuration Config-1 write direction
         .p5_wr_clk                      (c3_clk0), 
         .p5_wr_en                       (c3_p5_wr_en),
         .p5_wr_mask                     (c3_p5_wr_mask),
         .p5_wr_data                     (c3_p5_wr_data),
         .p5_wr_full                     (c3_p5_wr_full),
         .p5_wr_count                    (c3_p5_wr_count),
         .p5_wr_empty                    (c3_p5_wr_empty),
         .p5_wr_underrun                 (c3_p5_wr_underrun),
         .p5_wr_error                    (c3_p5_wr_error),
         // User Port-5 data read interface will be active only when the port is enabled in 
         // the port configuration Config-1 read direction
         .p5_rd_clk                      (c3_clk0), 
         .p5_rd_en                       (c3_p5_rd_en),
         .p5_rd_data                     (c3_p5_rd_data),
         .p5_rd_empty                    (c3_p5_rd_empty),
         .p5_rd_count                    (c3_p5_rd_count),
         .p5_rd_full                     (c3_p5_rd_full),
         .p5_rd_overflow                 (c3_p5_rd_overflow),
         .p5_rd_error                    (c3_p5_rd_error),

         .selfrefresh_enter              (1'b0), 
         .selfrefresh_mode               (c3_selfrefresh_mode)
      );
   
   
// My test ram ------------------------------------------------------------------------------------------
// Тестируем DDR3
// При запуске и во время теста - светодиод мигает
// если есть ошибка - светодиод ГОРИТ постоянно
// если ошибок НЕТ - светодиод НЕ ГОРИТ
//

localparam LED_OFF   = 0;
localparam LED_ON    = 1;
localparam LED_BLINK = 2;
reg [1:0] led_en = LED_BLINK;


reg [31:0] utx_d  = 0;
reg        utx_we = 0;
wire       utx_ready;

// Начальный и конечный адрес теста памяти
localparam MEM_ADR_START = 30'h00_00_00_00;
localparam MEM_ADR_STOP  = 30'h08_00_00_00-4; // 1GB = 0x8_000_000

// Патерн которым тестируем
wire [127:0] MEM_PATTERN = {32'h00000000,32'hffffffff,32'h55555555,32'haaaaaaaa};
localparam MEM_PATTERN_COUNT = 4-1; // количество патернов в MEM_PATTERN - 1
reg [2:0] mem_pattern_count = 0;

reg [31:0] mem_data      = 32'h00_00_00_00;
reg [29:0] mem_adr       = MEM_ADR_START;
reg        mem_error     = 0;

reg [31:0] utx_mem_dataw  = 0;
reg [31:0] utx_mem_datar  = 0;
reg [31:0] utx_mem_adr  = 0;

wire uart_tx;
reg mux_uart_str0_hex1 = 0; // =0 print printf_mem_adr_data, =1 uart_tx_string_8char
wire       o_uart_tx_str;
assign o_uart_tx = mux_uart_str0_hex1 == 0 ? o_uart_tx_str : uart_tx;
reg [63:0] str = 0;
reg        utx_we_str = 0;
wire       utx_ready_str;


printf_mem_adr_data PRINT_STRING_HEX
(
    .i_clk        (c3_clk0),
    .i_mem_adr    (utx_mem_adr),
    .i_mem_dataw  (utx_mem_dataw),
    .i_mem_datar  (utx_mem_datar),
    .i_we         (utx_we),
    .o_uart_tx    (uart_tx),
    .o_ready      (utx_ready)
);


uart_tx_string_8char PRINT_STRING_8_CHAR
(
    .i_clk        (c3_clk0),
    .i_data       (str),
    .i_we         (utx_we_str),
    .o_uart_tx    (o_uart_tx_str),
    .o_ready      (utx_ready_str)
);




reg [7:0] st = 0;

always @(posedge c3_clk0)
begin
    case (st)
	 0:
	 begin
		  str <= "\nTEST: \n";
		  utx_we_str <= 1;
		  st <= st + 1'b1;
	 end
	 
	 1:
	 begin
	     utx_we_str <= 0;
		  if (c3_calib_done) st <= st + 1'b1; 
	 end
	 
	 2:
	 begin
	     led_en <= LED_BLINK;
        st <= st + 1'b1;
	 end
	 
	 3:
	 begin
		  if (utx_ready_str) begin
		      mux_uart_str0_hex1 <= 1; // set mode uart tx string hex
		      st <= st + 1'b1;
		  end
    end
	 
	 4:
	 begin
	     st <= st + 1'b1;
	 end
	 
	 5:
	 begin
		  if (utx_ready == 1) begin
		      st <= st + 1'b1;
		  end
	 end
	 
	 6: // Write new data
	 begin
//	     $display("Write to FIFO 0x%X %t", mem_data, $time);
        case (mem_pattern_count)
		  0:mem_data <= MEM_PATTERN[31 : 0];
		  1:mem_data <= MEM_PATTERN[63 : 32];
		  2:mem_data <= MEM_PATTERN[95 : 64];
		  3:mem_data <= MEM_PATTERN[127: 96];
		  default:mem_data <= MEM_PATTERN[127: 96];
		  endcase
        st <= st + 1'b1;
    end
	 
	 7:
    begin
		  c3_p0_wr_data <= mem_data;
		  c3_p0_wr_mask <= 4'b0000; // =0 no mask bytes
		  c3_p0_wr_en <= 1;
		  st <= st + 1'b1;
	 end
	 
	 8:
	 begin
	     c3_p0_wr_en <= 0; // 1 - dword
		  st <= st + 1'b1;
	 end
	 
	 9:
	 begin
		  st <= st + 1'b1;
	 end
	 
	 10:
	 begin
		  st <= st + 1'b1;
	 end
	 
	 11:
	 begin
	     c3_p0_cmd_instr <= 3'b000; // write
		  c3_p0_cmd_byte_addr <= mem_adr; // adr
		  c3_p0_cmd_bl <= 0; // burst 1x32 bita
//		  c3_p0_cmd_bl <= 4-1; // burst 4x32 bita
		  c3_p0_cmd_en <= 1;
		  st <= st + 1'b1;
	 end
	 
	 12:
	 begin
	     c3_p0_cmd_en <= 0;
		  st <= st + 1'b1;
	 end
	 
	 13:
	 begin
		  if(c3_p0_cmd_empty) begin
		      st <= st + 1'b1;
		  end
	 end
	 
	 14:
	 begin
	     c3_p0_cmd_instr <= 3'b001; // read
		  c3_p0_cmd_byte_addr <= mem_adr; // adr
		  c3_p0_cmd_bl <= 0; // burst 1x32 bita
		  c3_p0_cmd_en <= 1;
		  st <= st + 1'b1;
	 end
	 
	 15:
	 begin
		  c3_p0_cmd_en <= 0;
		  st <= st + 1'b1;
	 end

	 16:
	 begin
	     if(c3_p0_cmd_empty) begin
            st <= st + 1'b1;
		  end
	 end

	 17:
	 begin
		  if (c3_p0_rd_empty == 0) begin
		      st <= st + 1'b1;
        end
	 end

	 18:
	 begin
	     utx_mem_adr <= {2'b0, mem_adr};
		  utx_mem_dataw <= mem_data;
		  utx_mem_datar <= c3_p0_rd_data;// Выводим dword в UART
        c3_p0_rd_en <= 1;
		  st <= st + 1'b1;
	 end

	 19:
	 begin
        c3_p0_rd_en <= 0;
		  st <= st + 1'b1;
	 end

	 20:
	 begin
// Выводить строку по каждому адресу в консоль
//	     if (utx_ready) begin
//				utx_we <= 1'b1;
//				st     <= st + 1'b1;
//		  end
	 
// Пропускаем вывод в консоль
        st <= st + 1'b1;
	 end

    21:
	 begin
        utx_we <= 1'b0;
	     if (mem_data != utx_mem_datar) begin
//	     if (mem_data != ~utx_mem_datar) begin // set MY ERROR for TEST !!!
		      utx_we <= 1'b1; // Включаем печать адреса с ошибкой
		      mem_error <= 1; // ERROR !!! cmp: mem data read != mem data write
				st <= 8'd26; // exit, end test mem
		  end else st <= st + 1'b1;
	 end

    22:
	 begin
		  st <= st + 1'b1;
	 end

    23:
	 begin
		  if (utx_ready == 1) begin
		      st <= st + 1'b1;
		  end
	 end
	 
	 24:
	 begin
	     if (mem_adr == MEM_ADR_STOP) begin
		      st <= st + 1'b1;
		  end else begin
		      mem_adr <= mem_adr + 29'd4; // MEM ADR + 4 -> NEXT ADR
				st <= 8'd6; // jmp to NEXT test mem
		  end
	 end

    25:
	 begin
	     if (mem_pattern_count == MEM_PATTERN_COUNT) begin
		      st <= st + 1'b1; // end test
		  end else begin
		      mem_adr <= MEM_ADR_START;
            mem_pattern_count <= mem_pattern_count + 1'b1;
				st <= 8'd6; // new write
		  end
	 end

	 26: // END test MEM ---------------------------------------
	 begin
	     utx_we <= 1'b0;
		  
	     case(mem_error)
		  0: 
		  begin
		      str <= "PASS OK\n";
		      led_en <= LED_OFF;
		  end
		  
		  1: 
		  begin
		      str <= "ERROR  \n";
		      led_en <= LED_ON;
		  end
		  endcase
		  
		  st <= st + 1'b1;
	 end

    27:
	 begin
		  st <= st + 1'b1;
	 end

    28:
	 begin
		  if (utx_ready == 1) st <= st + 1'b1;
	 end
	 
	 29:
	 begin
	     mux_uart_str0_hex1 <= 0; // set mode uart tx string char
		  utx_we_str <= 1;
		  st <= st + 1'b1;
	 end
	 
	 30:
	 begin
	     utx_we_str <= 0;
	 end
	 
	 default:
	 begin
	 
	 end
	 
	 endcase
end





		
		
		

wire sys_clk_ibufg_t;
IBUFG  u_ibufg_sys_clk
    (
        .I  (c3_sys_clk),
        .O  (sys_clk_ibufg)
    );


reg [15:0] reset_count = 0;
reg [3:0] reset_st = 0;
reg       reset_count_z = 0;

always @(posedge sys_clk_ibufg)
begin
    if (reset_count_z)
        reset_count <= 0;
    else
        reset_count <= reset_count + 1'b1;
	 
end

always @(posedge sys_clk_ibufg)
begin
    case (reset_st)
	 0:
	 begin
	     reset_count_z <= 1;
	     reset_st    <= reset_st + 1'd1;
	 end
	 
	 1:
	 begin
	     reset_count_z <= 0;
		  reset       <= 1'b1;
	     reset_st    <= reset_st + 1'd1;
		  $display("Reset ENABLE %t", $time );
	 end
	 

	 2:
	 begin
	     if (reset_count == 8'd200) begin
		      $display("Reset DISABLE %t", $time );
		      reset    <= 1'b0;
		      reset_st <= reset_st + 1'd1;
		  end
	 end

    3:
	 begin
	 end

	 default:
	 begin
	     reset_st <= reset_st + 1'd1;
	 end

	 endcase
end

reg [25:0] led_count = 0;
reg        led = 0;
//------------------------------------------------------------------------------
// Led blink for test this PRJ
//------------------------------------------------------------------------------
always @(posedge c3_clk0)
begin
    led_count <= led_count + 1'b1;
    if (led_count == 32'd12_500_000) begin
	     led_count <= 0;
		  led       <= ~led;
	 end
end

always @(led_en or led)
begin
    case(led_en)
	LED_OFF:   o_led = 1;
	LED_ON:    o_led = 0;
	LED_BLINK: o_led = led;
	default:   o_led = led;
	endcase
end

assign rst = reset;
assign error = mem_error;

assign calib_done = ~c3_calib_done;
assign c3_sys_clk_p = 1'b0;
assign c3_sys_clk_n = 1'b0;

   





endmodule   

 
