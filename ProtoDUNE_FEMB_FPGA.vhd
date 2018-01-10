--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: ProtoDUNE_FEMB_FPGA.VHD            
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created:  07/16/2015 
--////  Modified: 12/08/2016
--//// 
--////  Description:  TOP LEVEL ProtoDUNE FPGA FIRMWARE  
--////					  preliminary -- CODE
--////
--/////////////////////////////////////////////////////////////////////
--////
--//// Copyright (C) 2015 Brookhaven National Laboratory
--////
--/////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.sbndPkg.all;

entity ProtoDUNE_FEMB_FPGA is
	port 
	(
	
		ProtoDUNE_TX	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);	-- 1.5V PCML
		SFP_TX			: OUT STD_LOGIC;
		SFP_RX			: IN  STD_LOGIC;
		CLK_100MHz_OSC	: IN STD_LOGIC;	-- LVDS	  100MHz
		CLK_125MHz_OSC	: IN STD_LOGIC;	-- LVDS	  125MHz  Internal SERDES CLOCK		
		
		
		
		CLK_125M_spare	: IN STD_LOGIC;	-- LVDS	  125MHz  Internal SERDES CLOCK		
		REF_CLK4			: IN STD_LOGIC;	-- LVDS	  100MHz  Internal SERDES CLOCK		
		
		
		CLK_EXT			: IN STD_LOGIC;	-- LVDS
		CLK_DAQ			: IN STD_LOGIC;	-- LVDS
		
		ProtoDUNE_CLK	: IN STD_LOGIC;	-- LVDS
		ProtoDUNE_CMD	: IN STD_LOGIC;	-- LVDS		
		
		
		FE_RST_L			: OUT STD_LOGIC;	-- 1.8V		
		FE_RST_R			: OUT STD_LOGIC;	-- 1.8V				
		
		ASIC_CS			: OUT STD_LOGIC_VECTOR(7 downto 0);	-- 1.8V
		ASIC_CK			: OUT STD_LOGIC_VECTOR(7 downto 0);	-- 1.8V
		ASIC_SDI			: OUT STD_LOGIC_VECTOR(7 downto 0);	-- 1.8V
		ASIC_SDO			: IN  STD_LOGIC_VECTOR(7 downto 0);	-- 1.8V		
					
		
		ADC_STRB_L		: OUT STD_LOGIC;	-- LVDS  
		ADC_SDI_R		: OUT STD_LOGIC;	-- LVDS	USED TO BE ADC_REN_R		
		ADC_SDO_R		: IN STD_LOGIC;	-- LVDS				
		ADC_STRB_R		: OUT STD_LOGIC;	-- LVDS	
		ADC_SDI_L		: OUT STD_LOGIC;	-- LVDS	USED TO BE ADC_REN_L		
		ADC_SDO_L		: IN STD_LOGIC;	-- LVDS	
		ADC_CS			: OUT STD_LOGIC_VECTOR(7 downto 0);  -- LVDS	-- Part of SPI control
		
		

		ADC_eclk_RST_L	: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_IDXM_L: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_IDL_L	: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_READ_L: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_IDXL_L: OUT STD_LOGIC;	-- LVDS
		
		ADC_eclk_RST_R	: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_IDXM_R: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_IDL_R	: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_READ_R: OUT STD_LOGIC;	-- LVDS
		ADC_eclk_IDXL_R: OUT STD_LOGIC;	-- LVDS
			
		
		ADC_FD_0			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_1			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_2			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_3			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS		
		ADC_FD_4			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_5			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_6			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_7			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS				
			
		
		ADC_FF			: IN  STD_LOGIC_VECTOR(7 downto 0);  -- LVDS	-- NOT USED 
		ADC_BUSY			: IN  STD_LOGIC_VECTOR(7 downto 0);  -- LVDS	-- ADC_BUSY

		ADC_CLK			: OUT STD_LOGIC_VECTOR(7 downto 0);  -- LVDS	 -- 200MHz ADC clock
		ADC_CONV			: OUT STD_LOGIC_VECTOR(7 downto 0);  -- LVDS	 -- ADC SAMPLE CLOCK
		
		DAC_SELECT		: OUT STD_LOGIC;								-- 2.5V
		BRD_ID			: IN STD_LOGIC_VECTOR(4 downto 0);			-- 1.8V		
		DAC_CNTL			: INOUT STD_LOGIC_VECTOR(6 downto 0);		-- 1.8V		
		MISC_IO			: OUT STD_LOGIC_VECTOR(7 downto 0);			-- 2.5V
		EXTRA_IO			: INOUT STD_LOGIC_VECTOR(2 downto 0);		-- 2.5V
	
		ANALOG_SEL		: OUT STD_LOGIC;	
		JTAG_SEL			: OUT STD_LOGIC;	

		MISC_I_L			: IN  STD_LOGIC_VECTOR(3 downto 0);  -- LVDS	
		MISC_I_R			: IN  STD_LOGIC_VECTOR(3 downto 0);  -- LVDS		
		
		
		COM_OUT			: OUT STD_LOGIC;			-- LVDS
		I2C_SCL			: INOUT  STD_LOGIC;		-- 2.5V
		I2C_SDA			: INOUT STD_LOGIC;		-- 2.5V
		
		I2C_SCL_DIF_P	: IN STD_LOGIC;			-- LVDS
