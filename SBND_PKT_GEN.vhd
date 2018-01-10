
--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: SBND_PKT_GEN.VHD            
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


entity SBND_PKT_GEN is
	PORT
	(
	
	
		SYS_RST     	: IN STD_LOGIC;				-- reset		
		CLK_SYS	    	: IN STD_LOGIC;				-- system clock 		
		WRITE_ENABLE	: IN STD_LOGIC;
		START_BIT_MODE	: IN STD_LOGIC;
		ADC_Data_LATCH : IN STD_LOGIC;
		
		ADC_Data		   : IN ADC_array(0 to 1);		
		ADC_header		: IN SL_ARRAY_7_TO_0(0 to 1);			
		TIMESTAMP		: IN STD_LOGIC_VECTOR(15 downto 0);
		ADC_ERROR		: IN STD_LOGIC_VECTOR(15 downto 0);
		RESERVED			: IN STD_LOGIC_VECTOR(15 downto 0);
		DATA_VALID		: OUT STD_LOGIC;			
--		DATA_SOF			: OUT STD_LOGIC;			
		DATA_PKT			: OUT STD_LOGIC_VECTOR(16 downto 0)	
	);
end SBND_PKT_GEN;


architecture SBND_PKT_GEN_arch of SBND_PKT_GEN is


	TYPE 	 	state_type is (S_IDLE, S_START_Of_FRAME,S_FIRST_WORD, S_WRITE_PKT);
	SIGNAL 	state				: state_type;
	
	SIGNAL	CHECKSUM1		: STD_LOGIC_VECTOR(17 downto 0);
	SIGNAL	CHECKSUM2		: STD_LOGIC_VECTOR(17 downto 0);	
	SIGNAL	CHECKSUM3		: STD_LOGIC_VECTOR(17 downto 0);	
	SIGNAL	CHECKSUM4		: STD_LOGIC_VECTOR(17 downto 0);
	SIGNAL	CHECKSUM5		: STD_LOGIC_VECTOR(17 downto 0);
	SIGNAL	CHECKSUM6		: STD_LOGIC_VECTOR(17 downto 0);	
	SIGNAL	CHECKSUM7		: STD_LOGIC_VECTOR(17 downto 0);	
	SIGNAL	CHECKSUM8		: STD_LOGIC_VECTOR(23 downto 0);	
	SIGNAL	CHECKSUM9		: STD_LOGIC_VECTOR(15 downto 0);	
	
	
	SIGNAL	CHECKSUM_L		: STD_LOGIC_VECTOR(15 downto 0);	
	SIGNAL	TIMESTAMP_L		: STD_LOGIC_VECTOR(15 downto 0);	
	SIGNAL	ADC_ERROR_L		: STD_LOGIC_VECTOR(15 downto 0);	
	SIGNAL	RESERVED_L		: STD_LOGIC_VECTOR(15 downto 0);	
	SIGNAL	HEADER_L			: STD_LOGIC_VECTOR(15 downto 0);	
	SIGNAL	SELECT_Data		: STD_LOGIC_VECTOR(7 downto 0);	
	SIGNAL	DATA				: STD_LOGIC_VECTOR(16 downto 0);	
	SIGNAL	ADC_Data_L	   : ADC_array(0 to 1);		
	SIGNAL	DATA_VALID_L	: STD_LOGIC;
	SIGNAL	DATA_SOF_L		: STD_LOGIC;
	SIGNAL	ADC_Data_LATCH_DLY1 : STD_LOGIC;
	SIGNAL	ADC_Data_LATCH_DLY2 : STD_LOGIC;	
	

begin


			DATA			 <=	'1' & x"3c3c"								when (SELECT_Data = x"00" and START_BIT_MODE = '0') else
									'1' & x"3CBC"								when (SELECT_Data = x"00" and START_BIT_MODE = '1')  else
									'0' & CHECKSUM9							when (SELECT_Data = x"01") else
								-- '0' & X"FEAD"								when (SELECT_Data = x"00") else
									'0' & TIMESTAMP_L							when (SELECT_Data = x"02") else
									'0' & ADC_ERROR_L							when (SELECT_Data = x"03") else
									'0' & RESERVED_L							when (SELECT_Data = x"04") else
									'0' & HEADER_L								when (SELECT_Data = x"05") else		
									'0' & ADC_Data_L(0)(15 downto 0)		when (SELECT_Data = x"06") else
							--		'0' & x"FEAD"								when (SELECT_Data = x"06") else
									'0' & ADC_Data_L(0)(31 downto 16)	when (SELECT_Data = x"07") else
									'0' & ADC_Data_L(0)(47 downto 32)	when (SELECT_Data = x"08") else
									'0' & ADC_Data_L(0)(63 downto 48)	when (SELECT_Data = x"09") else
									'0' & ADC_Data_L(0)(79 downto 64)	when (SELECT_Data = x"0a") else
									'0' & ADC_Data_L(0)(95 downto 80)	when (SELECT_Data = x"0b") else
									'0' & ADC_Data_L(0)(111 downto 96)	when (SELECT_Data = x"0c") else
									'0' & ADC_Data_L(0)(127 downto 112)	when (SELECT_Data = x"0d") else
									'0' & ADC_Data_L(0)(143 downto 128)	when (SELECT_Data = x"0e") else
									'0' & ADC_Data_L(0)(159 downto 144)	when (SELECT_Data = x"0f") else
									'0' & ADC_Data_L(0)(175 downto 160)	when (SELECT_Data = x"10") else
									'0' & ADC_Data_L(0)(191 downto 176)	when (SELECT_Data = x"11") else
									
									'0' & ADC_Data_L(1)(15 downto 0)		when (SELECT_Data = x"12") else
									'0' & ADC_Data_L(1)(31 downto 16)	when (SELECT_Data = x"13") else
									'0' & ADC_Data_L(1)(47 downto 32)	when (SELECT_Data = x"14") else
									'0' & ADC_Data_L(1)(63 downto 48)	when (SELECT_Data = x"15") else
									'0' & ADC_Data_L(1)(79 downto 64)	when (SELECT_Data = x"16") else
									'0' & ADC_Data_L(1)(95 downto 80)	when (SELECT_Data = x"17") else
									'0' & ADC_Data_L(1)(111 downto 96)	when (SELECT_Data = x"18") else
									'0' & ADC_Data_L(1)(127 downto 112)	when (SELECT_Data = x"19") else
									'0' & ADC_Data_L(1)(143 downto 128)	when (SELECT_Data = x"1a") else
									'0' & ADC_Data_L(1)(159 downto 144)	when (SELECT_Data = x"1b") else
									'0' & ADC_Data_L(1)(175 downto 160)	when (SELECT_Data = x"1c") else
									'0' & ADC_Data_L(1)(191 downto 176)	when (SELECT_Data = x"1d") else
								--	'0' & X"FACE"								when (SELECT_Data = x"1d") else
									'0' & x"0000";
									
	
