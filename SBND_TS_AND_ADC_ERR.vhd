--*********************************************************
--* FILE  : SBND_TIME___ADC_ERR.VHD
--* Author: Jack Fried
--*
--* Last Modified: 12/09/2016
--*  
--* Description: SBND TIME STAMP and ADC ERROR check
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

ENTITY SBND_TS_AND_ADC_ERR IS

	PORT
	(
		sys_rst     	: IN STD_LOGIC;		-- SYSTEM RESET
		clk    		 	: IN STD_LOGIC;		-- SYSTEM RESET
		SW_TS_RESET   	: IN STD_LOGIC;		-- TIME STAMP RESET FROM REGISTERS
		SYNC_TS_RST	  	: IN STD_LOGIC;		-- TIME STAMP RESET FROM SYNC_CMD
		CONV_CLOCK    	: IN STD_LOGIC;		-- SYNC CMD_ SIGNAL
		ADC_BUSY			: IN STD_LOGIC_VECTOR(7 downto 0);		-- ADC BUSY  verify ADC convert took place
		
		ADC_ERROR		: OUT STD_LOGIC_VECTOR(15 downto 0);
		TIMESTAMP		: OUT STD_LOGIC_VECTOR(15 downto 0)

	);
	

	END SBND_TS_AND_ADC_ERR;

ARCHITECTURE SBND_TS_AND_ADC_ERR_ARCH OF SBND_TS_AND_ADC_ERR IS


 SIGNAL TS_RESET			: STD_LOGIC;
 SIGNAL TS_CNT				: STD_LOGIC_VECTOR(15 downto 0);
 SIGNAL ADC0_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0);
 SIGNAL ADC1_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0);
 SIGNAL ADC2_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0);
 SIGNAL ADC3_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0);
 SIGNAL ADC4_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0); 
 SIGNAL ADC5_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0);
 SIGNAL ADC6_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0);
 SIGNAL ADC7_BSY_CNT		: STD_LOGIC_VECTOR(7 downto 0);
 SIGNAL ADC_ERROR_LTCH  : STD_LOGIC_VECTOR(7 downto 0);
 

 
 SIGNAL CONV_CLOCK_S1	: STD_LOGIC;
 SIGNAL CONV_CLOCK_S2	: STD_LOGIC;
 SIGNAL ADC0_BSY_S1		: STD_LOGIC;
 SIGNAL ADC0_BSY_S2		: STD_LOGIC;
 SIGNAL ADC1_BSY_S1		: STD_LOGIC;
 SIGNAL ADC1_BSY_S2		: STD_LOGIC;	
 SIGNAL ADC2_BSY_S1		: STD_LOGIC;
 SIGNAL ADC2_BSY_S2		: STD_LOGIC;	
 SIGNAL ADC3_BSY_S1		: STD_LOGIC;
 SIGNAL ADC3_BSY_S2		: STD_LOGIC;		
 SIGNAL ADC4_BSY_S1		: STD_LOGIC;
 SIGNAL ADC4_BSY_S2		: STD_LOGIC;		
 SIGNAL ADC5_BSY_S1		: STD_LOGIC;
 SIGNAL ADC5_BSY_S2		: STD_LOGIC;		
 SIGNAL ADC6_BSY_S1		: STD_LOGIC;
 SIGNAL ADC6_BSY_S2		: STD_LOGIC;		
 SIGNAL ADC7_BSY_S1		: STD_LOGIC;
 SIGNAL ADC7_BSY_S2		: STD_LOGIC; 
 
 
 
 
begin

	TS_RESET			<= sys_rst or SW_TS_RESET or SYNC_TS_RST;
	TIMESTAMP		<= TS_CNT;
	ADC_ERROR		<= x"00" & ADC_ERROR_LTCH;

	
process(clk) 
begin
	if clk'event and clk = '1' then

			CONV_CLOCK_S1	<= CONV_CLOCK;
			CONV_CLOCK_S2	<= CONV_CLOCK_S1;
			ADC0_BSY_S1		<= ADC_BUSY(0);
			ADC0_BSY_S2		<= ADC0_BSY_S1;
			ADC1_BSY_S1		<= ADC_BUSY(1);
			ADC1_BSY_S2		<= ADC1_BSY_S1;	
			ADC2_BSY_S1		<= ADC_BUSY(2);
			ADC2_BSY_S2		<= ADC2_BSY_S1;		
			ADC3_BSY_S1		<= ADC_BUSY(3);
			ADC3_BSY_S2		<= ADC3_BSY_S1;		
			ADC4_BSY_S1		<= ADC_BUSY(4);
			ADC4_BSY_S2		<= ADC4_BSY_S1;		
			ADC5_BSY_S1		<= ADC_BUSY(5);
			ADC5_BSY_S2		<= ADC5_BSY_S1;		
			ADC6_BSY_S1		<= ADC_BUSY(6);
			ADC6_BSY_S2		<= ADC6_BSY_S1;		
			ADC7_BSY_S1		<= ADC_BUSY(7);
			ADC7_BSY_S2		<= ADC7_BSY_S1;		
	
	end if;
end process;	
	

	
 process(clk,TS_RESET) 
