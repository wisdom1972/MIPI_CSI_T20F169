
	/////////////////////////////////////////////////////////
	//Base Parameter 
  `define MipiTxPhyClkFrq       32'd1_500_000_000
  `define MipiTxPixelClkFreq    27'd   66_000_000
  `define MipiTxEscClkFreq      27'd   19_800_000   

	/////////////////////////////////////////////////////////
  //Mipi Tx Timing Parameter 
  `define MipiTx_TCLK_Post	    16'd113
  `define MipiTx_TCLK_Trail	    16'd96
  `define MipiTx_TCLK_Prepare	  16'd48
  `define MipiTx_TCLK_Zero	    16'd304
  `define MipiTx_TCLK_Pre	      16'd250

  `define MipiTx_THS_Prepare	  16'd66
  `define MipiTx_THS_Zero	      16'd142
  `define MipiTx_THS_Trail	    16'd90

  
  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  //以下部分请不要随意修改
  //以下部分请不要随意修改
  //以下部分请不要随意修改
  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  
	/////////////////////////////////////////////////////////
	//固有参数
  `define   TxLineDataBuffLength_Byte     16'd5760
  `define   Cycle_LP_Exit_EscClk          16'h5
  `define   Cycle_HBlankFM1Add_PhyClk     16'h32        //In Framer Mode = 1 HoriBlanking Additon PhyClk Number
  `define   LP_FallsTime                  16'h15
  `define   LP_RaiseTime                  16'h15  
  
	/////////////////////////////////////////////////////////
  //Calculate MIPI Signal Parameter 
	/////////////////////////////////////////////////////////
	//Clock  Priod & Cycle  为保证精度所有的数据都左移了8位，使用时需要计算完以后右移8位
  `define   Timing_TxPhyClkPriod_nsL8     ({30'd1_000_000_000   ,8'h0} / `MipiTxPhyClkFrq    )    
  `define   Timing_TxPixelClkPriod_nsL8   ({30'd1_000_000_000   ,8'h0} / `MipiTxPixelClkFreq )
  `define   Timing_TxEscClkPriod_nsL8     ({30'd1_000_000_000   ,8'h0} / `MipiTxEscClkFreq   )
  `define   Timing_TxClkCyclePerUs_nsL8   ({`MipiTxPixelClkFreq ,8'h0} / 28'd1_000_000       )                     
  `define   Timing_TxDataPerPixClk_nsL8   ({`MipiTxPhyClkFrq    ,8'h0} / `MipiTxPixelClkFreq )

  `define   Time_LP_FallsTime_nsL8        {`LP_FallsTime , 8'h0}
  `define   Time_LP_RaiseTime_nsL8        {`LP_RaiseTime , 8'h0}
  
	/////////////////////////////////////////////////////////
  //Mipi Tx Timing Parameter 为保证精度所有的数据都左移了8位，使用时需要计算完以后右移8位
  `define   Timing_Tx_TCLK_Post_nsL8	    {`MipiTx_TCLK_Post	  ,8'h0}
  `define   Timing_Tx_TCLK_Trail_nsL8	    {`MipiTx_TCLK_Trail	  ,8'h0} 
  `define   Timing_Tx_TCLK_Prepare_nsL8	  {`MipiTx_TCLK_Prepare	,8'h0} 
  `define   Timing_Tx_TCLK_Zero_nsL8	    {`MipiTx_TCLK_Zero	  ,8'h0}
  `define   Timing_Tx_TCLK_Pre_nsL8	      {`MipiTx_TCLK_Pre	    ,8'h0} 
  `define   Timing_Tx_THS_Prepare_nsL8	  {`MipiTx_THS_Prepare  ,8'h0}
  `define   Timing_Tx_THS_Zero_nsL8	      {`MipiTx_THS_Zero	    ,8'h0} 
  `define   Timing_Tx_THS_Trail_nsL8	    {`MipiTx_THS_Trail	  ,8'h0}
  `define   Timing_Tx_THS_Exit_nsL8	      {`MipiTx_THS_Exit     ,8'h0}
  
  `define   Timing_Tx_THS_Exit_nsL8	      (`Timing_TxEscClkPriod_nsL8 * `Cycle_LP_Exit_EscClk )
  
	/////////////////////////////////////////////////////////
	//Timing Parameter 为保证精度所有的数据都左移了8位，使用时需要计算完以后右移8位
  `define   Timing_Tx_TLPX_nsL8     `Timing_TxEscClkPriod_nsL8              //Tx LP00/01/10
  `define   Timing_Tx_THSSync_nsL8 (`Timing_TxPhyClkPriod_nsL8 *  8)
  `define   Timing_Tx_THS_PH_nsL8  (`Timing_TxPhyClkPriod_nsL8 * 32)
  `define   Timing_Tx_THS_PF_nsL8  (`Timing_TxPhyClkPriod_nsL8 * 16)
  `define   Timing_Tx_THS_SF_nsL8  (`Timing_TxPhyClkPriod_nsL8 * 32)
  
	/////////////////////////////////////////////////////////
	//LLC Break & Short Framer
  `define   Timing_Tx_THS_EoT_nsL8	  (`Timing_Tx_THS_Trail_nsL8 + `Time_LP_RaiseTime_nsL8)
  `define   Timing_Tx_THS_SoT_nsL8	  (`Timing_Tx_THS_Prepare_nsL8 + `Timing_Tx_THS_Zero_nsL8 + `Timing_Tx_THSSync_nsL8 + `Timing_Tx_TLPX_nsL8)
  `define   Timing_LLCBreak_nsL8      (`Timing_Tx_THS_EoT_nsL8 + `Timing_Tx_THS_SoT_nsL8 + `Timing_Tx_THS_Exit_nsL8)
  `define   Timing_ShortFramer_nsL8   (`Timing_LLCBreak_nsL8 + `Timing_Tx_THS_SF_nsL8)  
  `define   Cycle_ShortFramer         ((`Timing_ShortFramer_nsL8 / `Timing_TxPixelClkPriod_nsL8 ) + (((`Timing_ShortFramer_nsL8 % `Timing_TxPixelClkPriod_nsL8 ) == 0) ? 0 : 1))
    
	/////////////////////////////////////////////////////////	
	//VertBlanking & HoriBlanking
  `define   Cycle_MinHoriBlank_FM0    (`Cycle_ShortFramer)
  `define   Cycle_MinHoriBlank_FM1    (`Cycle_ShortFramer +  (`Cycle_HBlankFM1Add_PhyClk * `Timing_TxPhyClkPriod_nsL8 / `Timing_TxPixelClkPriod_nsL8))
  
  `define   Cycle_MinHoriBlank        (`MipiTxFramerMode ? `Cycle_MinHoriBlank_FM1 : `Cycle_MinHoriBlank_FM0)
  `define   Cycle_MinVertBlank        (`Cycle_ShortFramer + `Cycle_ShortFramer)
   
	/////////////////////////////////////////////////////////
  `define   Timing_HeriOverhead_FM0_nsL8   (`Timing_ShortFramer_nsL8  + `Timing_Tx_THS_PH_nsL8 + `Timing_Tx_THS_PF_nsL8 )
  `define   Timing_HeriOverhead_FM1_nsL8   (`Timing_ShortFramer_nsL8  + `Timing_ShortFramer_nsL8 + `Timing_Tx_THS_PH_nsL8 + `Timing_Tx_THS_PF_nsL8 )
  
  `define   Cycle_HeriOverhead_FM0    (((`Timing_HeriOverhead_FM0_nsL8 / `Timing_TxPixelClkPriod_nsL8 ) + (((`Timing_HeriOverhead_FM0_nsL8 % `Timing_TxPixelClkPriod_nsL8 ) == 0) ? 0 : 1 )) +  0)
  `define   Cycle_HeriOverhead_FM1    (((`Timing_HeriOverhead_FM1_nsL8 / `Timing_TxPixelClkPriod_nsL8 ) + (((`Timing_HeriOverhead_FM1_nsL8 % `Timing_TxPixelClkPriod_nsL8 ) == 0) ? 0 : 1 )))
   
	/////////////////////////////////////////////////////////
  //最小HeriSync周期
  `define   Cycle_HeriSyncMin_FM0     (`Cycle_HeriOverhead_FM0 + `Cycle_ShortFramer + `Cycle_ShortFramer)
  `define   Cycle_HeriSyncMin_FM1     (`Cycle_HeriOverhead_FM1 + `Cycle_ShortFramer + `Cycle_ShortFramer)
  
  `define   InVer_HeriSyncMin_FM0     ((21'h100000 / `Cycle_HeriSyncMin_FM0))      
  `define   InVer_HeriSyncMin_FM1     ((21'h100000 / `Cycle_HeriSyncMin_FM1))      
       
	`define   Cycle_HSync2DVald         (`Cycle_ShortFramer - 15'h10)
