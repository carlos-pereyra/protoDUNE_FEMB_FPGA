
--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: LBNE_HSTX.VHD            
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created: 11/04/2014 
--////  Description:  
--////					
--////
--/////////////////////////////////////////////////////////////////////
--////
--//// Copyright (C) 2014 Brookhaven National Laboratory
--////
--/////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.SbndPkg.all;

entity LBNE_HSTX is
	PORT
	(

		GXB_TX_A			: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		rst				: IN STD_LOGIC;
		tx_pll_areset	: IN STD_LOGIC;
		tx_digitalrst	: IN STD_LOGIC;	
		cal_clk_125MHz	: IN STD_LOGIC;
		gxb_clk			: IN STD_LOGIC;			
		Stream_EN		: IN STD_LOGIC;	
		PRBS_EN			: IN STD_LOGIC;	
		CNT_EN			: IN STD_LOGIC;			
		DATA_CLK			: IN STD_LOGIC;	
		DATA_VALID		: IN STD_LOGIC_VECTOR(3 downto 0);				
		DATA_PKT			: IN SL_ARRAY_16_TO_0(0 to 3)		
	);
end LBNE_HSTX;


architecture LBNE_HSTX_arch of LBNE_HSTX is


component ALTGX_TX
	PORT
	(
		tx_dataout		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);	
		tx_datain		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);	
		tx_ctrlenable	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);	
		tx_digitalreset: IN STD_LOGIC_VECTOR (3 DOWNTO 0);		
		cal_blk_clk		: IN STD_LOGIC;
		pll_inclk		: IN STD_LOGIC;
		pll_locked		: OUT STD_LOGIC;
		pll_areset		: IN STD_LOGIC;
		tx_clkout		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
end component;



SIGNAL	FIFO_DATA				: SL_ARRAY_16_TO_0(0 to 3);	
SIGNAL	FIFO_DATA2				: SL_ARRAY_15_TO_0(0 to 3);	

SIGNAL	FIFO_SOF					: STD_LOGIC_VECTOR (3 DOWNTO 0);

SIGNAL	DATA_OUT					: SL_ARRAY_15_TO_0(0 to 3);	
SIGNAL	ctrlenable				: SL_ARRAY_1_TO_0(0 to 3);	


SIGNAL	DATA_OUT1					: SL_ARRAY_15_TO_0(0 to 3);	
SIGNAL	ctrlenable1				: SL_ARRAY_1_TO_0(0 to 3);	
SIGNAL	DATA_OUT2					: SL_ARRAY_15_TO_0(0 to 3);	
SIGNAL	ctrlenable2				: SL_ARRAY_1_TO_0(0 to 3);	
SIGNAL	DATA_OUT3					: SL_ARRAY_15_TO_0(0 to 3);	
SIGNAL	ctrlenable3				: SL_ARRAY_1_TO_0(0 to 3);	
SIGNAL	DATA_OUT4					: SL_ARRAY_15_TO_0(0 to 3);	
SIGNAL	ctrlenable4				: SL_ARRAY_1_TO_0(0 to 3);	


SIGNAL	GXB_D_OUT			: STD_LOGIC_VECTOR (63 DOWNTO 0);
SIGNAL	CNTL_EN				: STD_LOGIC_VECTOR (7 DOWNTO 0);



SIGNAL	tx_digitalreset	: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL	tx_clkout			: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL	counter				: STD_LOGIC_VECTOR (15 DOWNTO 0);
SIGNAL	prbs_data			: STD_LOGIC_VECTOR (15 DOWNTO 0);
SIGNAL	ADC_FIFO_EMPTY		: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL	ADC_FIFO_EMPTY_L1	: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL	ADC_FIFO_EMPTY_L2	: STD_LOGIC_VECTOR (3 DOWNTO 0);


begin


