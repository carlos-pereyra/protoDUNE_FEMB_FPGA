--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: SBND_ASIC_RDOUT_V3.VHD          
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created:  02/08/2016
--////  Modified: 06/29/2016
--////  Description:  LBNE_ASIC_CNTRL
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
USE work.SbndPkg.all;

--  Entity Declaration

ENTITY SBND_ASIC_RDOUT_V2 IS

	PORT
	(
	
		clk_200Mhz    	: IN STD_LOGIC;				-- clock
		clk_sys	    	: IN STD_LOGIC;				-- system clock 
		sys_rst     	: IN STD_LOGIC;				-- reset			
		FEMB_TST_MODE	: IN STD_LOGIC;
		WIB_MODE			: IN STD_LOGIC;
		WFM_GEN_DATA	: IN STD_LOGIC_VECTOR(23 downto 0);		
		CHN_select		: IN STD_LOGIC_VECTOR(7 downto 0); 
		LATCH_LOC		: IN STD_LOGIC_VECTOR(7 downto 0); 		
		ADC_FD			: IN STD_LOGIC_VECTOR(1 downto 0);	-- LVDS
		ADC_BUSY			: IN STD_LOGIC;	-- LVDS
		ADC_TST_PATT_EN: IN STD_LOGIC; 
		ADC_TST_PATT	: IN STD_LOGIC_VECTOR(11 downto 0); 
		ADC_CONV		 	: IN STD_LOGIC;							-- LATCH FIFO DATA IN TO SHIFT REGISTER	
		ADC_header_out	: OUT STD_LOGIC_VECTOR(7 downto 0);
		UDP_DATA_LATCH : OUT STD_LOGIC;
		UDP_DATA_OUT	: OUT STD_LOGIC_VECTOR(15 downto 0);
		ADC_Data_LATCH : OUT STD_LOGIC;
		ADC_DATA			: OUT STD_LOGIC_VECTOR(191 downto 0) 
	);
	
	
	END SBND_ASIC_RDOUT_V2;

ARCHITECTURE behavior OF SBND_ASIC_RDOUT_V2 IS

  
  type state_type is (S_IDLE,  S_READ_SDATA);
  signal state: state_type;

 
-- signal ADC_D_ASIC	: ADC_array(0 to 15);
  
 signal EMPTY  		: STD_LOGIC;
 signal EMPTY1  		: STD_LOGIC;  
 signal EMPTY2  		: STD_LOGIC;  
 signal FF_EMPTY 		: STD_LOGIC; 
 
 
 signal SHIFT_CNT		: STD_LOGIC_VECTOR(7 downto 0);   
 signal WRD_CNT		: STD_LOGIC_VECTOR(7 downto 0);   
 signal BIT_CNT	 	: STD_LOGIC_VECTOR(7 downto 0);
 signal ADC_CNT		: INTEGER RANGE 0 TO 15; 

 signal sys_sync		: STD_LOGIC;  
 signal asic_empty_rst 		: STD_LOGIC;  
 signal asic_empty_rst_s 	: STD_LOGIC;  
 
 
 
 
 signal SR_A_ADC1		: STD_LOGIC_VECTOR(99 downto 0); 
 signal SR_B_ADC1		: STD_LOGIC_VECTOR(99 downto 0); 
 signal SR_A_ADC1_L	: STD_LOGIC_VECTOR(99 downto 0); 
 signal SR_B_ADC1_L	: STD_LOGIC_VECTOR(99 downto 0); 
 
 signal ADC_D_DATA	: STD_LOGIC_VECTOR(191 downto 0);

 
 signal ADC_header	: STD_LOGIC_VECTOR(7 downto 0); 
 SIGnal ADC_CONV_DLY1 : STD_LOGIC;  
 SIGnal ADC_CONV_DLY2 : STD_LOGIC;  

 
 signal SHIFT_latch			: STD_LOGIC;  
 signal SHIFT_latch_req		: STD_LOGIC;
 signal SHIFT_latch_ack		: STD_LOGIC;
 signal SHIFT_latch_req_s	: STD_LOGIC;
 signal Data_Latch			: STD_LOGIC;
 signal Data_Latch_dly		: STD_LOGIC;
 signal CHN_select_s			: STD_LOGIC_VECTOR(7 downto 0); 
 
begin


