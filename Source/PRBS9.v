
 `timescale 1ps/10fs   
 `define DebugData                                           
                                                            

///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-6-28
	版本：V1、0
	修改记录：
**********************************************************/

module PRBS9GenX8
(   
	//System Signal
	SysClk,		//(I)System Clock
	Reset_N,	//(I)System Reset
	//Signal
	ClkEn		,	//(I)Clock Enable
	DataOut		//(O)Data Output
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
	localparam	Alignment0 = 9'b1_000_100_00;	//1041，X9+X5+1
	localparam	Alignment1 = 9'b1_000_010_00;	//1021
	localparam	Alignment2 = 9'b1_001_011_00; //1131
	localparam	Alignment3 = 9'b1_100_110_00;	//1461
	localparam	Alignment4 = 9'b1_100_010_01;	//1423
	localparam	Alignment5 = 9'b1_000_101_10; //1055	    
	localparam	Alignment6 = 9'b1_001_110_11; //1167
	localparam	Alignment7 = 9'b1_101_100_00;	//1541
	
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	// Signal Define
	input		  		ClkEn  ;	
	output	[7:0]	DataOut;
	
	/////////////////////////////////////////////////////////
	
		
	//1111111111111111111111111111111111111111111111111111111
	
	/***************************************************
	目的概述：
	功能描述：
	***************************************************/ 
	wire	[7:0]  PrbsData;
		
	PRBS9Gen	#	(	.Alignment (Alignment0))
	U0_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[0])	//Data Output
	);
		
	PRBS9Gen	#	(	.Alignment (Alignment1))
	U1_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[1])	//Data Output
	);
	
	PRBS9Gen	#	(	.Alignment (Alignment2))
	U2_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[2])	//Data Output
	);
	
	PRBS9Gen	#	(	.Alignment (Alignment3))
	U3_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[3])	//Data Output
	);
	
	PRBS9Gen	#	(	.Alignment (Alignment4))
	U4_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[4])	//Data Output
	);
	
	PRBS9Gen	#	(	.Alignment (Alignment5))
	U5_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[5])	//Data Output
	);
	
	PRBS9Gen	#	(	.Alignment (Alignment6))
	U6_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[6])	//Data Output
	);
	
	PRBS9Gen	#	(	.Alignment (Alignment7))
	U7_PRBSGen	
	(
		//System Signal
		.SysClk		(SysClk		),	//System Clock
		.Reset_N	(Reset_N	),	//System Reset
		//Signal
		.ClkEn		(ClkEn		),	//Clock Enable
		.DataOut	(PrbsData[7])	//Data Output
	);
	
`ifdef DebugData //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
  reg [7:0] CntData = 8'h0;
  
  always @( posedge SysClk)  if (ClkEn) CntData <= # TCo_C CntData + 8'h1;  
  
	wire	[7:0]	DataOut = CntData;
  
`else //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
	wire	[7:0]	DataOut = PrbsData;
	
