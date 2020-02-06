
`timescale 100ps/10ps

///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-9-6
	版本：V1、0
	修改记录：
**********************************************************/

module MipiRxMoni
(   
	//System Signal
	SysClk,			//System Clock
	Reset_N,		//System Reset
	// MIPI Rx Signal
  PixelRxReset    , //(I)Pixel Rx DPHY/CSI Reset
  PixelRxHSync    , //(I)Pixel Rx Horizontal Synchronization
  PixelRxVSync    , //(I)Pixel Rx Vertical Synchronization
  PixelRxValid    , //(I)Pixel Rx Pixel Data Valid   
  MipiRxVirtCnl   , //(I)MIPI Rx Virtual Channel
  MipiRxPixNum    , //(I)MIPI Rx Pixel Number 
  MipiRxStaInd    , //(I)MIPI Rx State Indicate   
  MipiRxDType     , //(I)MIPI Rx Data Type
	// MIPI Rx Measure Value and State
	VidioFrmNum     , //(O)Vidio Framer Number  
	VidioHPixelNum  , //(O)Vidio Horizontal Pixel Number
	VidioVPixelNum  , //(O)Vidio Vertical Pixel Number    
	VidioVBlankTime , //(O)Vidio Vertical Blanking Time (us)      
	VidioHBlankTime , //(O)Vidio Horizontal Blanking Time (us)      
	VidioDataType   , //(O)Vidio Data Type
	VidioRestChg    , //(O)MIPI Rx Vidio Resolution Change	
	MipiRxStaChg    , //(O)MIPI Rx State Change          
	MipiRxSyncErr   , //(O)MIPI Rx VSync&HSync Error  
	MipiRxStaVCAct  , //(O)MIPI Rx VC Active Indicate
  MipiRxLanesAct    //(O)MIPI Rx Lanes Active Indicate
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
  parameter   [27:0]  RxPixelClkFreq_C  = 28'd100_000_000;
  localparam  [ 7:0]  RxClkCyclePerUs_C = RxPixelClkFreq_C / 28'd1_000_000;
    
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	// MIPI Rx Signal
  input           PixelRxReset    ; //(I)Pixel Rx DPHY/CSI Reset
  input           PixelRxHSync    ; //(I)Pixel Rx Horizontal Synchronization
  input           PixelRxVSync    ; //(I)Pixel Rx Vertical Synchronization
  input           PixelRxValid    ; //(I)Pixel Rx Pixel Data Valid   
  input   [ 3:0]  MipiRxPixNum    ; //(I)MIPI Rx Pixel Number 
  input   [ 1:0]  MipiRxVirtCnl   ; //(I)MIPI Rx Virtual Channel
  input   [17:0]  MipiRxStaInd    ; //(I)MIPI Rx State Indicate   
  input   [ 5:0]  MipiRxDType     ; //(I)MIPI Rx Data Type
    
	/////////////////////////////////////////////////////////
	// MIPI Rx Measure Value and State
	output  [ 7:0]  VidioFrmNum     ; //(O)Vidio Framer Number  
	output  [15:0]  VidioHPixelNum  ; //(O)Vidio Horizontal Pixel Number
	output  [15:0]  VidioVPixelNum  ; //(O)Vidio Vertical Pixel Number    
	output  [15:0]  VidioVBlankTime ; //(O)Vidio Vertical Blanking Time (us)      
	output  [15:0]  VidioHBlankTime ; //(O)Vidio Horizontal Blanking Time (us)     
	output  [ 5:0]  VidioDataType   ; //(O)Vidio Data Type   
	output          VidioRestChg    ; //(O)MIPI Rx Vidio Resolution Change	
	output          MipiRxStaChg    ; //(O)MIPI Rx State Change  
	output          MipiRxSyncErr   ; //(O)MIPI Rx VSync&HSync Error
	output  [3:0]   MipiRxStaVCAct  ; //(O)MIPI Rx VC Active Indicate
  output          MipiRxLanesAct  ; //(O)MIPI Rx Lanes Active Indicate
		
//1111111111111111111111111111111111111111111111111111111
//	
//	Input：
//	output：
//***************************************************/ 

	/////////////////////////////////////////////////////////
  reg   [1:0] MipiRxHSyncReg  = 2'h0;
  reg   [1:0] MipiRxVSyncReg  = 2'h0;
  reg   [1:0] MipiRxValidReg  = 2'h0;
  
  always @( posedge SysClk)  
  begin
    MipiRxHSyncReg  <= # TCo_C {MipiRxHSyncReg[0],PixelRxHSync};
    MipiRxVSyncReg  <= # TCo_C {MipiRxVSyncReg[0],PixelRxVSync};
    MipiRxValidReg  <= # TCo_C {MipiRxValidReg[0],PixelRxValid};
  end
  
	/////////////////////////////////////////////////////////
  reg MipiRxHSyncPos  = 1'h0;
  reg MipiRxVSyncPos  = 1'h0;
  reg MipiRxValidPos  = 1'h0;
  reg MipiRxHSyncNeg  = 1'h0;
  reg MipiRxVSyncNeg  = 1'h0;
  reg MipiRxValidNeg  = 1'h0;
  
  always @( posedge SysClk)  
  begin
    MipiRxHSyncPos  <= # TCo_C  (MipiRxHSyncReg  == 2'h1);
    MipiRxVSyncPos  <= # TCo_C  (MipiRxVSyncReg  == 2'h1);
    MipiRxValidPos  <= # TCo_C  (MipiRxValidReg  == 2'h1);
    MipiRxHSyncNeg  <= # TCo_C  (MipiRxHSyncReg  == 2'h2);
    MipiRxVSyncNeg  <= # TCo_C  (MipiRxVSyncReg  == 2'h2);
    MipiRxValidNeg  <= # TCo_C  (MipiRxValidReg  == 2'h2);
  end
  
	/////////////////////////////////////////////////////////
  //Generate Second Signal 
  reg [27:0]  SecondCnt = 28'h0;
  reg         SecondEn  =  1'h0;
  
  always @( posedge SysClk)  
  begin    
    if (|SecondCnt)   SecondCnt <= # TCo_C SecondCnt        - 28'h1;
    else              SecondCnt <= # TCo_C RxPixelClkFreq_C - 28'h1;
        
    SecondEn <= # TCo_C (SecondCnt == 28'h1);
  end
  
	/////////////////////////////////////////////////////////
	//Measure Vidio frame Rate
	reg   [7:0]   VidioFrmCnt   = 8'h0;
	reg   [7:0]   VidioFrmNum   = 8'h0;
  reg           VidioFrmLost  = 1'h0;
  
  always @( posedge SysClk)  
  begin
    if (SecondEn)             VidioFrmCnt <= # TCo_C MipiRxVSyncPos ? 8'h1 : 8'h0;
    else if (MipiRxVSyncPos)  VidioFrmCnt <= # TCo_C VidioFrmCnt + 8'h1;
    
    if (SecondEn)             VidioFrmNum <= # TCo_C VidioFrmCnt;
    
    VidioFrmLost <= # TCo_C (VidioFrmNum == 8'h0) & SecondEn;
  end
  
  wire  VidioFrmNumChg =  SecondEn & (VidioFrmNum != VidioFrmCnt) ;
  
	/////////////////////////////////////////////////////////
	//Measure Vidio Vertical Pixel Number
	reg [15:0]  VidioVPixelCnt  = 16'h0;
	reg [15:0]  VidioVPixelNum  = 16'h0;  
	
	always @( posedge SysClk)  
	begin
	  if (MipiRxVSyncPos)       VidioVPixelCnt  <= # TCo_C 16'h0;    
	  else if (MipiRxHSyncPos)  VidioVPixelCnt  <= # TCo_C VidioVPixelCnt + 16'h1; 
	  
	  if (VidioFrmLost)         VidioVPixelNum  <= # TCo_C 16'h0;
	  else if (MipiRxVSyncPos)  VidioVPixelNum  <= # TCo_C VidioVPixelCnt;      
  end
  
  wire  VidoVPixelNumChg = MipiRxVSyncNeg & (VidioVPixelNum  != VidioVPixelCnt);
  
	/////////////////////////////////////////////////////////
	//Measure Vidio Horizontal Pixel Number 
	reg [2:0]   DataAvailCnt;
	reg         HSyncEnd;
	
	always @( posedge SysClk) 
	begin
	  if (PixelRxValid)   DataAvailCnt <= # TCo_C 3'h7;
	  else                DataAvailCnt <= # TCo_C DataAvailCnt - {2'h0,|DataAvailCnt};
	  
	  HSyncEnd  <= # TCo_C (DataAvailCnt == 3'h1) & (~PixelRxValid); 
  end  
	
	reg   [15:0]  VidioHPixelCnt  = 16'h0;
	reg   [15:0]  VidioHPixelNum  = 16'h0;      
	
	always @( posedge SysClk)  
	begin
	  
	  if (PixelRxValid)   VidioHPixelCnt  <= # TCo_C VidioHPixelCnt + MipiRxPixNum; 
	  else if(HSyncEnd)   VidioHPixelCnt  <= # TCo_C 16'h0;    	                       
	  
	  if (VidioFrmLost)   VidioHPixelNum  <= # TCo_C 16'h0;
	  else if (HSyncEnd)  VidioHPixelNum  <= # TCo_C VidioHPixelCnt;    
  end  
                  
	wire VidioHPixelNumChg = HSyncEnd & (VidioHPixelNum != VidioHPixelCnt); 
	
	/////////////////////////////////////////////////////////
	//
	reg [1:0]   VidioRestChgChk = 2'h0; //MIPI Rx Vidio Resolution Change Check
	reg         VidioRestChg    = 1'h0; //MIPI Rx Vidio Resolution Change
	
	always @( posedge SysClk)  
	begin
	  if (VidioFrmNumChg | VidoVPixelNumChg | VidioHPixelNumChg)  VidioRestChgChk[0] <= # TCo_C 1'h1;
	  else if (SecondEn)  VidioRestChgChk[0] <= # TCo_C 1'h0;
	  
	  if (SecondEn) VidioRestChgChk[1]  <= # TCo_C VidioRestChgChk[0];
	  
	  VidioRestChg <= # TCo_C |VidioRestChgChk;
  end
	
//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//	
//	Input：
//	output：
//***************************************************/ 
  
  reg [7:0] USecondCnt  = 8'h0;
  reg       USecondEn   = 1'h0;
  
  always @( posedge SysClk)  
  begin
    if (|USecondCnt)    USecondCnt <= # TCo_C USecondCnt        - 8'h1;
    else                USecondCnt <= # TCo_C RxClkCyclePerUs_C - 8'h1;
    
    USecondEn <= # TCo_C (USecondCnt == 8'h1);
  end
  
	/////////////////////////////////////////////////////////
	//Measure Vidio Vertical Blanking Time 
	reg   [ 3:0]  VidioVBStaCnt   =  4'h0;  //Vidio Vertical Blanking Statistics Counter
	reg   [19:0]  VidioVBlankCnt  = 20'h0;  //Vidio Vertical Blanking Time Counter
	reg   [15:0]  VidioVBlankTime = 16'h0;  //Vidio Vertical Blanking time    
	
	always @( posedge SysClk)  
	begin
	  if (MipiRxVSyncPos) VidioVBStaCnt   <= # TCo_C VidioVBStaCnt + 4'h1;
	  
	  if (MipiRxVSyncPos & (&VidioVBStaCnt))                VidioVBlankCnt  <= # TCo_C 20'h0;
	  else if (~PixelRxVSync)  VidioVBlankCnt  <= # TCo_C   VidioVBlankCnt + {19'h0,USecondEn};
	                      
	  if (MipiRxVSyncPos & (&VidioVBStaCnt))  
	  begin
	    VidioVBlankTime  <= # TCo_C VidioVBlankCnt[19:4]+ {15'h0,VidioVBlankCnt[3]};
	  end
	  else if (VidioFrmLost)                  VidioVBlankTime  <= # TCo_C 16'h0;
  end  
		
	/////////////////////////////////////////////////////////
	//Measure Vidio Horizontal Blanking Time 
	reg   [ 3:0]  VidioHBStaCnt   =  4'h0;  //Vidio Horizontal Blanking Statistics Counter
	reg   [19:0]  VidioHBlankCnt  = 20'h0;
	reg   [15:0]  VidioHBlankTime = 16'h0;   
	reg           VidioHBlankAva  = 16'h0;   
		
	always @( posedge SysClk)  
	begin	  
	  if (~PixelRxVSync)        VidioHBStaCnt <= # TCo_C 4'h0;
	  else if (MipiRxHSyncPos)  VidioHBStaCnt <= # TCo_C VidioHBStaCnt + 4'h1;
	  
	  if (MipiRxHSyncPos & (&VidioHBStaCnt) | (~PixelRxVSync))    VidioHBlankCnt  <= # TCo_C 20'h0;
	  else if (~PixelRxHSync)         VidioHBlankCnt  <= # TCo_C  VidioHBlankCnt + {19'h0,USecondEn};
	  
	  if (~PixelRxVSync)        VidioHBlankAva  <= # TCo_C  1'h0;
	  else if (MipiRxHSyncNeg)  VidioHBlankAva  <= # TCo_C  1'h1; 
	  
	  if (MipiRxHSyncPos & VidioHBlankAva & (&VidioHBStaCnt))     
	  begin
	    VidioHBlankTime  <= # TCo_C VidioHBlankCnt[19:4] + {15'h0,VidioHBlankCnt[3]};
	  end
	  else if (VidioFrmLost)  VidioHBlankTime  <= # TCo_C 16'h0; 
  end  
		
//2222222222222222222222222222222222222222222222222222222



//3333333333333333333333333333333333333333333333333333333
//	
//	Input：
//	output：
//***************************************************/ 

	//Record MIPI-Rx Active Channel ; 1 : Active 
  reg    MipiRxStaActChk  = 1'h0;
  
  always @( posedge SysClk)    
  begin
    if  (SecondEn)            MipiRxStaActChk <= # TCo_C 1'h0;
    else if (MipiRxValidPos)  MipiRxStaActChk <= # TCo_C 1'h1;
  end
     
  reg   MipiRxLanesAct = 1'h0;
  
  always @( posedge SysClk)  
  begin 
    if (PixelRxReset)   MipiRxLanesAct <= # TCo_C 1'h0;
    else if (SecondEn)  MipiRxLanesAct <= # TCo_C MipiRxStaActChk;
  end
  
	/////////////////////////////////////////////////////////
	//Record MIPI-Rx Active Virtual Channel
	reg [3:0]   MipiRxVCAct   = 4'h0; 
	
	always @( posedge SysClk)  
	begin
	  if (SecondEn)             MipiRxVCAct <= # TCo_C 4'h0;
	  else if (MipiRxValidPos)   
	  begin
	    case (MipiRxVirtCnl)
	      2'h0: MipiRxVCAct[0] <= # TCo_C 4'h1;
	      2'h1: MipiRxVCAct[1] <= # TCo_C 4'h1;
	      2'h2: MipiRxVCAct[2] <= # TCo_C 4'h1;
	      2'h3: MipiRxVCAct[3] <= # TCo_C 4'h1;
	    endcase	      
    end
  end
     
	reg [3:0]   MipiRxStaVCAct      = 4'h0;
	
	always @( posedge SysClk)  if (SecondEn) MipiRxStaVCAct <= # TCo_C MipiRxVCAct;
		   
	/////////////////////////////////////////////////////////
	reg  [ 5:0]  VidioDataType   ; //(O)Vidio Data Type   
	
	always @( posedge SysClk)  
	begin
	  if (MipiRxValidPos)     VidioDataType <= # TCo_C MipiRxDType;	
	  else if (VidioFrmLost)  VidioDataType <= # TCo_C 6'h0;   
	end
	
	/////////////////////////////////////////////////////////
	//Record  MIPI-Rx Error
	reg [17:0]  MipiRxError;
	
	always @( posedge SysClk)  MipiRxError <= # TCo_C  MipiRxStaInd;
	
	/////////////////////////////////////////////////////////
	//Record MIPI-Rx State Change
	wire  RxStateChange =     (MipiRxError    != MipiRxStaInd    )
        |(SecondEn        & (MipiRxStaVCAct != MipiRxVCAct    )) 
        |(SecondEn        & (MipiRxLanesAct != MipiRxStaActChk))
        |(MipiRxValidPos  & (VidioDataType  != MipiRxDType    ))  ;
                  	        
	reg  [1:0]  MipiRxStaChgChk = 2'h0;
	
	always @( posedge SysClk)  
	begin
	  if (RxStateChange)  MipiRxStaChgChk[0]  <= # TCo_C 1'h1;
    else if (SecondEn)  MipiRxStaChgChk[0]  <= # TCo_C 1'h0;
    
    if (SecondEn)  MipiRxStaChgChk[1]  <= # TCo_C MipiRxStaChgChk[0];
  end
  
	reg         MipiRxStaChg    = 1'h0;
		
	always @( posedge SysClk)  MipiRxStaChg  <= # TCo_C |MipiRxStaChgChk;
			
//3333333333333333333333333333333333333333333333333333333



//4444444444444444444444444444444444444444444444444444444
//	HSync & VSync Error 
//	Input：
//	output：
//***************************************************/ 

  reg   RxHSyncErr;
  reg   RxVSyncErr;
  reg   RxSyncErr;    //Rx VSync&HSync Error

  
  always @( posedge SysClk)  
  begin
    if (SecondEn)             RxHSyncErr <= # TCo_C 1'h1;
    else if (MipiRxHSyncPos)  
      RxHSyncErr <= # TCo_C 1'h0;
    
    if (SecondEn)             RxVSyncErr <= # TCo_C 1'h1;
    else if (MipiRxVSyncPos)  
      RxVSyncErr <= # TCo_C 1'h0;
    
    RxSyncErr  <= # TCo_C (RxVSyncErr | RxHSyncErr) & SecondEn;        
  end
  
	wire  MipiRxSyncErr = RxSyncErr; //(O)MIPI Rx VSync&HSync Error
	
//4444444444444444444444444444444444444444444444444444444
	
	
	
endmodule 
	
		
		
///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-9-9
	版本：V1、0
	修改记录：
**********************************************************/

module MipiRxCtrl
(   
	//System Signal
	SysClk    ,	  //System Clock
	Reset_N   ,		//System Reset
	//Config & Control Signal
	CtrlRxDPHYRstN  , //(I)Control MIPI Rx DPHY Reset                   
	CtrlRxCSIRstN   , //(I)Control MIPI Rx CSI-2 Reset                  
	CtrlRxErrClr    , //(I)Control MIPI Rx Error Clear                  
	ConfRxVCEn      , //(I)Config  MIPI Rx Virtual Channel Enable       
	ConfRxLanNum    , //(I)Config  MIPI Rx Lanes      
  MipiRxLanesAct  , //(I)MIPI Rx Lanes Active Indicate
	MipiRxSyncErr   , //(I)MIPI Rx VSync&HSync Error   
	PixelRxReset    , //(O)MIPI Rx Reset Signal                
	//Output To MIPI                                                 
	MipiRxDPHYRstN  , //(O)[Control]MIPI Rx DPHY Reset                  
	MipiRxCSIRstN   , //(O)[Control]MIPI Rx CSI-2 Reset                 
	MipiRxErrClr    , //(O)[Status] MIPI Rx Error Clear               
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk  ;			//系统时钟
	input					Reset_N ;			//系统复位
	
	/////////////////////////////////////////////////////////
	//Config & Control Signal
  input			      CtrlRxDPHYRstN  ; //(I)Control MIPI Rx DPHY Reset (Low Active)
	input			      CtrlRxCSIRstN   ; //(I)Control MIPI Rx CSI-2 Reset (Low Active)
	input		        CtrlRxErrClr    ; //(I)Control MIPI Rx Error Clear
	input   [ 3:0]  ConfRxVCEn      ; //(I)Config  MIPI Rx Virtual Channel Enable
	input   [ 2:0]  ConfRxLanNum    ; //(I)Config  MIPI Rx Lanes
  input           MipiRxLanesAct  ; //(I)MIPI Rx Lanes Active Indicate
	input           MipiRxSyncErr   ; //(I)MIPI Rx VSync&HSync Error
	output          PixelRxReset    ; //(O)MIPI Rx Reset Signal    
	
	/////////////////////////////////////////////////////////        
	//Output To MIPI                                 
  output			    MipiRxDPHYRstN  ; //(O)MIPI Rx DPHY Reset (Low Active, To MIPI-Rx Interface)
	output			    MipiRxCSIRstN   ; //(O)MIPI Rx CSI-2 Reset  (Low Active, To MIPI-Rx Interface)
	output		      MipiRxErrClr    ; //(O)MIPI Rx Error Clear  (To MIPI-Rx Interface)
	
//1111111111111111111111111111111111111111111111111111111
//	
//	Input：
//	output：
//***************************************************/ 
	
	reg [ 3:0]  ConfLastRxVCEn    = 4'h0; //Config MIPI Rx Last  Virtual Channel Enable 
	reg [ 2:0]  ConfLastRxLanNum  = 3'h0; //Config MIPI Rx Last  Lanes Number
	reg         MipiRxAutoRst     = 1'h0; //MIPI-Rx Auto Reset as a Result of Config parameter Changed
	
	always @( posedge SysClk)  ConfLastRxVCEn   <= # TCo_C ConfRxVCEn  ; 
	always @( posedge SysClk)  ConfLastRxLanNum <= # TCo_C ConfRxLanNum; 
	always @( posedge SysClk)  MipiRxAutoRst    <= # TCo_C MipiRxSyncErr 
	                                              | (ConfLastRxVCEn   != ConfRxVCEn  ) 
	                                              | (ConfLastRxLanNum != ConfRxLanNum);
	                                              
	/////////////////////////////////////////////////////////
	reg [15:0] RxDPHYRstCnt = 16'h0;  //MIPI RX DPHY Reset Counter 
	
	always @( posedge SysClk or negedge Reset_N)  
	begin
	  if (!Reset_N)               RxDPHYRstCnt <= # TCo_C 16'h0;
	  else if (~CtrlRxDPHYRstN)   RxDPHYRstCnt <= # TCo_C 16'h0;
	  else if (MipiRxAutoRst)     RxDPHYRstCnt <= # TCo_C 16'h0;
	  else                        RxDPHYRstCnt <= # TCo_C RxDPHYRstCnt + {15'h0,(~RxDPHYRstCnt[15])};
  end
  
  wire  MipiRxDPHYRstN   = RxDPHYRstCnt[15];  //MIPI Rx DPHY Reset Operate (Low Active, MIPI-Rx Interface) 
  
	/////////////////////////////////////////////////////////
	reg [15:0] RxCSIRstCnt = 16'h0; //MIPI RX DPHY Reset Counter
	
	always @( posedge SysClk or negedge Reset_N)  
	begin
	  if (!Reset_N)             RxCSIRstCnt <= # TCo_C 16'h0;
	  else if (~CtrlRxCSIRstN)  RxCSIRstCnt <= # TCo_C 16'h0;
	  else if (MipiRxAutoRst)   RxCSIRstCnt <= # TCo_C 16'h0;
	  else                      RxCSIRstCnt <= # TCo_C RxCSIRstCnt + {15'h0,(~RxCSIRstCnt[15])};
  end
  
	wire	MipiRxCSIRstN   = RxCSIRstCnt[15]; //(O)MIPI Rx CSI-2 Reset (Low Active, MIPI-Rx Interface) 
	
	/////////////////////////////////////////////////////////
	reg PixelRxRstReg;  //Rx Reset Register
	
	always @( posedge SysClk)  PixelRxRstReg <= # TCo_C ~(MipiRxCSIRstN & MipiRxDPHYRstN);
	
	wire PixelRxReset = MipiRxCSIRstN & MipiRxDPHYRstN & PixelRxRstReg; //(O)MIPI Rx Reset Signal 
	
	/////////////////////////////////////////////////////////
	reg       RxFirstVSync   =  1'h0;
	reg [15:0] RxErrClrCnt   = 16'h0;
	
	always @( posedge SysClk)  
	begin
	  if (CtrlRxErrClr | PixelRxReset) 	RxErrClrCnt <= # TCo_C 16'hffff; 
	  else if (MipiRxLanesAct)          RxErrClrCnt <= # TCo_C RxErrClrCnt - {15'h0,RxErrClrCnt[15]};
  end
  
	wire			   MipiRxErrClr     = RxErrClrCnt[15]; //MIPI Rx CSI-2 Reset Operate (MIPI-Rx Interface) 
	
//1111111111111111111111111111111111111111111111111111111

	
	
	
endmodule 
	
		