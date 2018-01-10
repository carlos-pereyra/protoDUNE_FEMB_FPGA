--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: ProtoDUNE_ASIC_CNTRL.VHD          
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created: 03/13/2017
--////  Description:  ProtoDUNE_ASIC_CNTRL
--////					
--////
--/////////////////////////////////////////////////////////////////////
--////
--//// Copyright (C) 2014 Brookhaven National Laboratory
--////
--/////////////////////////////////////////////////////////////////////

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


--  Entity Declaration

ENTITY ProtoDUNE_ASIC_CNTRL IS
 generic ( SPI_SPD_CNTL      : integer range 0 to 255  := 64;
			  SPI_BITS			  : integer range 0 to 511  := 288;   -- number of ADC ASIC(144)  + FE ASIC bits (144)
			  ASIC_WR_ADDR   	  : STD_LOGIC_VECTOR(7 downto 0) := x"00";  			  
			  ASIC_RD_ADDR   	  : STD_LOGIC_VECTOR(7 downto 0) := x"50");
			  
	PORT
	(

		sys_rst     	: IN STD_LOGIC;				-- reset		
		clk_sys	    	: IN STD_LOGIC;				-- system clock 

		
		ADC_ASIC_RESET	: IN STD_LOGIC;				-- reset		
		FE_ASIC_RESET	: IN STD_LOGIC;				-- reset		
		ASIC_DAC_CNTL	: IN STD_LOGIC;			
		WRITE_SPI		: IN STD_LOGIC;		
				
		
		DPM_WREN		 	: OUT  STD_LOGIC;		
		DPM_ADDR		 	: OUT  STD_LOGIC_VECTOR(7 downto 0);		
		DPM_D			 	: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		DPM_Q				: IN STD_LOGIC_VECTOR(31 downto 0);		
		
		FE_RST_L			: OUT STD_LOGIC;
		FE_RST_R			: OUT STD_LOGIC;		
		
		ASIC_CS			: OUT STD_LOGIC_VECTOR(7 downto 0);
		ASIC_CK			: OUT STD_LOGIC_VECTOR(7 downto 0);	
		ASIC_SDI			: OUT STD_LOGIC_VECTOR(7 downto 0);	
		ASIC_SDO			: IN  STD_LOGIC_VECTOR(7 downto 0)			
			
		
	);
	
	END ProtoDUNE_ASIC_CNTRL;

ARCHITECTURE behavior OF ProtoDUNE_ASIC_CNTRL IS

 
  type state_type is (S_IDLE,
							S_ADC_ASIC_RESET,	
							S_FE_ASIC_RESET,
							S_WRITE_ADC_SPI_START,	
							S_WRITE_ADC_SPI_next_bit,	
							S_WRITE_ADC_SPI_CLK_HIGH,					
							S_WRITE_ADC_SPI_CLK_LOW,					
							S_WRITE_ADC_SPI_DONE);
							
  signal state: state_type;


	signal counter		: STD_LOGIC_VECTOR(15 downto 0);  
	signal SPI_DATA	: STD_LOGIC_VECTOR(31 downto 0); 
	signal SPI_RB_DATA: STD_LOGIC_VECTOR(31 downto 0);  	
  	signal bit_cnt		: STD_LOGIC_VECTOR(15 downto 0);  
	signal ASIC_bit_cnt: STD_LOGIC_VECTOR(15 downto 0);  
	signal index		: INTEGER RANGE 0 TO 31; 
	signal DPM_ADDR_S	: STD_LOGIC_VECTOR(7 downto 0);	
	signal DPM_RB_ADDR: STD_LOGIC_VECTOR(7 downto 0);		
	signal CHIP			: STD_LOGIC_VECTOR(3 downto 0);		

	
	signal CS			: STD_LOGIC;	
	signal CK			: STD_LOGIC;		
	signal SDI			: STD_LOGIC;		
	signal SDO			: STD_LOGIC;		
	signal DP_ADDR_SEL: STD_LOGIC;	
	
	signal FE_RST		: STD_LOGIC;	
	signal SPI_CNTL	: STD_LOGIC;	
	SIGNAL ASIC_CK_SPI: STD_LOGIC;	