begin
	if(TS_RESET = '1') then
		TS_CNT			<= x"0000";
		ADC0_BSY_CNT	<= x"00";
		ADC1_BSY_CNT	<= x"00";
		ADC2_BSY_CNT	<= x"00";
		ADC3_BSY_CNT	<= x"00";
		ADC4_BSY_CNT	<= x"00";
		ADC5_BSY_CNT	<= x"00";
		ADC6_BSY_CNT	<= x"00";
		ADC7_BSY_CNT	<= x"00";
		ADC_ERROR_LTCH		<= x"00";
	elsif clk'event and clk = '1' then
		if(CONV_CLOCK_S1 = '1' and CONV_CLOCK_S2 = '0') then
			TS_CNT	<= TS_CNT +1;
		end if;
		
		if(ADC0_BSY_S1 = '1' and ADC0_BSY_S2 = '0') then
			ADC0_BSY_CNT	<= ADC0_BSY_CNT +1;
		end if;		
		
		if(ADC1_BSY_S1 = '1' and ADC1_BSY_S2 = '0') then
			ADC1_BSY_CNT	<= ADC1_BSY_CNT +1;
		end if;			
		if(ADC2_BSY_S1 = '1' and ADC2_BSY_S2 = '0') then
			ADC2_BSY_CNT	<= ADC2_BSY_CNT +1;
		end if;			
		if(ADC3_BSY_S1 = '1' and ADC3_BSY_S2 = '0') then
			ADC3_BSY_CNT	<= ADC3_BSY_CNT +1;
		end if;			

		if(ADC4_BSY_S1 = '1' and ADC4_BSY_S2 = '0') then
			ADC4_BSY_CNT	<= ADC4_BSY_CNT +1;
		end if;	
		if(ADC5_BSY_S1 = '1' and ADC5_BSY_S2 = '0') then
			ADC5_BSY_CNT	<= ADC5_BSY_CNT +1;
		end if;	
		if(ADC6_BSY_S1 = '1' and ADC6_BSY_S2 = '0') then
			ADC6_BSY_CNT	<= ADC6_BSY_CNT +1;
		end if;	
		if(ADC7_BSY_S1 = '1' and ADC7_BSY_S2 = '0') then
			ADC7_BSY_CNT	<= ADC7_BSY_CNT +1;
		end if;			

		if(CONV_CLOCK_S1 = '0' and CONV_CLOCK_S2 = '1') then

			
			if(ADC0_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(0) <= '1'; 
			end if;
			if(ADC1_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(1) <= '1'; 
			end if;
			if(ADC2_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(2) <= '1'; 
			end if;
			if(ADC3_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(3) <= '1'; 
			end if;
			if(ADC4_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(4) <= '1'; 
			end if;
			if(ADC5_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(5) <= '1'; 
			end if;
			if(ADC6_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(6) <= '1';  
			end if;
			if(ADC7_BSY_CNT /= TS_CNT(7 downto 0)) then 
				ADC_ERROR_LTCH(7) <= '1'; 
			end if;		
		end if;
	end if;
end process;	
	
	
	
--	
--	
--	
-- process(CONV_CLOCK,TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		TS_CNT			<= x"0000";
--	elsif CONV_CLOCK'event and CONV_CLOCK = '1' then
--		TS_CNT	<= TS_CNT +1;
--	end if;
--end process;
--
--
-- process(CONV_CLOCK,TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC_ERROR_LTCH		<= x"00";
--	elsif CONV_CLOCK'event and CONV_CLOCK = '0' then
--
--		if(ADC0_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(0) <= '1'; 
--		end if;
--		if(ADC1_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(1) <= '1'; 
--		end if;
--		if(ADC2_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(2) <= '1'; 
--		end if;
--		if(ADC3_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(3) <= '1'; 
--		end if;
--		if(ADC4_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(4) <= '1'; 
--		end if;
--		if(ADC5_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(5) <= '1'; 
--		end if;
--		if(ADC6_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(6) <= '1';  
--		end if;
--		if(ADC7_BSY_CNT /= TS_CNT(7 downto 0)) then 
--			ADC_ERROR_LTCH(7) <= '1'; 
--		end if;		
--	
--	end if;
--end process;
--
--						
--					
-- process(ADC_BUSY(0),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC0_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(0)'event and ADC_BUSY(0) = '1' then
--		ADC0_BSY_CNT	<= ADC0_BSY_CNT +1;
--	end if;
--end process;
--
--			
-- process(ADC_BUSY(1),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC1_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(1)'event and ADC_BUSY(1) = '1' then
--		ADC1_BSY_CNT	<= ADC1_BSY_CNT +1;
--	end if;
--end process;
--
--			
-- process(ADC_BUSY(2),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC2_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(2)'event and ADC_BUSY(2) = '1' then
--		ADC2_BSY_CNT	<= ADC2_BSY_CNT +1;
--	end if;
--end process;
--
--			
-- process(ADC_BUSY(3),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC3_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(3)'event and ADC_BUSY(3) = '1' then
--		ADC3_BSY_CNT	<= ADC3_BSY_CNT +1;
--	end if;
--end process;
--
--			
-- process(ADC_BUSY(4),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC4_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(4)'event and ADC_BUSY(4) = '1' then
--		ADC4_BSY_CNT	<= ADC4_BSY_CNT +1;
--	end if;
--end process;
--
--			
-- process(ADC_BUSY(5),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC5_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(5)'event and ADC_BUSY(5) = '1' then
--		ADC5_BSY_CNT	<= ADC5_BSY_CNT +1;
--	end if;
--end process;
--
--			
-- process(ADC_BUSY(6),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC6_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(6)'event and ADC_BUSY(6) = '1' then
--		ADC6_BSY_CNT	<= ADC6_BSY_CNT +1;
--	end if;
--end process;
--
--			
-- process(ADC_BUSY(7),TS_RESET) 
--begin
--	if(TS_RESET = '1') then
--		ADC7_BSY_CNT			<= x"00";
--	elsif ADC_BUSY(7)'event and ADC_BUSY(7) = '1' then
--		ADC7_BSY_CNT	<= ADC7_BSY_CNT +1;
--	end if;
--end process;



END SBND_TS_AND_ADC_ERR_ARCH ;

	
	