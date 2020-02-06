
`timescale 100ps/10ps

  `define Debug           
  
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

module MipiTxData8B
(   
	//System Signal
	SysClk,			//System Clock
	Reset_N,		//System Reset
	//Tx Data Signal
	MipiTxDValid, //MIPI Tx Data Valid
	MipiTxData    //MIPI Tx Data
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	//Tx Data Signal
	input           MipiTxDValid; //MIPI Tx Data Valid
	output  [63:0]  MipiTxData  ; //MIPI Tx Data
		
//1111111111111111111111111111111111111111111111111111111
//	
//	Input：
//	output：
//***************************************************/ 

  wire  [7:0] PrbsData;

  PRBS9GenX8  U1_PrbsDataGen
  (   
  	//System Signal
  	.SysClk   (SysClk     ),	//(I)System Clock
  	.Reset_N  (Reset_N    ),	//(I)System Reset
  	//Signal
  	.ClkEn		(MipiTxDValid ),	//(I)Clock Enable
  	.DataOut	(PrbsData     )	  //(O)Data Output
  );

	/////////////////////////////////////////////////////////
		
	wire  [63:0]  MipiTxData  ; //MIPI Tx Data
	
	assign  MipiTxData[63:56] = PrbsData[7] ? 8'haa : 8'h55;
	assign  MipiTxData[55:48] = PrbsData[6] ? 8'haa : 8'h55;
	assign  MipiTxData[47:40] = PrbsData[5] ? 8'haa : 8'h55;
	assign  MipiTxData[39:32] = PrbsData[4] ? 8'haa : 8'h55;
	assign  MipiTxData[31:24] = PrbsData[3] ? 8'haa : 8'h55;
	assign  MipiTxData[23:16] = PrbsData[2] ? 8'haa : 8'h55;
	assign  MipiTxData[15: 8] = PrbsData[1] ? 8'haa : 8'h55;
	assign  MipiTxData[ 7: 0] = PrbsData[0] ? 8'haa : 8'h55;
	
	
		
//1111111111111111111111111111111111111111111111111111111

	
	
endmodule 
	
	
	
	
	
	

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

module MipiRxData8B
(   
	//System Signal
	SysClk,			//System Clock
	Reset_N,		//System Reset
	//Rx Data Signal
	MipiRxDValid, //MIPI Rx Data Valid
	MipiRxData  , //MIPI Rx DataOut
	MipiRxError , //MIPI Rx Error
	MiPiRxRight   //MIPI Rx Right
);

 	//Define  Parameter
	/////////////////////////////////////////////////////////
	parameter		TCo_C   		= 1;    
		
	parameter RightCntWidth_C = 20;
	
	/////////////////////////////////////////////////////////
	
	//Define Port
	/////////////////////////////////////////////////////////
	//System Signal
	input 				SysClk;				//系统时钟
	input					Reset_N;			//系统复位
	
	/////////////////////////////////////////////////////////
	//Rx Data Signal
	input           MipiRxDValid; //MIPI Rx Data Valid
	input   [63:0]  MipiRxData  ; //MIPI Rx DataOut
	output  [ 7:0]  MiPiRxRight ; //MIPI Rx Right
	output  [ 7:0]  MipiRxError ; //MIPI Rx Error
		
//1111111111111111111111111111111111111111111111111111111
//	
//	Input：
//	output：
//***************************************************/ 

  wire [7:0] ByteErr;
  
  assign  ByteErr[7]  = ( MipiRxData[63:56] != 8'haa  ) & ( MipiRxData[63:56] != 8'h55  );
  assign  ByteErr[6]  = ( MipiRxData[55:48] != 8'haa  ) & ( MipiRxData[55:48] != 8'h55  );
  assign  ByteErr[5]  = ( MipiRxData[47:40] != 8'haa  ) & ( MipiRxData[47:40] != 8'h55  );
  assign  ByteErr[4]  = ( MipiRxData[39:32] != 8'haa  ) & ( MipiRxData[39:32] != 8'h55  );
  assign  ByteErr[3]  = ( MipiRxData[31:24] != 8'haa  ) & ( MipiRxData[31:24] != 8'h55  );
  assign  ByteErr[2]  = ( MipiRxData[23:16] != 8'haa  ) & ( MipiRxData[23:16] != 8'h55  );
  assign  ByteErr[1]  = ( MipiRxData[15: 8] != 8'haa  ) & ( MipiRxData[15: 8] != 8'h55  );
  assign  ByteErr[0]  = ( MipiRxData[ 7: 0] != 8'haa  ) & ( MipiRxData[ 7: 0] != 8'h55  );
  
	/////////////////////////////////////////////////////////
  wire  [7:0] PrbsDataIn;
  
  assign  PrbsDataIn[7]   = ByteErr[7]  ^ MipiRxData[63];
  assign  PrbsDataIn[6]   = ByteErr[6]  ^ MipiRxData[55];
  assign  PrbsDataIn[5]   = ByteErr[5]  ^ MipiRxData[47];
  assign  PrbsDataIn[4]   = ByteErr[4]  ^ MipiRxData[39];
  assign  PrbsDataIn[3]   = ByteErr[3]  ^ MipiRxData[31];
  assign  PrbsDataIn[2]   = ByteErr[2]  ^ MipiRxData[23];
  assign  PrbsDataIn[1]   = ByteErr[1]  ^ MipiRxData[15];
  assign  PrbsDataIn[0]   = ByteErr[0]  ^ MipiRxData[ 7];
  
	/////////////////////////////////////////////////////////

	wire  [ 7:0]  MipiRxError ; //MIPI Rx Error
	wire  [ 7:0]  MiPiRxRight ; //MIPI Rx Right
	
  PRBS9ChkX8  # (.RightCntWidth_C (RightCntWidth_C))
  U1_PrbsCheck
  (
  	//System Signal
  	.SysClk   (SysClk      ),	//(I)System Clock
  	.Reset_N  (Reset_N     ),	//(I)System Reset
  	//Signal
  	.DataIn   (PrbsDataIn   ),
  	.ClkEn    (MipiRxDValid ),	
  	.Error    (MipiRxError  ),
  	.Right    (MiPiRxRight  )
  );
    
	/////////////////////////////////////////////////////////
		
//1111111111111111111111111111111111111111111111111111111



	
	
	
endmodule 
	
		
		
		