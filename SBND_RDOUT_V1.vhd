--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: SBND_RDOUT_V1.VHD          
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created:  10/01/2014
--////  Modified: 06/29/2016
--////  Description:  LBNE_ASIC_RDOUT
--////					
--////
--/////////////////////////////////////////////////////////////////////
--////
--//// Copyright (C) 2016 Brookhaven National Laboratory
--////
--/////////////////////////////////////////////////////////////////////

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE work.SbndPkg.all;

--  Entity Declaration

ENTITY SBND_RDOUT_V1 IS

	PORT
	(
		sys_rst     	: IN STD_LOGIC;				-- reset		
		clk_200Mhz    	: IN STD_LOGIC;				-- ADC clock
		clk_sys	    	: IN STD_LOGIC;				-- system clock 
	
		ADC_SYNC_MODE	: IN STD_LOGIC;				-- 0  use internal 2MHZ  clock  1 use external ADC_CON
		EXT_ADC_CONV	: IN STD_LOGIC;				
		
		ADC_CONV			: OUT STD_LOGIC_VECTOR(7 downto 0);	-- LVDS		USE TO BE ADC_RCK_L	
		TP_SYNC			: OUT STD_LOGIC;			
		ADC_RD_DISABLE	: IN STD_LOGIC;
		
		ADC_FD_0			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_1			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_2			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_3			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS		
		ADC_FD_4			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_5			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_6			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_FD_7			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS			
		
		ADC_FF			: IN  STD_LOGIC_VECTOR(7 downto 0);  -- LVDS	  -- NOT USED
		ADC_BUSY			: IN  STD_LOGIC_VECTOR(7 downto 0);  -- LVDS	
		ADC_CLK			: OUT STD_LOGIC_VECTOR(7 downto 0);  -- LVDS					
		
		
		CLK_select		: IN STD_LOGIC_VECTOR(7 downto 0); 		
		CHP_select		: IN STD_LOGIC_VECTOR(7 downto 0); 	
		CHN_select		: IN STD_LOGIC_VECTOR(7 downto 0); 
		
		TST_PATT_EN		: IN STD_LOGIC_VECTOR(7 downto 0); 
		TST_PATT			: IN STD_LOGIC_VECTOR(11 downto 0);
		
		LATCH_LOC_0		: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_1		: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_2		: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_3		: IN STD_LOGIC_VECTOR(7 downto 0); 
		LATCH_LOC_4		: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_5		: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_6		: IN STD_LOGIC_VECTOR(7 downto 0);
		LATCH_LOC_7		: IN STD_LOGIC_VECTOR(7 downto 0);
		

		FEMB_TST_MODE	: IN STD_LOGIC;
		WFM_GEN_ADDR	: OUT STD_LOGIC_VECTOR(7 downto 0);
		WFM_GEN_DATA	: IN STD_LOGIC_VECTOR(23 downto 0);

		
		OUT_of_SYNC	 	: OUT STD_LOGIC_VECTOR(15 downto 0);				
		
		ADC_Data_LATCH : OUT STD_LOGIC_VECTOR(7 downto 0);
		ADC_Data		   : OUT ADC_array(0 to 7);		
		ADC_header		: OUT SL_ARRAY_7_TO_0(0 to 7);	
		
		WIB_MODE			: IN STD_LOGIC;
		UDP_TST_LATCH	: OUT STD_LOGIC;		
		UDP_TST_DATA	: OUT STD_LOGIC_VECTOR(15 downto 0)
		
	);
	
	END SBND_RDOUT_V1;

ARCHITECTURE behavior OF SBND_RDOUT_V1 IS

 

	SIGNAL 	CLK_select_s	: STD_LOGIC_VECTOR(7 downto 0); 		
	SIGNAL 	CHP_select_s	: STD_LOGIC_VECTOR(7 downto 0); 	
	
	SIGNAL	ADC_SYNC_I		: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL	ADC_SYNC_CLK	: STD_LOGIC;
	
	SIGNAL	ADC_IN			: SL_ARRAY_1_TO_0(0 to 7);
	SIGNAL	LATCH_LOC		: SL_ARRAY_7_TO_0(0 to 7);
	SIGNAL	ADC_header_I	: SL_ARRAY_7_TO_0(0 to 7);
	SIGNAL	UDP_DATA			: SL_ARRAY_15_TO_0(0 to 7);
	SIGNAL	UDP_LATCH		: STD_LOGIC_VECTOR(7 downto 0);
   SIGNAL 	BIT_CNT	 		: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL	ADC_CONV_I		: STD_LOGIC;
	SIGNAL	WFM_ADDR			: STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL	ADC_CONV_DLY	: STD_LOGIC;
	
