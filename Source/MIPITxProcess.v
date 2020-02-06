
`timescale 100ps/10ps
`include  "../Source/MIPI_Parameter.v"

///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-1-6
	版本：V1、0
	修改记录：
**********************************************************/

module MipiTxCtrl
(   
	//System Signal
	SysClk  ,     //System Clock
	Reset_N ,		  //System Reset
	//Signal
	PixelTxEn     , //(I)MIPI Tx  Enable
	ConfDataType  , //(I)Configuration Data Type   
  CfgTxFrmRate  , //(I)Configuration Tx Framer Rate
  CfgTxVPixelNum, //(I)Configuration Tx Vertical Pixel Number  
	CfgTxHPixelNum, //(I)Configuration Tx Horizontal Pixel Number
  CfgTxVBlkTime , //(I)Configuration Tx Vertical Blanking Time (us)
  CfgTxHBlkTime , //(I)Configuration Tx Horizontal Blanking Time (us)    
	ConfTxFrmMod  , //(I)Configuration Framer Mode
	ConfLanesNum  , //(I)Configuration Lanes Number
	//Calculate Parameter      
	CalcVSyncLen  , //(O)Calculate Vertical Synchronization Length(Pixel  Clock Cycle)
	CalcHSyncLen  , //(O)Calculate Horizontal Synchronization Length  (Pixel  Clock Cycle)
	CalcDValidLen , //(O)Calculate Data Valid Length 	(Pixel  Clock Cycle) 
	CalcVBlankLen , //(O)Calculate Vertical Blanking  Length  (Pixel  Clock Cycle)	
	CalcHBlankLen , //(O)Calculate Horizontal Blanking  Length  (Pixel  Clock Cycle)
	CalcHPixelNum , //(O)Calculate Horizontal Pixel Number
  //MIPI Tx  Siganl       
  TxConfigEn  , //(O)MIPI Tx  Config Enable
  MipiTxHSync ,  //(O)MIPI Tx Horizontal Synchronization
  MipiTxVSync , //(O)MIPI TxVertical Synchronization
  MipiTxValid   //(O)MIPI Tx Pixel Data Valid  
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter	  TCo_C   		= 1;    
//	
//  parameter   [27:0]  TxPixelClkFreq_C      = `MipiTxPixelClkFreq;
//  
//  localparam  [15:0]  TxClkCyclePerUs_C     = `TxClkCyclePerUs;     //* 256 
//  
//  localparam  [ 7:0]  TxShortFramerLen_C    = `MipiShortFramerCycle ; 
//  localparam  [ 7:0]  HoriBlankingMinLen_C  = `MipiHoriBlankMinCycle; 
//  localparam  [ 7:0]  VertBlankingMinLen_C  = `MipiVertBlankMinCycle; 
//  
//  localparam          MipiLLCBreakTime_C    = `MipiLLCBreakTime ;
//  
//  localparam  [15:0]  TxOverheadCycle_FM0_C = `MipiHeriOverheadCycle_FM0;
//  localparam  [15:0]  TxOverheadCycle_FM1_C = `MipiHeriOverheadCycle_FM1;
//  
//  localparam  [16:0]  TxHSyncMaxNFactor_FM0_C   = `InVer_HeriSyncMin_FM0;
//  localparam  [16:0]  TxHSyncMaxNFactor_FM1_C   = `InVer_HeriSyncMin_FM1;
//  
//  localparam  [15:0]  TxDataPerPixClk_C     = `TxDataPerPixClk;  
      
  parameter   [27:0]  TxPixelClkFreq_C          = `MipiTxPixelClkFreq;
  
  localparam  [15:0]  TxClkCyclePerUs_C         = `Timing_TxClkCyclePerUs_nsL8;    
  localparam  [23:0]  TxDataPerPixClk_C         = `Timing_TxDataPerPixClk_nsL8;  
  
  localparam  [15:0]  TxShortFramerLen_C        = `Cycle_ShortFramer ; 
  localparam  [15:0]  VertBlankingMinLen_C      = `Cycle_MinVertBlank;     
  
  localparam  [15:0]  HoriBlankingMinLen_FM0_C  = `Cycle_MinHoriBlank_FM0; 
  localparam  [15:0]  HoriBlankingMinLen_FM1_C  = `Cycle_MinHoriBlank_FM1; 
  
  localparam  [15:0]  TxOverheadCycle_FM0_C     = `Cycle_HeriOverhead_FM0;
  localparam  [15:0]  TxOverheadCycle_FM1_C     = `Cycle_HeriOverhead_FM1;
  
  localparam  [16:0]  TxHSyncMaxNFactor_FM0_C   = `InVer_HeriSyncMin_FM0;
  localparam  [16:0]  TxHSyncMaxNFactor_FM1_C   = `InVer_HeriSyncMin_FM1;
  
//  localparam  [16:0]  HSync2VSyncDelay_FM0_C    = `Cycle_H2VDelay_FM0;
//  localparam  [16:0]  HSync2VSyncDelay_FM1_C    = `Cycle_H2VDelay_FM1;
//  
  localparam  [15:0]  TxHSync2DValCycle_C       = `Cycle_HSync2DVald;
      
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	// Signal Define
	input           PixelTxEn     ; //(I)MIPI Tx  Enable
  input   [ 7:0]  CfgTxFrmRate  ; //(I)Configuration Tx Framer Rate
  input   [15:0]  CfgTxVPixelNum; //(I)Configuration Tx Vertical Pixel Number  
	input   [15:0]  CfgTxHPixelNum; //(I)Configuration Tx Horizontal Pixel Number
  input   [11:0]  CfgTxVBlkTime ; //(I)Configuration Tx Vertical Blanking Time (us)
  input   [ 7:0]  CfgTxHBlkTime ; //(I)Configuration Tx Horizontal Blanking Time (us)
//	input   [ 3:0]  CfgTxPixelNum ; //(I)Configuration Tx Pixel Number Per Clock
  
	input   [ 5:0]  ConfDataType  ; //(I)Configuration Data Type   
	input           ConfTxFrmMod  ; //(I)Configuration Framer Mode
	input   [ 2:0]  ConfLanesNum   ; //(I)Configuration Lanes Number
	
	/////////////////////////////////////////////////////////
	//Calculate parameter 
	output   [23:0]   CalcVSyncLen  ; //(O)Calculate Vertical Synchronization Length(Pixel  Clock Cycle)
	output   [15:0]   CalcHSyncLen  ; //(O)Calculate Horizontal Synchronization Length  (Pixel  Clock Cycle)
	output   [15:0]   CalcDValidLen ; //(O)Calculate Data Valid Length  (Pixel  Clock Cycle) 
	output   [19:0]   CalcVBlankLen ; //(O)Calculate Vertical Blanking  Length  (Pixel  Clock Cycle)	
	output   [15:0]   CalcHBlankLen ; //(O)Calculate Horizontal Blanking  Length  (Pixel  Clock Cycle)
	output   [15:0]   CalcHPixelNum ; //(O)Calculate Horizontal Pixel Number
	
	/////////////////////////////////////////////////////////
  //MIPI Tx Siganl       
  output  TxConfigEn ; //(O)MIPI Tx  Config Enable
  output  MipiTxHSync; //(O)MIPI Tx  Horizontal Synchronization
  output  MipiTxVSync; //(O)MIPI Tx  Vertical Synchronization
  output  MipiTxValid; //(O)MIPI Tx  Pixel Data Valid
		
//1111111111111111111111111111111111111111111111111111111
//Calulate Vertical Synchronization Signal Parameter,
//In:   CfgTxFrmRate  CfgTxBlkLen
//Out:  CalcVSyncLen 	CalcVBlankLen
//***************************************************/   
	///////////////////////////////////////////////////////// 
	//Calculate  and Retrain Vertical Blanking Length  
	reg   [35:0]  CalcVBlankMult = 36'h0;
  
  reg   [19:0]  VBlankMultRslt = 20'h0;    
	reg   [19:0]  CalcVBlankLen  = 20'h0;   //Calculate Vertical Blanking  Length  (Pixel  Clock Cycle)	
	
	always @( posedge SysClk)  CalcVBlankMult <= # TCo_C  {6'h0,CfgTxVBlkTime} * {2'h0,TxClkCyclePerUs_C};
  always @( posedge SysClk)  VBlankMultRslt <= CalcVBlankMult[27:8];
	always @( posedge SysClk)  CalcVBlankLen <= # TCo_C  (VBlankMultRslt > {8'h0,VertBlankingMinLen_C}) 
	                                                    ? VBlankMultRslt : {8'h0,VertBlankingMinLen_C} ;
	
	/////////////////////////////////////////////////////////  
	//限制帧率不低于8帧（计数器位数的原因）
	wire  [7:0]   TxFramerRate = (|CfgTxFrmRate[7:3]) ? CfgTxFrmRate : 8'h8;
	
	///////////////////////////////////////////////////////// 
  wire  [23:0]  VSyncPeriod ; //Vertical Synchronization Period   
  wire          VSPeriodAva ; //Vertical Synchronization Period Available
  
	LengthCalc
	# (
	    .NumWidth_C   ( 8 ), //Width For NumPerUnit 
	    .LenWidth_C   (28 ), //Width For LenPerUnit 
	    .ValueWidth_C (24 )  //Width For LenValue   
	  )
	U1_VSyncLenCalc
  (   
  	//System Signal
  	.SysClk     (SysClk     ),	  //System Clock
  	.Reset_N    (Reset_N    ),		//System Reset
  	//Signal    
  	.NumPerUnit (TxFramerRate ),  //(I)Number Per Unit
  	.LenPerUnit (TxPixelClkFreq_C), //(I)Length Per Unit(Pixel  Clock Cycle)
  	.LenValue   (VSyncPeriod  ),  //(O)Length Value (Pixel  Clock Cycle)
	  .LenRemain  (             ), //(O)Length Remain
  	.LengthAva  (VSPeriodAva  )   //(O)Length Available
  );
  
	/////////////////////////////////////////////////////////  
	reg           CalcVSLenAva    =  1'h0; //Calculate Vertical Synchronization Length Available
	reg   [23:0]  VSyncLength    = 24'h0; //Calculate Vertical Synchronization Length(Pixel  Clock Cycle)
  
  always @( posedge SysClk)   CalcVSLenAva  <= # TCo_C  VSPeriodAva & (|CalcVBlankLen) &  (|VSyncLength);
  always @( posedge SysClk)   VSyncLength   <= # TCo_C (VSyncPeriod - {4'h0,CalcVBlankLen});  
    
//1111111111111111111111111111111111111111111111111111111
	
	
	
//2222222222222222222222222222222222222222222222222222222
//Calulate Horizontal Synchronization Signal Parameter,
//In:   CfgTxVPixelNum CfgTxHBlkTime
//Out:  CalcHSyncLen 	CalcHBlankLen
//***************************************************/   
//	wire  [31:0]  CalcHBlkMult    = {8'h0,CfgTxHBlkTime} * TxClkCyclePerUs_C;
//	reg   [15:0]  HBlkMultRslt    = 16'h0;
//	reg   [15:0]  CalcHBlankLen   = 16'h0; //Calculate Horizontal Blanking  Length  (Pixel  Clock Cycle)
//	
//	always @( posedge SysClk)  HBlkMultRslt   <= # TCo_C CalcHBlkMult[23:8];
//	always @( posedge SysClk)  CalcHBlankLen  <= # TCo_C (HBlkMultRslt  > {8'h0,HoriBlankingMinLen_C}) 
//	                                                    ? HBlkMultRslt  : {8'h0,HoriBlankingMinLen_C} ; 
	
	///////////////////////////////////////////////////////// 
  wire  [15:0]  HSyncPeriod ; //Horizontal Synchronization Period   
	///////////////////////////////////////////////////////// 
	//根据帧长计算最小行同步信号个数，根据最小行长度计算最大行同步个数；行同步数量必须在这个范围
	//Calculate HSync Number
	reg   [16:0]  TxHSyncMaxNFactor     = 17'h0; //Calculate Horizontal Synchronization Minimum Length
	reg   [49:0]  CalcHSyncMaxNum       = 50'h0;  //Calculate Horizontal Synchronization Maxim Number
	reg   [15:0]  HSyncMaxNum           = 16'h0;  //Horizontal Synchronization Maxim Number
	reg   [15:0]  HSyncNumber           = 16'h0;  //Horizontal Synchronization Number
	reg           HyncNumIgnor          =  1'h0;         
	
  always @( posedge SysClk)  TxHSyncMaxNFactor<= # TCo_C (ConfTxFrmMod ? TxHSyncMaxNFactor_FM1_C : TxHSyncMaxNFactor_FM0_C);
	always @( posedge SysClk)  CalcHSyncMaxNum  <= # TCo_C {1'h0 , VSyncLength} * {8'h0,TxHSyncMaxNFactor};
	always @( posedge SysClk)  HSyncMaxNum      <= # TCo_C CalcHSyncMaxNum[35:20];
	always @( posedge SysClk)  HyncNumIgnor     <= # TCo_C (HSyncMaxNum < CfgTxVPixelNum);
	always @( posedge SysClk)  HSyncNumber      <= # TCo_C HyncNumIgnor ? HSyncMaxNum 
	                                                      : (CfgTxVPixelNum >  {8'h0,VSyncPeriod[23:16]})
	                                                      ?  CfgTxVPixelNum : ({8'h0,VSyncPeriod[23:16]} + 16'h1);
	
  wire          HSPeriodAva ; //Horizontal Synchronization Period Available
  wire  [ 7:0]  VSyncRemain ;
  
	LengthCalc
	# (
	    .NumWidth_C   (16 ), //Width For NumPerUnit 
	    .LenWidth_C   (24 ), //Width For LenPerUnit 
	    .ValueWidth_C (16 )  //Width For LenValue   
	  )
	U2_HSyncLenCalc
  (   
  	//System Signal
  	.SysClk     (SysClk     ),	//System Clock
  	.Reset_N    (Reset_N    ),	//System Reset
  	//Signal    
  	.NumPerUnit (CfgTxVPixelNum ),  //(I)Number Per Unit
  	.LenPerUnit (VSyncLength    ),  //(I)Length Per Unit(Pixel  Clock Cycle)
  	.LenValue   (HSyncPeriod    ),  //(O)Length Value (Pixel  Clock Cycle)
	  .LenRemain  (VSyncRemain    ), //(O)Length Remain
  	.LengthAva  (HSPeriodAva    )   //(O)Length Available
  );
  
	/////////////////////////////////////////////////////////  
	reg   [15:0]  HBlankMaxLen    = 16'h0;
	reg   [15:0]  HBlankMinLen    = 16'h0;
	
	always @( posedge SysClk)  HBlankMinLen   <= # TCo_C ConfTxFrmMod ? HoriBlankingMinLen_FM1_C : HoriBlankingMinLen_FM0_C;  
	always @( posedge SysClk)  HBlankMaxLen   <= # TCo_C HSyncPeriod - TxHSync2DValCycle_C - TxOverheadCycle_FM1_C;	
	
	reg   [35:0]  CalcHBlkMult    = 36'h0;
//	wire  [31:0]  CalcHBlkMult    = {8'h0,CfgTxHBlkTime} * TxClkCyclePerUs_C;
	reg   [15:0]  HBlkMultRslt    = 16'h0;
	reg   [15:0]  CalcHBlankLen   = 16'h0; //Calculate Horizontal Blanking  Length  (Pixel  Clock Cycle)
	
	always @( posedge SysClk)  CalcHBlkMult <= # TCo_C {10'h0,CfgTxHBlkTime} * {2'h0,TxClkCyclePerUs_C};
	always @( posedge SysClk)  HBlkMultRslt   <= # TCo_C CalcHBlkMult[23:8];
	always @( posedge SysClk)  CalcHBlankLen  <= # TCo_C (HBlkMultRslt  > HBlankMinLen) 
	                                                    ? HBlkMultRslt  : HBlankMinLen ; 
	
	///////////////////////////////////////////////////////// 
	//Calculate Horizontal Blanking
//	reg   [35:0]  CalcHBlkMult    = 36'h0;
//	reg   [15:0]  HBlkMultRslt    = 16'h0;
//	reg   [15:0]  HBlankValLen    = 16'h0; //Calculate Horizontal Blanking  Valid Length  (Pixel  Clock Cycle)
//	
//	always @( posedge SysClk)  CalcHBlkMult <= # TCo_C {10'h0,CfgTxHBlkTime} * {2'h0,TxClkCyclePerUs_C};
//	always @( posedge SysClk)  HBlkMultRslt <= # TCo_C CalcHBlkMult[23:8];
//	always @( posedge SysClk)  HBlankValLen <= # TCo_C ((HBlankMinLen > HBlkMultRslt) | (ConfTxFrmMod == 1'h0) | HyncNumIgnor)
//	                                                  ? HBlankMinLen 
//	                                                  :(HBlkMultRslt < HBlankMaxLen) 
//	                                                  ? HBlkMultRslt : HBlankMaxLen ; 
	                                                  
	/////////////////////////////////////////////////////////  
	reg           CalcHSLenAva    =  1'h0; //Calculate Horizontal Synchronization Length Available
	reg   [15:0]  CalcHSyncLen    = 16'h0; //Calculate Horizontal Synchronization Length(Pixel  Clock Cycle)
	reg   [15:0]  CalcHSyncNum    = 16'h0; //Calculate Horizontal Synchronization Number Per Vertical
  
  always @( posedge SysClk)   CalcHSLenAva  <= # TCo_C HSPeriodAva & (|CalcHSyncLen) &  (|CalcHBlankLen);
  always @( posedge SysClk)   CalcHSyncLen  <= # TCo_C (HSyncPeriod - CalcHBlankLen);
  always @(            *  )   CalcHSyncNum  <= # TCo_C CfgTxVPixelNum;    
  
//	/////////////////////////////////////////////////////////  
  
//2222222222222222222222222222222222222222222222222222222



//3333333333333333333333333333333333333333333333333333333
//Calulate Data Valid Signal Parameter
//In:   CfgTxHPixelNum  PixelNumPD
//Out:   CalcDValidLen
//***************************************************/   

	///////////////////////////////////////////////////////// 
	wire          MipiParamAva  ;   //(O)MIPI Parameter Avaliable
	wire  [79:0]  MipiDataParam ;   //(O)Mipi Data Parameter
	
  MipiTypeLUT U1_MipiTypeLUT
  (   	
  	.SysClk        (SysClk        ),	//(I)System Clock
  	.MipiDataType  (ConfDataType  ),  //(I)Mipi Type 
  	.MipiParamAva  (MipiParamAva  ),  //(O)MIPI Parameter Avaliable
  	.MipiDataParam (MipiDataParam )   //(O)Mipi Data Parameter
  );

	wire            CfgTxPixelNumAva  = MipiParamAva;    //Pixel Number Available
	wire   [ 3:0]   CfgTxPixelNum     = MipiDataParam[ 3: 0];  //(I)Pixel Number Per Data Group	
	wire   [15:0]   CfgTxHPixelMax    = MipiDataParam[35:20];
	wire   [16:0]   CfgTxBitNFactor   = MipiDataParam[56:40];
	
  /////////////////////////////////////////////////////////
  
  reg    [15:0]   HoriPayloadLen = 16'h0;
  
  always @( posedge SysClk)  
  begin
    if (ConfTxFrmMod)   HoriPayloadLen <= # TCo_C CalcHSyncLen - TxOverheadCycle_FM1_C;
    else                HoriPayloadLen <= # TCo_C HSyncPeriod  - TxOverheadCycle_FM0_C;
  end
  
	/////////////////////////////////////////////////////////  
  reg   [35:0]  HoriPayloadBitNum = 36'h0 ;
  reg   [16:0]  CalcHoriBitNum    = 17'h0 ;
  
  always @( posedge SysClk)  HoriPayloadBitNum <= # TCo_C ({2'h0,HoriPayloadLen} * {2'h0,TxDataPerPixClk_C});
  always @( posedge SysClk)  
  begin
    case (ConfLanesNum)
      3'h1    : CalcHoriBitNum <= # TCo_C HoriPayloadBitNum[24: 8];
      3'h2    : CalcHoriBitNum <= # TCo_C HoriPayloadBitNum[23: 7];
      3'h3    : CalcHoriBitNum <= # TCo_C HoriPayloadBitNum[23: 7] + HoriPayloadBitNum[24: 8];
      3'h4    : CalcHoriBitNum <= # TCo_C HoriPayloadBitNum[22: 6];
      default : CalcHoriBitNum <= # TCo_C HoriPayloadBitNum[24: 8];
    endcase
  end
  
	/////////////////////////////////////////////////////////  
  reg   [35:0]  CalcHoriMaxPixelNum   = 36'h0;
  
  always @( posedge SysClk)  CalcHoriMaxPixelNum  <= # TCo_C {1'h0,CalcHoriBitNum} * {1'h0,CfgTxBitNFactor};
  
  wire  [15:0]  HoriMaxPixelNum   = {CalcHoriMaxPixelNum[32:20],3'h0};
  
	/////////////////////////////////////////////////////////  
  reg   [15:0]  RealHoriPixelNum = 16'h0;
  
  always @( posedge SysClk)  RealHoriPixelNum <= # TCo_C (HoriMaxPixelNum  < CfgTxHPixelNum)  
                                                        ? HoriMaxPixelNum  : CfgTxHPixelNum  ;
                                                        
	/////////////////////////////////////////////////////////  
	reg  [15:0]   CalcHPixelNum = 16'h0; //(O)Calculate Horizontal Pixel Number
	
	always @( posedge SysClk)  CalcHPixelNum <= # TCo_C ( CfgTxHPixelMax  < RealHoriPixelNum)  
                                                     ?  CfgTxHPixelMax  : RealHoriPixelNum  ;
	
	/////////////////////////////////////////////////////////  
	wire   [15:0] DValLenValue; //(I)Data Valid Length Value
  wire          DValidLenAva; //Horizontal Synchronization Period Available
  
	LengthCalc
	# (
	    .NumWidth_C   ( 4 ), //Width For NumPerUnit 
	    .LenWidth_C   (16 ), //Width For LenPerUnit 
	    .ValueWidth_C (16 )  //Width For LenValue   
	  )
	U4_DValidCalc
  (   
  	//System Signal
  	.SysClk     (SysClk     ),	//System Clock
  	.Reset_N    (Reset_N    ),	//System Reset
  	//Signal    
  	.NumPerUnit (CfgTxPixelNum    ),  //(I)Number Per Unit
  	.LenPerUnit (CalcHPixelNum    ),  //(I)Length Per Unit(Pixel  Clock Cycle)
  	.LenValue   (DValLenValue     ),  //(O)Length Value (Pixel  Clock Cycle)
	  .LenRemain  (                 ), //(O)Length Remain
  	.LengthAva  (DValidLenAva     )   //(O)Length Available
  );
  
	/////////////////////////////////////////////////////////  
	reg          CalcDVLenAva   =  1'h0; //Calculate Data Valid Available
	reg  [15:0]  CalcDValidLen  = 16'h0; //Calculate Data Valid Length  (Pixel  Clock Cycle) 
	
  always @( posedge SysClk)   CalcDVLenAva  <= # TCo_C  DValidLenAva  &  (|CalcDValidLen);
  always @(            *  )   CalcDValidLen <= # TCo_C  DValLenValue;

	/////////////////////////////////////////////////////////  
	reg   [23:0]  CalcVSyncLen    = 24'h0; //Calculate Vertical Synchronization Length(Pixel  Clock Cycle)
	
	always @( posedge SysClk)   CalcVSyncLen  <= # TCo_C  VSyncLength + {8'h0,HSyncPeriod} + {8'h0,HSyncPeriod};//(&VSyncRemain) ?  VSyncLength : VSyncLength + CalcDValidLen;

//3333333333333333333333333333333333333333333333333333333



//4444444444444444444444444444444444444444444444444444444
//Generate Pixel Control Signal
//Out : MipiTxHSync MipiTxVSync MipiTxValid
//***************************************************/ 
 
  wire  TxOpConfigEn  ; //(O)MIPI Tx  Config Enable
  
  reg   TxConfigEn; //Pixel Control Parameter Config Enable
  
  always @( posedge SysClk)
  begin
    TxConfigEn  <= # TCo_C TxOpConfigEn & CalcVSLenAva & CalcHSLenAva & CalcDVLenAva;
  end
  
	/////////////////////////////////////////////////////////
	reg   [23:0]  VSyncLen  = 24'h0; //(I)Vertical Synchronization Length(Pixel  Clock Cycle)
	reg   [15:0]  HSyncLen  = 16'h0; //(I)Horizontal Synchronization Length  (Pixel  Clock Cycle)
	reg   [15:0]  DValidLen = 16'h0; //(I)Data Valid Length (Pixel  Clock Cycle) 
	reg   [19:0]  VBlankLen = 20'h0; //(I)Vertical Blanking  Length  (Pixel  Clock Cycle)
	reg   [15:0]  HBlankLen = 16'h0; //(I)Horizontal Blanking Length  (Pixel  Clock Cycle)
	reg   [15:0]  HSyncNum  = 16'h0; //(I)Horizontal Synchronization Number Per Vertical
	                                                     
	always @( posedge SysClk)   
	begin
	  if (TxConfigEn)
	  begin       
	    VSyncLen    <= # TCo_C CalcVSyncLen   ; 
	    HSyncLen    <= # TCo_C CalcHSyncLen   ; 
	    DValidLen   <= # TCo_C CalcDValidLen  ; 
	    VBlankLen   <= # TCo_C CalcVBlankLen  ; 
	    HBlankLen   <= # TCo_C CalcHBlankLen  - 16'h1; 
	    HSyncNum    <= # TCo_C CalcHSyncNum   ; 
    end
  end       
                                            
	/////////////////////////////////////////////////////////
	reg  TxCtrlOpEn = 1'h0;
	
	always @( posedge SysClk)
  begin
    if (TxCtrlOpEn)     TxCtrlOpEn <= # TCo_C PixelTxEn;
    else if(TxConfigEn) TxCtrlOpEn <= # TCo_C PixelTxEn;
  end
  
	/////////////////////////////////////////////////////////
  //MIPI Tx Siganl       
  wire  MipiTxHSync; //(O)MIPI Tx  Horizontal Synchronization
  wire  MipiTxVSync; //(O)MIPI Tx  Vertical Synchronization
  wire  MipiTxValid; //(O)MIPI Tx  Pixel Data Valid
	
	MipiTxOperate # (.TxShortFramerLen_C (TxShortFramerLen_C))
	U1_MipiTxOperate
  (   
  	//System Signal
  	.SysClk     (SysClk     ),	//System Clock
  	.Reset_N    (Reset_N    ),	//System Reset
  	//Config Signal
  	.VSyncLen   (VSyncLen   ), //(I)Vertical Synchronization Length(Pixel  Clock Cycle)
  	.VBlankLen  (VBlankLen  ), //(I)Vertical Blanking  Length  (Pixel  Clock Cycle)
  	.HSyncLen   (HSyncLen   ), //(I)Horizontal Synchronization Length  (Pixel  Clock Cycle)
  	.HBlankLen  (HBlankLen  ), //(I)Horizontal Blanking Length  (Pixel  Clock Cycle)
  	.DValidLen  (DValidLen  ), //(I)Data Valid Length (Pixel  Clock Cycle)    
  	.HSyncNum   (HSyncNum   ), //(I)Horizontal Synchronization Number Per Vertical
	  .PixelTxEn  (TxCtrlOpEn ), //(I)MIPI Tx  Enable
    //MIPI Tx  Siganl       
    .TxConfigEn (TxOpConfigEn ), //(O)MIPI Tx  Config Enable
    .MipiTxHSync(MipiTxHSync  ), //(O)MIPI Tx Horizontal Synchronization
    .MipiTxVSync(MipiTxVSync  ), //(O)MIPI Tx Vertical Synchronization
    .MipiTxValid(MipiTxValid  )  //(O)MIPI Tx  Pixel Data Valid
  );
  	

//4444444444444444444444444444444444444444444444444444444



endmodule 






	
		
///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	产生MIPI的控制信号
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-1-6
	版本：V1、0
	修改记录：
**********************************************************/

module  MipiTxOperate
(   
	//System Signal
	SysClk      ,	//System Clock
	Reset_N     ,	//System Reset
	//Config Signal
	VSyncLen    , //(I)Vertical Synchronization Length(Pixel  Clock Cycle)
	VBlankLen   , //(I)Vertical Blanking  Length  (Pixel  Clock Cycle)
	HSyncLen    , //(I)Horizontal Synchronization Length  (Pixel  Clock Cycle)
	HBlankLen   , //(I)Horizontal Blanking Length  (Pixel  Clock Cycle)
	DValidLen   , //(I)Data Valid Length (Pixel  Clock Cycle) 
	HSyncNum    , //(I)Horizontal Synchronization Number Per Vertical
	PixelTxEn   , //(I)MIPI Tx  Enable
  //MIPI Tx  Siganl       
  TxConfigEn  , //(O)MIPI Tx  Config Enable
  MipiTxHSync , //(O)MIPI TxHorizontal Synchronization
  MipiTxVSync , //(O)MIPI Tx Vertical Synchronization
  MipiTxValid   //(O)MIPI Tx  Pixel Data Valid
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C = 1;    
		
  parameter  [7:0]  TxShortFramerLen_C = 7'h40;
  
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	//Config Signal
	input   [23:0]  VSyncLen    ; //(I)Vertical Synchronization Length(Pixel  Clock Cycle)
	input   [19:0]  VBlankLen   ; //(I)Vertical Blanking  Length  (Pixel  Clock Cycle)
	input   [15:0]  HSyncLen    ; //(I)Horizontal Synchronization Length  (Pixel  Clock Cycle)
	input   [15:0]  HBlankLen   ; //(I)Horizontal Blanking Length  (Pixel  Clock Cycle)
	input   [15:0]  DValidLen   ; //(I)Data Valid Length (Pixel  Clock Cycle)  
	input   [15:0]  HSyncNum    ; //(I)Horizontal Synchronization Number Per Vertical
	input           PixelTxEn   ; //(I)MIPI Tx  Enable
	
	/////////////////////////////////////////////////////////
  //MIPI Tx Siganl       
  output  TxConfigEn  ; //(O)MIPI Tx  Config Enable
  output  MipiTxHSync ; //(O)MIPI Tx  Horizontal Synchronization
  output  MipiTxVSync ; //(O)MIPI Tx  Vertical Synchronization
  output  MipiTxValid ; //(O)MIPI Tx  Pixel Data Valid
		
	//1111111111111111111111111111111111111111111111111111111
	
	/*++++++++++++++++++++++++++++++++++
	处理场同步信号
	输入：
	输出：
	++++++++++++++++++++++++++++++++++*/	
	/////////////////////////////////////////////////////////
	reg   PixelTxEnReg  =  1'h0;
	reg   PixelTxEnChg  =  1'h0;
	
	always @( posedge SysClk)   PixelTxEnReg <= # TCo_C PixelTxEn;
	always @( posedge SysClk)   PixelTxEnChg <= # TCo_C ~PixelTxEnReg & PixelTxEn;
  
	/////////////////////////////////////////////////////////
	reg [23:0]  VSyncLenCnt ; //Vertical Synchronization Length Counter
	reg [19:0]  VBlankLenCnt; //Vertical Blanking Length Counter
	reg         VSyncSigEnd ; //Vertical Synchronization Signal End
  reg         VBlankSigEnd; //Vertical Blanking Signal End
  	
	always @( posedge SysClk or negedge Reset_N)
	begin
		if (!Reset_N)
		begin            
  	  VSyncLenCnt   <= # TCo_C 24'h0;
  	  VBlankLenCnt  <= # TCo_C 20'h0;
  	  VSyncSigEnd   <= # TCo_C  1'h0;
      VBlankSigEnd  <= # TCo_C  1'h0;
		end
		else
		begin
		  if (VBlankSigEnd)   VSyncLenCnt   <= # TCo_C VSyncLen     -  24'h1;  
		  else                VSyncLenCnt   <= # TCo_C VSyncLenCnt  - {23'h0 , (~&VSyncLenCnt)}  ;    

		  if (VSyncSigEnd)    VBlankLenCnt  <= # TCo_C VBlankLen    -  20'h1;  
		  else                VBlankLenCnt  <= # TCo_C VBlankLenCnt - {19'h0 , (~&VBlankLenCnt)} ;   
		  
  	  VSyncSigEnd   <= # TCo_C  (VSyncLenCnt  == 24'h1) | (~|VSyncLenCnt) & (~|VBlankLenCnt);
      VBlankSigEnd  <= # TCo_C  ((VBlankLenCnt == 20'h1) & PixelTxEn) | PixelTxEnChg;
		end
	end
	
	wire  VSyncStart = VBlankSigEnd;  //Vertical Synchronization Start
	
	/////////////////////////////////////////////////////////
  reg  MipiTxVSync = 1'h0; //(O)MIPI Tx Vertical Synchronization
  
	always @( posedge SysClk)
  begin
    if (VSyncSigEnd)        MipiTxVSync <= # TCo_C 1'h0;
    else if (VBlankSigEnd)  MipiTxVSync <= # TCo_C 1'h1;
  end
   
	//1111111111111111111111111111111111111111111111111111111
	
	
	
	//22222222222222222222222222222222222222222222222222222
	
	/*++++++++++++++++++++++++++++++++++
	处理行同步信号
	输入：
	输出：
	++++++++++++++++++++++++++++++++++*/			
	  
	/////////////////////////////////////////////////////////
	reg [15:0]  HSyncLenCnt ;   //Horizontal Synchronization Length Counter
	reg         HSyncSigEnd ;   //Horizontal Synchronization Signal End
  reg [15:0]  HSyncNumCnt ;   //Horizontal Synchronization Number Counter
  
	always @( posedge SysClk or negedge Reset_N)
	begin
	  if (!Reset_N)         HSyncNumCnt <= # TCo_C 16'h0;
	  else if (VSyncStart)  HSyncNumCnt <= # TCo_C HSyncNum    - 16'h1;
	  else if (HSyncSigEnd) HSyncNumCnt <= # TCo_C HSyncNumCnt - {15'h0 , (|HSyncNumCnt)} ;  
  end
  
	/////////////////////////////////////////////////////////
  reg  HoriSyncAva = 1'h0;  //Horizontal Synchronization Counter Available
  
  always @( posedge SysClk)
  begin
    if (VSyncStart)   HoriSyncAva <= # TCo_C 1'h1;
    else if ((HSyncNumCnt == 16'h0) & HSyncSigEnd)
      HoriSyncAva <= # TCo_C 1'h0;
  end
  
	/////////////////////////////////////////////////////////
	reg [15:0]  HBlankLenCnt; //Horizontal Blanking Length Counter
	reg         HBlankSigEnd; //Horizontal Blanking Signal End
	
  always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)
    begin
	    HSyncLenCnt   <= # TCo_C 16'h0;
	    HBlankLenCnt  <= # TCo_C 16'h0;
	    HSyncSigEnd   <= # TCo_C  1'h0;
	    HBlankSigEnd  <= # TCo_C  1'h0;
    end
    else if (VSyncStart)
    begin
	    HSyncLenCnt   <= # TCo_C 16'h0; 
	    HBlankLenCnt  <= # TCo_C HSyncLen; 
//	    HBlankLenCnt  <= # TCo_C HBlankLen; 
//	    HBlankLenCnt  <= # TCo_C {1'h0 , HBlankLen[15:1] + {15'h0,HBlankLen[0]}}; 
	    HSyncSigEnd   <= # TCo_C  1'h0;
	    HBlankSigEnd  <= # TCo_C  1'h0;
    end
    else if (HoriSyncAva)
    begin
		  if (HBlankSigEnd)   HSyncLenCnt   <= # TCo_C HSyncLen     - 16'h1;  
		  else                HSyncLenCnt   <= # TCo_C HSyncLenCnt  - {15'h0 , (|HSyncLenCnt)} ;    
		  if (HSyncSigEnd)    HBlankLenCnt  <= # TCo_C HBlankLen    - 16'h1;  
		  else                HBlankLenCnt  <= # TCo_C HBlankLenCnt - {15'h0 , (|HBlankLenCnt)};   
  	  HSyncSigEnd   <= # TCo_C  (HSyncLenCnt  == 16'h1);
      HBlankSigEnd  <= # TCo_C  (HBlankLenCnt == 16'h1);
    end
	end
				
	wire  HSyncStart = HBlankSigEnd;  //Horizontal Synchronization Start
	
	/////////////////////////////////////////////////////////
  reg  MipiTxHSync = 1'h0; //(O)MIPI Tx Horizontal Synchronization
  
	always @( posedge SysClk)
  begin
    if (HSyncSigEnd)      MipiTxHSync <= # TCo_C 1'h0;
    else if (HSyncStart)  MipiTxHSync <= # TCo_C 1'h1;
  end
	
	//22222222222222222222222222222222222222222222222222222
	
	
	
	//3333333333333333333333333333333333333333333333333333333
	
	/*++++++++++++++++++++++++++++++++++
	输入：
	输出：
	++++++++++++++++++++++++++++++++++*/	
	
	/***************************************************
	目的概述：
	功能描述：
	***************************************************/    
	
	/////////////////////////////////////////////////////////
	reg  [7:0] H2DDlyLenCnt; //Horizontal Synchronization To Data Valid Delay Length Counter
	
	always @( posedge SysClk or negedge Reset_N)
	begin
		if (!Reset_N)         H2DDlyLenCnt <= # TCo_C 8'h0;
		else if (HSyncStart)  H2DDlyLenCnt <= # TCo_C HBlankLen-1;//TxShortFramerLen_C;// - 8'h10;
		else                  H2DDlyLenCnt <= # TCo_C H2DDlyLenCnt - {7'h0 , (|H2DDlyLenCnt)};
	end
		
	reg DValidStart = 1'h0; //Data Valid Start
	
	always @( posedge SysClk) DValidStart <= (H2DDlyLenCnt == 8'h1);

	/////////////////////////////////////////////////////////
	reg  [15:0]   DValidLenCnt; //(I)Data Valid Length Counter
	
	always @( posedge SysClk)
  begin
    if (DValidStart)    DValidLenCnt <= # TCo_C DValidLen - 16'h1;
    else                DValidLenCnt <= # TCo_C DValidLenCnt - {15'h0 , (|DValidLenCnt)};
  end
  
  reg DValidEnd = 1'h0;
  
  always @( posedge SysClk)  DValidEnd <= (DValidLenCnt == 16'h1);
  
	/////////////////////////////////////////////////////////
  reg  MipiTxValid = 4'h0; //(O)MIPI Tx  Data Valid
  
	always @( posedge SysClk)
  begin
//    MipiTxValid <= # TCo_C &DValidLenCnt[1:0];
    if (DValidEnd)        MipiTxValid <= # TCo_C 1'h0;
    else if (DValidStart) MipiTxValid <= # TCo_C 1'h1;
  end
	
	//3333333333333333333333333333333333333333333333333333333
	
	
	
	
	//4444444444444444444444444444444444444444444444444444444
	
	/*++++++++++++++++++++++++++++++++++
	
	输入：
	输出：
	++++++++++++++++++++++++++++++++++*/	  
  reg [7:0]   TxConfCnt   ; //Tx Configuration Counter
  reg         TxConfigEn  ; //(O)MIPI Tx  Config Enable
  
  always @( posedge SysClk)
  begin
	  if (VSyncSigEnd)    TxConfCnt  <= # TCo_C (|VBlankLen[19:10]) ? 8'hff : VBlankLen[9:1];  
	  else                TxConfCnt  <= # TCo_C TxConfCnt       - {7'h0 , (|TxConfCnt)} ;   
	  
	  TxConfigEn <= # TCo_C (TxConfCnt == 8'h1) | (~PixelTxEn) ; 
  end
  

	//4444444444444444444444444444444444444444444444444444444
	
	
	
endmodule 






///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-1-6
	版本：V1、0
	修改记录：
**********************************************************/

module  LengthCalc
(   
	//System Signal
	SysClk,			//System Clock
	Reset_N,		//System Reset
	//Signal
	NumPerUnit, //(I)Number Per Unit
	LenPerUnit, //(I)Length Per Unit(Pixel  Clock Cycle)
	LenValue  , //(O)Length Value (Pixel  Clock Cycle)
	LenRemain , //(O)Length Remain
	LengthAva   //(O)Length Available
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
	parameter   NumWidth_C    =  7  ; //Width For NumPerUnit 
	parameter   LenWidth_C    = 28  ; //Width For LenPerUnit 
	parameter   ValueWidth_C  = 24  ; //Width For LenValue   
	
	localparam  NW_C = NumWidth_C   ; //Width For NumPerUnit   
	localparam  LW_C = LenWidth_C   ; //Width For LenPerUnit   
	localparam  VW_C = ValueWidth_C ; //Width For LenValue     
	
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	// Signal Define
	input   [NW_C-1:0]  NumPerUnit; //(I)Number Per Unit
	input   [LW_C-1:0]  LenPerUnit; //(I)Length Per Unit(Pixel  Clock Cycle)
	output  [VW_C-1:0]  LenValue  ; //(O)Length Value (Pixel  Clock Cycle)
	output              LengthAva ; //(O)Length Available
	output  [ 7:0]      LenRemain ; //(O)Length Remain
	
	//1111111111111111111111111111111111111111111111111111111
		
	/////////////////////////////////////////////////////////	
	reg               NumPerUnitChg   = 1'h0;
	reg   [NW_C-1:0]  NumPerUnitReg   = {NW_C{1'h0}};
	
	always @( posedge SysClk)   NumPerUnitReg <= # TCo_C NumPerUnit;
	always @( posedge SysClk)   NumPerUnitChg <= # TCo_C (NumPerUnitReg != NumPerUnit);
	
	/////////////////////////////////////////////////////////	
	reg               LenPerUnitChg   = 1'h0;
	reg   [LW_C-1:0]  LenPerUnitReg   = {LW_C{1'h0}};
	
	always @( posedge SysClk)   LenPerUnitReg <= # TCo_C LenPerUnit;
	always @( posedge SysClk)   LenPerUnitChg <= # TCo_C (LenPerUnitReg != LenPerUnit);
	
	wire  ReCalcEn = NumPerUnitChg | LenPerUnitChg;
	
	/////////////////////////////////////////////////////////	
	reg   ULenCalcAva  = 1'h0;
	reg   ULenCalcEnd  = 1'h0;
	reg [LW_C-1:0]  ULenCalcCnt  = {LW_C{1'h0}};
	
	always @( posedge SysClk)
  begin
    if  (ReCalcEn)        ULenCalcAva <= # TCo_C 1'h1;
    else if (ULenCalcEnd) ULenCalcAva <= # TCo_C 1'h0;
  end
  	
	always @( posedge SysClk)
  begin
    if (ReCalcEn)   ULenCalcCnt <= # TCo_C LenPerUnit  - {{LW_C-1{1'h0}},1'h1};
    else  if (ULenCalcAva)     ULenCalcCnt <= # TCo_C (ULenCalcCnt - {{(LW_C-NW_C){1'h0}},NumPerUnitReg});
  end
  
	always @( posedge SysClk or negedge Reset_N)
  begin
    if (!Reset_N)           ULenCalcEnd  <= # TCo_C 1'h0;
    else if (ULenCalcAva)   ULenCalcEnd  <= # TCo_C (ULenCalcCnt < {{(LW_C-NW_C){1'h0}},NumPerUnitReg});
    else                    ULenCalcEnd  <= # TCo_C 1'h0;
  end
  
  reg  [7:0]   ULenCalcCntReg = 8'h0;
  
  always @( posedge SysClk)  
  begin
    if (ULenCalcAva & (~ULenCalcEnd))  
    begin
      ULenCalcCntReg <= # TCo_C (|ULenCalcCnt[LW_C-1:8]) ? 8'hff : ULenCalcCnt[7:0];
    end
  end
  
  wire  [ 7:0]  LenRemain = ULenCalcCntReg;
  
	/////////////////////////////////////////////////////////	  
  reg   [5:0]   AvaCnt;
  
  always @( posedge SysClk)  
  begin
    if (NumPerUnitChg | ULenCalcAva)  AvaCnt <= # TCo_C 6'h0;
    else if (~ AvaCnt[5])              AvaCnt <= # TCo_C AvaCnt + 6'h1; 
  end
  
	wire  LengthAva = AvaCnt[5]; //(O)Length Available
	
	/////////////////////////////////////////////////////////	
  
	reg   [VW_C-1:0]  LenValueCnt   = {VW_C{1'h0}};
	
	always @( posedge SysClk)
  begin
    if (ReCalcEn)           LenValueCnt <= # TCo_C {VW_C{1'h0}};
    else if (ULenCalcAva)   LenValueCnt <= # TCo_C LenValueCnt + {{VW_C-1{1'h0}},1'h1};
  end
  
	/////////////////////////////////////////////////////////	
	reg   [VW_C-1:0]  LenValue  = {VW_C{1'h0}}; //(O)Length Value (Pixel  Clock Cycle)
	
	always @( posedge SysClk)
	begin
	  if (ULenCalcEnd)  LenValue <= # TCo_C LenValueCnt;
  end
  
	//1111111111111111111111111111111111111111111111111111111
	
	
	
endmodule 
	
		






///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-1-6
	版本：V1、0
	修改记录：
**********************************************************/

module  MipiTypeLUT
(   	
	SysClk        ,		//(I)System Clock
	MipiDataType  ,   //(I)Mipi Type 
	MipiParamAva  ,   //(O)MIPI Parameter Avaliable
	MipiDataParam     //(O)Mipi Data Parameter
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				  SysClk        ;   //(I)System Clock
	input   [5:0]   MipiDataType  ;   //(I)Mipi Type
	output          MipiParamAva  ;   //(O)MIPI Parameter Avaliable
	output  [79:0]  MipiDataParam ;   //(O)Mipi Data Parameter
	
	/////////////////////////////////////////////////////////
	// Signal Define
		
//1111111111111111111111111111111111111111111111111111111
//	
//	Input：
//	output：
//***************************************************/ 
	/////////////////////////////////////////////////////////
	reg [1:0]  LUTSelCnt = 2'h0;
	
	always @( posedge SysClk)  LUTSelCnt <= # TCo_C LUTSelCnt + 2'h1;
	
	/////////////////////////////////////////////////////////
  wire  [ 7:0]  PixelTypeLutA ; //Pixel Type LUT Address             
  
  assign PixelTypeLutA[7:2]  = MipiDataType;
  assign PixelTypeLutA[1:0]  = LUTSelCnt;
  
	/////////////////////////////////////////////////////////  
  wire  [19:0]  PixelTypeLutD;  //Pixel Type LUT Data   
	
	EFX_RAM_5K #
	(
		.READ_WIDTH			(20), 	// 20 256x20
		.WRITE_WIDTH		(20), 	// 20 256x20
		.OUTPUT_REG			(1'h0), // 1 add pipe-line read register
		.RCLK_POLARITY	(1'b1), // 0 falling edge, 1 rising edge
		.RE_POLARITY		(1'b1), // 0 active low, 1 active high
		.WCLK_POLARITY	(1'b1), // 0 falling edge, 1 rising edge
		.WE_POLARITY		(1'b1), // 0 active low, 1 active high
		.WCLKE_POLARITY(1'b1), // 0 active low, 1 active high
		
		.INIT_0	   ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_1	   ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_2	   ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_3	   ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_4	   ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_5	   ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_6	   ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_7	   ( 256'h0080B4084262800008200080B408848800000000000000000000000000000000  ),
		.INIT_8	   ( 256'h08200080B4088484000000000000000000008000082AAB80F008444480000820  ),
		.INIT_9	   ( 256'h800008199A8090082222800008200080B4084444800008200080B40842428000  ),
		.INIT_A	   ( 256'h3333800008200080B4084444800008222380C00844448000082AAB80F0084444  ),
		.INIT_B	   ( 256'h0000000000000000000000000000800008155680780822228000081C7280A008  ),
		.INIT_C	   ( 256'h25819B688888800008555681E00888AA00000000000000000000000000000000  ),
		.INIT_D	   ( 256'h082AAB80F0084455800008333481200844668000084000816808888880000849  ),
		.INIT_E	   ( 256'h0000000000000000000000000000000000000000800008249380CDB844448000  ),
		.INIT_F	   ( 256'h8888800008400081680888888000084000816808888880000840008168088888  ),
		.INIT_10	 ( 256'h6808888880000840008168088888800008400081680888888000084000816808  ),
		.INIT_11	 ( 256'h0000000000000000000000000000000080000840008168088888800008400081  ),
		.INIT_12	 ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),
		.INIT_13	 ( 256'h0000000000000000000000000000000000000000000000000000000000000000  ),


		.WRITE_MODE("READ_FIRST")  // Output "old" data

	)
	U4_PixelTypeLut
	( 
  	.WCLK		( 1'h0), 
  	.WE			( 1'h0), 
  	.WCLKE	( 1'h0), 
  	.WDATA	(20'h0), 
  	.WADDR	( 8'h0),
  	
  	.RCLK		(SysClk), 
  	.RE  		(1'h1), 
  	.RDATA	(PixelTypeLutD), 
  	.RADDR	(PixelTypeLutA)
	); 
	
	/////////////////////////////////////////////////////////
	wire  [1:0] LUTRegSel = LUTSelCnt - 2'h1;
	
	reg [79:0]  MipiDataParam = 80'h0;
	
	always @( posedge SysClk)  
	begin
	  if (LUTRegSel == 2'h0)  MipiDataParam[19: 0]  <= # TCo_C PixelTypeLutD;
	  if (LUTRegSel == 2'h1)  MipiDataParam[39:20]  <= # TCo_C PixelTypeLutD;
	  if (LUTRegSel == 2'h2)  MipiDataParam[59:40]  <= # TCo_C PixelTypeLutD;
	  if (LUTRegSel == 2'h3)  MipiDataParam[79:60]  <= # TCo_C PixelTypeLutD;
  end
		
//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//	
//	Input：
//	output：
//***************************************************/ 

	/////////////////////////////////////////////////////////
  reg  [5:0]  MipiDataTypeReg;
  
  always @( posedge SysClk)  MipiDataTypeReg <= # TCo_C MipiDataType;
  
  reg  [2:0]  MipiDTypeChgCnt;
   
  always @( posedge SysClk)  
  begin
    if (MipiDataTypeReg == MipiDataType)    MipiDTypeChgCnt <= # TCo_C 3'h0;
    else if         (~PixelTypeLutD[19])    MipiDTypeChgCnt <= # TCo_C 3'h0;
    else        MipiDTypeChgCnt <= # TCo_C  MipiDTypeChgCnt + {2'h0,(~MipiDTypeChgCnt[2])};
  end
  
	wire   MipiParamAva  = MipiDTypeChgCnt[2];   //(O)MIPI Parameter Avaliable
	
	/////////////////////////////////////////////////////////
	
//22222222222222222222222222222222222222222222222222222




endmodule 