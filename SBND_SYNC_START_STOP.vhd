--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: SBND_SYNC_START_STOP.VHD          
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created:  2/21/2017
--////  Description:  SBND_SYNC_START_STOP
--////					
--////
--/////////////////////////////////////////////////////////////////////
--////
--//// Copyright (C) 2017 Brookhaven National Laboratory
--////
--/////////////////////////////////////////////////////////////////////

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE work.SbndPkg.all;

--  Entity Declaration

ENTITY SBND_SYNC_START_STOP IS

	PORT
	(
		sys_rst     		: IN STD_LOGIC;				-- reset		
		clk_sys	    		: IN STD_LOGIC;				-- system clock 
		STOP_DATA			: IN STD_LOGIC;		-- FROM TIMING SYSTEM
		START_DATA			: IN STD_LOGIC;		-- FROM TIMING SYSTEM
		ADC_DISABLE_REG	: IN STD_LOGIC;
		ADC_RD_DISABLE		: OUT STD_LOGIC
	);
	
	END SBND_SYNC_START_STOP;

ARCHITECTURE behavior OF SBND_SYNC_START_STOP IS


	SIGNAL	REG_CNTRL_1 : STD_LOGIC;
	SIGNAL	REG_CNTRL_2 : STD_LOGIC;
		
begin

	process(clk_sys) 	
	begin
		if (clk_sys'event AND clk_sys = '1') then		
			REG_CNTRL_1		<= ADC_DISABLE_REG;
			REG_CNTRL_2 	<= REG_CNTRL_1;
		end if;
	end process;	

		 
	process(clk_sys) 	
	begin
		  if (sys_rst = '1') then		
				ADC_RD_DISABLE		<= '0';
		  elsif (clk_sys'event AND clk_sys = '1') then		
				if(STOP_DATA = '1') then
					ADC_RD_DISABLE		<= '1';
				end if;
				if(START_DATA = '1') then
					ADC_RD_DISABLE		<= '0';
				end if;
				if(REG_CNTRL_1 = '0' and REG_CNTRL_2 = '1') then
					ADC_RD_DISABLE		<= '1';
				end if;
				if(REG_CNTRL_1 = '1' and REG_CNTRL_2 = '0') then
					ADC_RD_DISABLE		<= '0';
				end if;
			end if;
	end process;	


	 
END behavior;

	
	