begin

			 ADC_IN(0)	<= ADC_FD_0;
			 ADC_IN(1)	<= ADC_FD_1;
			 ADC_IN(2)	<= ADC_FD_2;
			 ADC_IN(3)	<= ADC_FD_3;
			 ADC_IN(4)	<= ADC_FD_4;
			 ADC_IN(5)	<= ADC_FD_5;
			 ADC_IN(6)	<= ADC_FD_6;
			 ADC_IN(7)	<= ADC_FD_7;
					
			 LATCH_LOC(0)	<= LATCH_LOC_0;
			 LATCH_LOC(1)	<= LATCH_LOC_1;
			 LATCH_LOC(2)	<= LATCH_LOC_2;
			 LATCH_LOC(3)	<= LATCH_LOC_3;
			 LATCH_LOC(4)	<= LATCH_LOC_4;
			 LATCH_LOC(5)	<= LATCH_LOC_5;
			 LATCH_LOC(6)	<= LATCH_LOC_6;
			 LATCH_LOC(7)	<= LATCH_LOC_7;
			 
			 ADC_header		<= ADC_header_I;
			 
			  process(clk_sys) 	
			  begin
				if (clk_sys'event AND clk_sys = '1') then		
						CLK_select_s	<= CLK_select;
						CHP_select_s	<= CHP_select;
				end if;
			end process;	


					
		
			ADC_SYNC_CLK	<= clk_200Mhz;
			ADC_CLK(0)		<= ADC_SYNC_CLK when (CLK_select_s(0) = '0') else not ADC_SYNC_CLK ;		
			ADC_CLK(1)		<= ADC_SYNC_CLK when (CLK_select_s(1) = '0') else not ADC_SYNC_CLK ;	
			ADC_CLK(2)		<= ADC_SYNC_CLK when (CLK_select_s(2) = '0') else not ADC_SYNC_CLK ;		
			ADC_CLK(3)		<= ADC_SYNC_CLK when (CLK_select_s(3) = '0') else not ADC_SYNC_CLK ;		
			ADC_CLK(4)		<= ADC_SYNC_CLK when (CLK_select_s(4) = '0') else not ADC_SYNC_CLK ;			
			ADC_CLK(5)		<= ADC_SYNC_CLK when (CLK_select_s(5) = '0') else not ADC_SYNC_CLK ;	
			ADC_CLK(6)		<= ADC_SYNC_CLK when (CLK_select_s(6) = '0') else not ADC_SYNC_CLK ;		
			ADC_CLK(7)		<= ADC_SYNC_CLK when (CLK_select_s(7) = '0') else not ADC_SYNC_CLK ;					
			
	
			UDP_TST_DATA <=   UDP_DATA(0) when (CHP_select_s = x"0") else
									UDP_DATA(1) when (CHP_select_s = x"1") else
									UDP_DATA(2) when (CHP_select_s = x"2") else
									UDP_DATA(3) when (CHP_select_s = x"3") else																
									UDP_DATA(4) when (CHP_select_s = x"4") else
									UDP_DATA(5) when (CHP_select_s = x"5") else
									UDP_DATA(6) when (CHP_select_s = x"6") else
									UDP_DATA(7) when (CHP_select_s = x"7") else
									x"0000";

								
			UDP_TST_LATCH <=  UDP_LATCH(0) when (CHP_select_s = x"0") else
									UDP_LATCH(1) when (CHP_select_s = x"1") else
									UDP_LATCH(2) when (CHP_select_s = x"2") else
									UDP_LATCH(3) when (CHP_select_s = x"3") else
									UDP_LATCH(4) when (CHP_select_s = x"4") else
									UDP_LATCH(5) when (CHP_select_s = x"5") else
									UDP_LATCH(6) when (CHP_select_s = x"6") else
									UDP_LATCH(7) when (CHP_select_s = x"7") else
									'0';
									
		
		
			OUT_of_SYNC(0)		<=  '0' when (ADC_header_I(0)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(1)		<=  '0' when (ADC_header_I(0)(6 downto 4) = b"010") else '1';
			OUT_of_SYNC(2)		<=  '0' when (ADC_header_I(1)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(3)		<=  '0' when (ADC_header_I(1)(6 downto 4) = b"010") else '1';
			OUT_of_SYNC(4)		<=  '0' when (ADC_header_I(2)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(5)		<=  '0' when (ADC_header_I(2)(6 downto 4) = b"010") else '1';
			OUT_of_SYNC(6)		<=  '0' when (ADC_header_I(3)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(7)		<=  '0' when (ADC_header_I(3)(6 downto 4) = b"010") else '1';
			OUT_of_SYNC(8)		<=  '0' when (ADC_header_I(4)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(9)		<=  '0' when (ADC_header_I(4)(6 downto 4) = b"010") else '1';
			OUT_of_SYNC(10)	<=  '0' when (ADC_header_I(5)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(11)	<=  '0' when (ADC_header_I(5)(6 downto 4) = b"010") else '1';
			OUT_of_SYNC(12)	<=  '0' when (ADC_header_I(6)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(13)	<=  '0' when (ADC_header_I(6)(6 downto 4) = b"010") else '1';
			OUT_of_SYNC(14)	<=  '0' when (ADC_header_I(7)(2 downto 0) = b"010") else '1';
			OUT_of_SYNC(15)	<=  '0' when (ADC_header_I(7)(6 downto 4) = b"010") else '1';

	
		
CHK: for i in 0 to 7  generate 

SBND_ASIC_RDOUT_V2 : entity work.SBND_ASIC_RDOUT_V2
	PORT MAP
	(
			clk_200Mhz		=> clk_200Mhz,
			clk_sys			=> clk_sys,	
			sys_rst 			=> sys_rst or ADC_RD_DISABLE,
			FEMB_TST_MODE	=> FEMB_TST_MODE,
			WIB_MODE			=> WIB_MODE,
			WFM_GEN_DATA	=> WFM_GEN_DATA,
			ADC_FD			=> ADC_IN(i),
			ADC_BUSY			=> ADC_BUSY(i),
			CHN_select		=> CHN_select,	
			LATCH_LOC		=> LATCH_LOC(i),							
			ADC_TST_PATT_EN=> TST_PATT_EN(i),
			ADC_TST_PATT	=> TST_PATT,
			ADC_header_out =>	ADC_header_I(i),			
			ADC_CONV			=> ADC_CONV_I ,	
			UDP_DATA_LATCH => UDP_LATCH(i),
			UDP_DATA_OUT 	=> UDP_DATA(i),
			ADC_Data_LATCH => ADC_Data_LATCH(i),
			ADC_Data			=>	ADC_Data(i)
	);
	 
end generate;



  process(clk_200Mhz,sys_rst) 
  begin
	 if (sys_rst = '1') then
		ADC_CONV_I	<= '0';
		BIT_CNT		<= x"00";
     elsif (clk_200Mhz'event AND clk_200Mhz = '1') then
 
 		if( ADC_SYNC_MODE = '0' ) then 
			BIT_CNT		<= BIT_CNT + 1;		
			if (BIT_CNT >= x"30") then
				ADC_CONV_I		<= '0';
			else
				ADC_CONV_I		<= '1';
			end if;
			if (BIT_CNT >= x"63")  then  
					BIT_CNT		<= x"00";
			end if;
		else
			ADC_CONV_I <=	EXT_ADC_CONV;
		end if;	
	 end if;
end process;





			ADC_CONV(0)	<=    ADC_CONV_I;				
			ADC_CONV(1)	<=    ADC_CONV_I;				
			ADC_CONV(2)	<=    ADC_CONV_I;				
			ADC_CONV(3)	<=    ADC_CONV_I;				
			ADC_CONV(4)	<=    ADC_CONV_I;				
			ADC_CONV(5)	<=    ADC_CONV_I;			
			ADC_CONV(6)	<=    ADC_CONV_I;		
			ADC_CONV(7)	<=    ADC_CONV_I;		
					
			TP_SYNC		<=		ADC_CONV_I;	
	 
	

process(clk_sys) 
  begin
	if (clk_sys'event AND clk_sys = '1') then
		ADC_CONV_DLY <= ADC_CONV_I ;
		WFM_GEN_ADDR <= WFM_ADDR;
		if(ADC_CONV_I = '0' and ADC_CONV_DLY = '1') then
			WFM_ADDR	<= WFM_ADDR + 1;
		end if;
	end if;
end process;	 
	 
	 
	 
END behavior;

	
	