CHECKSUM1	<=  b"00" & (ADC_Data_L(0)(15 downto 0))    + (ADC_DATA_L(0)(31 downto 16))   + (ADC_DATA_L(0)(47 downto 32))   + (ADC_DATA_L(0)(63 downto 48));
CHECKSUM2	<=  b"00" & (ADC_DATA_L(0)(79 downto 64))   + (ADC_DATA_L(0)(95 downto 80))   + (ADC_DATA_L(0)(111 downto 96))  + (ADC_DATA_L(0)(127 downto 112));
CHECKSUM3	<=  b"00" & (ADC_DATA_L(0)(143 downto 128)) + (ADC_DATA_L(0)(159 downto 144)) + (ADC_DATA_L(0)(175 downto 160)) + (ADC_DATA_L(0)(191 downto 176));

CHECKSUM4	<=  b"00" & (ADC_Data_L(1)(15 downto 0))    + (ADC_DATA_L(1)(31 downto 16))   + (ADC_DATA_L(1)(47 downto 32))   + (ADC_DATA_L(1)(63 downto 48));
CHECKSUM5	<=  b"00" & (ADC_DATA_L(1)(79 downto 64))   + (ADC_DATA_L(1)(95 downto 80))   + (ADC_DATA_L(1)(111 downto 96))  + (ADC_DATA_L(1)(127 downto 112));
CHECKSUM6	<=  b"00" & (ADC_DATA_L(1)(143 downto 128)) + (ADC_DATA_L(1)(159 downto 144)) + (ADC_DATA_L(1)(175 downto 160)) + (ADC_DATA_L(1)(191 downto 176));


CHECKSUM7	<=	 b"00"      & TIMESTAMP_L + ADC_ERROR_L + RESERVED_L + HEADER_L;
CHECKSUM8	<=  b"000000" & CHECKSUM1  + CHECKSUM2 + CHECKSUM3 + CHECKSUM4 + CHECKSUM5  + CHECKSUM6 + CHECKSUM7;
CHECKSUM9	<=  CHECKSUM8(23 DOWNTO 16) + CHECKSUM8(15 DOWNTO 0);



process(CLK_SYS) 
  begin
	if (CLK_SYS'event AND CLK_SYS = '1') then
		DATA_PKT			<= DATA;
		DATA_VALID		<= DATA_VALID_L;
	--	DATA_SOF			<= DATA_SOF_L;
		
	end if;
end process;

  process(CLK_SYS,SYS_RST) 
  begin
	 if (SYS_RST = '1') then
	 
		SELECT_Data	<= x"00";
		state 		<= S_idle;	
		DATA_SOF_L	<= '0';
		DATA_VALID_L<= '0';
     elsif (CLK_SYS'event AND CLK_SYS = '1') then
		ADC_Data_LATCH_DLY1	<= ADC_Data_LATCH;
		ADC_Data_LATCH_DLY2	<= ADC_Data_LATCH_DLY1;
			CASE state IS
			when S_IDLE =>	
				SELECT_Data	<= x"00";	
				DATA_SOF_L	<= '0';
				DATA_VALID_L<= '0';
				ADC_Data_L	<= ADC_Data;
				TIMESTAMP_L	<= TIMESTAMP;
				ADC_ERROR_L	<= ADC_ERROR;
				RESERVED_L	<= RESERVED;
				HEADER_L		<= ADC_header(0) & ADC_header(1);				
				if (ADC_Data_LATCH  = '1' and ADC_Data_LATCH_DLY1 = '0' and WRITE_ENABLE = '1') then
						state 		<= S_FIRST_WORD;			
				end if;	
				
		   when S_START_Of_FRAME =>
		   --			DATA_SOF_L	<= '1';
			--		DATA_VALID_L<= '1';
					state 		<= S_FIRST_WORD;	
		   when S_FIRST_WORD =>
					DATA_SOF_L	<= '0';
					DATA_VALID_L<= '1';
					state 		<= S_WRITE_PKT;		
			when S_WRITE_PKT =>
					DATA_SOF_L	<= '0';
					DATA_VALID_L<= '1';
					SELECT_Data	<=  SELECT_Data + 1;
					if(SELECT_Data >= x"1D") then
						DATA_SOF_L	<= '0';
						DATA_VALID_L<= '0';
						state 		<= S_idle;
					end if;
			when others =>		
					state <= S_idle;		
			end case; 
	 end if;
end process;


end SBND_PKT_GEN_arch;
