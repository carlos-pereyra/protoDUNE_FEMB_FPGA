--/////////////////////////////////////////////////////////////////////
--////                              
--////  File: SBND_Registers.VHD          
--////                                                                                                                                      
--////  Author: Jack Fried			                  
--////          jfried@bnl.gov	              
--////  Created: 02/04/2016
--////  Description:  SBND UDP, I2C  and DPM register interface
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

--  Entity Declaration

ENTITY SBND_Registers IS

	PORT
	(
		rst         : IN STD_LOGIC;				-- state machine reset
		clk         : IN STD_LOGIC;
		
		BOARD_ID			 : IN  STD_LOGIC_VECTOR(15 downto 0);
		VERSION_ID		 : IN  STD_LOGIC_VECTOR(15 downto 0);
		
		I2C_data        : IN  STD_LOGIC_VECTOR(31 downto 0);	
		I2C_address     : IN  STD_LOGIC_VECTOR(15 downto 0);	
		I2C_WR    	 	 : IN STD_LOGIC;
		I2C_data_out	 : OUT  STD_LOGIC_VECTOR(31 downto 0);
		
		UDP_data        : IN STD_LOGIC_VECTOR(31 downto 0);	
		UDP_WR_address  : IN STD_LOGIC_VECTOR(15 downto 0); 
		UDP_RD_address  : IN STD_LOGIC_VECTOR(15 downto 0); 
		UDP_WR    	 	 : IN STD_LOGIC;	
		UDP_data_out	 : OUT  STD_LOGIC_VECTOR(31 downto 0);			
				
		DPM_B_WREN		 : IN  STD_LOGIC;		
		DPM_B_ADDR		 : IN  STD_LOGIC_VECTOR(7 downto 0);		
		DPM_B_Q			 : OUT STD_LOGIC_VECTOR(31 downto 0);
		DPM_B_D			 : IN  STD_LOGIC_VECTOR(31 downto 0);	

		DPM_C_ADDR		 : IN  STD_LOGIC_VECTOR(7 downto 0);		
		DPM_C_Q			 : OUT STD_LOGIC_VECTOR(31 downto 0);
		
		reg0_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg1_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg2_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg3_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg4_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg5_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg6_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg7_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg8_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg9_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg10_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg11_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg12_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg13_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg14_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg15_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg16_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg17_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg18_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg19_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg20_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg21_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg22_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg23_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg24_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg25_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg26_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg27_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg28_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg29_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg30_i		: IN  STD_LOGIC_VECTOR(31 downto 0);			
		reg31_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg32_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg33_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg34_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg35_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg36_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg37_i		: IN  STD_LOGIC_VECTOR(31 downto 0);	
		reg38_i		: IN  STD_LOGIC_VECTOR(31 downto 0);		
		reg39_i		: IN  STD_LOGIC_VECTOR(31 downto 0);			
		
		reg0_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg1_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg2_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg3_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg4_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg5_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg6_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg7_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg8_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg9_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg10_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg11_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg12_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg13_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg14_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg15_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);
		reg16_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg17_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg18_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg19_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg20_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);
		reg21_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg22_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg23_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg24_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg25_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg26_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg27_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg28_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg29_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg30_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);
		reg31_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg32_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg33_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg34_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg35_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg36_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg37_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);	
		reg38_o		: OUT  STD_LOGIC_VECTOR(31 downto 0);		
		reg39_o		: OUT  STD_LOGIC_VECTOR(31 downto 0)			
	);
	
END SBND_Registers;


ARCHITECTURE Behavior OF SBND_Registers IS




component DPM_LBNE_REG
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock				: IN STD_LOGIC  := '1';
		data_a			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data_b			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren_a			: IN STD_LOGIC  := '0';
		wren_b			: IN STD_LOGIC  := '0';
		q_a				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;


component DPM_SAMP_WFM
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock				: IN STD_LOGIC  := '1';
		data_a			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data_b			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren_a			: IN STD_LOGIC  := '0';
		wren_b			: IN STD_LOGIC  := '0';
		q_a				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b				: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;


