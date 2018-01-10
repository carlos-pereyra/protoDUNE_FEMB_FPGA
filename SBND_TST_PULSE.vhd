--*********************************************************
--* FILE  : SBND_TST_PULE.VHD
--* Author: Jack Fried
--*
--* Last Modified: 12/08/2016
--*  
--* Description: SBND_TST_PULE
--*		 		               
--*
--*
--*
--*
--*
--*
--*********************************************************

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


--  Entity Declaration

ENTITY SBND_TST_PULSE IS

	PORT
	(
		sys_rst     	: IN STD_LOGIC;			
		clk_50Mhz    	: IN STD_LOGIC;				-- clock
		FPGA_TP_EN		: IN STD_LOGIC;		
		ASIC_TP_EN		: IN STD_LOGIC;					
		INT_TP_EN		: IN STD_LOGIC;
		EXT_TP_EN		: IN STD_LOGIC;
		TP_EXT_GEN		: IN STD_LOGIC;		
		LA_SYNC		 	: IN STD_LOGIC;
		TP_AMPL			: IN STD_LOGIC_VECTOR(5 downto 0);
		TP_DLY			: IN STD_LOGIC_VECTOR(15 downto 0);
		TP_FREQ			: IN STD_LOGIC_VECTOR(15 downto 0);
		DAC_CNTL			: OUT STD_LOGIC_VECTOR(6 downto 0);
		ASIC_DAC_CNTL	: OUT STD_LOGIC
	);
	

	END SBND_TST_PULSE;

ARCHITECTURE behavior OF SBND_TST_PULSE IS


 signal TP_FRQ_CNT		: STD_LOGIC_VECTOR(15 downto 0);
 signal TP_DLY_CNT		: STD_LOGIC_VECTOR(15 downto 0);
 signal TP_EN				: STD_LOGIC;
 signal LA_SYNC_event	: STD_LOGIC;
 signal LA_SYNC_D1		: STD_LOGIC;
 signal LA_SYNC_D2		: STD_LOGIC;
 signal ADC_CAL_CMD_S1	: STD_LOGIC;
 signal ADC_CAL_CMD_S2	: STD_LOGIC;
 signal LATCH_PUL_WIDTH	: STD_LOGIC;
 signal WIDTH_CNT			: STD_LOGIC_VECTOR(7 downto 0);
 signal pul_WIDTH 		: STD_LOGIC_VECTOR(7 downto 0);
 signal GEN_EXT_PUL 		: STD_LOGIC;
 signal CNT_EN 			: STD_LOGIC;
 SIGNAL TP_EXT_GEN_S1	: STD_LOGIC;
 SIGNAL TP_EXT_GEN_S2	: STD_LOGIC;
 
begin


		DAC_CNTL  		<= '1' & TP_AMPL when (TP_EN = '0') and (FPGA_TP_EN = '1') else
								b"1000000";		
		
		ASIC_DAC_CNTL	<= '1' when (TP_EN = '0') and (ASIC_TP_EN = '1') else 
								'0';
	
 process(clk_50Mhz,sys_rst) 
begin
	if clk_50Mhz'event and clk_50Mhz = '1' then
		LA_SYNC_D1		<= LA_SYNC;
		LA_SYNC_D2		<= LA_SYNC_D1;
		TP_EXT_GEN_S1	<= TP_EXT_GEN;
		TP_EXT_GEN_S2 	<= TP_EXT_GEN_S1;				
	end if;
end process;

			

 process(clk_50Mhz,sys_rst) 
begin
	if  (sys_rst = '1') then
		TP_FRQ_CNT		<= x"0000";
		LA_SYNC_event	<= '0';
		TP_EN				<= '0';
		TP_DLY_CNT  	<=  x"0000";
		GEN_EXT_PUL 	<= '0';
	elsif clk_50Mhz'event and clk_50Mhz = '1' then
		if(TP_EXT_GEN_S1 = '1') and (TP_EXT_GEN_S2 = '0') and (EXT_TP_EN = '1') then
				GEN_EXT_PUL <= '1';
		end if;	
		if( LA_SYNC_D1 = '1' and LA_SYNC_D2 = '0') then
			TP_FRQ_CNT	<= TP_FRQ_CNT + 1;
		end if;	
		if(TP_FRQ_CNT >= TP_FREQ) and (INT_TP_EN = '1') then
			TP_FRQ_CNT		<= x"0000";
			LA_SYNC_event	<= '1';
		end if;
		
		if(LA_SYNC_event = '1') or (GEN_EXT_PUL = '1') then
				TP_DLY_CNT  <=  TP_DLY_CNT + 1;
				if(TP_DLY_CNT = TP_DLY) then
					TP_EN			<= '1';
				end if;
				if(TP_DLY_CNT = (TP_DLY + 1000))  then  -- 500
					TP_EN			<= '0';
					TP_DLY_CNT  <=  x"0000";	
					LA_SYNC_event	<= '0';
					GEN_EXT_PUL 	<= '0';
				end if;					
		end if;	
	end if;
end process;






END behavior;

	
	