`endif //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
  
	//1111111111111111111111111111111111111111111111111111111
	
	
	
	
endmodule 
	
		
///////////////////////////////////////////////////////////
/**********************************************************
	功能描述：
	
	重要输入信号要求：
	详细设计方案文件编号：
	仿真文件名：
	
	编制：朱仁昌
	创建日期： 2019-6-28
	版本：V1、0
	修改记录：
**********************************************************/

module PRBS9ChkX8
(
	//System Signal
	SysClk  ,		//(I)System Clock
	Reset_N ,		//(I)System Reset
	//Signal
	DataIn  ,		//(I)Data Input
	ClkEn   ,		//(I)Clock Enable
	Error   ,		//(O)Data Error
	Right				//(O)Data Right
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
	parameter RightCntWidth_C = 20;
	
	localparam	Alignment0 = 9'b1_000_100_00;	//1041，X9+X5+1
	localparam	Alignment1 = 9'b1_000_010_00;	//1021
	localparam	Alignment2 = 9'b1_001_011_00; //1131
	localparam	Alignment3 = 9'b1_100_110_00;	//1461
	localparam	Alignment4 = 9'b1_100_010_01;	//1423
	localparam	Alignment5 = 9'b1_000_101_10; //1055	    
	localparam	Alignment6 = 9'b1_001_110_11; //1167
	localparam	Alignment7 = 9'b1_101_100_00;	//1541
	
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	// Signal Define
	input	[7:0]	  DataIn  ;	//(I)Data Input
	input				  ClkEn   ;	//(I)Clock Enable
	output [7:0]	Error   ;	//(O)Data Error
	output [7:0]	Right		;	//(O)Data Right
	
	//1111111111111111111111111111111111111111111111111111111
	
	/***************************************************
	目的概述：
	功能描述：
	***************************************************/ 
	wire	[7:0]	RxError;
	wire	[7:0]	RxRight;
	
	PRBS9Chk # (.Alignment			(Alignment0),
							.RightCntWidth_C(RightCntWidth_C))
	U0_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[0]),	//(I)Data Input
		.ClkEn 	(ClkEn 	),	//(I)Clock Enable
		.Error 	(RxError[0]),	//(O)Data Error
		.Right	(RxRight[0]) 	//(O)Data Right
	);
	
	PRBS9Chk # (.Alignment			(Alignment1),
							.RightCntWidth_C(RightCntWidth_C))
	U1_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[1]),	//(I)Data Input
		.ClkEn 	(ClkEn 	),	//(I)Clock Enable
		.Error 	(RxError[1]),	//(O)Data Error
		.Right	(RxRight[1]) 	//(O)Data Right
	);
	PRBS9Chk # (.Alignment			(Alignment2),
							.RightCntWidth_C(RightCntWidth_C))
	U2_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[2]),	//(I)Data Input
		.ClkEn 	(ClkEn 	),	//(I)Clock Enable
		.Error 	(RxError[2]),	//(O)Data Error
		.Right	(RxRight[2]) 	//(O)Data Right
	);
	PRBS9Chk # (.Alignment			(Alignment3),
							.RightCntWidth_C(RightCntWidth_C))
	U3_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[3]),	//(I)Data Input
		.ClkEn 	(ClkEn 		),	//(I)Clock Enable
		.Error 	(RxError[3]),	//(O)Data Error
		.Right	(RxRight[3]) 	//(O)Data Right
	);
	PRBS9Chk # (.Alignment			(Alignment4),
							.RightCntWidth_C(RightCntWidth_C))
	U4_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[4]),	//(I)Data Input
		.ClkEn 	(ClkEn 	),	//(I)Clock Enable
		.Error 	(RxError[4]),	//(O)Data Error
		.Right	(RxRight[4]) 	//(O)Data Right
	);
	PRBS9Chk # (.Alignment			(Alignment5),
							.RightCntWidth_C(RightCntWidth_C))
	U5_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[5]),	//(I)Data Input
		.ClkEn 	(ClkEn 		),	//(I)Clock Enable
		.Error 	(RxError[5]),	//(O)Data Error
		.Right	(RxRight[5]) 	//(O)Data Right
	);
	PRBS9Chk # (.Alignment			(Alignment6),
							.RightCntWidth_C(RightCntWidth_C))
	U6_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[6]),	//(I)Data Input
		.ClkEn 	(ClkEn 		),	//(I)Clock Enable
		.Error 	(RxError[6]),	//(O)Data Error
		.Right	(RxRight[6]) 	//(O)Data Right
	);
	PRBS9Chk # (.Alignment			(Alignment7),
							.RightCntWidth_C(RightCntWidth_C))
	U7_PRBS9Chk
	(
		//System Signal
		.SysClk  (SysClk  ),//(I)System Clock
		.Reset_N (Reset_N ),//(I)System Reset
		//Signal
		.DataIn	(DataIn[7] ),	//(I)Data Input
		.ClkEn 	(ClkEn 	),	//(I)Clock Enable
		.Error 	(RxError[7]),	//(O)Data Error
		.Right	(RxRight[7]) 	//(O)Data Right
	);
	
	
`ifdef DebugData //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	//Debug
  reg [7:0] LastRxData = 8'h0;
  
  always @( posedge SysClk)  if (ClkEn) LastRxData <= # TCo_C DataIn + 8'h1;
  
  reg [7:0] Error = 8'h0;
  
  always @( posedge SysClk)  if (ClkEn) Error  <= # TCo_C (LastRxData ^ DataIn);  
  