--		I2C_SCL_DIF_N	: IN STD_LOGIC;			-- LVDS	

		I2C_SDA_DIF_P	: INOUT STD_LOGIC;		-- BUSED LVDS
		I2C_SDA_DIF_N	: INOUT STD_LOGIC;		-- BUSED LVDS	
		
		I2C_SCL_MISC	: INOUT STD_LOGIC;		-- 2.5V
		I2C_SDA_MISC	: INOUT STD_LOGIC		   -- 2.5V
	
	);

end ProtoDUNE_FEMB_FPGA;


architecture ProtoDUNE_FEMB_FPGA_arch of ProtoDUNE_FEMB_FPGA is




component alt_pll
	PORT
	(
		clkswitch : IN STD_LOGIC ;
		areset	:  IN STD_LOGIC ;
		inclk0	:  IN STD_LOGIC ;
		inclk1	:  IN STD_LOGIC ;
		c0			: OUT STD_LOGIC ;
		c1			: OUT STD_LOGIC ;
		c2			: OUT STD_LOGIC ;
		c3			: OUT STD_LOGIC ;
		c4			: OUT STD_LOGIC 

	);
end component;




SIGNAL   SIG_IN		:	STD_LOGIC;
SIGNAL	clk_200Mhz 		:  STD_LOGIC;
SIGNAL	clk_125Mhz 		:  STD_LOGIC;
SIGNAL	clk_100Mhz 		:  STD_LOGIC;
SIGNAL	clk_50Mhz		:  STD_LOGIC;
SIGNAL	clk_2Mhz			:  STD_LOGIC;
SIGNAL	LOC_CLK			:  STD_LOGIC;


SIGNAL	reset 			:  STD_LOGIC;
SIGNAL	start				: STD_LOGIC;
SIGNAL	TIME_STMP_RST	: STD_LOGIC;	

SIGNAL	TIMESTAMP		:  STD_LOGIC_VECTOR(15  DOWNTO 0);
SIGNAL	ADC_ERROR		:  STD_LOGIC_VECTOR(15  DOWNTO 0);
SIGNAL	USER_DATA		:  STD_LOGIC_VECTOR(15  DOWNTO 0);

SIGNAL	reg0_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg1_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg2_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg3_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg4_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg5_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg6_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg7_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg8_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg9_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg10_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg11_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg12_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg13_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg14_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg15_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg16_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg17_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg18_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg19_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg20_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg21_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg22_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg23_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg24_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg25_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg26_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg27_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg28_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg29_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg30_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg31_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg32_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg33_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg34_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg35_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg36_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg37_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg38_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);
SIGNAL	reg39_p 			:  STD_LOGIC_VECTOR(31  DOWNTO 0);

SIGNAL	DPM_WREN					:  STD_LOGIC;		
SIGNAL	DPM_ADDR					:  STD_LOGIC_VECTOR(7 downto 0);		
SIGNAL	DPM_Q						:  STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	DPM_D						:  STD_LOGIC_VECTOR(31 downto 0);	

SIGNAL	FPGA_F_DPM_WREN		:  STD_LOGIC;		
SIGNAL	FPGA_F_DPM_ADDR		:  STD_LOGIC_VECTOR(7 downto 0);		
SIGNAL	FPGA_F_DPM_Q			:  STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	FPGA_F_DPM_D			:  STD_LOGIC_VECTOR(31 downto 0);	

SIGNAL	ProtoDUNE_SPI_DPM_WREN		:  STD_LOGIC;		
SIGNAL	ProtoDUNE_SPI_DPM_ADDR		:  STD_LOGIC_VECTOR(7 downto 0);		
SIGNAL	ProtoDUNE_SPI_DPM_Q			:  STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	ProtoDUNE_SPI_DPM_D			:  STD_LOGIC_VECTOR(31 downto 0);	


SIGNAL	WFM_GEN_ADDR			:  STD_LOGIC_VECTOR(7 downto 0);		
SIGNAL	WFM_GEN_DATA			:  STD_LOGIC_VECTOR(31 downto 0);



SIGNAL	rd_strb 					:  STD_LOGIC;
SIGNAL	wr_strb 					:  STD_LOGIC;
SIGNAL	WR_address				:  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	RD_address				:  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	data 						:  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rdout 					:  STD_LOGIC_VECTOR(31 DOWNTO 0);


SIGNAL	I2C_data      	  		:  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	I2C_address    	 	:  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	I2C_WR    	 	 		:  STD_LOGIC;
SIGNAL	I2C_data_out	 		:  STD_LOGIC_VECTOR(31 DOWNTO 0);
		

SIGNAL	UDP_data        		:  STD_LOGIC_VECTOR(31 downto 0);	
SIGNAL	UDP_WR_address  		:  STD_LOGIC_VECTOR(15 downto 0); 
SIGNAL	UDP_RD_address  		:  STD_LOGIC_VECTOR(15 downto 0); 
SIGNAL	UDP_WR    	 	 		:  STD_LOGIC;	
SIGNAL	UDP_data_out	 		:  STD_LOGIC_VECTOR(31 downto 0);		
		
SIGNAL	SYS_RESET				:  STD_LOGIC;
SIGNAL	REG_RESET				:  STD_LOGIC;

