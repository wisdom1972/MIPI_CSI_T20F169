

# Efinity Interface Designer SDC
# Version: 2019.3.272
# Date: 2020-02-05 01:26

# Copyright (C) 2017 - 2019 Efinix Inc. All rights reserved.

# Device: T20F169
# Project: MIPIDebug
# Timing Model: C4 (final)

# PLL Constraints
#################
create_clock -period 50.00 MipiTxEscClk
create_clock -period 10.00 MipiTxPixelClk
create_clock -period 10.00 MipiRxCalClk
create_clock -period 10.00 MipiRxPixelClk

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {MipiRefClk}]
# set_input_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {MipiRefClk}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[0]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[0]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {LED[1]}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {LED[1]}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {PixelRxHSync}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {PixelRxHSync}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {PixelRxValid}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {PixelRxValid}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {PixelTxValid}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {PixelTxValid}]

# LVDS TX GPIO Constraints
############################
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {PixelRxVSync}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {PixelRxVSync}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {PixelTxHSync}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {PixelTxHSync}]
# set_output_delay -clock <CLOCK> -max <MAX CALCULATION> [get_ports {PixelTxVSync}]
# set_output_delay -clock <CLOCK> -min <MIN CALCULATION> [get_ports {PixelTxVSync}]

# LVDS Rx Constraints
####################

# MIPI RX Constraints
#####################################
set_output_delay -clock MipiRxPixelClk -max -3.546 [get_ports {MipiRx_VC_ENA[3] MipiRx_VC_ENA[2] MipiRx_VC_ENA[1] MipiRx_VC_ENA[0]}]
set_output_delay -clock MipiRxPixelClk -min -1.987 [get_ports {MipiRx_VC_ENA[3] MipiRx_VC_ENA[2] MipiRx_VC_ENA[1] MipiRx_VC_ENA[0]}]
set_output_delay -clock MipiRxPixelClk -max -3.997 [get_ports {MipiRx_CLEAR}]
set_output_delay -clock MipiRxPixelClk -min -1.899 [get_ports {MipiRx_CLEAR}]
set_input_delay -clock MipiRxPixelClk -max 5.194 [get_ports {MipiRx_VSYNC[3] MipiRx_VSYNC[2] MipiRx_VSYNC[1] MipiRx_VSYNC[0]}]
set_input_delay -clock MipiRxPixelClk -min 2.597 [get_ports {MipiRx_VSYNC[3] MipiRx_VSYNC[2] MipiRx_VSYNC[1] MipiRx_VSYNC[0]}]
set_input_delay -clock MipiRxPixelClk -max 5.188 [get_ports {MipiRx_HSYNC[3] MipiRx_HSYNC[2] MipiRx_HSYNC[1] MipiRx_HSYNC[0]}]
set_input_delay -clock MipiRxPixelClk -min 2.594 [get_ports {MipiRx_HSYNC[3] MipiRx_HSYNC[2] MipiRx_HSYNC[1] MipiRx_HSYNC[0]}]
set_input_delay -clock MipiRxPixelClk -max 5.042 [get_ports {MipiRx_VALID}]
set_input_delay -clock MipiRxPixelClk -min 2.521 [get_ports {MipiRx_VALID}]
set_input_delay -clock MipiRxPixelClk -max 5.112 [get_ports {MipiRx_CNT[3] MipiRx_CNT[2] MipiRx_CNT[1] MipiRx_CNT[0]}]
set_input_delay -clock MipiRxPixelClk -min 2.556 [get_ports {MipiRx_CNT[3] MipiRx_CNT[2] MipiRx_CNT[1] MipiRx_CNT[0]}]
set_input_delay -clock MipiRxPixelClk -max 5.140 [get_ports {MipiRx_DATA[*]}]
set_input_delay -clock MipiRxPixelClk -min 2.570 [get_ports {MipiRx_DATA[*]}]
set_input_delay -clock MipiRxPixelClk -max 5.057 [get_ports {MipiRx_ERROR[*]}]
set_input_delay -clock MipiRxPixelClk -min 2.529 [get_ports {MipiRx_ERROR[*]}]
set_input_delay -clock MipiRxPixelClk -max 5.055 [get_ports {MipiRx_ULPS_CLK}]
set_input_delay -clock MipiRxPixelClk -min 2.528 [get_ports {MipiRx_ULPS_CLK}]
set_input_delay -clock MipiRxPixelClk -max 5.064 [get_ports {MipiRx_ULPS[3] MipiRx_ULPS[2] MipiRx_ULPS[1] MipiRx_ULPS[0]}]
set_input_delay -clock MipiRxPixelClk -min 2.532 [get_ports {MipiRx_ULPS[3] MipiRx_ULPS[2] MipiRx_ULPS[1] MipiRx_ULPS[0]}]

