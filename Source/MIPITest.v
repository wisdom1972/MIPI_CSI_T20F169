`timescale 100ps/10ps
`define Efinity_Debug

///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要Input信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-1-6
	版本：V1、0
	修改记录：
	//////////////
	19-09-09：V1.1
  Release第一个版本
  功能：
  1、MIPI发送
  	通过VIO配置MIPI-Rx的工作模式
  	通过VIO修改图像参数；
  	通过VIO显示自动计算的控制参数，并产生控制信号；
  	产生伪随机数据用于和MIPI-Rx对接测试硬件误码；
  2、MIPI接收
  	通过VIO配置MIPI-Rx的工作模式；
  	通过VIO检视MIPI-Rx的工作状态；
  	内部自动测量图像参数并通过VIO显示；
  	和MIPI-Rx配合测试硬件误码；
  3、MIPI-RX波形显示
  	通过ILA对MIPI-RX的波形进行显示
  4、硬件测试接口
  	对MIPI-TX和MIPI-RX的控制信号输出到GPIO，可以通过示波器进行检测；
  	
	//////////////
	19-09-09: V1.2
	1、添加了MIPIRx的参数（Lanes、VCEn）修改产生复位；
	2、添加了MIPITx的参数（Lanes、FrmMode）修改产生复位；
	3、增加了MIPI RX复位后对清楚告警功能；
	4、增加了MIPITX和MIPIRX上电复位功能；

	//////////////
	19-09-10: V1.3
	1、把Tx和RX的同步信号输出，并锁到管脚	    
	2、把Rx和TX的VIO的顺序排列了一下；
	3、添加MIPIRxDaTaType到ILA；
	4、修改了VIO显示RxDataType的问题；
	5、修改了RxReselutionChange一直为高的Bug；
	6、修改接收行场消隐的算法，使VIO显示不会有太大波动；
  	
  //////////////
  	
  19-10-03：V1.4
  1、修改了显示的行和列像素值搞反了的Bug；
  2、由于MIPI-Tx是在数据全部进入到TxDvaid后才发送数据，所以把TxDvalid的位置放在HSync信号以后；经测试最稳定的位置在600ns范围（刚好是一个EoT-LPS-SoT的时间）；
  3、在FramerMode为1时 ，THS-Trail=90ns，如果HSync间隔小于900ns，数据会出错；所以在程序中将HSync信号间隔（HoriBlanking）设置为900ns；
  4、由于TxBuff的长度为5760Byte，所以在设置上做了Buffer长度的限制，当设置的行像素长度时，限制有效数据不超过5760字节；否则按5760字节计算；避免演示出错；

  3、没有做错误配置的提醒；
  4、只支持了收发像素对应的类型的数据检查（如0x24,0x2a等）；没有对其它类型做支持；
  5、对VC的支持过于简单；

  //////////////
  	
  19-10-11：V1.5
  1、找到规律并修改了有时候出现VSync短帧丢失的Bug；
  2、修改当计算出来的DValid大于HSync的Bug;
  3、在计算最大DValid时，交换了计算顺序，先做除法，避免了最后乘积超过17位的情况；
  4、重新安排了计算是需要保证的数据的优先级：一、硬件限制；二、保证分辨率；三、保证数据长度；

  //////////////
  	
  20-02-05：V1.6

  1、调整了目录结构，方便开Debuger
  2、完善了SDC
	
**********************************************************/

module MipiTest (
	//Check Resultwire 
`ifdef  Efinity_Debug	 //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  
	jtag_inst1_CAPTURE,  
	jtag_inst1_DRCK,     
	jtag_inst1_RESET,    
	jtag_inst1_RUNTEST,  
	jtag_inst1_SEL,      
	jtag_inst1_SHIFT,    
	jtag_inst1_TCK,      
	jtag_inst1_TDI,      
	jtag_inst1_TMS,      
	jtag_inst1_UPDATE,   
	jtag_inst1_TDO,    
`endif  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
	//System Signal
	PllLocked		        ,	//PLL Locked
	//MIPI Tx Signal
	MipiTxEscClk        , //(I)[Control]MIPI Tx Escape Clock 
	MipiTxPixelClk      , //(I)[Control]MIPI Tx Pixel Clock
	MipiTx_DPHY_RSTN     , //(O)[Control]MIPI Tx DPHY Reset (Low Active)
	MipiTx_RSTN          , //(O)[Control]MIPI Tx CSI-2 Reset (Low Active)
	MipiTx_LANES         , //(O)[Control]MIPI Tx Tx lanes 
	MipiTx_FRAME_MODE    , //(O)[Video]  MIPI Tx Frame Mode
	MipiTx_HRES          , //(O)[Video]  MIPI Tx Horizontal Resolution
	MipiTx_HSYNC         , //(O)[Video]  MIPI Tx Horizontal Synchronization
	MipiTx_VSYNC         , //(O)[Video]  MIPI Tx Vertical Synchronization
	MipiTx_VALID         , //(O)[Video]  MIPI Tx Valid Fixel Data 
	MipiTx_TYPE          , //(O)[Video]  MIPI Tx Video Data Typte
	MipiTx_DATA          , //(O)[Video]  MIPI Tx Video Data
	MipiTx_VC            , //(O)[Video]  MIPI Tx Virtual Channel
	MipiTx_ULPS_ENTER    , //(O)[ULPS]   MIPI Tx Clock Lane Enter
	MipiTx_ULPS_EXIT     , //(O)[ULPS]   MIPI Tx Clock Lane Exit
	MipiTx_ULPS_CLK_ENTER, //(O)[ULPS]   MIPI Tx Data Lane Enter
	MipiTx_ULPS_CLK_EXIT , //(O)[ULPS]   MIPI Tx Data Lane Exit
	//MIPI Tx Signal（Monitor） 
	MMipiTx_DPHY_RSTN     , //(O)[Control]MIPI Tx DPHY Reset (Low Active)
	MMipiTx_RSTN          , //(O)[Control]MIPI Tx CSI-2 Reset (Low Active)
	MMipiTx_LANES         , //(O)[Control]MIPI Tx Tx lanes 
	MMipiTx_FRAME_MODE    , //(O)[Video]  MIPI Tx Frame Mode
	MMipiTx_HRES          , //(O)[Video]  MIPI Tx Horizontal Resolution
	MMipiTx_HSYNC         , //(O)[Video]  MIPI Tx Horizontal Synchronization
	MMipiTx_VSYNC         , //(O)[Video]  MIPI Tx Vertical Synchronization
	MMipiTx_VALID         , //(O)[Video]  MIPI Tx Valid Fixel Data 
	MMipiTx_TYPE          , //(O)[Video]  MIPI Tx Video Data Typte
	MMipiTx_DATA          , //(O)[Video]  MIPI Tx Video Data
	MMipiTx_VC            , //(O)[Video]  MIPI Tx Virtual Channel
	MMipiTx_ULPS_ENTER    , //(O)[ULPS]   MIPI Tx Clock Lane Enter
	MMipiTx_ULPS_EXIT     , //(O)[ULPS]   MIPI Tx Clock Lane Exit
	MMipiTx_ULPS_CLK_ENTER, //(O)[ULPS]   MIPI Tx Data Lane Enter
	MMipiTx_ULPS_CLK_EXIT , //(O)[ULPS]   MIPI Tx Data Lane Exit
	//MIPI Rx Signal
	MipiRxCalClk      , //(O)[Control]MIPI Rx DPHY Calibration Clock
	MipiRxPixelClk    , //(O)[Control]MIPI Rx Pixel Clock
  MipiRx_DPHY_RSTN  , //(O)[Control]MIPI Rx DPHY Reset
	MipiRx_RSTN       , //(O)[Control]MIPI Rx CSI-2 Reset
	MipiRx_VC_ENA     , //(O)[Control]MIPI Rx Virtual
	MipiRx_LANES      , //(O)[Control]MIPI Rx Lanes	
	MipiRx_HSYNC      , //(I)[Video]  MIPI Rx Horizontal Synchronization
	MipiRx_VSYNC      , //(I)[Video]  MIPI Rx Vertical Synchronization
	MipiRx_CNT        , //(I)[Video]  MIPI Rx Valid Pixel Count
	MipiRx_VALID      , //(I)[Video]  MIPI Rx Valid Pixel Data
	MipiRx_TYPE       , //(I)[Video]  MIPI Rx Video Data Type
	MipiRx_DATA       , //(I)[Video]  MIPI Rx Video Data
	MipiRx_VC         , //(I)[Video]  MIPI Rx Virtual Channel	
	MipiRx_CLEAR      , //(I)[Status] MIPI Rx Error Clear
	MipiRx_ERROR      , //(I)[Status] MIPI Rx Error
	MipiRx_ULPS_CLK   , //(I)[Status] MIPI Rx ULPS Clock 
	MipiRx_ULPS       , //(I)[Status] MIPI Rx ULPS 
	//Moniter Signal
  PixelRxHSync  , //(O)Pixel Rx Horizontal Synchronization
  PixelRxVSync  , //(O)Pixel Rx Vertical Synchronization
  PixelRxValid  , //(O)Pixel Rx Pixel Data Valid 
  PixelTxHSync  , //(O)Pixel Tx Horizontal Synchronization
  PixelTxVSync  , //(O)Pixel Tx Vertical Synchronization
  PixelTxValid  , //(O)Pixel Tx Pixel Data Valid 
  //Other Signal
  LED           //LED
 );
 
 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
			
  localparam  [27:0]  TxPixelClkFreq_C  = `MipiTxPixelClkFreq;
  localparam  [27:0]  RxPixelClkFreq_C  = 28'd100_000_000;
	parameter           RightCntWidth_C   = 24;
  
  localparam  RxClkCyclePerUs_C = RxPixelClkFreq_C / 28'd1_000_000;
  localparam  TxClkCyclePerUs_C = TxPixelClkFreq_C / 28'd1_000_000;
  
	/////////////////////////////////////////////////////////
	
	//Define Port
`ifdef  Efinity_Debug	 //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  
  input  jtag_inst1_CAPTURE ;
  input  jtag_inst1_DRCK    ;
  input  jtag_inst1_RESET   ;
  input  jtag_inst1_RUNTEST ;
  input  jtag_inst1_SEL     ;
  input  jtag_inst1_SHIFT   ;
  input  jtag_inst1_TCK     ;
  input  jtag_inst1_TDI     ;
  input  jtag_inst1_TMS     ;
  input  jtag_inst1_UPDATE  ;
  output jtag_inst1_TDO     ;
