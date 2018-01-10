--*********************************************************
--* FILE  : ProtoDUNE_ADC_CLK_TOP.VHD
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

ENTITY ProtoDUNE_ADC_CLK_TOP IS

	PORT
	(
		sys_rst     	: IN STD_LOGIC;				-- clock
		clk    		 	: IN STD_LOGIC;				-- clock		
		
		PHASE_CONTROL_L: IN STD_LOGIC_VECTOR(7 downto 0);  -- WIDTH		
		PHASE_CONTROL_R: IN STD_LOGIC_VECTOR(7 downto 0);  -- WIDTH				
		
		
		ADC_CONV			: IN STD_LOGIC; 
		
		CLK_DIS			: IN STD_LOGIC;		
	
		INV_RST	 		: IN STD_LOGIC_VECTOR(1 downto 0);	 -- invert
		OFST_RST			: IN STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
		WDTH_RST			: IN STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH

		INV_READ 		: IN STD_LOGIC_VECTOR(1 downto 0);	 -- invert	
		OFST_READ	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
		WDTH_READ	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH

		INV_IDXM		 	: IN STD_LOGIC_VECTOR(1 downto 0);	 -- invert	
		OFST_IDXM		: IN STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
		WDTH_IDXM	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH

		INV_IDXL		 	: IN STD_LOGIC_VECTOR(1 downto 0);	 -- invert	
		OFST_IDXL	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
		WDTH_IDXL	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
		
	
		INV_IDL		 	: IN STD_LOGIC_VECTOR(1 downto 0);	 -- invert	
		OFST_IDL_f1	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
		WDTH_IDL_f1	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH
		OFST_IDL_f2	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- OFFSET
		WDTH_IDL_f2	 	: IN STD_LOGIC_VECTOR(31 downto 0);  -- WIDTH


		ADC_RST_L		: OUT STD_LOGIC;	
		ADC_IDXM_L		: OUT STD_LOGIC;	
		ADC_IDL_L		: OUT STD_LOGIC;	
		ADC_READ_L		: OUT STD_LOGIC;	
		ADC_IDXL_L		: OUT STD_LOGIC;
		
		
		ADC_RST_R		: OUT STD_LOGIC;	
		ADC_IDXM_R		: OUT STD_LOGIC;	
		ADC_IDL_R		: OUT STD_LOGIC;	
		ADC_READ_R		: OUT STD_LOGIC;	
		ADC_IDXL_R		: OUT STD_LOGIC		
	
	);
END ProtoDUNE_ADC_CLK_TOP;

ARCHITECTURE behavior OF ProtoDUNE_ADC_CLK_TOP IS


begin


	ProtoDUNE_ADC_clk_gen_INST1 : ENTITY WORK.ProtoDUNE_ADC_clk_gen

	PORT MAP
	(
		sys_rst     	=> sys_rst,
		clk    		 	=> CLK,
		CLK_DIS			=> CLK_DIS,
		ADC_CONV			=> ADC_CONV,
		INV_RST	 		=> INV_RST(0),
		OFST_RST			=> OFST_RST(15 DOWNTO 0),
		WDTH_RST			=> WDTH_RST(15 DOWNTO 0),

		INV_READ 		=> INV_READ(0),
		OFST_READ	 	=> OFST_READ(15 DOWNTO 0),
		WDTH_READ	 	=> WDTH_READ(15 DOWNTO 0),

		INV_IDXM		 	=> INV_IDXM(0),
		OFST_IDXM		=> OFST_IDXM(15 DOWNTO 0),
		WDTH_IDXM	 	=> WDTH_IDXM(15 DOWNTO 0),

		INV_IDXL		 	=> INV_IDXL(0),
		OFST_IDXL	 	=> OFST_IDXL(15 DOWNTO 0),
		WDTH_IDXL	 	=> WDTH_IDXL(15 DOWNTO 0),
	
		INV_IDL		 	=> INV_IDL(0),
		OFST_IDL_f1	 	=> OFST_IDL_f1(15 DOWNTO 0),
		WDTH_IDL_f1	 	=> WDTH_IDL_f1(15 DOWNTO 0),
		OFST_IDL_f2	 	=> OFST_IDL_f2(15 DOWNTO 0),
		WDTH_IDL_f2	 	=> WDTH_IDL_f2(15 DOWNTO 0),

		phasecounterselect	=> PHASE_CONTROL_R(2 DOWNTO 0),
		phasestep				=> PHASE_CONTROL_R(3),
		phaseupdown				=> PHASE_CONTROL_R(4),
		scanclk					=> PHASE_CONTROL_R(5),	
		
		ADC_RST			=> ADC_RST_R,
		ADC_IDXM			=> ADC_IDXM_R,
		ADC_IDL			=> ADC_IDL_R,
		ADC_READ			=> ADC_READ_R,
		ADC_IDXL			=> ADC_IDXL_R	
	
	);
	
	

	ProtoDUNE_ADC_clk_gen_INST2 : ENTITY WORK.ProtoDUNE_ADC_clk_gen

	PORT MAP
	(
		sys_rst     	=> sys_rst,
		clk    		 	=> CLK,
		CLK_DIS			=> CLK_DIS,
		ADC_CONV			=> ADC_CONV,	
		INV_RST	 		=> INV_RST(1),
		OFST_RST			=> OFST_RST(31 DOWNTO 16),
		WDTH_RST			=> WDTH_RST(31 DOWNTO 16),

		INV_READ 		=> INV_READ(1),
		OFST_READ	 	=> OFST_READ(31 DOWNTO 16),
		WDTH_READ	 	=> WDTH_READ(31 DOWNTO 16),

		INV_IDXM		 	=> INV_IDXM(1),
		OFST_IDXM		=> OFST_IDXM(31 DOWNTO 16),
		WDTH_IDXM	 	=> WDTH_IDXM(31 DOWNTO 16),

		INV_IDXL		 	=> INV_IDXL(1),
		OFST_IDXL	 	=> OFST_IDXL(31 DOWNTO 16),
		WDTH_IDXL	 	=> WDTH_IDXL(31 DOWNTO 16),
		
	
		INV_IDL		 	=> INV_IDL(1),
		OFST_IDL_f1	 	=> OFST_IDL_f1(31 DOWNTO 16),
		WDTH_IDL_f1	 	=> WDTH_IDL_f1(31 DOWNTO 16),
		OFST_IDL_f2	 	=> OFST_IDL_f2(31 DOWNTO 16),
		WDTH_IDL_f2	 	=> WDTH_IDL_f2(31 DOWNTO 16),

		phasecounterselect	=> PHASE_CONTROL_L( 2 DOWNTO 0),
		phasestep				=> PHASE_CONTROL_L(3),
		phaseupdown				=> PHASE_CONTROL_L(4),
		scanclk					=> PHASE_CONTROL_L(5),
		
		ADC_RST			=> ADC_RST_L,
		ADC_IDXM			=> ADC_IDXM_L,
		ADC_IDL			=> ADC_IDL_L,
		ADC_READ			=> ADC_READ_L,
		ADC_IDXL			=> ADC_IDXL_L	
	
	);	
	
 

END behavior;