//  
//  
//  
//  
//  
//  
//  
//	/////////////////////////////////////////////////////////
//  //Calculate
//	/////////////////////////////////////////////////////////
//	//Clock  Priod & Cycle  为保证精度所有的数据都左移了8位，使用时需要计算完以后右移8位
//  `define MipiRxPhyClkPriod     ({30'd1_000_000_000   ,8'h0} / `MipiTxPhyClkFrq    )
//  `define MipiRxPixelClkPriod   ({30'd1_000_000_000   ,8'h0} / `MipiTxPixelClkFreq )
//  `define MipiRxEscClkPriod     ({30'd1_000_000_000   ,8'h0} / `MipiTxEscClkFreq   )
//  
//  `define TxClkCyclePerUs       ({`MipiTxPixelClkFreq ,8'h0} / 28'd1_000_000      )
//  `define TxDataPerPixClk       ({`MipiTxPhyClkFrq    ,8'h0} / `MipiTxPixelClkFreq)
//
//	/////////////////////////////////////////////////////////
//	//Timing Parameter
//  `define MipiTx_TLPX             (`MipiRxEscClkPriod>>8)
//                                  
//  `define MipiTx_THSSync          ((`MipiRxPhyClkPriod *  8) >> 8)
//  `define MipiTx_THS_PH           ((`MipiRxPhyClkPriod * 32) >> 8)
//  `define MipiTx_THS_PF           ((`MipiRxPhyClkPriod * 16) >> 8)
//  `define MipiTx_THS_ShortFramer  ((`MipiRxPhyClkPriod * 32) >> 8)
//  
//	/////////////////////////////////////////////////////////
//	//LLC Break
//  `define MipiTx_THS_EoT	        (`MipiTx_THS_Trail + 16'd15)
//  `define MipiTx_THS_SoT	        (`MipiTx_THS_Prepare + `MipiTx_THS_Zero + `MipiTx_THSSync + `MipiTx_TLPX)
//
//  `define MipiLLCBreakTime        (`MipiTx_THS_EoT + `MipiTx_THS_SoT + `MipiTx_THS_Exit)
//
//  `define MipiLLCBreakCycle       (( `MipiLLCBreakTime        * `MipiTxPixelClkFreq ) /1_000_000_000)
//  
//  `define MipiHoriBlankMinCycle   (((`MipiLLCBreakTime + 200) * `MipiTxPixelClkFreq ) /1_000_000_000)
//  `define MipiVertBlankMinCycle   `MipiLLCBreakCycle
//   
//  `define MipiShortFramerCycle    (`MipiLLCBreakCycle + `MipiTx_THS_ShortFramer)
//  
//	/////////////////////////////////////////////////////////
//  `define MipiHeriOverheadTime_FM0    ( `MipiLLCBreakTime       + `MipiTx_THS_PH + `MipiTx_THS_PF)
//  `define MipiHeriOverheadTime_FM1    ((`MipiLLCBreakTime * 2 ) + `MipiTx_THS_PH + `MipiTx_THS_PF)
//  
//  `define MipiHeriOverheadCycle_FM0   (`MipiHeriOverheadTime_FM0 * `MipiTxPixelClkFreq /1_000_000_000)
//  `define MipiHeriOverheadCycle_FM1   (`MipiHeriOverheadTime_FM1 * `MipiTxPixelClkFreq /1_000_000_000)