`else //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
	wire  [7:0] Error = RxError;
	
`endif //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 

  reg [RightCntWidth_C-1:0]   RightChkCnt;
  
  always @( posedge SysClk)  if (ClkEn) RightChkCnt <= # TCo_C RightChkCnt + {{(RightCntWidth_C-1){1'h0}},1'h1};
  
	/////////////////////////////////////////////////////////
  reg  RightChkEn;
  
  always @( posedge SysClk)  RightChkEn <= # TCo_C  &RightChkCnt & ClkEn;
  
	/////////////////////////////////////////////////////////
  reg [7:0]  RightChk;
  
  always @( posedge SysClk) 
  begin
    if (RightChkEn)   RightChk  <= # TCo_C 8'hff;
    else  
    begin      
      if (Error[0])   RightChk[0] <= # TCo_C 1'h0;
      if (Error[1])   RightChk[1] <= # TCo_C 1'h0;
      if (Error[2])   RightChk[2] <= # TCo_C 1'h0;
      if (Error[3])   RightChk[3] <= # TCo_C 1'h0;
      if (Error[4])   RightChk[4] <= # TCo_C 1'h0;
      if (Error[5])   RightChk[5] <= # TCo_C 1'h0;
      if (Error[6])   RightChk[6] <= # TCo_C 1'h0;
      if (Error[7])   RightChk[7] <= # TCo_C 1'h0;
    end
  end
  
  reg [7:0]  Right;
  
  always @( posedge SysClk)  if (RightChkEn)  Right <= # TCo_C RightChk; 
  
	//1111111111111111111111111111111111111111111111111111111
	
	
	
endmodule
		                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                                                                                                                                                   
///////////////////////////////////////////////////////////  
/**********************************************************  
	功能描述：产生伪随机码                                                 
	                                                           
	输入信号：                                                 
		1。系统信号：SysClk, Reset_N                            
		2。定时信号：                                  
		3。数据输入：                                  
		4。控制输入：ClkEn                             
		5。配置信息：	                                          
		6。其他输入：                                          
	输出信号：                                                   
		1。数据输出：DataOut                                   
		2。控制输出：                            
		3。状态输出：	                                             
		4。其他输出：                                            
	重要输入信号要求：	                                       
**********************************************************/ 
module PRBS9Gen
(
	//System Signal
	SysClk	,	//System Clock
	Reset_N	,	//System Reset
	//Signal
	ClkEn		,	//Clock Enable
	DataOut		//Data Output
);

	parameter  TCo_C = 1;                
	parameter	 Alignment = 9'b1_000_100_00;	//1041，X9+X5+1
	