SIGNAL	FPGA_F_ENABLE			:  STD_LOGIC;
SIGNAL 	FPGA_F_OP_CODE			:  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL 	FPGA_F_STRT_OP			:  STD_LOGIC;
SIGNAL 	FPGA_F_ADDR				:  STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL 	FPGA_F_status			:  STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL	SW_TS_RESET					:  STD_LOGIC;

SIGNAL	ADC_RESET				:  STD_LOGIC;
SIGNAL	FE_RESET					:  STD_LOGIC;
SIGNAL	WRITE_ADC_ASIC_SPI	:  STD_LOGIC;
SIGNAL	WRITE_FE_ASIC_SPI		:  STD_LOGIC;


SIGNAL 	CLK_select				: 	STD_LOGIC_VECTOR(7 downto 0); 		
SIGNAL 	CHP_select				:	STD_LOGIC_VECTOR(7 downto 0); 		
SIGNAL 	CHN_select				:	STD_LOGIC_VECTOR(7 downto 0); 
SIGNAL	TST_PATT_EN				:	STD_LOGIC_VECTOR(7 downto 0); 
SIGNAL	TST_PATT					:	STD_LOGIC_VECTOR(11 downto 0);
SIGNAL 	ADC_TEST_PAT_EN		:  STD_LOGIC;


SIGNAL	Header_P_event			:	STD_LOGIC_VECTOR(7 downto 0); 	-- Number of events packed per header  	

SIGNAL	LATCH_LOC_0				:	STD_LOGIC_VECTOR(7 downto 0);	
SIGNAL	LATCH_LOC_1				:	STD_LOGIC_VECTOR(7 downto 0);
SIGNAL	LATCH_LOC_2				:	STD_LOGIC_VECTOR(7 downto 0);
SIGNAL	LATCH_LOC_3				:	STD_LOGIC_VECTOR(7 downto 0);
SIGNAL	LATCH_LOC_4				:	STD_LOGIC_VECTOR(7 downto 0);	
SIGNAL	LATCH_LOC_5				:	STD_LOGIC_VECTOR(7 downto 0);
SIGNAL	LATCH_LOC_6				:	STD_LOGIC_VECTOR(7 downto 0);
SIGNAL	LATCH_LOC_7				:	STD_LOGIC_VECTOR(7 downto 0);	



SIGNAL	OUT_of_SYNC	 			:  STD_LOGIC_VECTOR(15 downto 0);		

SIGNAL	ADC_Data_LATCH 		:	STD_LOGIC_VECTOR(7 downto 0);	
	
SIGNAL	ADC_Data		   		: ADC_array(0 to 7);		
SIGNAL	ADC_header				: SL_ARRAY_7_TO_0(0 to 7);		
	
SIGNAL	UDP_TST_LATCH			:	STD_LOGIC;
SIGNAL	UDP_TST_DATA			:	STD_LOGIC_VECTOR(15 downto 0);
	
SIGNAL	WIB_MODE					: STD_LOGIC;
SIGNAL	DATA_VALID				: STD_LOGIC_VECTOR(3 downto 0);			
SIGNAL	DATA_PKT					: SL_ARRAY_16_TO_0(0 to 3);

SIGNAL	TP_SYNC					: STD_LOGIC;
SIGNAL	TP_AMPL					: STD_LOGIC_VECTOR(5 downto 0);
SIGNAL	TP_DLY					: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL	TP_FREQ					: STD_LOGIC_VECTOR(15 downto 0);


SIGNAL	ADC_DATA_EN				: STD_LOGIC;
SIGNAL	Stream_EN				: STD_LOGIC;
SIGNAL	PRBS_EN					: STD_LOGIC;	
SIGNAL	CNT_EN					: STD_LOGIC;

SIGNAL	clk_200					: STD_LOGIC;

SIGNAL	FPGA_TP_EN				: STD_LOGIC;
SIGNAL	ASIC_TP_EN				: STD_LOGIC;

SIGNAL	test1						: STD_LOGIC;
SIGNAL	test2						: STD_LOGIC;

SIGNAL	INT_TP_EN				: STD_LOGIC;
SIGNAL	EXT_TP_EN				: STD_LOGIC;

SIGNAL	tx_pll_areset			: STD_LOGIC;
SIGNAL	tx_digitalrst			: STD_LOGIC;	

SIGNAL	TP_EXT_GEN				: STD_LOGIC;	
SIGNAL	ASIC_DAC_CNTL			: STD_LOGIC;	

SIGNAL	ADC_CONV_OUT			: STD_LOGIC;		

SIGNAL	FEMB_TST_MODE			: STD_LOGIC;		
SIGNAL	STOP_DATA				: STD_LOGIC;		
SIGNAL	START_DATA				: STD_LOGIC;		
SIGNAL	ADC_RD_DISABLE			: STD_LOGIC;
SIGNAL	ADC_DISABLE_REG		: STD_LOGIC;
SIGNAL	UDP_FRAME_SIZE			: STD_LOGIC_VECTOR(11 downto 0);
SIGNAL	START_BIT_MODE			: STD_LOGIC;	