begin


		ASIC_CK_SPI  <= '0' when (SPI_CNTL = '1') else ASIC_DAC_CNTL;

		ASIC_CS(0)		<= CS WHEN (CHIP = X"0") OR (CHIP = X"F")  ELSE '0';
		ASIC_CS(1)		<= CS WHEN (CHIP = X"1") OR (CHIP = X"F")  ELSE '0';
		ASIC_CS(2)		<= CS WHEN (CHIP = X"2") OR (CHIP = X"F")  ELSE '0';
		ASIC_CS(3)		<= CS WHEN (CHIP = X"3") OR (CHIP = X"F")  ELSE '0';
		ASIC_CS(4)		<= CS WHEN (CHIP = X"4") OR (CHIP = X"F")  ELSE '0';
		ASIC_CS(5)		<= CS WHEN (CHIP = X"5") OR (CHIP = X"F")  ELSE '0';
		ASIC_CS(6)		<= CS WHEN (CHIP = X"6") OR (CHIP = X"F")  ELSE '0';	
		ASIC_CS(7)		<= CS WHEN (CHIP = X"7") OR (CHIP = X"F")  ELSE '0';
		
		
		ASIC_CK(0)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"0" OR CHIP = X"F" )) else ASIC_CK_SPI;
		ASIC_CK(1)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"1" OR CHIP = X"F" )) else ASIC_CK_SPI;
		ASIC_CK(2)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"2" OR CHIP = X"F" )) else ASIC_CK_SPI;
		ASIC_CK(3)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"3" OR CHIP = X"F" )) else ASIC_CK_SPI;
		ASIC_CK(4)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"4" OR CHIP = X"F" )) else ASIC_CK_SPI;
		ASIC_CK(5)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"5" OR CHIP = X"F" )) else ASIC_CK_SPI;
		ASIC_CK(6)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"6" OR CHIP = X"F" )) else ASIC_CK_SPI;
		ASIC_CK(7)		<= CK  when (SPI_CNTL = '1' AND (CHIP = X"7" OR CHIP = X"F" )) else ASIC_CK_SPI;
		

		ASIC_SDI(0)		<= SDI WHEN (CHIP = X"0") OR (CHIP = X"F")  ELSE '0';
		ASIC_SDI(1)		<= SDI WHEN (CHIP = X"1") OR (CHIP = X"F")  ELSE '0';
		ASIC_SDI(2)		<= SDI WHEN (CHIP = X"2") OR (CHIP = X"F")  ELSE '0';
		ASIC_SDI(3)		<= SDI WHEN (CHIP = X"3") OR (CHIP = X"F")  ELSE '0';
		ASIC_SDI(4)		<= SDI WHEN (CHIP = X"4") OR (CHIP = X"F")  ELSE '0';
		ASIC_SDI(5)		<= SDI WHEN (CHIP = X"5") OR (CHIP = X"F")  ELSE '0';
		ASIC_SDI(6)		<= SDI WHEN (CHIP = X"6") OR (CHIP = X"F")  ELSE '0';
		ASIC_SDI(7)		<= SDI WHEN (CHIP = X"7") OR (CHIP = X"F")  ELSE '0';
		
		
		SDO				<= ASIC_SDO(0) when (CHIP = X"0") else
								ASIC_SDO(1) when (CHIP = X"1") else
								ASIC_SDO(2) when (CHIP = X"2") else
								ASIC_SDO(3) when (CHIP = X"3") else
								ASIC_SDO(4) when (CHIP = X"4") else
								ASIC_SDO(5) when (CHIP = X"5") else
								ASIC_SDO(6) when (CHIP = X"6") else
								ASIC_SDO(7) when (CHIP = X"7") else
								ASIC_SDO(0);
								
		
		
		FE_RST_L			<=	FE_RST;
		FE_RST_R			<=	FE_RST;	
		


		DPM_ADDR			<= DPM_ADDR_S when (DP_ADDR_SEL = '0') else DPM_RB_ADDR;

  process(clk_sys,sys_rst) 
  begin
	 if (sys_rst = '1') then
		CS				<=	'0';
		Ck				<=	'0';		
		SDI			<= '0';
		FE_RST		<= '1';
		index			<=  0;
		DPM_WREN		<= '0';
		DP_ADDR_SEL	<= '0';
		DPM_ADDR_S	<= (others => '0');
		DPM_RB_ADDR	<= (others => '0');
		DPM_D			<= (others => '0');
		counter		<= X"0000";
		bit_cnt		<= X"0000";
		DP_ADDR_SEL	<= '0';
		SPI_CNTL		<= '0';
		CHIP			<= x"0";
		ASIC_bit_cnt	<= x"0000";
		state 		<= S_idle;	
     elsif (clk_sys'event AND clk_sys = '1') then
			CASE state IS
			when S_IDLE =>	
				CHIP			<= x"0";
				CS				<=	'0';
				CK				<=	'0';
				SDI			<= '0';
				FE_RST		<= '1';
				counter		<= X"0000";
				index			<= 0;
				bit_cnt		<= X"0000";
				ASIC_bit_cnt<= x"0000";
				DPM_WREN		<= '0';
				DP_ADDR_SEL	<= '0';
				SPI_CNTL		<= '0';	
				DPM_ADDR_S	<= (others => '0');
				bit_cnt		<= (others => '0');
				SPI_RB_DATA	<= (others => '0');
				if (ADC_ASIC_RESET = '1')  then		
					SPI_CNTL		<= '1';			
					CHIP			<= x"F";
					state 		<= S_ADC_ASIC_RESET;	
				elsif (FE_ASIC_RESET = '1')  then
					state 		<= S_FE_ASIC_RESET;	
				elsif (WRITE_SPI = '1')  then
					CHIP			<= x"0";
					SPI_CNTL		<= '1';				
					DPM_ADDR_S 	<= ASIC_WR_ADDR(7 DOWNTO 0);	    	
					DPM_RB_ADDR	<= ASIC_RD_ADDR(7 DOWNTO 0);   			  	
					state 		<= S_WRITE_ADC_SPI_START;
				end if;	
							
			when S_ADC_ASIC_RESET =>	
				counter		<= counter + 1;
				if   (counter = 1)  then
					CK		<= '1';
				elsif(counter = 2)  then
					CS		<=	'1';
				elsif(counter = 5)  then
					CS		<=	'0';
				elsif(counter = 10)  then
					CS		<=	'0';
					CK		<= '0';
				elsif(counter >= 15)  then	
					state <= S_idle;	
				end if;
			when S_FE_ASIC_RESET	 =>
				counter		<= counter + 1;
				FE_RST		<= '0';
				if(counter >= 6)  then	
					state 		<= S_idle;	
				end if;												
			when S_WRITE_ADC_SPI_START	 =>
				SDI			<= '0';
				CS				<=	'0';
				CK				<= '0';	
				CHIP			<= x"0";
				index			<= 0;			
				SPI_DATA		<= DPM_Q(31 downto 0);	
				state 		<= S_WRITE_ADC_SPI_next_bit;
			when	S_WRITE_ADC_SPI_next_bit	=>	
				index			<= index + 1;
				CS				<=	'1';
				CK				<= '0';	
				SDI			<= SPI_DATA(index);
				DP_ADDR_SEL	<= '0';									-- RB added				
--				SPI_RB_DATA(index)	<= SDO;   -- RB added
				counter		<= X"0000";
				state 		<=	S_WRITE_ADC_SPI_CLK_HIGH;
				if( index = 31 ) then
					index <= 0;
					DPM_ADDR_S	<= DPM_ADDR_S	+ 1;
				end if;
				if( bit_cnt = 2304) then
						SPI_RB_DATA(index)		<= '0';   -- RB FIX
						SDI			<= '0';
						state 		<=	S_WRITE_ADC_SPI_DONE;
				end if;
				if(ASIC_bit_cnt	=	SPI_BITS) then
					CHIP	<= CHIP + 1;
					ASIC_bit_cnt	<= x"0000";
				end if;
			when	S_WRITE_ADC_SPI_CLK_HIGH	=>	
				counter		<= counter + 1;
				
				if(counter = 5)  then			
					SPI_RB_DATA(index-1)	<= SDO;   -- RB added	
				end if;
				CK			<= '1';	
				if(counter >= SPI_SPD_CNTL)  then
					bit_cnt		<=	bit_cnt + 1;			
					ASIC_bit_cnt<= ASIC_bit_cnt + 1;
					SPI_DATA		<= DPM_Q;
					counter		<= X"0000";
					state 		<= S_WRITE_ADC_SPI_CLK_LOW;	
				end if;					
			when	S_WRITE_ADC_SPI_CLK_LOW	=>				
				counter		<= counter + 1;
				CK			<= '0';	
				if(index = 0) then							
					DPM_D			<=	SPI_RB_DATA;			
					if( counter = 2)	then					-- RB added
						DP_ADDR_SEL	<= '1';					-- RB added
					elsif( counter = 4)	then				-- RB added
						DPM_WREN		<= '1';					-- RB added
					elsif( counter = 6)	then				-- RB added
						DPM_WREN		<= '0';					-- RB added		
					elsif( counter = 8)	then				-- RB added
						DPM_RB_ADDR	<= DPM_RB_ADDR + 1;	-- RB added
						DPM_D			<= (others => '0');	-- RB added
						SPI_RB_DATA	<= (others => '0');	-- RB added
						DP_ADDR_SEL	<= '0';					-- RB added
					end if;										-- RB added
				end if; 											-- RB added
				if(counter > SPI_SPD_CNTL)  then	
					counter		<= X"0000";
					state 		<= S_WRITE_ADC_SPI_next_bit;	
				end if;	
			when	S_WRITE_ADC_SPI_DONE	=>		
				counter		<= counter + 1;			-- RB added
				SDI			<= '0';
				CS				<=	'0';
				CK				<= '0';					
				DPM_D			<=	SPI_RB_DATA;			-- RB added
				if( counter = 2)	then					-- RB added
					DP_ADDR_SEL	<= '1';					-- RB added
				elsif( counter = 4)	then				-- RB added
					DPM_WREN		<= '1';					-- RB added
				elsif( counter = 6)	then				-- RB added
					DPM_WREN		<= '0';					-- RB added		
				elsif( counter >= 8)	then				-- RB added•
					DPM_RB_ADDR	<= DPM_RB_ADDR + 1;	-- RB added
					DPM_D			<= (others => '0');	-- RB added
					SPI_RB_DATA	<= (others => '0');	-- RB added
					DP_ADDR_SEL	<= '0';					-- RB added
					state 		<= S_idle;							
				end if;
			 when others =>		
					state <= S_idle;		
			 end case; 
	 end if;
end process;

END behavior;

	
	