/*
	parameter		Alignment = 9'b1_000_010_00;	//1021
	parameter		Alignment = 9'b1_001_011_00; 	//1131
	parameter		Alignment = 9'b1_100_110_00;	//1461
	parameter		Alignment = 9'b1_100_010_01;	//1423
	parameter		Alignment = 9'b1_000_101_10; 	//1055	    
	parameter		Alignment = 9'b1_001_110_11; 	//1167
	parameter		Alignment = 9'b1_101_100_00;	//1541
	parameter		Alignment = 9'b1_011_011_01; 	//1333
	parameter		Alignment = 9'b1_110_000_10;	//1605
	parameter		Alignment = 9'b1_010_011_00; 	//1231
	parameter		Alignment = 9'b1_000_010_11; 	//1027
*/	
	input		  SysClk ;
	input		  Reset_N;
	input		  ClkEn  ;	
	output		DataOut;
	
	reg	[8:0]	PRBSSft;
	
  /***************************************************
	信号输入：SysClk,Reset_N,ClkEn
	信号输出：DataOut
	目的概述：产生随机序列
	功能描述： 
	重点测试：	
	***************************************************/   
	wire	[8:0]	PRBSAlignment;
	wire    		PRBSIn       ;  
	wire			  DataOut      ;
	
	assign  # TCo_C	PRBSAlignment = PRBSSft & Alignment;
	assign  # TCo_C PRBSIn = 	PRBSAlignment[0] ^ PRBSAlignment[1]
								^	PRBSAlignment[2] ^ PRBSAlignment[3]	 
								^	PRBSAlignment[4] ^ PRBSAlignment[5]	
								^	PRBSAlignment[6] ^ PRBSAlignment[7]	
								^	PRBSAlignment[8];	
	
	always @ (posedge SysClk or negedge Reset_N)
	begin
		if ( ! Reset_N)
		begin
			PRBSSft	<= # TCo_C 9'h0;
		end
		else if (ClkEn)
		begin      
			if (|PRBSSft)
			begin
				PRBSSft[8]	<= # TCo_C PRBSSft[7];
				PRBSSft[7]	<= # TCo_C PRBSSft[6];
				PRBSSft[6]	<= # TCo_C PRBSSft[5];
				PRBSSft[5]	<= # TCo_C PRBSSft[4];
				PRBSSft[4]	<= # TCo_C PRBSSft[3];
				PRBSSft[3]	<= # TCo_C PRBSSft[2];
				PRBSSft[2]	<= # TCo_C PRBSSft[1];
				PRBSSft[1]	<= # TCo_C PRBSSft[0];
				PRBSSft[0]	<= # TCo_C PRBSIn ; 
			end
			else
			begin
				PRBSSft	<= # TCo_C Alignment;
			end
		end
	end	                          
	
	assign # TCo_C DataOut = PRBSSft[8];    
	
endmodule





                           
///////////////////////////////////////////////////////////  
/**********************************************************  
	功能描述：检测伪随机码                                                
	                                                           
	输入信号：                                                 
		1。系统信号：SysClk, Reset_N                            
		2。定时信号：                                  
		3。数据输入：DataIn                                  
		4。控制输入：ClkEn                             
		5。配置信息：	                                          
		6。其他输入：                                          
	输出信号：                                                   
		1。数据输出：                                   
		2。控制输出：Error,Right                           
		3。状态输出：	                                             
		4。其他输出：                                            
	重要输入信号要求：	                                       
**********************************************************/

module PRBS9Chk
(
	//System Signal
	SysClk  ,
	Reset_N ,	
	//Signal
	DataIn  ,
	ClkEn   ,	
	Error    ,
	Right
);

	parameter	 	TCo_C = 1;    
	         
	parameter RightCntWidth_C = 20;
	
	localparam 	RCW_C = RightCntWidth_C;
	
	parameter		Alignment = 9'b1_000_100_00;	//1041，X9+X5+1
	