SIGNAL	PERIOD					:  STD_LOGIC_VECTOR(15 downto 0);
SIGNAL	INV_RST	 				:  STD_LOGIC_VECTOR(1 downto 0);		-- invert
SIGNAL	OFST_RST					:  STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
SIGNAL	WDTH_RST					:  STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
SIGNAL	INV_READ 				:  STD_LOGIC_VECTOR(1 downto 0);		-- invert					
SIGNAL	OFST_READ	 			:  STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
SIGNAL	WDTH_READ			 	:  STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
SIGNAL	INV_IDXM				 	:  STD_LOGIC_VECTOR(1 downto 0);		-- invert					
SIGNAL	OFST_IDXM				:  STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
SIGNAL	WDTH_IDXM	 			:  STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
SIGNAL	INV_IDXL				 	:  STD_LOGIC_VECTOR(1 downto 0);		-- invert					
SIGNAL	OFST_IDXL			 	:  STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
SIGNAL	WDTH_IDXL	 			:  STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
SIGNAL	INV_IDL				 	:  STD_LOGIC_VECTOR(1 downto 0);		-- invert						
SIGNAL	OFST_IDL_f1			 	:  STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
SIGNAL	WDTH_IDL_f1			 	:  STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
SIGNAL	OFST_IDL_f2	 			:  STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
SIGNAL	WDTH_IDL_f2	 			:  STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
SIGNAL   PHASE_CONTROL_R		:  STD_LOGIC_VECTOR(7 downto 0);  
SIGNAL   PHASE_CONTROL_L		:  STD_LOGIC_VECTOR(7 downto 0);  
begin



	
----- register map -------


	SYS_RESET				<= reg0_p(0);							-- SYSTEM RESET
	REG_RESET				<= reg0_p(1);							-- RESISTER RESET
	SW_TS_RESET				<= reg0_p(2);							-- TIME_STAMP RESET
	ADC_RESET				<= reg1_p(0);		
	FE_RESET					<= reg1_p(1);	
	
	WRITE_ADC_ASIC_SPI 	<= reg2_p(0);	 	
	WRITE_FE_ASIC_SPI 	<= reg2_p(1);	
 	
	TST_PATT_EN				<= reg3_p(7 downto 0);		
	TST_PATT					<= reg3_p(27 downto 16);
	ADC_TEST_PAT_EN	 	<= reg3_p(31);	 	
	
	
	LATCH_LOC_0				<= reg4_p(7 downto 0);		
	LATCH_LOC_1				<= reg4_p(15 downto 8);	
	LATCH_LOC_2				<= reg4_p(23 downto 16);	
	LATCH_LOC_3				<= reg4_p(31 downto 24);	
	
	
	
	
	LATCH_LOC_4				<= reg14_p(7 downto 0);	
	LATCH_LOC_5				<= reg14_p(15 downto 8);	
	LATCH_LOC_6				<= reg14_p(23 downto 16);	
	LATCH_LOC_7				<= reg14_p(31 downto 24);	

	FPGA_TP_EN				<= reg16_p(0);	
	ASIC_TP_EN				<= reg16_p(1);	
	
	TP_AMPL					<= reg5_p(5 downto 0);	
	TP_FREQ		 			<= reg5_p(31 downto 16);
	TP_DLY					<= reg5_p(15 downto 8);

	
	CLK_select				<= reg6_p(7 downto 0);	
	--OUT_of_SYNC				reg6(31 downto 16);
	CHP_select				<= reg7_p(7 downto 0);	
	CHN_select				<= reg17_p(3 downto 0) & reg7_p(11 downto 8);	
	
--	Header_P_event			<= reg8_p(7 downto 0);	 

	WIB_MODE					<= reg8_p(0);	
	ADC_DISABLE_REG		<= reg8_p(4);	
	

	Stream_EN				<= reg9_p(0);		
	PRBS_EN					<= reg9_p(1);		
	CNT_EN					<= reg9_p(2);
	ADC_DATA_EN				<= reg9_p(3);		


	FPGA_F_OP_CODE			<= reg10_p(7 downto 0);				-- EPCS  OP CODE
	FPGA_F_STRT_OP			<= reg10_p(8);							-- START FLASH OPERATION
	--FPGA_F_ENABLE			<= reg10_p(31);						-- ENABLE EPCS PROGRAMMING 
	FPGA_F_ADDR				<= reg11_p(23 downto 0);			-- EPCS ADDRESS
	--FPGA_F_status			REG 12 
	FPGA_F_ENABLE			<= reg13_p(0);	