signal	DP_A_data 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal	DP_A_WR				: STD_LOGIC;
signal	DP_A_Q				: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal	DP_A_ADDR 			: STD_LOGIC_VECTOR (7 DOWNTO 0);

signal	DP_C_Q				: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal	DP_C_WR				: STD_LOGIC;

SIGNAL	I2C_SEL				: integer;
SIGNAL	SCRATCH_PAD			: STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL	DP_A_WR_DLY			: STD_LOGIC;
begin



DP_A_ADDR		<= (I2C_address(7 downto 0))  WHEN (I2C_SEL = 1)  ELSE		-- LAST INTERFACE THAT WROTE REG IS INCONTROL OF DPM
					   UDP_WR_address(7 downto 0) WHEN (UDP_WR = '1' or DP_A_WR_DLY = '1') else
						UDP_RD_address(7 downto 0);


DPM_LBNE_REG_inst : DPM_LBNE_REG
	PORT MAP
	(
		address_a		=> DP_A_ADDR,
		address_b		=> DPM_B_ADDR,
		clock				=> clk,
		data_a			=> DP_A_data,
		data_b			=> DPM_B_D,
		wren_a			=> DP_A_WR,
		wren_b			=> DPM_B_WREN,
		q_a				=> DP_A_Q,
		q_b				=> DPM_B_Q
	);

	
	DPM_SAMP_WFM_inst : DPM_SAMP_WFM
	PORT MAP
	(
		address_a		=> DP_A_ADDR,
		address_b		=> DPM_C_ADDR,
		clock				=> clk,
		data_a			=> DP_A_data,	
		data_b			=> x"00000000",
		wren_a			=> DP_C_WR,
		wren_b			=> '0',
		q_a				=> DP_C_Q,
		q_b				=> DPM_C_Q
	);
	
	
	  I2C_data_out	<=	 		 reg0_i 	when (I2C_address = x"0000")	else
									 reg1_i 	when (I2C_address = x"0001")	else
									 reg2_i 	when (I2C_address = x"0002")	else
									 reg3_i 	when (I2C_address = x"0003")	else
									 reg4_i 	when (I2C_address = x"0004")	else
									 reg5_i 	when (I2C_address = x"0005")	else
									 reg6_i 	when (I2C_address = x"0006")	else
									 reg7_i 	when (I2C_address = x"0007")	else
									 reg8_i 	when (I2C_address = x"0008")	else
									 reg9_i 	when (I2C_address = x"0009")	else
									 reg10_i	when (I2C_address = x"000a")	else
									 reg11_i	when (I2C_address = x"000b")	else
									 reg12_i	when (I2C_address = x"000c")	else
									 reg13_i	when (I2C_address = x"000d")	else
									 reg14_i	when (I2C_address = x"000e")	else
									 reg15_i	when (I2C_address = x"000f")	else
									 reg16_i	when (I2C_address = x"0010")	else
									 reg17_i	when (I2C_address = x"0011")	else
									 reg18_i	when (I2C_address = x"0012")	else
									 reg19_i	when (I2C_address = x"0013")	else
									 reg20_i	when (I2C_address = x"0014")	else
									 reg21_i	when (I2C_address = x"0015")	else
									 reg22_i	when (I2C_address = x"0016")	else
									 reg23_i	when (I2C_address = x"0017")	else
									 reg24_i	when (I2C_address = x"0018")	else
									 reg25_i	when (I2C_address = x"0019")	else
									 reg26_i	when (I2C_address = x"001A")	else
									 reg27_i	when (I2C_address = x"001B")	else
									 reg28_i	when (I2C_address = x"001C")	else
									 reg29_i	when (I2C_address = x"001D")	else
									 reg30_i	when (I2C_address = x"001E")	else	
									 reg31_i	when (I2C_address = x"001f")	else
									 reg32_i	when (I2C_address = x"0020")	else
									 reg33_i	when (I2C_address = x"0021")	else
									 reg34_i	when (I2C_address = x"0022")	else
									 reg35_i	when (I2C_address = x"0023")	else
									 reg36_i	when (I2C_address = x"0024")	else
									 reg37_i	when (I2C_address = x"0025")	else
									 reg38_i	when (I2C_address = x"0026")	else
									 reg39_i	when (I2C_address = x"0027")	else									 
									 SCRATCH_PAD					when (I2C_address = x"0100")	else
									 BOARD_ID	& VERSION_ID	when (I2C_address = x"0101")	else
									 DP_A_Q 							when (I2C_address >= x"0200")	 and (I2C_address < x"0300") else
									 DP_C_Q 							when (I2C_address >= x"0300")	else									 
									 X"00000000";		 
 
		UDP_data_out <=	 	 reg0_i 	when (UDP_RD_address = x"0000")	else
									 reg1_i 	when (UDP_RD_address = x"0001")	else
									 reg2_i 	when (UDP_RD_address = x"0002")	else
									 reg3_i 	when (UDP_RD_address = x"0003")	else
									 reg4_i 	when (UDP_RD_address = x"0004")	else
									 reg5_i 	when (UDP_RD_address = x"0005")	else
									 reg6_i 	when (UDP_RD_address = x"0006")	else
									 reg7_i 	when (UDP_RD_address = x"0007")	else
									 reg8_i 	when (UDP_RD_address = x"0008")	else
									 reg9_i 	when (UDP_RD_address = x"0009")	else
									 reg10_i	when (UDP_RD_address = x"000a")	else
									 reg11_i	when (UDP_RD_address = x"000b")	else
									 reg12_i	when (UDP_RD_address = x"000c")	else
									 reg13_i	when (UDP_RD_address = x"000d")	else
									 reg14_i	when (UDP_RD_address = x"000e")	else
									 reg15_i	when (UDP_RD_address = x"000f")	else
									 reg16_i	when (UDP_RD_address = x"0010")	else
									 reg17_i	when (UDP_RD_address = x"0011")	else
									 reg18_i	when (UDP_RD_address = x"0012")	else
									 reg19_i	when (UDP_RD_address = x"0013")	else
									 reg20_i	when (UDP_RD_address = x"0014")	else
									 reg21_i	when (UDP_RD_address = x"0015")	else
									 reg22_i	when (UDP_RD_address = x"0016")	else
									 reg23_i	when (UDP_RD_address = x"0017")	else
									 reg24_i	when (UDP_RD_address = x"0018")	else
									 reg25_i	when (UDP_RD_address = x"0019")	else
									 reg26_i	when (UDP_RD_address = x"001A")	else
									 reg27_i	when (UDP_RD_address = x"001B")	else
									 reg28_i	when (UDP_RD_address = x"001C")	else
									 reg29_i	when (UDP_RD_address = x"001D")	else
									 reg30_i	when (UDP_RD_address = x"001E")	else	
									 reg31_i	when (UDP_RD_address = x"001F")	else
									 reg32_i	when (UDP_RD_address = x"0020")	else
									 reg33_i	when (UDP_RD_address = x"0021")	else
									 reg34_i	when (UDP_RD_address = x"0022")	else
									 reg35_i	when (UDP_RD_address = x"0023")	else
									 reg36_i	when (UDP_RD_address = x"0024")	else
									 reg37_i	when (UDP_RD_address = x"0025")	else
									 reg38_i	when (UDP_RD_address = x"0026")	else
									 reg39_i	when (UDP_RD_address = x"0027")	else									 
									 SCRATCH_PAD					when (UDP_RD_address = x"0100")	else
									 BOARD_ID	& VERSION_ID	when (UDP_RD_address = x"0101")	else
									 DP_A_Q 							when (UDP_RD_address >= x"0200")	and (UDP_RD_address < x"0300")  else
									 DP_C_Q 							when (UDP_RD_address >= x"0300")	else
									 X"00000000";		 
		 					 
  process(clk,rst) 
  begin
		if (rst = '1') then
			I2C_SEL		<= 0;
			reg0_o		<= X"00000000";		
			reg1_o		<= X"00000000";	
			reg2_o		<= X"00000000";	
			reg3_o		<= X"00000000";	
			reg4_o		<= X"00000000";	
			reg5_o		<= X"00000000";	
			reg6_o		<= X"00000000";	
			reg7_o		<= X"00000000";	
			reg8_o		<= X"00000000";		
			reg9_o		<= X"00000000";	
			reg10_o		<= X"00000000";	
			reg11_o		<= X"00000000";	
			reg12_o		<= X"00000000";		
			reg13_o		<= X"00000000";
			reg14_o		<= X"00000000";	
			reg15_o		<= X"00000000";
			reg16_o		<= X"00000000";	
			reg17_o		<= X"00000000";	
			reg18_o		<= X"00000000";		
			reg19_o		<= X"00000000";	
			reg20_o		<= X"01f80000";	
			reg21_o		<= X"00000000";	
			reg22_o		<= X"00000000";		
			reg23_o		<= X"00000000";
			reg24_o		<= X"00000000";	
			reg25_o		<= X"00000000";
			reg26_o		<= X"00000000";	
			reg27_o		<= X"00000000";	
			reg28_o		<= X"00000000";		
			reg29_o		<= X"00000000";	
			reg30_o		<= X"00000000";	
			reg31_o		<= X"00000000";	
			reg32_o		<= X"00000000";		
			reg33_o		<= X"00000000";
			reg34_o		<= X"00000000";	
			reg35_o		<= X"00000000";
			reg36_o		<= X"00000000";	
			reg37_o		<= X"00000000";	
			reg38_o		<= X"00000000";		
			reg39_o		<= X"00000000";		
		elsif (clk'event  AND  clk = '1') then				

			reg0_o					<= X"00000000";	-- AUTO CLEAR REG 
			reg1_o(1 downto 0)	<= B"00";	
			reg2_o(1 downto 0)	<= B"00";	
			DP_A_WR					<= '0';		
			DP_C_WR					<= '0';
			DP_A_WR_DLY				<= DP_A_WR or DP_C_WR;		
			if (I2C_SEL = 1) then
				DP_A_data			<= I2C_data;
				if (I2C_WR = '1') and (I2C_address >= x"0200") and (I2C_address < x"0300") then
					DP_A_WR				<= '1';		
				end if;
				if (I2C_WR = '1') and (I2C_address >= x"0300") then
					DP_C_WR				<= '1';		
				end if;									
			else
				DP_A_data			<= UDP_data;
				if (UDP_WR = '1') and (UDP_WR_address >= x"0200") and (UDP_WR_address < x"0300") then
					DP_A_WR				<= '1';
					DP_A_WR_DLY			<= '1';	
				end if;		
				if (UDP_WR = '1') and (UDP_WR_address >= x"0300") then
					DP_C_WR				<= '1';
					DP_A_WR_DLY			<= '1';	
				end if;				
			
			end if;
			
			if (I2C_WR = '1') then
				I2C_SEL		<= 1;
				CASE I2C_address IS
					when x"0000" => 	reg0_o   <= I2C_data;
					when x"0001" => 	reg1_o   <= I2C_data;	
					when x"0002" => 	reg2_o   <= I2C_data;
					when x"0003" => 	reg3_o   <= I2C_data;
					when x"0004" => 	reg4_o   <= I2C_data;
					when x"0005" => 	reg5_o   <= I2C_data;
					when x"0006" => 	reg6_o   <= I2C_data;
					when x"0007" => 	reg7_o   <= I2C_data;
					when x"0008" => 	reg8_o   <= I2C_data;
					when x"0009" => 	reg9_o   <= I2C_data;	
					when x"000A" => 	reg10_o   <= I2C_data;
					when x"000B" => 	reg11_o   <= I2C_data;
					when x"000C" => 	reg12_o   <= I2C_data;
					when x"000D" => 	reg13_o   <= I2C_data;
					when x"000E" => 	reg14_o   <= I2C_data;
					when x"000F" => 	reg15_o   <= I2C_data;		
					when x"0010" => 	reg16_o   <= I2C_data;
					when x"0011" => 	reg17_o   <= I2C_data;
					when x"0012" => 	reg18_o   <= I2C_data;
					when x"0013" => 	reg19_o   <= I2C_data;	
					when x"0014" => 	reg20_o   <= I2C_data;	
					when x"0015" => 	reg21_o   <= I2C_data;
					when x"0016" => 	reg22_o   <= I2C_data;
					when x"0017" => 	reg23_o   <= I2C_data;
					when x"0018" => 	reg24_o   <= I2C_data;
					when x"0019" => 	reg25_o   <= I2C_data;		
					when x"001A" => 	reg26_o   <= I2C_data;
					when x"001B" => 	reg27_o   <= I2C_data;
					when x"001C" => 	reg28_o   <= I2C_data;
					when x"001D" => 	reg29_o   <= I2C_data;	
					when x"001E" => 	reg30_o   <= I2C_data;	
					when x"001F" => 	reg31_o   <= I2C_data;
					when x"0020" => 	reg32_o   <= I2C_data;
					when x"0021" => 	reg33_o   <= I2C_data;
					when x"0022" => 	reg34_o   <= I2C_data;
					when x"0023" => 	reg35_o   <= I2C_data;		
					when x"0024" => 	reg36_o   <= I2C_data;
					when x"0025" => 	reg37_o   <= I2C_data;
					when x"0026" => 	reg38_o   <= I2C_data;
					when x"0027" => 	reg39_o   <= I2C_data;	
					when x"0100" =>	SCRATCH_PAD	<= I2C_data;	
					WHEN OTHERS =>  
				end case;  
			end if;		
		
			if (UDP_WR = '1') then
				I2C_SEL		<= 0;
				CASE UDP_WR_address IS
					when x"0000" => 	reg0_o   <= UDP_data;
					when x"0001" => 	reg1_o   <= UDP_data;	
					when x"0002" => 	reg2_o   <= UDP_data;
					when x"0003" => 	reg3_o   <= UDP_data;
					when x"0004" => 	reg4_o   <= UDP_data;
					when x"0005" => 	reg5_o   <= UDP_data;
					when x"0006" => 	reg6_o   <= UDP_data;
					when x"0007" => 	reg7_o   <= UDP_data;
					when x"0008" => 	reg8_o   <= UDP_data;
					when x"0009" => 	reg9_o   <= UDP_data;	
					when x"000A" => 	reg10_o  <= UDP_data;
					when x"000B" => 	reg11_o  <= UDP_data;
					when x"000C" => 	reg12_o  <= UDP_data;
					when x"000D" => 	reg13_o  <= UDP_data;
					when x"000E" => 	reg14_o  <= UDP_data;
					when x"000F" => 	reg15_o  <= UDP_data;
					when x"0010" => 	reg16_o  <= UDP_data;
					when x"0011" => 	reg17_o  <= UDP_data;
					when x"0012" => 	reg18_o  <= UDP_data;
					when x"0013" => 	reg19_o  <= UDP_data;
					when x"0014" => 	reg20_o  <= UDP_data;
					when x"0015" => 	reg21_o  <= UDP_data;
					when x"0016" => 	reg22_o  <= UDP_data;
					when x"0017" => 	reg23_o  <= UDP_data;
					when x"0018" => 	reg24_o  <= UDP_data;
					when x"0019" => 	reg25_o  <= UDP_data;	
					when x"001A" => 	reg26_o  <= UDP_data;
					when x"001B" => 	reg27_o  <= UDP_data;
					when x"001C" => 	reg28_o  <= UDP_data;
					when x"001D" => 	reg29_o  <= UDP_data;
					when x"001E" => 	reg30_o  <= UDP_data;		
					when x"001F" => 	reg31_o  <= UDP_data;	
					when x"0020" => 	reg32_o  <= UDP_data;	
					when x"0021" => 	reg33_o  <= UDP_data;	
					when x"0022" => 	reg34_o  <= UDP_data;	
					when x"0023" => 	reg35_o  <= UDP_data;		
					when x"0024" => 	reg36_o  <= UDP_data;	
					when x"0025" => 	reg37_o  <= UDP_data;	
					when x"0026" => 	reg38_o  <= UDP_data;	
					when x"0027" => 	reg39_o  <= UDP_data;						
					when x"0100" =>	SCRATCH_PAD	<= UDP_data;	
					WHEN OTHERS =>  
				end case;  
			 end if;

	end if;
end process;
	

END behavior;