--		FF_EMPTY			<= ADC_BUSY;
		
					
  process(clk_sys) 	
  begin
	if (clk_sys'event AND clk_sys = '1') then	
	
	
			if(CHN_select(4) = '1') and (WIB_MODE = '0') then
				UDP_DATA_LATCH 	<= Data_Latch;
				CHN_select_s	<= x"0" & CHN_select(3 downto 0);
			else
				if(Data_Latch	= '1') and (Data_Latch_dly = '0') then
					if (WIB_MODE = '0') then
						CHN_select_s		<= x"00";
					else
						CHN_select_s		<= x"10";
					end if;
					UDP_DATA_LATCH 	<= '1';
					Data_Latch_dly 	<= '1';
				end if;
				if (Data_Latch_dly = '1') then
					CHN_select_s	<= CHN_select_s + 1;
				end if;	
				
				if(CHN_select_s >= x"0f") and (Data_Latch_dly = '1') and (WIB_MODE = '0') then
					UDP_DATA_LATCH <= '0';
					Data_Latch_dly <= '0';
				elsif(CHN_select_s >= x"1C") and (Data_Latch_dly = '1') and (WIB_MODE = '1') then
					UDP_DATA_LATCH <= '0';
					Data_Latch_dly <= '0';
				end if;
				
			end if;
			
			
	end if;
end process;	
					
			
	
--					ADC_D_ASIC(7) 	<= SR_A_ADC1_L(11 downto 0);
--					ADC_D_ASIC(6) 	<= SR_A_ADC1_L(23 downto 12);
--					ADC_D_ASIC(5) 	<= SR_A_ADC1_L(35 downto 24);
--					ADC_D_ASIC(4) 	<= SR_A_ADC1_L(47 downto 36);
--					ADC_D_ASIC(3) 	<= SR_A_ADC1_L(59 downto 48);
--					ADC_D_ASIC(2) 	<= SR_A_ADC1_L(71 downto 60);
--					ADC_D_ASIC(1) 	<= SR_A_ADC1_L(83 downto 72);
--					ADC_D_ASIC(0) 	<= SR_A_ADC1_L(95 downto 84);


	
		UDP_DATA_OUT  <= x"0" & ADC_D_DATA(95 downto 84) 	when (CHN_select_s = x"00") else 
							  x"1" & ADC_D_DATA(83 downto 72)  	when (CHN_select_s = x"01") else
							  x"2" & ADC_D_DATA(71 downto 60) 	when (CHN_select_s = x"02") else 
							  x"3" & ADC_D_DATA(59 downto 48)  	when (CHN_select_s = x"03") else
							  x"4" & ADC_D_DATA(47 downto 36)	when (CHN_select_s = x"04") else 
							  x"5" & ADC_D_DATA(35 downto 24) 	when (CHN_select_s = x"05") else
							  x"6" & ADC_D_DATA(23 downto 12) 	when (CHN_select_s = x"06") else 
							  x"7" & ADC_D_DATA(11 downto 0) 	when (CHN_select_s = x"07") else
							  x"8" & ADC_D_DATA(191 downto 180)	when (CHN_select_s = x"08") else 
							  x"9" & ADC_D_DATA(179 downto 168)	when (CHN_select_s = x"09") else
							  x"a" & ADC_D_DATA(167 downto 156)	when (CHN_select_s = x"0a") else 
							  x"b" & ADC_D_DATA(155 downto 144)	when (CHN_select_s = x"0b") else						 
							  x"c" & ADC_D_DATA(143 downto 132)	when (CHN_select_s = x"0c") else 
							  x"d" & ADC_D_DATA(131 downto 120)	when (CHN_select_s = x"0d") else						 
							  x"e" & ADC_D_DATA(119 downto 108)	when (CHN_select_s = x"0e") else 
							  x"f" & ADC_D_DATA(107 downto 96)	when (CHN_select_s = x"0f") else 
							  x"FACE" 									when (CHN_select_s = x"10") else 
							  ADC_D_DATA(15 downto 0)				when (CHN_select_s = x"11") else 
							  ADC_D_DATA(31 downto 16)				when (CHN_select_s = x"12") else 
							  ADC_D_DATA(47 downto 32)				when (CHN_select_s = x"13") else 
							  ADC_D_DATA(63 downto 48)				when (CHN_select_s = x"14") else 
							  ADC_D_DATA(79 downto 64)				when (CHN_select_s = x"15") else 
							  ADC_D_DATA(95 downto 80)				when (CHN_select_s = x"16") else 
							  ADC_D_DATA(111 downto 96)			when (CHN_select_s = x"17") else 
							  ADC_D_DATA(127 downto 112)			when (CHN_select_s = x"18") else 
							  ADC_D_DATA(143 downto 128)			when (CHN_select_s = x"19") else 
							  ADC_D_DATA(159 downto 144)			when (CHN_select_s = x"1A") else 
							  ADC_D_DATA(175 downto 160)			when (CHN_select_s = x"1B") else 
							  ADC_D_DATA(191 downto 176)			when (CHN_select_s = x"1C") else 
							  x"DEAD";
	
									
  process(clk_200Mhz) 
  begin
	if (clk_200Mhz'event AND clk_200Mhz = '1') then		
		ADC_CONV_DLY1	<= ADC_CONV;
		ADC_CONV_DLY2	<= ADC_CONV_DLY1;
	end if;
end process;	
			
	
process(clk_sys) 
begin
	if clk_sys'event and clk_sys = '1' then	
			asic_empty_rst_s 	<= asic_empty_rst;	
			ADC_header_out	  	<= ADC_header;
			ADC_Data_LATCH 	<= Data_Latch;
	end if;	
end process;	
	

 process(clk_sys,sys_rst) 
begin

	if clk_sys'event and clk_sys = '1' then
		if  (sys_rst = '1')  then	
	--		ADC_D_ASIC			<= ((others=> (others=>'0')));
			ADC_D_DATA			<= (others=>'0');
			SHIFT_latch_ack	<= '1';	
			ADC_CNT			<= 0;
		else
			Data_Latch			<= '0';
			SHIFT_latch_ack	<= '0';
			ADC_CNT			<= 0;
			if(SHIFT_latch_req_s = '1')then		
				SHIFT_latch_ack	<= '1';
				ADC_CNT			<= 1;
				if(ADC_TST_PATT_EN = '0') then 
				
					ADC_D_DATA(95 downto 0)	   <= SR_A_ADC1_L(95 downto 0);
					ADC_D_DATA(191 downto 96)	<= SR_B_ADC1_L(95 downto 0);
					ADC_header(3 downto 0)		<= SR_A_ADC1_L(99 downto 96);
					ADC_header(7 downto 4)  	<= SR_B_ADC1_L(99 downto 96);
				else
				
					if(FEMB_TST_MODE = '0') then
						ADC_D_DATA(95 downto 84) 	<= ADC_TST_PATT;
						ADC_D_DATA(83 downto 72)  	<= ADC_TST_PATT;
						ADC_D_DATA(71 downto 60) 	<= ADC_TST_PATT;
						ADC_D_DATA(59 downto 48)  	<= ADC_TST_PATT;
						ADC_D_DATA(47 downto 36)	<= ADC_TST_PATT; 
						ADC_D_DATA(35 downto 24) 	<= ADC_TST_PATT;
						ADC_D_DATA(23 downto 12) 	<= ADC_TST_PATT; 
						ADC_D_DATA(11 downto 0) 	<= ADC_TST_PATT;
						ADC_D_DATA(191 downto 180)	<= ADC_TST_PATT; 
						ADC_D_DATA(179 downto 168)	<= ADC_TST_PATT;
						ADC_D_DATA(167 downto 156)	<= ADC_TST_PATT; 
						ADC_D_DATA(155 downto 144)	<= ADC_TST_PATT;						 
						ADC_D_DATA(143 downto 132)	<= ADC_TST_PATT;
						ADC_D_DATA(131 downto 120)	<= ADC_TST_PATT;						 
						ADC_D_DATA(119 downto 108)	<= ADC_TST_PATT; 
						ADC_D_DATA(107 downto 96)  <= ADC_TST_PATT; 
					else
						ADC_D_DATA(95 downto 84) 	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(83 downto 72)  	<= WFM_GEN_DATA(11 downto 0);
						ADC_D_DATA(71 downto 60) 	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(59 downto 48)  	<= WFM_GEN_DATA(11 downto 0);
						ADC_D_DATA(47 downto 36)	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(35 downto 24) 	<= WFM_GEN_DATA(11 downto 0);
						ADC_D_DATA(23 downto 12) 	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(11 downto 0) 	<= WFM_GEN_DATA(11 downto 0);
						ADC_D_DATA(191 downto 180)	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(179 downto 168)	<= WFM_GEN_DATA(11 downto 0);
						ADC_D_DATA(167 downto 156)	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(155 downto 144)	<= WFM_GEN_DATA(11 downto 0);						 
						ADC_D_DATA(143 downto 132)	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(131 downto 120)	<= WFM_GEN_DATA(11 downto 0);						 
						ADC_D_DATA(119 downto 108)	<= WFM_GEN_DATA(23 downto 12);
						ADC_D_DATA(107 downto 96)  <= WFM_GEN_DATA(11 downto 0);					
					end if;
					
					ADC_header(3 downto 0)		<= X"A";
					ADC_header(7 downto 4)  	<= X"A";
				end if;	
			end if;
			if( ADC_CNT = 1) then
				Data_Latch		<= '1';
				ADC_CNT			<= 0;
				ADC_DATA			<= ADC_D_DATA;
			end if;
		end if;
	end if;	
end process;


			
			


 process(SHIFT_latch,sys_rst,SHIFT_latch_ack) 
begin
	if  (sys_rst = '1') or (SHIFT_latch_ack = '1') then	
		SHIFT_latch_req	<= '0';
	elsif SHIFT_latch'event and SHIFT_latch = '1' then
		SHIFT_latch_req	<= '1';
	end if;
end process;

		
process(clk_sys,sys_rst,SHIFT_latch_ack) 
begin
	if  (sys_rst = '1') or (SHIFT_latch_ack = '1') then	
		SHIFT_latch_req_s	<= '0';
	elsif clk_sys'event and clk_sys = '0' then
		SHIFT_latch_req_s	<= SHIFT_latch_req;
	end if;
end process;




process(clk_200Mhz,sys_rst) 
begin
	if  (sys_rst = '1') then
		SR_A_ADC1  <=(others => '0');
		SR_B_ADC1  <=(others => '0');
	elsif clk_200Mhz'event and clk_200Mhz = '1' then
		SR_A_ADC1	<= SR_A_ADC1(98 downto 0) & ADC_FD(1);
		SR_B_ADC1	<= SR_B_ADC1(98 downto 0) & ADC_FD(0);			
	end if;
end process;


 process(clk_200Mhz,sys_rst) 
begin
	if  (sys_rst = '1') then
		SHIFT_CNT	<= x"00";
		WRD_CNT 		<= x"00";
		SHIFT_latch	<= '0';
	elsif clk_200Mhz'event and clk_200Mhz = '1' then
		SHIFT_latch	<= '0';
		if(sys_sync = '1') then
			SHIFT_latch	<= '1';
			SR_A_ADC1_L	<= SR_A_ADC1;
			SR_B_ADC1_L	<= SR_B_ADC1;	
		end if;

	end if;
end process;



  process(clk_200Mhz,sys_rst) 
  begin
	 if (sys_rst = '1') then
	 
		sys_sync		<= '0';
		BIT_CNT		<= x"00";
		state 		<= S_idle;	
		asic_empty_rst	<= '1';
     elsif (clk_200Mhz'event AND clk_200Mhz = '1') then
			CASE state IS
			when S_IDLE =>	
				BIT_CNT			<= x"00";
				sys_sync			<= '0';
				asic_empty_rst	<= '1';
				if (ADC_CONV_DLY1 = '1' and ADC_CONV_DLY2 = '0') then
					  asic_empty_rst	<= '0';
					  state 				<= S_READ_SDATA;				
				end if;		  
		   when S_READ_SDATA =>	
					BIT_CNT		<= BIT_CNT + 1;
					sys_sync		<= '0';
					if(BIT_CNT = LATCH_LOC) then
						sys_sync		<= '1';
					end if;
					if (BIT_CNT >= x"60")  then
						if (ADC_CONV_DLY1 = '1' and ADC_CONV_DLY2 = '0') then
							BIT_CNT		<= x"00";
							state 		<= S_READ_SDATA;
						end if;
					end if;
					if (BIT_CNT >= x"64")  then
						state 		<= S_idle;
					end if;

			 when others =>		
					state <= S_idle;		
			 end case; 
	 end if;
end process;
END behavior;

	
	