--	tx_digitalreset		<=	reg20_p(1);  used bellow
	DAC_SELECT				<= reg16_p(8);	
	SIG_IN					<= reg15_p(0);

	
	INT_TP_EN				<= not reg18_p(0);
	EXT_TP_EN				<= not reg18_p(1);
	FEMB_TST_MODE			<= reg19_p(0);
	START_BIT_MODE			<= reg20_p(4);
	tx_pll_areset			<= reg20_p(0);
	tx_digitalrst			<= reg20_p(1);
	UDP_FRAME_SIZE			<= reg20_p(27 downto 16);
	
	PERIOD					<= reg21_p(15 DOWNTO 0);
	INV_RST	 				<= reg21_p(21) & reg21_p(16);    
	OFST_RST					<= reg22_p; 	  	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	WDTH_RST					<= reg23_p;		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	INV_READ 				<= reg21_p(22) & reg21_p(17);      
	OFST_READ			 	<= reg24_p;		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	WDTH_READ			 	<= reg25_p;		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	INV_IDXM				 	<= reg21_p(23) & reg21_p(18);     
	OFST_IDXM				<= reg26_p;		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	WDTH_IDXM			 	<= reg27_p;		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	INV_IDXL		 			<= reg21_p(24) & reg21_p(19);      
	OFST_IDXL		 		<= reg28_p;		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	WDTH_IDXL			 	<= reg29_p;		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	INV_IDL				 	<= reg21_p(25) & reg21_p(20);      
	OFST_IDL_f1			 	<= reg30_p;	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	WDTH_IDL_f1			 	<= reg31_p;	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	OFST_IDL_f2			 	<= reg32_p;	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
	WDTH_IDL_f2			 	<= reg33_p;	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)	
	PHASE_CONTROL_R		<= reg34_p(7 DOWNTO 0);
	PHASE_CONTROL_L		<= reg34_p(15 DOWNTO 8);
	
	
	
	
	
-----  end of register map



sys_rst_inst : entity work.sys_rst
PORT MAP(	clk 			=> clk_50Mhz,
				reset_in 	=> SYS_RESET,
				start 		=> start,
				RST_OUT 		=> reset);
			
			
alt_pll_inst : alt_pll
	PORT MAP
	(
	
		clkswitch 	=> BRD_ID(0),
		areset		=> SYS_RESET,
		inclk0		=> CLK_100MHz_OSC,
		inclk1		=> ProtoDUNE_CLK,
		c0				=> clk_200Mhz,
		c1				=> clk_125Mhz,
		c2				=> clk_100Mhz,
		c3				=> clk_50Mhz,
		c4				=> clk_2Mhz
	);
	
		
 LOC_CLK		<= clk_50Mhz; 
		

 I2C_slave_inst1 : entity work.I2C_slave_32bit_A16
	PORT MAP
	(
		rst   	   		=> reset,
		sys_clk	   		=> clk_50Mhz,
		I2C_BRD_ADDR		=> b"0000101",
		SCL         		=> I2C_SCL_DIF_P , -- I2C_SDA_SCL, --_DIF_P,
		SDA_P	        		=> I2C_SDA_DIF_P,
		SDA_N        		=> I2C_SDA_DIF_N,	
		REG_ADDRESS			=> I2C_address,
		REG_DOUT				=> I2C_data_out,
		REG_DIN				=> I2C_data ,
		REG_WR_STRB 		=> I2C_WR
	);
	
	

	
 SBND_Registers_inst :  entity work.SBND_Registers 
	PORT MAP
	(
		rst         => reset or REG_RESET,	
		clk         => clk_100Mhz,

		BOARD_ID		=> x"00" & b"000" & BRD_ID,
		VERSION_ID	=> x"0302",
		
		I2C_data       => I2C_data,
		I2C_address    => I2C_address,
		I2C_WR    	 	=> I2C_WR , 
		I2C_data_out	=> I2C_data_out,	
		
		
		UDP_data       =>	UDP_data,
		UDP_WR_address => UDP_WR_address,
		UDP_RD_address => UDP_RD_address,
		UDP_WR    	 	=> UDP_WR ,
		UDP_data_out	=> UDP_data_out,
			
		
		DPM_B_WREN		=> DPM_WREN,
		DPM_B_ADDR		=> DPM_ADDR,
		DPM_B_Q			=> DPM_Q,
		DPM_B_D			=> DPM_D,

		DPM_C_ADDR		=>	WFM_GEN_ADDR,
		DPM_C_Q			=> WFM_GEN_DATA,
		
		reg0_i 	=> reg0_p,
		reg1_i 	=> reg1_p,		 
		reg2_i 	=> reg2_p,		 
		reg3_i 	=> reg3_p,	
		reg4_i 	=> reg4_p,
		reg5_i 	=> reg5_p,
		reg6_i 	=> OUT_of_SYNC & reg6_p(15 downto 0),
		reg7_i 	=> reg7_p,
		reg8_i 	=> reg8_p,
		reg9_i 	=> ADC_RD_DISABLE & reg9_p(30 downto 0),		 
		reg10_i 	=> reg10_p,
		reg11_i 	=> reg11_p,
		reg12_i 	=> FPGA_F_status,
		reg13_i 	=> reg13_p,
		reg14_i 	=> reg14_p,
		reg15_i 	=> reg15_p,	
		reg16_i 	=> reg16_p,
		reg17_i 	=> reg17_p,
		reg18_i 	=> reg18_p,
		reg19_i 	=> reg19_p,		 
		reg20_i  => reg20_p,
		reg21_i 	=> reg21_p,
		reg22_i 	=> reg22_p,
		reg23_i 	=> reg23_p,
		reg24_i 	=> reg24_p,
		reg25_i 	=> reg25_p,	
		reg26_i 	=> reg26_p,
		reg27_i 	=> reg27_p,
		reg28_i 	=> reg28_p,
		reg29_i 	=> reg29_p,		 
		reg30_i  => reg30_p,	
		reg31_i 	=> reg31_p,
		reg32_i 	=> reg32_p,
		reg33_i 	=> reg33_p,
		reg34_i 	=> reg34_p,
		reg35_i 	=> reg35_p,	
		reg36_i 	=> reg36_p,
		reg37_i 	=> reg37_p,
		reg38_i 	=> reg38_p,
		reg39_i 	=> reg39_p,			 		 
		
		reg0_o 	=> reg0_p,
		reg1_o 	=> reg1_p,		 
		reg2_o 	=> reg2_p,		 
		reg3_o 	=> reg3_p,		
		reg4_o 	=> reg4_p,
		reg5_o 	=> reg5_p,
		reg6_o 	=> reg6_p,
		reg7_o 	=> reg7_p,
		reg8_o 	=> reg8_p,
		reg9_o 	=> reg9_p,		 
		reg10_o 	=> reg10_p,
		reg11_o 	=> reg11_p,
		reg12_o 	=> reg12_p,
		reg13_o 	=> reg13_p,
		reg14_o 	=> reg14_p,
		reg15_o 	=> reg15_p,
		reg16_o 	=> reg16_p,
		reg17_o 	=> reg17_p,
		reg18_o 	=> reg18_p,
		reg19_o 	=> reg19_p,		 
		reg20_o 	=> reg20_p,
		reg21_o 	=> reg21_p,
		reg22_o 	=> reg22_p,
		reg23_o 	=> reg23_p,
		reg24_o 	=> reg24_p,
		reg25_o 	=> reg25_p,
		reg26_o 	=> reg26_p,
		reg27_o 	=> reg27_p,
		reg28_o 	=> reg28_p,
		reg29_o 	=> reg29_p,		 
		reg30_o 	=> reg30_p,
		reg31_o 	=> reg31_p,
		reg32_o 	=> reg32_p,
		reg33_o 	=> reg33_p,
		reg34_o 	=> reg34_p,
		reg35_o 	=> reg35_p,
		reg36_o 	=> reg36_p,
		reg37_o 	=> reg37_p,
		reg38_o 	=> reg38_p,
		reg39_o 	=> reg39_p		
	);

	
	
	
	DPM_WREN		<=	ProtoDUNE_SPI_DPM_WREN	when (FPGA_F_ENABLE = '0') else
						FPGA_F_DPM_WREN;
	DPM_ADDR		<= ProtoDUNE_SPI_DPM_ADDR	when (FPGA_F_ENABLE = '0') else
						FPGA_F_DPM_ADDR;
	DPM_D			<= ProtoDUNE_SPI_DPM_D	when (FPGA_F_ENABLE = '0') else
						FPGA_F_DPM_D;

	FPGA_F_DPM_Q				<= DPM_Q;	
	ProtoDUNE_SPI_DPM_Q		<= DPM_Q;

	
	
	


