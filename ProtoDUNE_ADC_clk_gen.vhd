--*********************************************************
--* FILE  : ProtoDUNE_ADC_clk_gen.VHD
--* Author: Jack Fried
--*
--* Last Modified: 03/07/2017
--*  
--* Description: ProtoDUNE_ADC_clk_gen
--*		 		               
--*
--*
--*********************************************************

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


--  Entity Declaration

ENTITY ProtoDUNE_ADC_clk_gen IS

	PORT
	(
		sys_rst     	: IN STD_LOGIC;				-- clock
		clk    		 	: IN STD_LOGIC;				-- clock		
		CLK_DIS			: IN STD_LOGIC;		
		ADC_CONV			: IN STD_LOGIC;
		
		INV_RST	 		: IN STD_LOGIC;							-- invert
		OFST_RST			: IN STD_LOGIC_VECTOR(15 downto 0);  -- OFFSET
		WDTH_RST			: IN STD_LOGIC_VECTOR(15 downto 0);  -- WIDTH

		INV_READ 		: IN STD_LOGIC;							-- invert		
		OFST_READ	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- OFFSET
		WDTH_READ	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- WIDTH

		INV_IDXM		 	: IN STD_LOGIC;							-- invert		
		OFST_IDXM		: IN STD_LOGIC_VECTOR(15 downto 0);  -- OFFSET
		WDTH_IDXM	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- WIDTH

		INV_IDXL		 	: IN STD_LOGIC;							-- invert		
		OFST_IDXL	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- OFFSET
		WDTH_IDXL	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- WIDTH
		
	
		INV_IDL		 	: IN STD_LOGIC;							-- invert		
		OFST_IDL_f1	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- OFFSET
		WDTH_IDL_f1	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- WIDTH
		OFST_IDL_f2	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- OFFSET
		WDTH_IDL_f2	 	: IN STD_LOGIC_VECTOR(15 downto 0);  -- WIDTH


		phasecounterselect	: IN STD_LOGIC_VECTOR (2 DOWNTO 0) :=  (OTHERS => '0');
		phasestep				: IN STD_LOGIC  := '0';
		phaseupdown				: IN STD_LOGIC  := '0';
		scanclk					: IN STD_LOGIC  := '1';		
		
		ADC_RST			: OUT STD_LOGIC;	
		ADC_IDXM			: OUT STD_LOGIC;	
		ADC_IDL			: OUT STD_LOGIC;	
		ADC_READ			: OUT STD_LOGIC;	
		ADC_IDXL			: OUT STD_LOGIC		
		
	
	);
END ProtoDUNE_ADC_clk_gen;

ARCHITECTURE behavior OF ProtoDUNE_ADC_clk_gen IS



component ADC_PLL
	PORT
	(
		areset					: IN STD_LOGIC  := '0';
		inclk0					: IN STD_LOGIC  := '0';
		phasecounterselect	: IN STD_LOGIC_VECTOR (2 DOWNTO 0) :=  (OTHERS => '0');
		phasestep				: IN STD_LOGIC  := '0';
		phaseupdown				: IN STD_LOGIC  := '0';
		scanclk					: IN STD_LOGIC  := '1';
		c0							: OUT STD_LOGIC ;
		c1							: OUT STD_LOGIC ;
		c2							: OUT STD_LOGIC ;
		c3							: OUT STD_LOGIC ;
		c4							: OUT STD_LOGIC ;
		locked					: OUT STD_LOGIC ;
		phasedone				: OUT STD_LOGIC 
	);
end component;


signal	cLOCK_0 : std_LOGIC;
signal	cLOCK_1 : std_LOGIC;
signal	cLOCK_2 : std_LOGIC;
signal	cLOCK_3 : std_LOGIC;
signal	cLOCK_4 : std_LOGIC;

begin


ADC_PLL_INST : ADC_PLL
	PORT map
	(
		inclk0		=> clk,
		c0				=> cLOCK_0,
		c1				=> cLOCK_1,
		c2				=> cLOCK_2,
		c3				=> cLOCK_3,
		c4				=> cLOCK_4,
		locked		=> OPEN
	);



ProtoDUNE_clk_gen_RST : ENTITY WORK.ProtoDUNE_clk_gen
	PORT map
	(
		sys_rst     	=> sys_rst,
		clk    		 	=> cLOCK_0,
		ADC_CONV			=> ADC_CONV,
		CLK_DIS			=> CLK_DIS,
		INV_CLK	 		=> INV_RST,
		OFST_CLK_f1	 	=> OFST_RST,
		WDTH_CLK_f1	 	=> WDTH_RST,
		CLK_OUT			=> ADC_RST
	);


ProtoDUNE_clk_gen_READ  : ENTITY WORK.ProtoDUNE_clk_gen
	PORT map
	(
		sys_rst     	=> sys_rst,
		clk    		 	=> cLOCK_1,
		ADC_CONV			=> ADC_CONV,  
		CLK_DIS			=> CLK_DIS,
		INV_CLK	 		=> INV_READ,
		OFST_CLK_f1	 	=> OFST_READ,
		WDTH_CLK_f1	 	=> WDTH_READ,
		CLK_OUT			=> ADC_READ
	);

ProtoDUNE_clk_gen_IDXM : ENTITY WORK.ProtoDUNE_clk_gen
	PORT map
	(
		sys_rst     	=> sys_rst,
		clk    		 	=> cLOCK_2,
		ADC_CONV			=> ADC_CONV,  
		CLK_DIS			=> CLK_DIS,
		INV_CLK	 		=> INV_IDXM,
		OFST_CLK_f1	 	=> OFST_IDXM,
		WDTH_CLK_f1	 	=> WDTH_IDXM,
		CLK_OUT			=> ADC_IDXM
	);
ProtoDUNE_clk_gen_IDXL : ENTITY WORK.ProtoDUNE_clk_gen
	PORT map
	(
		sys_rst     	=> sys_rst,
		clk    		 	=> cLOCK_3,
		ADC_CONV			=> ADC_CONV,  
		CLK_DIS			=> CLK_DIS,
		INV_CLK	 		=> INV_IDXL,
		OFST_CLK_f1	 	=> OFST_IDXL,
		WDTH_CLK_f1	 	=> WDTH_IDXL,
		CLK_OUT			=> ADC_IDXL
	);

ProtoDUNE_clk_gen_IDL : ENTITY WORK.ProtoDUNE_clk_gen
	PORT map
	(
		sys_rst     	=> sys_rst,
		clk    		 	=> cLOCK_4,
		ADC_CONV			=> ADC_CONV,  
		CLK_DIS			=> CLK_DIS,
		INV_CLK	 		=> INV_IDL,
		OFST_CLK_f1	 	=> OFST_IDL_f1,
		WDTH_CLK_f1	 	=> WDTH_IDL_f1,
		OFST_CLK_f2	 	=> OFST_IDL_f2,
		WDTH_CLK_f2	 	=> WDTH_IDL_f2,
		CLK_OUT			=> ADC_IDL
	);	
	
	 
END behavior;
