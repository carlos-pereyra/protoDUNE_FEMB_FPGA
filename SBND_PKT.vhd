
--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: SBND_PKT.VHD            
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created: 06/30/2016 
--////  Description:  
--////					
--////
--/////////////////////////////////////////////////////////////////////
--////
--//// Copyright (C) 2016 Brookhaven National Laboratory
--////
--/////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.SbndPkg.all;


entity SBND_PKT is
	PORT
	(
		
		SYS_RST     	: IN STD_LOGIC;				-- reset		
		CLK_SYS	    	: IN STD_LOGIC;				-- system clock 		
		WRITE_ENABLE	: IN STD_LOGIC;
		ADC_Data_LATCH : IN STD_LOGIC_VECTOR(7 downto 0);
		START_BIT_MODE	: IN STD_LOGIC;		
		ADC_Data		   : IN ADC_array(0 to 7);		
		ADC_header		: IN SL_ARRAY_7_TO_0(0 to 7);			
		TIMESTAMP		: IN STD_LOGIC_VECTOR(15 downto 0);
		ADC_ERROR		: IN STD_LOGIC_VECTOR(15 downto 0);
		RESERVED			: IN STD_LOGIC_VECTOR(15 downto 0);
	
		DATA_VALID		: OUT STD_LOGIC_VECTOR(3 downto 0);				
		DATA_PKT			: OUT SL_ARRAY_16_TO_0(0 to 3)
			
	);
end SBND_PKT;


architecture SBND_PKT_arch of SBND_PKT is

SIGNAL D_VALID 		: STD_LOGIC;

begin





D_VALID		<= '0' when (ADC_Data_LATCH = x"00") else '1';


CHK: for i in 0 to 3  generate 
SBND_PKT_GEN_inst1 : entity work.SBND_PKT_GEN
	PORT MAP
	(
		SYS_RST     	=> SYS_RST,
		CLK_SYS	    	=> CLK_SYS,
		WRITE_ENABLE	=> WRITE_ENABLE,
		START_BIT_MODE	=> START_BIT_MODE,
		ADC_Data_LATCH => ADC_Data_LATCH(i*2),
		
		ADC_Data		   => ADC_Data(i*2 to (i*2+1)),
		ADC_header		=> ADC_header(i*2 to (i*2+1)),
		TIMESTAMP		=> TIMESTAMP,
		ADC_ERROR		=> ADC_ERROR,
		RESERVED			=> RESERVED,
		DATA_VALID		=> DATA_VALID(i),
		DATA_PKT			=> DATA_PKT(i)
	);
end generate;




end SBND_PKT_arch;