SFL_EPCS_inst	: entity work.SFL_EPCS
	PORT MAP
	(
		rst         => reset,			
		clk         => LOC_CLK,
		JTAG_EEPROM	=> FPGA_F_ENABLE,
		start_op		=> FPGA_F_STRT_OP,			
		op_code	   => FPGA_F_OP_CODE,	
		address	   => FPGA_F_ADDR, 		
		status		=> FPGA_F_status,		
		DPM_WREN		=> FPGA_F_DPM_WREN,
		DPM_ADDR		=> FPGA_F_DPM_ADDR,
		DPM_Q	  		=> FPGA_F_DPM_Q,
		DPM_D			=>	FPGA_F_DPM_D
		
	);



	SBND_RDOUT_V1_inst :	entity work.SBND_RDOUT_V1
	PORT MAP
	(

		sys_rst     	=> SYS_RESET or ADC_RESET,	
		clk_200Mhz    	=> clk_200Mhz,
		clk_sys	    	=> clk_100Mhz,
		
		ADC_SYNC_MODE	=> BRD_ID(0),
		EXT_ADC_CONV	=> ProtoDUNE_CMD,
		ADC_RD_DISABLE	=> ADC_RD_DISABLE,
		TP_SYNC			=> TP_SYNC,
		ADC_CONV			=> ADC_CONV,
		

		ADC_FD_0			=> ADC_FD_0,
		ADC_FD_1			=> ADC_FD_1,		
		ADC_FD_2			=> ADC_FD_2,		
		ADC_FD_3			=> ADC_FD_3,			
		ADC_FD_4			=> ADC_FD_4,		
		ADC_FD_5			=> ADC_FD_5,		
		ADC_FD_6			=> ADC_FD_6,		
		ADC_FD_7			=> ADC_FD_7,					
		
		ADC_FF			=> ADC_FF,
		ADC_BUSY			=> ADC_BUSY,
		ADC_CLK			=> ADC_CLK,
	
		CLK_select		=>	CLK_select,
		CHP_select		=>	CHP_select,			--: IN STD_LOGIC_VECTOR(7 downto 0); 		
		CHN_select		=>	CHN_select,			--: IN STD_LOGIC_VECTOR(7 downto 0); 
		
		TST_PATT_EN		=> TST_PATT_EN,		--: IN STD_LOGIC_VECTOR(7 downto 0); 
		TST_PATT			=> TST_PATT,			--: IN STD_LOGIC_VECTOR(11 downto 0);

		
		LATCH_LOC_0		=> LATCH_LOC_0,		--: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_1		=> LATCH_LOC_1,		--: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_2		=> LATCH_LOC_2,		--: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_3		=> LATCH_LOC_3,		--: IN STD_LOGIC_VECTOR(7 downto 0);	
		LATCH_LOC_4		=> LATCH_LOC_4,		--: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_5		=> LATCH_LOC_5,		--: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_6		=> LATCH_LOC_6,		--: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_7		=> LATCH_LOC_7,		--: IN STD_LOGIC_VECTOR(7 downto 0);	
		
		FEMB_TST_MODE	=> FEMB_TST_MODE,
		WFM_GEN_ADDR	=> WFM_GEN_ADDR,	
		WFM_GEN_DATA	=> WFM_GEN_DATA(23 downto 0),			

		OUT_of_SYNC		=> OUT_of_SYNC,
		
		
		ADC_Data_LATCH		=> ADC_Data_LATCH,
		ADC_Data		   	=> ADC_Data,
		ADC_header			=> ADC_header,
		WIB_MODE				=> WIB_MODE,
		
		UDP_TST_LATCH	=> UDP_TST_LATCH,
		UDP_TST_DATA	=> UDP_TST_DATA
	);	
	
	
	
	
	
	