/*parameter		Alignment = 9'b1_000_010_00;	//1021
	parameter		Alignment = 9'b1_001_011_00; 	//1131
	parameter		Alignment = 9'b1_100_110_00;	//1461
	parameter		Alignment = 9'b1_100_010_01;	//1423
	parameter		Alignment = 9'b1_000_101_10; 	//1055	    
	parameter		Alignment = 9'b1_001_110_11; 	//1167
	parameter		Alignment = 9'b1_101_100_00;	//1541
	parameter		Alignment = 9'b1_011_011_01; 	//1333
	parameter		Alignment = 9'b1_110_000_10;	//1605
	parameter		Alignment = 9'b1_010_011_00; 	//1231
	parameter		Alignment = 9'b1_000_010_11; 	//1027  
*/	
	
	input		SysClk	;
	input		Reset_N	;
	
	input		DataIn;
	input		ClkEn	;
	
	output	Error	;    
	output	Right	;
		
	/***************************************************
	信号输入：	SysClk,Reset_N,ClkEn
	信号输出：	DataShift[8:0]
	目的概述：	对输入的数据进行串并转换
	功能描述：
	重点测试：	
	***************************************************/   
	reg	[8:0]	DataShift;                              
	
	always @ (posedge SysClk or negedge Reset_N)
	begin
		if ( ! Reset_N)
		begin
			DataShift	<= # TCo_C 0;
		end
		else if (ClkEn)
		begin
			DataShift[8]	<= # TCo_C DataShift[7];
			DataShift[7]	<= # TCo_C DataShift[6];
			DataShift[6]	<= # TCo_C DataShift[5];
			DataShift[5]	<= # TCo_C DataShift[4];
			DataShift[4]	<= # TCo_C DataShift[3];
			DataShift[3]	<= # TCo_C DataShift[2];
			DataShift[2]	<= # TCo_C DataShift[1];
			DataShift[1]	<= # TCo_C DataShift[0];
			DataShift[0]	<= # TCo_C DataIn;
		end
	end	
			
	/***************************************************
	信号输入：	SysClk,Reset_N,ClkEn,DataShift
	信号输出：	PRBSShift[8:0]
	目的概述：	产生一个与输入信号同步的伪随机码
	功能描述：
	重点测试：	
	***************************************************/   
	wire	[8:0]	PRBSAlignment;     
	reg		[8:0]	PRBSShift;
	wire    		PRBSIn;  
	
	assign  # TCo_C	PRBSAlignment = PRBSShift & Alignment;
	assign  # TCo_C PRBSIn = 	PRBSAlignment[0] ^ PRBSAlignment[1]
													^	PRBSAlignment[2] ^ PRBSAlignment[3]	 
													^	PRBSAlignment[4] ^ PRBSAlignment[5]	
													^	PRBSAlignment[6] ^ PRBSAlignment[7]	
													^	PRBSAlignment[8];	
								
	always @ (posedge SysClk or negedge Reset_N)
	begin
		if ( ! Reset_N)
		begin
			PRBSShift	<= # TCo_C 9'h0;
		end
		else
		begin
			if (ClkEn)
			begin
				if (DataShift != PRBSShift)
				begin
					PRBSShift[8:1]	<= # TCo_C DataShift[7:0];
					PRBSShift[0]		<=	# TCo_C DataIn;
				end
				else if (|PRBSShift)  
				begin
					PRBSShift[8]	<= # TCo_C PRBSShift[7];
					PRBSShift[7]	<= # TCo_C PRBSShift[6];
					PRBSShift[6]	<= # TCo_C PRBSShift[5];
					PRBSShift[5]	<= # TCo_C PRBSShift[4];
					PRBSShift[4]	<= # TCo_C PRBSShift[3];
					PRBSShift[3]	<= # TCo_C PRBSShift[2];
					PRBSShift[2]	<= # TCo_C PRBSShift[1];
					PRBSShift[1]	<= # TCo_C PRBSShift[0];
					PRBSShift[0]	<= # TCo_C PRBSIn ;  	  
				end
				else
				begin      
					PRBSShift	<= # TCo_C Alignment;	
				end
			end
		end
	end		
	
	/***************************************************
	信号输入：	SysClk,Reset_N,ClkEn,DataShift,PRBSShift[8:0]
	信号输出：	Error
	目的概述：	产生检测结果
	功能描述：	当数据输入的串并转换的结果和伪随机码产生器不同时，输出Err信号
	重点测试：	
	***************************************************/ 
	reg			Error;   
	
	always @ (posedge SysClk or negedge Reset_N)
	begin
		if ( ! Reset_N)		Error	<= # TCo_C 1'h1;   
		else							Error <= # TCo_C  DataShift != PRBSShift;   
	end      
	
  /***************************************************
	信号输入：	SysClk,Reset_N,ClkEn,Error
	信号输出：	RightCnt
	目的概述：	产生检测结果
	功能描述：	
	重点测试：	
	***************************************************/	
	reg	 [RCW_C-1:0]	RightCnt;  
	reg	 Right;
		
	always @ (posedge SysClk or negedge Reset_N)
	begin
		if ( ! Reset_N)
		begin
			RightCnt 	<= # TCo_C 	{RCW_C{1'h0}};
			Right			<= # TCo_C 	1'h0;
		end
		else	if (ClkEn)
		begin   
			if (Error)						RightCnt <= # TCo_C {RCW_C{1'h0}};
			else if (~&RightCnt)	RightCnt <= # TCo_C RightCnt + 	{{RCW_C-1{1'h0}},1'h1};
			
			Right			<= # TCo_C 	& RightCnt;
		end
	end      
	
endmodule