# MIPI TX Constraints
#####################################
set_output_delay -clock MipiRxPixelClk -max -3.640 [get_ports {MipiTx_LANES[1] MipiTx_LANES[0]}]
set_output_delay -clock MipiRxPixelClk -min -2.054 [get_ports {MipiTx_LANES[1] MipiTx_LANES[0]}]
set_output_delay -clock MipiRxPixelClk -max -3.898 [get_ports {MipiTx_VSYNC}]
set_output_delay -clock MipiRxPixelClk -min -1.950 [get_ports {MipiTx_VSYNC}]
set_output_delay -clock MipiRxPixelClk -max -3.899 [get_ports {MipiTx_HSYNC}]
set_output_delay -clock MipiRxPixelClk -min -1.978 [get_ports {MipiTx_HSYNC}]
set_output_delay -clock MipiRxPixelClk -max -3.855 [get_ports {MipiTx_VALID}]
set_output_delay -clock MipiRxPixelClk -min -1.993 [get_ports {MipiTx_VALID}]
set_output_delay -clock MipiRxPixelClk -max -3.727 [get_ports {MipiTx_DATA[*]}]
set_output_delay -clock MipiRxPixelClk -min -1.844 [get_ports {MipiTx_DATA[*]}]
set_output_delay -clock MipiRxPixelClk -max -3.532 [get_ports {MipiTx_TYPE[*]}]
set_output_delay -clock MipiRxPixelClk -min -1.926 [get_ports {MipiTx_TYPE[*]}]
set_output_delay -clock MipiRxPixelClk -max -4.028 [get_ports {MipiTx_FRAME_MODE}]
set_output_delay -clock MipiRxPixelClk -min -1.945 [get_ports {MipiTx_FRAME_MODE}]
set_output_delay -clock MipiRxPixelClk -max -3.993 [get_ports {MipiTx_ULPS_CLK_ENTER}]
set_output_delay -clock MipiRxPixelClk -min -1.947 [get_ports {MipiTx_ULPS_CLK_ENTER}]
set_output_delay -clock MipiRxPixelClk -max -4.013 [get_ports {MipiTx_ULPS_CLK_EXIT}]
set_output_delay -clock MipiRxPixelClk -min -1.943 [get_ports {MipiTx_ULPS_CLK_EXIT}]
set_output_delay -clock MipiRxPixelClk -max -3.812 [get_ports {MipiTx_ULPS_ENTER[3] MipiTx_ULPS_ENTER[2] MipiTx_ULPS_ENTER[1] MipiTx_ULPS_ENTER[0]}]
set_output_delay -clock MipiRxPixelClk -min -1.924 [get_ports {MipiTx_ULPS_ENTER[3] MipiTx_ULPS_ENTER[2] MipiTx_ULPS_ENTER[1] MipiTx_ULPS_ENTER[0]}]
set_output_delay -clock MipiRxPixelClk -max -3.742 [get_ports {MipiTx_ULPS_EXIT[3] MipiTx_ULPS_EXIT[2] MipiTx_ULPS_EXIT[1] MipiTx_ULPS_EXIT[0]}]
set_output_delay -clock MipiRxPixelClk -min -1.918 [get_ports {MipiTx_ULPS_EXIT[3] MipiTx_ULPS_EXIT[2] MipiTx_ULPS_EXIT[1] MipiTx_ULPS_EXIT[0]}]
set_output_delay -clock MipiRxPixelClk -max -3.640 [get_ports {MMipiTx_LANES[1] MMipiTx_LANES[0]}]
set_output_delay -clock MipiRxPixelClk -min -2.054 [get_ports {MMipiTx_LANES[1] MMipiTx_LANES[0]}]
set_output_delay -clock MipiRxPixelClk -max -3.898 [get_ports {MMipiTx_VSYNC}]
set_output_delay -clock MipiRxPixelClk -min -1.950 [get_ports {MMipiTx_VSYNC}]
set_output_delay -clock MipiRxPixelClk -max -3.899 [get_ports {MMipiTx_HSYNC}]
set_output_delay -clock MipiRxPixelClk -min -1.978 [get_ports {MMipiTx_HSYNC}]
set_output_delay -clock MipiRxPixelClk -max -3.855 [get_ports {MMipiTx_VALID}]
set_output_delay -clock MipiRxPixelClk -min -1.993 [get_ports {MMipiTx_VALID}]
set_output_delay -clock MipiRxPixelClk -max -3.727 [get_ports {MMipiTx_DATA[*]}]
set_output_delay -clock MipiRxPixelClk -min -1.844 [get_ports {MMipiTx_DATA[*]}]
set_output_delay -clock MipiRxPixelClk -max -3.532 [get_ports {MMipiTx_TYPE[*]}]
set_output_delay -clock MipiRxPixelClk -min -1.926 [get_ports {MMipiTx_TYPE[*]}]
set_output_delay -clock MipiRxPixelClk -max -4.028 [get_ports {MMipiTx_FRAME_MODE}]
set_output_delay -clock MipiRxPixelClk -min -1.945 [get_ports {MMipiTx_FRAME_MODE}]
set_output_delay -clock MipiRxPixelClk -max -3.993 [get_ports {MMipiTx_ULPS_CLK_ENTER}]
set_output_delay -clock MipiRxPixelClk -min -1.947 [get_ports {MMipiTx_ULPS_CLK_ENTER}]
set_output_delay -clock MipiRxPixelClk -max -4.013 [get_ports {MMipiTx_ULPS_CLK_EXIT}]
set_output_delay -clock MipiRxPixelClk -min -1.943 [get_ports {MMipiTx_ULPS_CLK_EXIT}]
set_output_delay -clock MipiRxPixelClk -max -3.812 [get_ports {MMipiTx_ULPS_ENTER[3] MMipiTx_ULPS_ENTER[2] MMipiTx_ULPS_ENTER[1] MMipiTx_ULPS_ENTER[0]}]
set_output_delay -clock MipiRxPixelClk -min -1.924 [get_ports {MMipiTx_ULPS_ENTER[3] MMipiTx_ULPS_ENTER[2] MMipiTx_ULPS_ENTER[1] MMipiTx_ULPS_ENTER[0]}]
set_output_delay -clock MipiRxPixelClk -max -3.742 [get_ports {MMipiTx_ULPS_EXIT[3] MMipiTx_ULPS_EXIT[2] MMipiTx_ULPS_EXIT[1] MMipiTx_ULPS_EXIT[0]}]
set_output_delay -clock MipiRxPixelClk -min -1.918 [get_ports {MMipiTx_ULPS_EXIT[3] MMipiTx_ULPS_EXIT[2] MMipiTx_ULPS_EXIT[1] MMipiTx_ULPS_EXIT[0]}]

# JTAG Constraints
####################
# create_clock -period <USER_PERIOD> [get_ports {jtag_inst1_TCK}]
# create_clock -period <USER_PERIOD> [get_ports {jtag_inst1_DRCK}]
set_output_delay -clock jtag_inst1_TCK -max 0.111 [get_ports {jtag_inst1_TDO}]
set_output_delay -clock jtag_inst1_TCK -min 0.053 [get_ports {jtag_inst1_TDO}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.267 [get_ports {jtag_inst1_CAPTURE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.134 [get_ports {jtag_inst1_CAPTURE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.267 [get_ports {jtag_inst1_RESET}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.134 [get_ports {jtag_inst1_RESET}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.267 [get_ports {jtag_inst1_RUNTEST}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.134 [get_ports {jtag_inst1_RUNTEST}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.231 [get_ports {jtag_inst1_SEL}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.116 [get_ports {jtag_inst1_SEL}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.267 [get_ports {jtag_inst1_UPDATE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.134 [get_ports {jtag_inst1_UPDATE}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -max 0.321 [get_ports {jtag_inst1_SHIFT}]
set_input_delay -clock_fall -clock jtag_inst1_TCK -min 0.161 [get_ports {jtag_inst1_SHIFT}]