SBND_TS_AND_ADC_ERR_inst : entity work.SBND_TS_AND_ADC_ERR

	PORT MAP 
	(
		SYS_RST     	=> reset,			-- SYSTEM RESET
		clk    		 	=> clk_100Mhz,		
		SW_TS_RESET    =>	TIME_STMP_RST,	-- TIME STAMP RESET FROM REGISTERS
		SYNC_TS_RST	  	=>	SW_TS_RESET,	-- TIME STAMP RESET FROM SYNC_CMD
		CONV_CLOCK    	=>	TP_SYNC,			-- CONVERT SIGNAL
		ADC_BUSY			=>	ADC_BUSY,			-- ADC BUSY  verify ADC convert took place		
		ADC_ERROR		=> ADC_ERROR,
		TIMESTAMP		=> TIMESTAMP

	);
	


SBND_PKT_INST :	entity work.SBND_PKT
	PORT MAP
	(
		SYS_RST     	=> reset,
		CLK_SYS	    	=> clk_100Mhz,
		WRITE_ENABLE	=> ADC_DATA_EN,
		START_BIT_MODE	=> START_BIT_MODE,
		ADC_Data_LATCH => ADC_Data_LATCH,
		
		ADC_Data		   => ADC_Data,
		ADC_header		=> ADC_header,
		TIMESTAMP		=> TIMESTAMP,
		ADC_ERROR		=> ADC_ERROR,
		RESERVED			=> USER_DATA,	
		DATA_VALID		=>	DATA_VALID,		
		DATA_PKT			=> DATA_PKT
	);

	
SBND_HSTX_INST : entity work.SBND_HSTX
	PORT MAP
	(
		GXB_TX_A			=> ProtoDUNE_TX,
		rst				=> reset,
		tx_pll_areset	=> tx_pll_areset,
		tx_digitalrst	=> tx_digitalrst,
		cal_clk_125MHz	=> clk_125Mhz,
		gxb_clk			=> CLK_125MHz_OSC,
		Stream_EN		=> Stream_EN,
		PRBS_EN			=> PRBS_EN,
		CNT_EN			=>	CNT_EN,
		DATA_CLK			=> clk_100Mhz,
		DATA_VALID		=>	DATA_VALID,		
		START_BIT_MODE	=> START_BIT_MODE,
		DATA_PKT			=> DATA_PKT
	);	
	
	
	
 ProtoDUNE_ASIC_CNTRL_inst :	entity work.ProtoDUNE_ASIC_CNTRL
	PORT MAP
	(

		sys_rst     	=> SYS_RESET ,	
		clk_sys   		=> clk_100Mhz,
		
		ADC_ASIC_RESET	=>	ADC_RESET,
		FE_ASIC_RESET	=>	FE_RESET,
		WRITE_SPI		=> WRITE_ADC_ASIC_SPI,
		ASIC_DAC_CNTL	=> ASIC_DAC_CNTL,
		
		DPM_WREN		 	=> ProtoDUNE_SPI_DPM_WREN,
		DPM_ADDR		 	=> ProtoDUNE_SPI_DPM_ADDR,
		DPM_D			 	=> ProtoDUNE_SPI_DPM_D,
		DPM_Q				=> ProtoDUNE_SPI_DPM_Q,

		ASIC_CS			=> ASIC_CS,
		ASIC_CK			=> ASIC_CK,
		ASIC_SDI			=> ASIC_SDI,	
		ASIC_SDO			=> ASIC_SDO,
		FE_RST_L			=> FE_RST_L,
		FE_RST_R			=> FE_RST_R
			
	);

	
SBND_PWM_CLK_DECODER_inst : entity work.SBND_PWM_CLK_DECODER
	PORT MAP
	(		RESET				=> SYS_RESET,
			CLK_100MHz		=> clk_100Mhz,
			SBND_SYNC_CMD	=> ProtoDUNE_CMD,
			CMD1				=> TP_EXT_GEN,
			CMD2				=> TIME_STMP_RST,
			CMD3				=> STOP_DATA,
			CMD4				=> START_DATA											
	);

	
	
	
	 SBND_SYNC_START_STOP_inst : entity work.SBND_SYNC_START_STOP
	PORT MAP
	(
		sys_rst     		=> SYS_RESET,
		clk_sys	    		=> clk_100Mhz,
		STOP_DATA			=> STOP_DATA,
		START_DATA			=> START_DATA,	
		ADC_DISABLE_REG	=> ADC_DISABLE_REG,
		ADC_RD_DISABLE		=> ADC_RD_DISABLE
	);
	
	