`endif  //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
    
	/////////////////////////////////////////////////////////
	//System Signal
	input		[2:0] PllLocked;		//PLL Locked
	
	/////////////////////////////////////////////////////////    
	//MIPI Tx Signal
	input           MipiTxEscClk         ; //(O)[Control]MIPI Tx Escape Clock 
	input           MipiTxPixelClk       ; //(O)[Control]MIPI Tx Pixel Clock
	output 			    MipiTx_DPHY_RSTN     ; //(O)[Control]MIPI Tx DPHY Reset (Low Active)
	output 			    MipiTx_RSTN          ; //(O)[Control]MIPI Tx CSI-2 Reset (Low Active)
	output [1:0] 		MipiTx_LANES         ; //(O)[Control]MIPI Tx Tx lanes    	
	output 			    MipiTx_FRAME_MODE    ; //(O)[Video]  MIPI Tx Frame Mode
	output [15:0]   MipiTx_HRES          ; //(O)[Video]  MIPI Tx Horizontal Resolution
	output       		MipiTx_HSYNC         ; //(O)[Video]  MIPI Tx Horizontal Synchronization
	output       		MipiTx_VSYNC         ; //(O)[Video]  MIPI Tx Vertical Synchronization
	output 			    MipiTx_VALID         ; //(O)[Video]  MIPI Tx Valid Fixel Data 
	output [5:0] 		MipiTx_TYPE          ; //(O)[Video]  MIPI Tx Video Data Typte
	output [63:0]   MipiTx_DATA          ; //(O)[Video]  MIPI Tx Video Data
	output [1:0] 		MipiTx_VC            ; //(O)[Video]  MIPI Tx Virtual Channel	
	output [3:0] 		MipiTx_ULPS_ENTER    ; //(O)[ULPS]   MIPI Tx Clock Lane Enter
	output [3:0] 		MipiTx_ULPS_EXIT     ; //(O)[ULPS]   MIPI Tx Clock Lane Exit
	output 			    MipiTx_ULPS_CLK_ENTER; //(O)[ULPS]   MIPI Tx Data Lane Enter
	output 			    MipiTx_ULPS_CLK_EXIT ; //(O)[ULPS]   MIPI Tx Data Lane Exit
	
	//MIPI Tx Signal
	output 			    MMipiTx_DPHY_RSTN     ; //(O)[Control]MIPI Tx DPHY Reset (Low Active)
	output 			    MMipiTx_RSTN          ; //(O)[Control]MIPI Tx CSI-2 Reset (Low Active)
	output [1:0] 		MMipiTx_LANES         ; //(O)[Control]MIPI Tx Tx lanes    	
	output 			    MMipiTx_FRAME_MODE    ; //(O)[Video]  MIPI Tx Frame Mode
	output [15:0]   MMipiTx_HRES          ; //(O)[Video]  MIPI Tx Horizontal Resolution
	output       		MMipiTx_HSYNC         ; //(O)[Video]  MIPI Tx Horizontal Synchronization
	output       		MMipiTx_VSYNC         ; //(O)[Video]  MIPI Tx Vertical Synchronization
	output 			    MMipiTx_VALID         ; //(O)[Video]  MIPI Tx Valid Fixel Data 
	output [5:0] 		MMipiTx_TYPE          ; //(O)[Video]  MIPI Tx Video Data Typte
	output [63:0]   MMipiTx_DATA          ; //(O)[Video]  MIPI Tx Video Data
	output [1:0] 		MMipiTx_VC            ; //(O)[Video]  MIPI Tx Virtual Channel	
	output [3:0] 		MMipiTx_ULPS_ENTER    ; //(O)[ULPS]   MIPI Tx Clock Lane Enter
	output [3:0] 		MMipiTx_ULPS_EXIT     ; //(O)[ULPS]   MIPI Tx Clock Lane Exit
	output 			    MMipiTx_ULPS_CLK_ENTER; //(O)[ULPS]   MIPI Tx Data Lane Enter
	output 			    MMipiTx_ULPS_CLK_EXIT ; //(O)[ULPS]   MIPI Tx Data Lane Exit
	
	/////////////////////////////////////////////////////////
	//MIPI Rx Signal
	input           MipiRxCalClk    ; //(I)[Control]MIPI Rx DPHY Calibration Clock
	input           MipiRxPixelClk  ; //(I)[Control]MIPI Rx Pixel Clock
  output 			    MipiRx_DPHY_RSTN ; //(O)[Control]MIPI Rx DPHY Reset
	output 			    MipiRx_RSTN      ; //(O)[Control]MIPI Rx CSI-2 Reset
	output  [ 3:0]  MipiRx_VC_ENA    ; //(O)[Control]MIPI Rx Virtual Channel Enable
	output  [ 1:0]  MipiRx_LANES     ; //(O)[Control]MIPI Rx Lanes
	input   [ 3:0] 	MipiRx_HSYNC     ; //(I)[Video]  MIPI Rx Horizontal Synchronization
	input   [ 3:0] 	MipiRx_VSYNC     ; //(I)[Video]  MIPI Rx Vertical Synchronization
	input   [ 3:0] 	MipiRx_CNT       ; //(I)[Video]  MIPI Rx Valid Pixel Count
	input 			    MipiRx_VALID     ; //(I)[Video]  MIPI Rx Valid Pixel Data
	input   [ 5:0] 	MipiRx_TYPE      ; //(I)[Video]  MIPI Rx Video Data Type
	input   [63:0] 	MipiRx_DATA      ; //(I)[Video]  MIPI Rx Video Data
	input   [ 1:0] 	MipiRx_VC        ; //(I)[Video]  MIPI Rx Virtual Channel
	output 			    MipiRx_CLEAR     ; //(I)[Status] MIPI Rx Error Clear
	input   [17:0] 	MipiRx_ERROR     ; //(I)[Status] MIPI Rx Error
	input 			    MipiRx_ULPS_CLK  ; //(I)[Status] MIPI Rx ULPS Clock 
	input   [ 3:0] 	MipiRx_ULPS      ; //(I)[Status] MIPI Rx ULPS 
	
	/////////////////////////////////////////////////////////
	//Moniter Signal
  output  PixelRxHSync; //(O)Pixel Rx Horizontal Synchronization
  output  PixelRxVSync; //(O)Pixel Rx Vertical Synchronization
  output  PixelRxValid; //(O)Pixel Rx Pixel Data Valid 
  output  PixelTxHSync; //(O)Pixel Tx Horizontal Synchronization
  output  PixelTxVSync; //(O)Pixel Tx Vertical Synchronization
  output  PixelTxValid; //(O)Pixel Tx Pixel Data Valid 
  
	/////////////////////////////////////////////////////////
  //Other Signal
  output   [1:0]  LED;   //LED
    
	/////////////////////////////////////////////////////////
  
  //SystemSystemSystemSystemSystemSystemSystemSystemSystemSystem
  wire  Reset_N = &PllLocked[2:1];
    
  wire  TxSysClk  = MipiTxPixelClk;
  wire  RxSysClk  = MipiRxPixelClk;
    
  //SystemSystemSystemSystemSystemSystemSystemSystemSystemSystem
  
//1111111111111111111111111111111111111111111111111111111
//	MIPI Tx Contol
//	Input：
//	output：
//***************************************************/ 
  
	/////////////////////////////////////////////////////////  
	wire           PixelTxEn      ; //(I)Pixel Tx Enable
  wire   [ 5:0]  ConfDataType   ; //Configuration Data Type      
  wire   [ 7:0]  CfgTxFrmRate   ; //(I)Configuration Tx Framer Rate
  wire   [15:0]  CfgTxVPixelNum ; //(I)Configuration Tx Vertical Pixel Number  
	wire   [15:0]  CfgTxHPixelNum ; //(I)Configuration Tx Horizontal Pixel Number
  wire   [11:0]  CfgTxVBlkTime  ; //(I)Configuration Tx Vertical Blanking Time (us)
  wire   [ 7:0]  CfgTxHBlkTime  ; //(I)Configuration Tx Horizontal Blanking Time (us)
	wire   [ 2:0]  ConfLanesNum   ; //(I)Configuration Lanes Number
	wire           ConfTxFrmMod   ; //(I)Configuration Framer Mode
	//Calculate parameter 
	wire   [23:0]  CalcVSyncLen   ; //(O)Calculate Vertical Synchronization Length(Pixel  Clock Cycle)
	wire   [15:0]  CalcHSyncLen   ; //(O)Calculate Horizontal Synchronization Length  (Pixel  Clock Cycle)
	wire   [15:0]  CalcDValidLen  ; //(O)Calculate Data Valid Length  (Pixel  Clock Cycle) 
	wire   [19:0]  CalcVBlankLen  ; //(O)Calculate Vertical Blanking  Length  (Pixel  Clock Cycle)	
	wire   [15:0]  CalcHBlankLen  ; //(O)Calculate Horizontal Blanking  Length  (Pixel  Clock Cycle)
	wire   [15:0]  CalcHPixelNum  ; //(O)Calculate Horizontal Pixel Number
	
  //MIPI Tx Siganl       
  wire  TxConfigEn  ; //(O)Pixel Tx Config Enable
  wire  MipiTxHSync ; //(O)MIPI Tx  Horizontal Synchronization   
  wire  MipiTxVSync ; //(O)MIPI Tx  Vertical Synchronization     
  wire  MipiTxValid ; //(O)MIPI Tx  Pixel Data Valid             
  
  MipiTxCtrl  # (.TxPixelClkFreq_C  (TxPixelClkFreq_C))
  U2_MipiTxCtrl
  (   
  	//System Signal
  	.SysClk       (TxSysClk  ),         //System Clock
  	.Reset_N      (Reset_N ),		     //System Reset
  	//Signal
  	.PixelTxEn      (PixelTxEn      ), //(I)Pixel Tx Enable
	  .ConfDataType   (ConfDataType   ), //(I)Configuration Data Type   
    .CfgTxFrmRate   (CfgTxFrmRate   ), //(I)Configuration Tx Framer Rate
    .CfgTxVPixelNum (CfgTxVPixelNum ), //(I)Configuration Tx Vertical Pixel Number  
  	.CfgTxHPixelNum (CfgTxHPixelNum ), //(I)Configuration Tx Horizontal Pixel Number
    .CfgTxVBlkTime  (CfgTxVBlkTime  ), //(I)Configuration Tx Vertical Blanking Time (us)
    .CfgTxHBlkTime  (CfgTxHBlkTime  ), //(I)Configuration Tx Horizontal Blanking Time (us)    
	  .ConfLanesNum   (ConfLanesNum   ), //(I)Configuration Lanes Number
	  .ConfTxFrmMod   (ConfTxFrmMod   ), //(I)Configuration Framer Mode
  	//Calculate Parameter      
  	.CalcVSyncLen   (CalcVSyncLen   ), //(O)Calculate Vertical Synchronization Length(Pixel  Clock Cycle)
  	.CalcHSyncLen   (CalcHSyncLen   ), //(O)Calculate Horizontal Synchronization Length  (Pixel  Clock Cycle)
  	.CalcDValidLen  (CalcDValidLen  ), //(O)Calculate Data Valid Length 	(Pixel  Clock Cycle) 
  	.CalcVBlankLen  (CalcVBlankLen  ), //(O)Calculate Vertical Blanking  Length  (Pixel  Clock Cycle)	
  	.CalcHBlankLen  (CalcHBlankLen  ), //(O)Calculate Horizontal Blanking  Length  (Pixel  Clock Cycle)
	  .CalcHPixelNum  (CalcHPixelNum  ), //(O)Calculate Horizontal Pixel Number
    //Pixel Tx Siganl       
    .TxConfigEn     (TxConfigEn   ), //(O)Pixel Tx Config Enable
    .MipiTxHSync    (MipiTxHSync  ), //(O)MIPI Tx  Horizontal Synchronization   
    .MipiTxVSync    (MipiTxVSync  ), //(O)MIPI Tx  Vertical Synchronization     
    .MipiTxValid    (MipiTxValid  )  //(O)MIPI Tx  Pixel Data Valid             
  );

	/////////////////////////////////////////////////////////
	wire          MipiTx_HSYNC = MipiTxHSync ; //(O)[Video]  MIPI Tx Horizontal Synchronization      
	wire          MipiTx_VSYNC = MipiTxVSync ; //(O)[Video]  MIPI Tx Vertical Synchronization        
	wire          MipiTx_VALID = MipiTxValid ; //(O)[Video]  MIPI Tx Valid Fixel Data  
	
	/////////////////////////////////////////////////////////	
	reg   [ 1:0]  ConfLansNumCode;
	
	always @( * )  
	begin
	  case (ConfLanesNum)
	    3'h1    : ConfLansNumCode <= # TCo_C 2'h0;
	    3'h2    : ConfLansNumCode <= # TCo_C 2'h1;
	    3'h3    : ConfLansNumCode <= # TCo_C 2'h2;
	    3'h4    : ConfLansNumCode <= # TCo_C 2'h3;
	    default : ConfLansNumCode <= # TCo_C 2'h0;
	  endcase
  end
	
	/////////////////////////////////////////////////////////
	reg   [ 1:0]  MipiTx_LANES      =  2'h3;    //(O)[Control]MIPI Tx Tx lanes    	
	reg   			  MipiTx_FRAME_MODE =  1'h0;    //(O)[Video]  MIPI Tx Frame Mode
	reg   [15:0]  MipiTx_HRES       = 16'd1920; //(O)[Video]  MIPI Tx Horizontal Resolution
	reg   [ 5:0]  MipiTx_TYPE       =  6'h2a      ; //(O)[Video]  MIPI Tx Video Data Typte	
	
	always @( posedge TxSysClk)  
	begin
	  if (TxConfigEn)
	  begin
	    MipiTx_LANES       <= # TCo_C  ConfLansNumCode;
	    MipiTx_FRAME_MODE  <= # TCo_C  ConfTxFrmMod   ;
	    MipiTx_HRES        <= # TCo_C  CalcHPixelNum  ;
	    MipiTx_TYPE        <= # TCo_C  ConfDataType   ;
    end
  end
        	
	/////////////////////////////////////////////////////////
	wire 		CtrlTxDPHYRstN; //MIPI Tx DPHY Reset (Low Active)
	wire 		CtrlTxCSIRstN ; //MIPI Tx CSI-2 Reset (Low Active)  
	
	/////////////////////////////////////////////////////////
	reg     MipiTxAutoRst;  //MIPI-Tx Auto Reset as a Result of Config parameter Changed  
	
	always @( posedge TxSysClk)  
	begin
	  MipiTxAutoRst <= # TCo_C (MipiTx_LANES      != ConfLansNumCode)
	                          |(MipiTx_FRAME_MODE != ConfTxFrmMod   );
  end
	
	/////////////////////////////////////////////////////////
	reg [15:0] TxDPHYRstCnt = 16'h0;  //MIPI TX DPHY Reset Counter 
	
	always @( posedge TxSysClk or negedge Reset_N)  
	begin
	  if (!Reset_N)             TxDPHYRstCnt <= # TCo_C 16'h0; 
	  else if (~CtrlTxDPHYRstN) TxDPHYRstCnt <= # TCo_C 16'h0;
	  else if (MipiTxAutoRst)   TxDPHYRstCnt <= # TCo_C 16'h0;
	  else                      TxDPHYRstCnt <= # TCo_C TxDPHYRstCnt + {15'h0,(~TxDPHYRstCnt[15])};
  end
  
  //wire  MipiTxDPHYRstN   = TxDPHYRstCnt[15];  //MIPI Rx DPHY Reset Operate (Low Active, MIPI-Rx Interface) 
  
  
	/////////////////////////////////////////////////////////
	reg [15:0] TxCSIRstCnt = 16'h0; //MIPI RX DPHY Reset Counter
	
	always @( posedge TxSysClk or negedge Reset_N)  
	begin
	  if (!Reset_N)             TxCSIRstCnt <= # TCo_C 16'h0;
	  else if (~CtrlTxCSIRstN)  TxCSIRstCnt <= # TCo_C 16'h0;
	  else if (MipiTxAutoRst)   TxCSIRstCnt <= # TCo_C 16'h0;
	  else                      TxCSIRstCnt <= # TCo_C TxCSIRstCnt + {15'h0,(~TxCSIRstCnt[15])};
  end
  
	//wire	MipiTxCSIRstN       = TxCSIRstCnt[15]; //(O)MIPI Rx CSI-2 Reset (Low Active, MIPI-Rx Interface) 
	
	/////////////////////////////////////////////////////////	
	reg   TxVSyncNeg      = 1'h0;
	reg   MipiTxDPHYRstN  = 1'h0;
	reg   MipiTxCSIRstN   = 1'h0;
	
	always @( posedge TxSysClk)  if (TxVSyncNeg)  MipiTxDPHYRstN  <= # TCo_C TxDPHYRstCnt[15];
	always @( posedge TxSysClk)  if (TxVSyncNeg)  MipiTxCSIRstN   <= # TCo_C TxCSIRstCnt[15] & MipiTxDPHYRstN;
	
	/////////////////////////////////////////////////////////	
	wire 		MipiTx_DPHY_RSTN = MipiTxDPHYRstN; //(O)[Control]MIPI Tx DPHY Reset (Low Active)
	wire 		MipiTx_RSTN      = MipiTxCSIRstN ; //(O)[Control]MIPI Tx CSI-2 Reset (Low Active) 
  
	/////////////////////////////////////////////////////////	
	wire [3:0] 		MipiTx_ULPS_ENTER      = 4'h0; //(O)[ULPS]   MIPI Tx Clock Lane Enter
	wire [3:0] 		MipiTx_ULPS_EXIT       = 4'h0; //(O)[ULPS]   MIPI Tx Clock Lane Exit
	wire 			    MipiTx_ULPS_CLK_ENTER  = 1'h0; //(O)[ULPS]   MIPI Tx Data Lane Enter
	wire 			    MipiTx_ULPS_CLK_EXIT   = 1'h0; //(O)[ULPS]   MIPI Tx Data Lane Exit
	
//1111111111111111111111111111111111111111111111111111111



//22222222222222222222222222222222222222222222222222222
//	Generate Mipi Tx Data
//	Input：
//	output：
//***************************************************/ 

	/////////////////////////////////////////////////////////
  reg   PixelTxHSync = 1'h0; //(O)Pixel Tx Horizontal Synchronization
  reg   PixelTxVSync = 1'h0; //(O)Pixel Tx Vertical Synchronization
  reg   PixelTxValid = 1'h0; //(O)Pixel Tx Pixel Data Valid 
	
	always @( posedge TxSysClk)  PixelTxHSync <= # TCo_C  MipiTxHSync;
	always @( posedge TxSysClk)  PixelTxVSync <= # TCo_C  MipiTxVSync;
	always @( posedge TxSysClk)  PixelTxValid <= # TCo_C  MipiTxValid; 	                                     
	                                     
	/////////////////////////////////////////////////////////
	reg   TxVSyncPos = 1'h0;
	
	always @( posedge TxSysClk) TxVSyncNeg <= # TCo_C (~MipiTxVSync ) & PixelTxVSync;
	always @( posedge TxSysClk) TxVSyncPos <= # TCo_C (~PixelTxVSync) & MipiTxVSync ;
	
	/////////////////////////////////////////////////////////
	reg [1:0]   MipiTxVCCnt = 2'h0;
	
	always @( posedge TxSysClk)  if (TxVSyncPos)  MipiTxVCCnt <= # TCo_C MipiTxVCCnt + 2'h1;
	
	/////////////////////////////////////////////////////////
	wire [3:0]    MipiTxVCEn;
	
	reg [1:0] MipiTx_VC = 2'h0;
	
	always @( posedge TxSysClk)  
	begin
	  if (MipiTxVCEn)
	  begin
	    case (MipiTxVCCnt)  
	      2'h0: if(MipiTxVCEn[0])  MipiTx_VC <= # TCo_C 2'h0;
	      2'h1: if(MipiTxVCEn[1])  MipiTx_VC <= # TCo_C 2'h1;
	      2'h2: if(MipiTxVCEn[2])  MipiTx_VC <= # TCo_C 2'h2;
	      2'h3: if(MipiTxVCEn[3])  MipiTx_VC <= # TCo_C 2'h3;
	    endcase
    end
    else MipiTx_VC <= # TCo_C 2'h0;
  end
	
	/////////////////////////////////////////////////////////
	wire  [63:0]   MipiTx_DATA; //(O)[Video]  MIPI Tx Video Data
	
	MipiTxData8B  U2_MipiTxData
  (   
  	//System Signal
  	.SysClk       (TxSysClk   ),  //System Clock
  	.Reset_N      (Reset_N    ),  //System Reset
  	//Tx Data Signal
  	.MipiTxDValid (MipiTx_VALID ), //MIPI Tx Data Valid
  	.MipiTxData   (MipiTx_DATA  )  //MIPI Tx Data
  );
	
	/////////////////////////////////////////////////////////		
	wire 			    MMipiTx_DPHY_RSTN       = MipiTx_DPHY_RSTN      ; //(O)[Control]MIPI Tx DPHY Reset (Low Active)
	wire 			    MMipiTx_RSTN            = MipiTx_RSTN           ; //(O)[Control]MIPI Tx CSI-2 Reset (Low Active)
	wire [1:0] 		MMipiTx_LANES           = MipiTx_LANES          ; //(O)[Control]MIPI Tx Tx lanes    	
	wire 			    MMipiTx_FRAME_MODE      = MipiTx_FRAME_MODE     ; //(O)[Video]  MIPI Tx Frame Mode
	wire [15:0]   MMipiTx_HRES            = MipiTx_HRES           ; //(O)[Video]  MIPI Tx Horizontal Resolution
	wire       		MMipiTx_HSYNC           = MipiTx_HSYNC          ; //(O)[Video]  MIPI Tx Horizontal Synchronization
	wire       		MMipiTx_VSYNC           = MipiTx_VSYNC          ; //(O)[Video]  MIPI Tx Vertical Synchronization
	wire 			    MMipiTx_VALID           = MipiTx_VALID          ; //(O)[Video]  MIPI Tx Valid Fixel Data 
	wire [5:0] 		MMipiTx_TYPE            = MipiTx_TYPE           ; //(O)[Video]  MIPI Tx Video Data Typte
	wire [63:0]   MMipiTx_DATA            = MipiTx_DATA           ; //(O)[Video]  MIPI Tx Video Data
	wire [1:0] 		MMipiTx_VC              = MipiTx_VC             ; //(O)[Video]  MIPI Tx Virtual Channel	
	wire [3:0] 		MMipiTx_ULPS_ENTER      = MipiTx_ULPS_ENTER     ; //(O)[ULPS]   MIPI Tx Clock Lane Enter
	wire [3:0] 		MMipiTx_ULPS_EXIT       = MipiTx_ULPS_EXIT      ; //(O)[ULPS]   MIPI Tx Clock Lane Exit
	wire 			    MMipiTx_ULPS_CLK_ENTER  = MipiTx_ULPS_CLK_ENTER ; //(O)[ULPS]   MIPI Tx Data Lane Enter
	wire 			    MMipiTx_ULPS_CLK_EXIT   = MipiTx_ULPS_CLK_EXIT  ; //(O)[ULPS]   MIPI Tx Data Lane Exit
	
//22222222222222222222222222222222222222222222222222222



//3333333333333333333333333333333333333333333333333333333
//	Measure Mipi Rx Parameter
//	Input：
//	output：
//***************************************************/ 
  //Output To Pin
  wire  PixelRxVSync  = MipiRx_VSYNC[MipiRx_VC];    //(O)Pixel Rx Vertical Synchronization
  wire  PixelRxHSync  = MipiRx_HSYNC[MipiRx_VC];    //(O)Pixel Rx Horizontal Synchronization
  wire  PixelRxValid  = MipiRx_VALID;     //(O)Pixel Rx Pixel Data Valid 
  
	/////////////////////////////////////////////////////////
  wire          PixelRxReset                ; //(I)Pixel Rx DPHY/CSI Reset
  wire  [ 3:0]  MipiRxPixNum  = MipiRx_CNT  ; //(I)MIPI Rx Pixel Number 
  wire  [ 1:0]  MipiRxVirtCnl = MipiRx_VC   ; //(I)MIPI Rx Virtual Channel
  wire  [17:0]  MipiRxStaInd  = MipiRx_ERROR; //(I)MIPI Rx State Indicate   
  wire  [ 5:0]  MipiRxDType   = MipiRx_TYPE ; //(I)MIPI Rx Data Type
    
	/////////////////////////////////////////////////////////
	// MIPI Rx Measure Value and State
	wire  [ 7:0]  VidioFrmNum     ; //(O)Vidio Framer Number  
	wire  [15:0]  VidioHPixelNum  ; //(O)Vidio Horizontal Pixel Number
	wire  [15:0]  VidioVPixelNum  ; //(O)Vidio Vertical Pixel Number    
	wire  [15:0]  VidioVBlankTime ; //(O)Vidio Vertical Blanking Time (us)      
	wire  [15:0]  VidioHBlankTime ; //(O)Vidio Horizontal Blanking Time (us)       
	wire  [ 5:0]  VidioDataType   ; //(O)Vidio Data Type     
	wire          VidioRestChg    ; //(O)MIPI Rx Vidio Resolution Change	
	wire          MipiRxStaChg    ; //(O)MIPI Rx State Change  
	wire          MipiRxSyncErr   ; //(O)MIPI Rx VSync&HSync Error
	wire  [3:0]   MipiRxStaVCAct  ; //(O)MIPI Rx VC Active Indicate
  wire          MipiRxLanesAct  ; //(O)MIPI Rx Lanes Active Indicate
		
	MipiRxMoni  # (.RxPixelClkFreq_C  (RxPixelClkFreq_C))
	U3_MipiRxMonitor
  (   
  	//System Signal
  	.SysClk           (RxSysClk       ),  //System Clock
  	.Reset_N          (Reset_N        ),	//System Reset
  	// MIPI Rx Signal                 
    .PixelRxReset     (PixelRxReset   ),  //(I)Pixel Rx DPHY/CSI Reset
    .PixelRxHSync     (PixelRxHSync   ),  //(I)Pixel Rx Horizontal Synchronization
    .PixelRxVSync     (PixelRxVSync   ),  //(I)Pixel Rx Vertical Synchronization
    .PixelRxValid     (PixelRxValid   ),  //(I)Pixel Rx Pixel Data Valid   
    .MipiRxVirtCnl    (MipiRxVirtCnl  ),  //(I)MIPI Rx Virtual Channel
    .MipiRxPixNum     (MipiRxPixNum   ),  //(I)MIPI Rx Pixel Number 
    .MipiRxStaInd     (MipiRxStaInd   ),  //(I)MIPI Rx State Indicate    
    .MipiRxDType      (MipiRxDType    ),  //(I)MIPI Rx Data Type
  	// MIPI Rx Measure Value and State    
  	.VidioFrmNum      (VidioFrmNum    ),  //(O)Vidio Framer Number  
  	.VidioHPixelNum   (VidioHPixelNum ),  //(O)Vidio Horizontal Pixel Number
  	.VidioVPixelNum   (VidioVPixelNum ),  //(O)Vidio Vertical Pixel Number    
  	.VidioVBlankTime  (VidioVBlankTime),  //(O)Vidio Vertical Blanking Time (us)      
  	.VidioHBlankTime  (VidioHBlankTime),  //(O)Vidio Horizontal Blanking Time (us)       
	  .VidioDataType    (VidioDataType  ),  //(O)Vidio Data Type    
  	.VidioRestChg     (VidioRestChg   ),  //(O)MIPI Rx Vidio Resolution Change	
  	.MipiRxStaChg     (MipiRxStaChg   ),  //(O)MIPI Rx State Change      
	  .MipiRxSyncErr    (MipiRxSyncErr  ),  //(O)MIPI Rx VSync&HSync Error  
  	.MipiRxStaVCAct   (MipiRxStaVCAct ),  //(O)MIPI Rx VC Active Indicate
    .MipiRxLanesAct   (MipiRxLanesAct )   //(O)MIPI Rx Lanes Active Indicate
  );

	/////////////////////////////////////////////////////////
	//Config & Control Signal
  wire			    CtrlRxDPHYRstN ; //(I)Control MIPI Rx DPHY Reset (Low Active)
	wire			    CtrlRxCSIRstN  ; //(I)Control MIPI Rx CSI-2 Reset (Low Active)
	wire		      CtrlRxErrClr   ; //(I)Control MIPI Rx Error Clear
	wire  [ 3:0]  ConfRxVCEn     ; //(I)Config  MIPI Rx Virtual Channel Enable
	wire  [ 2:0]  ConfRxLanNum   ; //(I)Config  MIPI Rx Lanes  
	//Output To MIPI                                 
  wire	        MipiRxDPHYRstN ; //(O)MIPI Rx DPHY Reset (Low Active, To MIPI-Rx Interface)
	wire	        MipiRxCSIRstN  ; //(O)MIPI Rx CSI-2 Reset  (Low Active, To MIPI-Rx Interface)
	wire	        MipiRxErrClr   ; //(O)MIPI Rx Error Clear  (To MIPI-Rx Interface)
	
	MipiRxCtrl  U3_MipiRxControl
  (   
  	//System Signal
  	.SysClk         (RxSysClk ),  //System Clock
  	.Reset_N        (Reset_N  ),	//System Reset
  	//Config & Control Signal
  	.CtrlRxDPHYRstN  (CtrlRxDPHYRstN), //(I)Control MIPI Rx DPHY Reset                   
  	.CtrlRxCSIRstN   (CtrlRxCSIRstN ), //(I)Control MIPI Rx CSI-2 Reset                  
  	.CtrlRxErrClr    (CtrlRxErrClr  ), //(I)Control MIPI Rx Error Clear                  
  	.ConfRxVCEn      (ConfRxVCEn    ), //(I)Config  MIPI Rx Virtual Channel Enable       
  	.ConfRxLanNum    (ConfRxLanNum  ), //(I)Config  MIPI Rx Lanes      
    .MipiRxLanesAct  (MipiRxLanesAct), //(I)MIPI Rx Lanes Active Indicate
  	.MipiRxSyncErr   (MipiRxSyncErr ), //(I)MIPI Rx VSync&HSync Error   
  	.PixelRxReset    (PixelRxReset  ), //(O)MIPI Rx Reset Signal                
  	//Output To MIPI                                                 
  	.MipiRxDPHYRstN  (MipiRxDPHYRstN), //(O)[Control]MIPI Rx DPHY Reset                  
  	.MipiRxCSIRstN   (MipiRxCSIRstN ), //(O)[Control]MIPI Rx CSI-2 Reset                 
  	.MipiRxErrClr    (MipiRxErrClr  )  //(O)[Status] MIPI Rx Error Clear               
  );
  
	/////////////////////////////////////////////////////////	
	wire [ 3:0]  MipiRxVCEn       = ConfRxVCEn  ; //MIPI Rx Virtual Channel Enable (To MIPI-Rx Interface) 
	
	reg  [ 1:0]  MipiRxLanNum     = 2'h0; //MIPI Rx Lanes (To MIPI-Rx Interface) 
	
	always @( posedge RxSysClk)  
	begin
	  case (ConfRxLanNum)
	    3'h1    : MipiRxLanNum <= # TCo_C 2'h0;
	    3'h2    : MipiRxLanNum <= # TCo_C 2'h1;
	    3'h3    : MipiRxLanNum <= # TCo_C 2'h2;
	    3'h4    : MipiRxLanNum <= # TCo_C 2'h3;
	    default : MipiRxLanNum <= # TCo_C 2'h0;
	  endcase
  end
  
	/////////////////////////////////////////////////////////
  wire			   MipiRx_DPHY_RSTN = MipiRxDPHYRstN; //(O)[Control]MIPI Rx DPHY Reset
	wire			   MipiRx_RSTN      = MipiRxCSIRstN ; //(O)[Control]MIPI Rx CSI-2 Reset
	wire		     MipiRx_CLEAR     = MipiRxErrClr  ; //(I)[Status] MIPI Rx Error Clear
	wire [ 3:0]  MipiRx_VC_ENA    = MipiRxVCEn    ; //(O)[Control]MIPI Rx Virtual Channel Enable
	wire [ 1:0]  MipiRx_LANES     = MipiRxLanNum  ; //(O)[Control]MIPI Rx Lanes
	
//3333333333333333333333333333333333333333333333333333333



//4444444444444444444444444444444444444444444444444444444
//	Check Mipi Rx Data
//	Input：
//	output：
//***************************************************/ 

	wire  [ 7:0]  MiPiRxRight ; //MIPI Rx Right
	wire  [ 7:0]  MipiRxError ; //MIPI Rx Error
	
  MipiRxData8B  # (.RightCntWidth_C (RightCntWidth_C))
  U4_MipiRxData
  (   
  	//System Signal
  	.SysClk       (RxSysClk  ), //System Clock
  	.Reset_N      (Reset_N   ),	//System Reset
  	//Rx Data Signal
  	.MipiRxDValid (MipiRx_VALID ), //MIPI Rx Data Valid
  	.MipiRxData   (MipiRx_DATA  ), //MIPI Rx DataOut
  	.MipiRxError  (MipiRxError  ), //MIPI Rx Error
  	.MiPiRxRight  (MiPiRxRight  )  //MIPI Rx Right
  );
  
	/////////////////////////////////////////////////////////
	wire   [1:0]  LED;
	
	assign LED[1] = |MipiRxError;
	assign LED[0] = &MiPiRxRight;		
		
	/////////////////////////////////////////////////////////		
  wire  [7:0] MipiRxData;
  
  assign  MipiRxData[7]   = MipiRx_DATA[63];
  assign  MipiRxData[6]   = MipiRx_DATA[55];
  assign  MipiRxData[5]   = MipiRx_DATA[47];
  assign  MipiRxData[4]   = MipiRx_DATA[39];
  assign  MipiRxData[3]   = MipiRx_DATA[31];
  assign  MipiRxData[2]   = MipiRx_DATA[23];
  assign  MipiRxData[1]   = MipiRx_DATA[15];
  assign  MipiRxData[0]   = MipiRx_DATA[ 7];
  
//4444444444444444444444444444444444444444444444444444444



//5555555555555555555555555555555555555555555555555555555
//	
//	Input：
//	output：
//***************************************************/ 

	/////////////////////////////////////////////////////////
	
//5555555555555555555555555555555555555555555555555555555
	
	
    
    
    
  //DebugDebugDebugDebugDebugDebugDebugDebugDebugDebugDebug
  /////////////////////////////////////////////////////////
  
  /////////////////////////////////////////////////////////
  //Input
  wire         MipiTx_clk                           = MipiTxPixelClk;
  wire  [23:0] MipiTx_ParamTxVertSyncLength_Cycle   = CalcVSyncLen  ; //(O)Calculate Vertical Synchronization Length(Pixel  Clock Cycle)                
  wire  [15:0] MipiTx_ParamTxHoriSyncLength_Cycle   = CalcHSyncLen  ; //(O)Calculate Horizontal Synchronization Length  (Pixel  Clock Cycle)            
  wire  [15:0] MipiTx_paramTxDataValidLength_Cycle  = CalcDValidLen ; //(O)Calculate Data Valid Length  (Pixel  Clock Cycle)                            
  wire  [19:0] MipiTx_paramTxVertBlankLength_Cycle  = CalcVBlankLen ; //(O)Calculate Vertical Blanking  Length  (Pixel  Clock Cycle)	   
  wire  [15:0] MipiTx_paramTxHoriBlankLength_Cycle  = CalcHBlankLen ; //(O)Calculate Horizontal Blanking  Length  (Pixel  Clock Cycle)  
  wire  [15:0] MipiTx_RealTxHoriPixelNumber         = CalcHPixelNum ; //(O)Calculate Horizontal Pixel Number
  //Output 
  wire  [ 7:0] MipiTx_ConfigTxFrameRate       ;     
  wire  [15:0] MipiTx_ConfigTxVertPixelNumber ;     
  wire  [15:0] MipiTx_ConfigTxHoriPixelNumber ;     
  wire  [11:0] MipiTx_ConfigTxVBlankTime_us   ;     
  wire  [ 7:0] MipiTx_ConfigTxHBlankTime_us   ;     
  wire  [ 2:0] MipiTx_configTxLanesNumber     ;     
  wire  [ 5:0] MipiTx_ConfigPixelDataType     ;    
  wire  [ 0:0] MipiTx_ConfigTxFramerMode      ; 
  
  wire  [ 0:0] MipiTx_ControlTxDPHYReset      ;     
  wire  [ 0:0] MipiTx_ControlTxCSIReset       ;     
  wire  [ 0:0] MipiTx_ControlTxDisable        ;     
  wire  [ 3:0] MipiTx_ConfigTxVCEnable        ;

  /////////////////////////////////////////////////////////
  //Input    
  wire          MipiRx_clk                    = MipiRxPixelClk  ;  
  
  wire  [7:0]   MipiRx_VidioRxFrameRate       = VidioFrmNum     ; //(O)Vidio Framer Number  
  wire  [15:0]  MipiRx_VidioRxVertPixeNumber  = VidioVPixelNum  ; //(O)Vidio Vertical Pixel Number    
  wire  [15:0]  MipiRx_VidioRxHoriPixeNumber  = VidioHPixelNum  ; //(O)Vidio Horizontal Pixel Number
  wire  [19:0]  MipiRx_VidioRxVBlankTime_us   = VidioVBlankTime ; //(O)Vidio Vertical Blanking Time (us) 
  wire  [15:0]  MipiRx_VidioRxHBlankTime_us   = VidioHBlankTime ; //(O)Vidio Horizontal Blanking Time (us) 
  
  wire  [ 5:0]  MipiRx_StaRxDataType          = VidioDataType   ; //(I)[Video]  MIPI Rx Video Data Type
  wire  [ 3:0]  MipiRx_StateRxVCActive        = MipiRxStaVCAct  ; //(O)MIPI Rx VC Active Indicate
  wire  [17:0]  MipiRx_StateRxError           = MipiRx_ERROR    ; //(I)[Status] MIPI Rx Error
  wire  [ 0:0]  MipiRx_StateRxReslutionChange = VidioRestChg    ; //(O)MIPI Rx Vidio Resolution Change	
  wire  [ 0:0]  MipiRx_StateRxStateChange     = MipiRxStaChg    ; //(O)MIPI Rx State Change  
  wire  [ 0:0]  MipiRx_StateRxChannelActive   = MipiRxLanesAct  ; //(O)MIPI Rx Lanes Active Indicate
  wire  [ 7:0]  MipiRx_StateRxDataRight       = MiPiRxRight     ; //   MIPI Rx Right
  
  //Output 
  wire  [2:0]   MipiRx_ConfigRxLanesNumber;
  wire  [3:0]   MipiRx_ConfigRxVCEnable   ;
  wire  [0:0]   MipiRx_ControlRxDPHYReset ;
  wire  [0:0]   MipiRx_ControlRxCSIReset  ;
  wire  [0:0]   MipiRx_ControlRxErrorClear;       
 
  /////////////////////////////////////////////////////////
  wire          LA_MipiRx_clk             = MipiRxPixelClk ;
  wire  [3:0]   LA_MipiRx_MipiRxVSync     = MipiRx_VSYNC   ;
  wire  [3:0]   LA_MipiRx_MipiRxHSync     = MipiRx_HSYNC   ;
  wire  [0:0]   LA_MipiRx_MipiRxDValid    = MipiRx_VALID   ;
  wire  [7:0]   LA_MipiRx_MipiRxData      = MipiRxData     ;   
  wire  [0:0]   LA_MipiRx_MipiRxError     =|MipiRxError    ;
  wire  [1:0]   LA_MipiRx_MipiRxVC        = MipiRxVirtCnl  ; 
  wire  [5:0]   LA_MipiRx_MipiRxDataType  = MipiRx_TYPE    ;
    
  edb_top edb_top_inst  (
    .bscan_CAPTURE      ( jtag_inst1_CAPTURE  ),
    .bscan_DRCK         ( jtag_inst1_DRCK     ),
    .bscan_RESET        ( jtag_inst1_RESET    ),
    .bscan_RUNTEST      ( jtag_inst1_RUNTEST  ),
    .bscan_SEL          ( jtag_inst1_SEL      ),
    .bscan_SHIFT        ( jtag_inst1_SHIFT    ),
    .bscan_TCK          ( jtag_inst1_TCK      ),
    .bscan_TDI          ( jtag_inst1_TDI      ),
    .bscan_TMS          ( jtag_inst1_TMS      ),
    .bscan_UPDATE       ( jtag_inst1_UPDATE   ),
    .bscan_TDO          ( jtag_inst1_TDO      ),
    
  /////////////////////////////////////////////////////////
    .MipiTx_clk                         ( MipiTx_clk ),
    .MipiTx_ParamTxVertSyncLength_Cycle ( MipiTx_ParamTxVertSyncLength_Cycle  ),
    .MipiTx_ParamTxHoriSyncLength_Cycle ( MipiTx_ParamTxHoriSyncLength_Cycle  ),
    .MipiTx_paramTxDataValidLength_Cycle( MipiTx_paramTxDataValidLength_Cycle ),
    .MipiTx_paramTxVertBlankLength_Cycle( MipiTx_paramTxVertBlankLength_Cycle ),
    .MipiTx_paramTxHoriBlankLength_Cycle( MipiTx_paramTxHoriBlankLength_Cycle ),
    .MipiTx_RealTxHoriPixelNumber       ( MipiTx_RealTxHoriPixelNumber        ),
    
    .MipiTx_ConfigTxFrameRate           ( MipiTx_ConfigTxFrameRate            ),
    .MipiTx_ConfigTxVertPixelNumber     ( MipiTx_ConfigTxVertPixelNumber      ),
    .MipiTx_ConfigTxHoriPixelNumber     ( MipiTx_ConfigTxHoriPixelNumber      ),
    .MipiTx_ConfigTxVBlankTime_us       ( MipiTx_ConfigTxVBlankTime_us        ),
    .MipiTx_ConfigTxHBlankTime_us       ( MipiTx_ConfigTxHBlankTime_us        ),
    .MipiTx_configTxLanesNumber         ( MipiTx_configTxLanesNumber          ),
    .MipiTx_ConfigPixelDataType         ( MipiTx_ConfigPixelDataType          ),
    .MipiTx_ConfigTxFramerMode          ( MipiTx_ConfigTxFramerMode           ),
    .MipiTx_ConfigTxVCEnable            ( MipiTx_ConfigTxVCEnable             ),
    
    .MipiTx_ControlTxDPHYReset          ( MipiTx_ControlTxDPHYReset           ),
    .MipiTx_ControlTxCSIReset           ( MipiTx_ControlTxCSIReset            ),
    .MipiTx_ControlTxDisable            ( MipiTx_ControlTxDisable             ),
    
  /////////////////////////////////////////////////////////
    .MipiRx_clk                         ( MipiRx_clk                    ),
    .MipiRx_VidioRxFrameRate            ( MipiRx_VidioRxFrameRate       ),
    .MipiRx_VidioRxVertPixeNumber       ( MipiRx_VidioRxVertPixeNumber  ),
    .MipiRx_VidioRxHoriPixeNumber       ( MipiRx_VidioRxHoriPixeNumber  ),
    .MipiRx_VidioRxVBlankTime_us        ( MipiRx_VidioRxVBlankTime_us   ),
    .MipiRx_VidioRxHBlankTime_us        ( MipiRx_VidioRxHBlankTime_us   ),
    
    .MipiRx_StaRxDataType               ( MipiRx_StaRxDataType          ),
    .MipiRx_StateRxVCActive             ( MipiRx_StateRxVCActive        ),
    .MipiRx_StateRxError                ( MipiRx_StateRxError           ),
    .MipiRx_StateRxReslutionChange      ( MipiRx_StateRxReslutionChange ),
    .MipiRx_StateRxStateChange          ( MipiRx_StateRxStateChange     ),
    .MipiRx_StateRxChannelActive        ( MipiRx_StateRxChannelActive   ),
    .MipiRx_StateRxDataRight            ( MipiRx_StateRxDataRight       ),
    
    .MipiRx_ConfigRxLanesNumber         ( MipiRx_ConfigRxLanesNumber    ),
    .MipiRx_ConfigRxVCEnable            ( MipiRx_ConfigRxVCEnable       ),
    .MipiRx_ControlRxDPHYReset          ( MipiRx_ControlRxDPHYReset     ),
    .MipiRx_ControlRxCSIReset           ( MipiRx_ControlRxCSIReset      ),
    .MipiRx_ControlRxErrorClear         ( MipiRx_ControlRxErrorClear    ),
    
  /////////////////////////////////////////////////////////
    .LA_MipiRx_clk              ( LA_MipiRx_clk           ),
    .LA_MipiRx_MipiRxVSync      ( LA_MipiRx_MipiRxVSync   ),
    .LA_MipiRx_MipiRxHSync      ( LA_MipiRx_MipiRxHSync   ),
    .LA_MipiRx_MipiRxDValid     ( LA_MipiRx_MipiRxDValid  ),
    .LA_MipiRx_MipiRxData       ( LA_MipiRx_MipiRxData    ),
    .LA_MipiRx_MipiRxError      ( LA_MipiRx_MipiRxError   ),
    .LA_MipiRx_MipiRxVC         ( LA_MipiRx_MipiRxVC      ),
    .LA_MipiRx_MipiRxDataType   ( LA_MipiRx_MipiRxDataType)
  );


  /////////////////////////////////////////////////////////

  wire  [15:0]  HoriPixelNum;
  //MIPI Tx  
  assign  PixelTxEn     = ~MipiTx_ControlTxDisable          ; //Pixel Tx Enable   
  assign  MipiTxVCEn    = MipiTx_ConfigTxVCEnable           ; //Configuration Tx VC Enable
  assign  CfgTxFrmRate  = MipiTx_ConfigTxFrameRate          ; //Configuration Tx Framer Rate
  assign  CfgTxHPixelNum= MipiTx_ConfigTxHoriPixelNumber    ; //Configuration Tx Horizontal Number
	assign  CfgTxVPixelNum= MipiTx_ConfigTxVertPixelNumber    ; //Configuration Tx Vertical Pixel Number  
  assign  CfgTxVBlkTime = MipiTx_ConfigTxVBlankTime_us      ; //Configuration Tx Vertical Blanking Time (us)
  assign  CfgTxHBlkTime = MipiTx_ConfigTxHBlankTime_us      ; //Configuration Tx Horizontal Blanking Time (us)
	assign  ConfLanesNum  = MipiTx_configTxLanesNumber        ; //Configuration Lanes Number Horizontal
	assign  ConfDataType  = MipiTx_ConfigPixelDataType        ; //Configuration Pixel Data Type                
	assign  ConfTxFrmMod  = MipiTx_ConfigTxFramerMode         ; //Configuration Framer Mode
                                                                    
	assign  CtrlTxDPHYRstN= MipiTx_ControlTxDPHYReset         ; //MIPI Tx DPHY Reset (Low Active)
	assign  CtrlTxCSIRstN = MipiTx_ControlTxCSIReset          ; //MIPI Tx CSI-2 Reset (Low Active)  
	         
  //MIP                                                                  
  assign  CtrlRxDPHYRstN= MipiRx_ControlRxDPHYReset ; //(O)[Control]MIPI Rx DPHY Reset
	assign  CtrlRxCSIRstN = MipiRx_ControlRxCSIReset  ; //(O)[Control]MIPI Rx CSI-2 Reset
	assign  CtrlRxErrClr  = MipiRx_ControlRxErrorClear; //(I)[Status] MIPI Rx Error Clear
	assign  ConfRxVCEn    = MipiRx_ConfigRxVCEnable   ; //(O)[Control]MIPI Rx Virtual Channel Enable
	assign  ConfRxLanNum  = MipiRx_ConfigRxLanesNumber; //(O)[Control]MIPI Rx Lanes
	
  /////////////////////////////////////////////////////////
	
//Rx Error 
//0	  :   ERR_ESC	Escape Entry Error                : Asserted when an unrecognized escape entry command is received
//1	  :   CRC_ERROR_VC0	CRC ERROR VC0               : Set to 1 when check sum error occurs
//2	  :   CRC_ERROR_VC1	CRC ERROR VC1               : Set to 1 when check sum error occurs
//3	  :   CRC_ERROR_VC2	CRC ERROR VC2               : Set to 1 when check sum error occurs

//4	  :   CRC_ERROR_VC3	CRC ERROR VC3               : Set to 1 when check sum error occurs
//5	  :   HS_RX_TIMEOUT_ERR	HS RX Timeout Error     : The protocol should time out when no EoT is received within a certain period in HS RX mode
//6	  :   ECC_1BIT_ERROR	ECC Single Bit Error      : Set to 1 when there is a single bit error
//7	  :   ECC_2BIT_ERROR	ECC 2 Bit Error           : Set to 1 when there is a 2 bit error in the packet

//8	  :   ECCBIT_ERROR	ECC Error                   : Asserted  when an error exists in ECC
//9	  :   ECC_NO_ERROR	ECC No Error                : Asserted  when an ECC is computframed with the result zero
//10	:   FRAME_SYNC_ERROR	Frame Sync Error        : Asserted  when a frame end is not paired with a frame start on the same virtual channel
//11	:   INVLD_PKT_LEN	Invalid Packet Length       : Set to 1 if there is an invalid packet length

//12	:   INVLD_VC	Invalid VC ID                   : Set to 1 if there is an invalid CSI VC ID
//13	:   INVLD_DATA_TYPE 	Invalid Data Type       : Set to 1 if the received data is invalid        
//14	:   ERR_FRAME	Error in Frame                  : Asserted when VSYNC END received when CRC error is present in the data packet
//15	:   CONTROL_ERR	Control Error                 : Asserted when an incorrect line state sequence is detected

//16	:   SOT_ERR	Start-of-Transmission(SOT) Error  : Corrupted high-speed SOT leader sequence while proper synchronization can still be achieved
//17	:   SOT_SYNC_ERR	SOT Synchronization Error   : Corrupted high-speed SOT leader sequence while proper  synchronization cannot be expected  

endmodule



