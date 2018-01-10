--*********************************************************
--* FILE  : ProtoDUNE_clk_gen.VHD
--* Author: Jack Fried
--*
--* Last Modified: 03/07/2017
--*  
--* Description: ProtoDUNE_clk_gen
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

ENTITY ProtoDUNE_clk_gen IS

	PORT
	(
		sys_rst     	: IN STD_LOGIC;				-- clock
		clk    		 	: IN STD_LOGIC;				-- clock		
		ADC_CONV			: IN STD_LOGIC;
		CLK_DIS			: IN STD_LOGIC;	
		INV_CLK	 		: IN STD_LOGIC;							-- invert		
		OFST_CLK_f1	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- OFFSET
		WDTH_CLK_f1	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- WIDTH
		OFST_CLK_f2	 	: IN STD_LOGIC_VECTOR(15 downto 0) := x"ffff";  -- OFFSET
		WDTH_CLK_f2	 	: IN STD_LOGIC_VECTOR(15 downto 0) := x"ffff";  -- WIDTH
		CLK_OUT			: OUT STD_LOGIC
	
	);
END ProtoDUNE_clk_gen;

ARCHITECTURE behavior OF ProtoDUNE_clk_gen IS


 signal CLK_GEN			: STD_LOGIC;
 signal COUNTER	 		: STD_LOGIC_VECTOR(15 downto 0);
 signal t_count	 		: STD_LOGIC_VECTOR(15 downto 0);
 signal ADC_CONV_SYNC_1	: STD_LOGIC; 
 signal ADC_CONV_SYNC_2	: STD_LOGIC; 
begin

	
	CLK_OUT	<= CLK_GEN;
	
	
  process(clk,sys_rst) 
  begin

	 if (sys_rst = '1') then
		CLK_GEN		<= '0';			
		COUNTER			<= x"0000";
     elsif (clk'event AND clk = '1') then
	  ADC_CONV_SYNC_1	<= ADC_CONV;
	  ADC_CONV_SYNC_2	<= ADC_CONV_SYNC_1;	 
		if( COUNTER <= 2000) then
			COUNTER		<= COUNTER + 1;
		 end if;
		CLK_GEN		<= '0' xnor (not INV_CLK);
		if((COUNTER >= OFST_CLK_f1) AND (COUNTER < (OFST_CLK_f1 + WDTH_CLK_f1))) then
			CLK_GEN 	  	<= '1' xnor (not INV_CLK)	;
		end if; 	
		if((COUNTER >= OFST_CLK_f2) AND (COUNTER < (OFST_CLK_f2 + WDTH_CLK_f2))) then
			CLK_GEN 	  	<= '1' xnor (not INV_CLK)	;
		end if; 
	--if(COUNTER >= perIOD) then 	
		if(ADC_CONV_SYNC_1 = '1' and ADC_CONV_SYNC_2 = '0' AND CLK_DIS = '0') then
			COUNTER <= x"0000";
		end if;		
		
	
	 end if;
end process;
END behavior;