SBND_TST_PULSE_inst : entity work.SBND_TST_PULSE 
	PORT MAP 
	(
		sys_rst 				=> SYS_RESET,	
		clk_50Mhz			=> clk_50Mhz,
		FPGA_TP_EN			=> FPGA_TP_EN,
		ASIC_TP_EN			=> ASIC_TP_EN,			
		INT_TP_EN			=> INT_TP_EN,
		EXT_TP_EN			=> EXT_TP_EN,
		TP_EXT_GEN			=> TP_EXT_GEN,
		
		LA_SYNC		 		=> TP_SYNC,	
		TP_AMPL				=> TP_AMPL,
		TP_DLY				=>	x"00" & TP_DLY,
		TP_FREQ				=> TP_FREQ,	 
		DAC_CNTL				=> DAC_CNTL,
		ASIC_DAC_CNTL		=> ASIC_DAC_CNTL
	);

	

	MISC_IO(0)	<= '0';	
	MISC_IO(2)	<= '0';
	MISC_IO(4)	<= '0';
	MISC_IO(6)	<= '0';


	MISC_IO(1)	<= '0';	
	MISC_IO(3)	<= '0';	
	MISC_IO(5)	<= '0';	
	MISC_IO(7)	<= '0';	
		
	
udp_io_inst1 : entity work.udp_io
PORT MAP(	SPF_OUT 				=> SFP_RX,
				SFP_IN 				=> SFP_TX,
				reset 				=> reset,
				start 				=> start,
				BRD_IP				=> x"C0A87964",
				BRD_MAC				=> x"AABBCCDDEE64",
				clk_125MHz 			=> CLK_125M_spare,
				gxb_cal_blk_clk	=> CLK_125MHz,
				config_clk_40MHz 	=> clk_50MHz,
				clk_io 				=> clk_100Mhz,
				FRAME_SIZE			=> x"1f8",
				tx_fifo_clk 		=> clk_100MHz,
				tx_fifo_wr 			=> UDP_TST_LATCH,
				tx_fifo_in 			=> UDP_TST_DATA,
				tx_fifo_used		=> open,
				header_user_info 	=> (others => '0'),
				rdout 				=> UDP_data_out,
				system_status 		=> x"00001000",
				TIME_OUT_wait 		=> x"00005000",
				wr_strb 				=> UDP_WR,
				rd_strb 				=> open,
				WR_address 			=> UDP_WR_address,
				RD_address 			=> UDP_RD_address,
				data 					=> UDP_data,
				LED					=> open);

				
				
				
ProtoDUNE_ADC_CLK_TOP_INST : ENTITY WORK.ProtoDUNE_ADC_CLK_TOP

	PORT MAP
	(
		sys_rst     	=> SYS_RESET,
		clk    		 	=> clk_100Mhz,
		ADC_CONV			=> ProtoDUNE_CMD,
		
		PHASE_CONTROL_L =>PHASE_CONTROL_L,
		PHASE_CONTROL_R =>PHASE_CONTROL_R,
		CLK_DIS			=> PERIOD(0),	
		INV_RST	 		=> INV_RST,    
		OFST_RST			=> OFST_RST, 	  	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		WDTH_RST			=> WDTH_RST,		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)

		INV_READ 		=> INV_READ,
		OFST_READ	 	=> OFST_READ,		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		WDTH_READ	 	=> WDTH_READ,		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)

		INV_IDXM		 	=> INV_IDXM,
		OFST_IDXM		=> OFST_IDXM,		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		WDTH_IDXM	 	=> WDTH_IDXM,		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)

		INV_IDXL		 	=> INV_IDXL,
		OFST_IDXL	 	=> OFST_IDXL,		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		WDTH_IDXL	 	=> WDTH_IDXL,		--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		
	
		INV_IDL		 	=> INV_IDL,
		OFST_IDL_f1	 	=> OFST_IDL_f1,	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		WDTH_IDL_f1	 	=> WDTH_IDL_f1,	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		OFST_IDL_f2	 	=> OFST_IDL_f2,	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)
		WDTH_IDL_f2	 	=> WDTH_IDL_f2,	--LEFT SIDE(31..15)  RIGHT SIDE(15..0)


		ADC_RST_L		=> ADC_eclk_RST_L,
		ADC_IDXM_L		=> ADC_eclk_IDXM_L,
		ADC_IDL_L		=> ADC_eclk_IDL_L,
		ADC_READ_L		=> ADC_eclk_READ_L,
		ADC_IDXL_L		=> ADC_eclk_IDXL_L,
		
		ADC_RST_R		=> ADC_eclk_RST_R,
		ADC_IDXM_R		=> ADC_eclk_IDXM_R,
		ADC_IDL_R		=> ADC_eclk_IDL_R,
		ADC_READ_R		=> ADC_eclk_READ_R,
		ADC_IDXL_R		=> ADC_eclk_IDXL_R	

	);


	
	
end ProtoDUNE_FEMB_FPGA_arch;
