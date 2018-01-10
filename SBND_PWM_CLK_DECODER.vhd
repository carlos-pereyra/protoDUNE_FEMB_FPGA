
--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: SBND_PWM_CLK_DECODER.VHD            
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created: 10/21/2016 
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


entity SBND_PWM_CLK_DECODER is
	PORT
	(
	
			RESET				: IN STD_LOGIC;	
			CLK_100MHz		: IN STD_LOGIC;
			SBND_SYNC_CMD	: IN STD_LOGIC;
			
			CMD1				: OUT STD_LOGIC; -- CALIB
			CMD2				: OUT STD_LOGIC; -- TIMESTAMP RESET
			CMD3				: OUT STD_LOGIC; -- START
			CMD4				: OUT STD_LOGIC -- STOP
												
	);
end SBND_PWM_CLK_DECODER;



architecture SBND_PWM_CLK_DECODER_arch of SBND_PWM_CLK_DECODER is


	SIGNAL	WORD_CNT			: integer range 127 downto 0;	
	SIGNAL	LAST_CNT			: integer range 127 downto 0;	
	SIGNAL	Current_CNT		: integer range 127 downto 0;		

	SIGNAL	CMD_IN_S1		: std_logic;
	SIGNAL	CMD_IN_S2		: std_logic;
	
begin
	
	
  process(CLK_100MHz	,RESET) 
  begin		
		if(RESET = '1' ) then
			WORD_CNT			<=  0;
			LAST_CNT 		<= 0;
			Current_CNT		<= 0;
		elsif (CLK_100MHz'event AND CLK_100MHz	 = '1') then
			WORD_CNT		<= WORD_CNT + 1;
			CMD_IN_S1	<= SBND_SYNC_CMD;
			CMD_IN_S2	<= CMD_IN_S1;
			if(CMD_IN_S1 = '1' and CMD_IN_S2 = '0') then
				WORD_CNT	<=  1;
			end if;
			if(CMD_IN_S1 = '0' and CMD_IN_S2 = '1') then
				LAST_CNT 	<= Current_CNT;
				Current_CNT	<= WORD_CNT;
			end if;
	  end if;
end process;


	CMD1	<= '1' when (LAST_CNT = 20 and Current_CNT	= 30)  else '0';
	CMD2	<= '1' when (LAST_CNT = 15 and Current_CNT	= 35) else '0';
	CMD3	<= '1' when (LAST_CNT = 10 and Current_CNT	= 40) else '0';
	CMD4	<= '1' when (LAST_CNT = 5  and Current_CNT	= 45) else '0';
	

end SBND_PWM_CLK_DECODER_arch;


