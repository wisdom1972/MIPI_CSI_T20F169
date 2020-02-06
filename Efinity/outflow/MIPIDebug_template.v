
// Efinity Top-level template
// Version: 2019.3.272
// Date: 2020-02-06 12:27

// Copyright (C) 2017 - 2019 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as /home/wisdom/2019.3/project/MIPIDebug1.6/Efinity/MIPIDebug.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  MIPIDebug
//     #4)  Insert design content.


module MIPIDebug
(
  input [5:0] MipiRx_TYPE,
  input jtag_inst1_UPDATE,
  input jtag_inst1_CAPTURE,
  input MipiRxCalClk,
  input jtag_inst1_RESET,
  input [17:0] MipiRx_ERROR,
  input [3:0] MipiRx_HSYNC,
  input jtag_inst1_RUNTEST,
  input jtag_inst1_DRCK,
  input [3:0] MipiRx_ULPS,
  input MipiTxEscClk,
  input MipiRxPixelClk,
  input MipiRx_VALID,
  input jtag_inst1_SHIFT,
  input [3:0] MipiRx_VSYNC,
  input jtag_inst1_SEL,
  input [1:0] MipiRx_VC,
  input MipiTxPixelClk,
  input [3:0] MipiRx_CNT,
  input MipiRx_ULPS_CLK,
  input jtag_inst1_TCK,
  input [63:0] MipiRx_DATA,
  input [2:1] PllLocked,
  input jtag_inst1_TMS,
  input jtag_inst1_TDI,
  output [1:0] MipiRx_LANES,
  output PixelRxHSync,
  output MipiRx_RSTN,
  output [5:0] MMipiTx_TYPE,
  output MipiTx_HSYNC,
  output [3:0] MMipiTx_ULPS_EXIT,
  output [15:0] MMipiTx_HRES,
  output MipiRx_DPHY_RSTN,
  output [3:0] MMipiTx_ULPS_ENTER,
  output [3:0] MipiRx_VC_ENA,
  output PixelTxValid,
  output MipiTx_VSYNC,
  output MipiTx_ULPS_CLK_EXIT,
  output MMipiTx_ULPS_CLK_ENTER,
  output MMipiTx_DPHY_RSTN,
  output MMipiTx_FRAME_MODE,
  output MipiTx_RSTN,
  output PixelRxVSync,
  output MMipiTx_RSTN,
  output MMipiTx_VSYNC,
  output [15:0] MipiTx_HRES,
  output jtag_inst1_TDO,
  output MipiTx_FRAME_MODE,
  output MipiTx_DPHY_RSTN,
  output [63:0] MMipiTx_DATA,
  output [1:0] MipiTx_LANES,
  output [1:0] MMipiTx_VC,
  output [1:0] LED,
  output PixelTxVSync,
  output MipiTx_ULPS_CLK_ENTER,
  output [3:0] MipiTx_ULPS_EXIT,
  output [1:0] MMipiTx_LANES,
  output MipiTx_VALID,
  output MMipiTx_HSYNC,
  output PixelTxHSync,
  output [63:0] MipiTx_DATA,
  output [1:0] MipiTx_VC,
  output MMipiTx_VALID,
  output PixelRxValid,
  output [3:0] MipiTx_ULPS_ENTER,
  output [5:0] MipiTx_TYPE,
  output MMipiTx_ULPS_CLK_EXIT,
  output MipiRx_CLEAR
);


endmodule