ALTGX_TX_inst2	: ALTGX_TX
	PORT MAP
	(
		tx_dataout			=> GXB_TX_A,	
		cal_blk_clk			=>	cal_clk_125MHz,
		pll_inclk			=> gxb_clk,
		tx_ctrlenable		=> CNTL_EN,	 	
		tx_datain			=> GXB_D_OUT,	
		tx_digitalreset	=>	tx_digitalreset,
		pll_areset			=> tx_pll_areset,
		tx_clkout			=>	tx_clkout,
		pll_locked			=> open
		
	);




	
	tx_digitalreset	<= x"0" when (tx_digitalrst = '0') else x"f";
	
	
	
	ctrlenable1(0)	<= b"11"	when (Stream_EN 	= '0') else
							b"00"		when (CNT_EN 	= '1') or (PRBS_EN 	= '1') else
							b"11"    when (FIFO_SOF(0)	 = '1') else
							b"00"		when (ADC_FIFO_EMPTY(0) = '0') else							
							b"11";
	ctrlenable1(1)	<= b"11"		when (Stream_EN 	= '0') else
							b"00"		when (CNT_EN 	= '1') or (PRBS_EN 	= '1') else
							b"11"    when (FIFO_SOF(1)	 = '1') else
							b"00"		when (ADC_FIFO_EMPTY(1) = '0') else							
							b"11";
	ctrlenable1(2)	<= b"11"		when (Stream_EN 	= '0') else
							b"00"		when (CNT_EN 	= '1') or (PRBS_EN 	= '1') else
							b"11"    when (FIFO_SOF(2)	 = '1') else
							b"00"		when (ADC_FIFO_EMPTY(2) = '0') else							
							b"11";
	ctrlenable1(3)	<= b"11"		when (Stream_EN 	= '0') else
							b"00"		when (CNT_EN 	= '1') or (PRBS_EN 	= '1') else
							b"11"    when (FIFO_SOF(3)	 = '1') else
							b"00"		when (ADC_FIFO_EMPTY(3) = '0') else							
							b"11";							
														
														
														
	DATA_OUT1(0)	<=	x"BCFB"			when (Stream_EN 	= '0') else
						counter			when (CNT_EN 	= '1') else
						prbs_data		when (PRBS_EN 	= '1') else
						FIFO_DATA2(0)  when (ADC_FIFO_EMPTY(0) = '0') else
						x"BCFB";

	DATA_OUT1(1)	<=	x"BCFB"			when (Stream_EN 	= '0') else
						counter			when (CNT_EN 	= '1') else
						prbs_data		when (PRBS_EN 	= '1') else
						FIFO_DATA2(1)  when (ADC_FIFO_EMPTY(1) = '0') else
						x"BCFB";
							
	DATA_OUT1(2)	<=	x"BCFB"			when (Stream_EN 	= '0') else
						counter			when (CNT_EN 	= '1') else
						prbs_data		when (PRBS_EN 	= '1') else
						FIFO_DATA2(2)  when (ADC_FIFO_EMPTY(2) = '0') else
						x"BCFB";		
							
	DATA_OUT1(3)	<=	x"BCFB"			when (Stream_EN 	= '0') else
						counter			when (CNT_EN 	= '1') else
						prbs_data		when (PRBS_EN 	= '1') else
						FIFO_DATA2(3)   when (ADC_FIFO_EMPTY(3) = '0') else
						x"BCFB";

	
CHK: for i in 0 to 3  generate 	

ADC_FIFO_inst2 : entity work.ADC_FIFO
	PORT MAP
	(
		data		=> DATA_PKT(i),
		wrclk		=>	DATA_CLK,
		wrreq		=> DATA_VALID(i) and Stream_EN,
		rdclk		=> tx_clkout(0),
		rdreq		=> not ADC_FIFO_EMPTY_L1(i),
		q			=> FIFO_DATA(i),
		rdempty	=> ADC_FIFO_EMPTY_L1(i)
	);		
	

end generate;



	process(tx_clkout(0)) 
	begin
		if tx_clkout(0)'event and tx_clkout(0) = '1' then	
			ADC_FIFO_EMPTY_L2	<= ADC_FIFO_EMPTY_L1;	
			ADC_FIFO_EMPTY 	<= ADC_FIFO_EMPTY_L2;	
			
			
			
			DATA_OUT2	<= DATA_OUT1;
			DATA_OUT3	<= DATA_OUT2;
			DATA_OUT4	<= DATA_OUT3;
			DATA_OUT		<= DATA_OUT4;
			
			
			ctrlenable2	<= ctrlenable1;
			ctrlenable3	<= ctrlenable2;
			ctrlenable4	<= ctrlenable3;			
			ctrlenable	<= ctrlenable4;
			
			
			GXB_D_OUT	<=  DATA_OUT(0)  & DATA_OUT(1)	& DATA_OUT(2)	 & DATA_OUT(3);
			CNTL_EN		<= ctrlenable(0) & ctrlenable(1) & ctrlenable(2) & ctrlenable(3);
			for i in 0 to 3 loop
				FIFO_DATA2(i)		<= FIFO_DATA(i)(15 downto 0);
				FIFO_SOF(i)			<= FIFO_DATA(i)(16);			
			end loop;
		end if;
	end process;	

	
	
	
	
process(tx_clkout(0),rst) 
begin
	if  (rst = '1') then
		counter 		<= (others => '0');
		prbs_data	<= (others => '0');
	elsif tx_clkout(0)'event and tx_clkout(0) = '1' then
			counter		<= counter + 1;
			prbs_data	<= PRBS_GEN(prbs_data);
	end if;
end process;
	
end LBNE_HSTX_arch;






