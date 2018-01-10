--------------------------------------------------------------------
--  MODULE NAME: UPD_IO.vhd

--  FUNCTIONAL DESCRIPTION:
--  This module will form and transmit UDP packets for both
--  Register and variable size data packets upto 1024 bytes
---------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;




ENTITY UDP_IO IS 
	PORT
	(
		SPF_OUT 					: IN  STD_LOGIC;
		reset 					: IN  STD_LOGIC;
		start						: IN  STD_LOGIC;
		BRD_IP					: in 	STD_LOGIC_VECTOR(31 downto 0);
		BRD_MAC					: in 	STD_LOGIC_VECTOR(47 downto 0);
		clk_125MHz 				: IN  STD_LOGIC;
		gxb_cal_blk_clk		: IN  STD_LOGIC;
		config_clk_40MHz 		: IN  STD_LOGIC;
		clk_io					: IN  STD_LOGIC;
		rdout 					: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		FRAME_SIZE				: IN  std_logic_vector(11 downto 0);  -- 0x1f8
		tx_fifo_clk 			: IN  STD_LOGIC;
		tx_fifo_wr 				: IN  STD_LOGIC;
		tx_fifo_in 				: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		header_user_info	  	: IN  STD_LOGIC_VECTOR(63 downto 0);
  		TIME_OUT_wait			: IN  STD_LOGIC_VECTOR(31 downto 0);
 		system_status			: IN  STD_LOGIC_VECTOR(31 downto 0);	
		SFP_IN 					: OUT STD_LOGIC;
		tx_fifo_full 			: OUT STD_LOGIC;
		wr_strb 					: OUT STD_LOGIC;
		rd_strb 					: OUT STD_LOGIC;
		WR_address 				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		RD_address 				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);	
		data 						: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		tx_fifo_used			: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		LED						: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
		
	);
END UDP_IO;

ARCHITECTURE UDP_IO_arch OF UDP_IO IS 

--
--COMPONENT mac_reg_cntl
--	PORT(clk 					: IN STD_LOGIC;
--		 reset 					: IN STD_LOGIC;
--		 start 					: IN STD_LOGIC;
--		 reg_busy 				: IN STD_LOGIC;
--		 mac_addr 				: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
--		 reg_data_out 			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
--		 reg_rd 					: OUT STD_LOGIC;
--		 reg_wr 					: OUT STD_LOGIC;
--		 reg_addr 				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 reg_data_in 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
--	);
--END COMPONENT;
--

COMPONENT mac_reg_cntl
	PORT(clk 					: IN STD_LOGIC;
		 reset 					: IN STD_LOGIC;
		 start 					: IN STD_LOGIC;
		 IP_LOC					: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 reg_busy 				: IN STD_LOGIC;
		 mac_addr 				: IN STD_LOGIC_VECTOR(47 DOWNTO 0);
		 reg_data_out 			: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 reg_rd 					: OUT STD_LOGIC;
		 reg_wr 					: OUT STD_LOGIC;
		 reg_addr 				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 reg_data_in 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;





COMPONENT rx_frame 
	port
	(
    clk         		     	: in  std_logic;                     -- Input CLK from MAC Reciever
    reset			        	: in  std_logic;                     -- Synchronous reset signal
	 BRD_IP					  	: in std_logic_vector(31 downto 0);	 
    rx_data_in	      	  	: in  std_logic_vector(7 downto 0);  -- Output data 
    rx_dval				  	  	: in  std_logic;                    -- source ready
    rx_eop	    		  	  	: in  std_logic;                      -- Output end of frame	 
    rx_sop 	   	  	  		: in  std_logic;                     -- Output start of frame

 	 src_MAC					  	: out std_logic_vector(47 downto 0);
	 src_IP					  	: out std_logic_vector(31 downto 0);
	 arp_req				  		: out std_logic;
	 ping_req				  	: out std_logic;
	 IO_address					: out std_logic_vector(15 downto 0);
	 IO_data						: out std_logic_vector(31 downto 0);
	 WR_strb						: out std_logic;
	 RD_strb						: out std_logic
    );
END COMPONENT;


COMPONENT tx_frame 
	port
	(
	   clk         		  	: in  std_logic;                     -- Input CLK from MAC Reciever
      reset			        	: in  std_logic;                     -- Synchronous reset signal
		tx_fifo_clk		  	  	: in  std_logic;		
		tx_fifo_in			  	: in  std_logic_vector(15 downto 0);
		tx_fifo_wr		  	  	: in  std_logic;
		tx_fifo_full		  	: out std_logic;  
		tx_fifo_used		   : out STD_LOGIC_VECTOR (11 DOWNTO 0);		
		FRAME_SIZE				: IN  std_logic_vector(11 downto 0);
		BRD_IP					: in 	STD_LOGIC_VECTOR(31 downto 0);
		BRD_MAC					: in 	STD_LOGIC_VECTOR(47 downto 0);

		ip_dest_addr		  	: in  std_logic_vector(31 downto 0);
		mac_dest_addr		 	: in  std_logic_vector(47 downto 0);
      tx_dst_rdy  	 	  	: in  std_logic;    		-- Input destination ready 
		header_user_info	  	: in  std_logic_vector(63 downto 0);
		
		arp_req				   : in  std_logic;		 -- gen arp_responce
		reg_rd_strb				: in  std_logic;    		-- Input destination ready 
		reg_start_address		: in  std_logic_vector(15 downto 0);
		reg_RDOUT_num			: in  std_logic_vector(3 downto 0);   -- number of registers to read out
		reg_address				: out  std_logic_vector(15 downto 0);
		reg_data					: in  std_logic_vector(31 downto 0);
		TIME_OUT_wait			: in  std_logic_vector(31 downto 0);	
 		system_status			: in  std_logic_vector(31 downto 0);	 
		tx_rdy					: IN STD_LOGIC;		
		tx_data_out      		: out std_logic_vector(7 downto 0);  -- Output data
      tx_eop_out       		: out std_logic;                      -- Output end of frame
      tx_sop_out       		: out std_logic;                     -- Output start of frame		
		tx_src_rdy  	  	   : out std_logic                    -- source ready

      );
END COMPONENT;

component tse_mac is
		port (
			clk              : in  std_logic                     := 'X';             -- clk
			reset            : in  std_logic                     := 'X';             -- reset
			readdata         : out std_logic_vector(31 downto 0);                    -- readdata
			read             : in  std_logic                     := 'X';             -- read
			writedata        : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			write            : in  std_logic                     := 'X';             -- write
			waitrequest      : out std_logic;                                        -- waitrequest
			address          : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- address
			ff_rx_clk        : in  std_logic                     := 'X';             -- clk
			ff_tx_clk        : in  std_logic                     := 'X';             -- clk
			ff_rx_data       : out std_logic_vector(7 downto 0);                     -- data
			ff_rx_eop        : out std_logic;                                        -- endofpacket
			rx_err           : out std_logic_vector(5 downto 0);                     -- error
			ff_rx_rdy        : in  std_logic                     := 'X';             -- ready
			ff_rx_sop        : out std_logic;                                        -- startofpacket
			ff_rx_dval       : out std_logic;                                        -- valid
			ff_tx_data       : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- data
			ff_tx_eop        : in  std_logic                     := 'X';             -- endofpacket
			ff_tx_err        : in  std_logic                     := 'X';             -- error
			ff_tx_rdy        : out std_logic;                                        -- ready
			ff_tx_sop        : in  std_logic                     := 'X';             -- startofpacket
			ff_tx_wren       : in  std_logic                     := 'X';             -- valid
			xon_gen          : in  std_logic                     := 'X';             -- xon_gen
			xoff_gen         : in  std_logic                     := 'X';             -- xoff_gen
			ff_tx_crc_fwd    : in  std_logic                     := 'X';             -- ff_tx_crc_fwd
			ff_tx_septy      : out std_logic;                                        -- ff_tx_septy
			tx_ff_uflow      : out std_logic;                                        -- tx_ff_uflow
			ff_tx_a_full     : out std_logic;                                        -- ff_tx_a_full
			ff_tx_a_empty    : out std_logic;                                        -- ff_tx_a_empty
			rx_err_stat      : out std_logic_vector(17 downto 0);                    -- rx_err_stat
			rx_frm_type      : out std_logic_vector(3 downto 0);                     -- rx_frm_type
			ff_rx_dsav       : out std_logic;                                        -- ff_rx_dsav
			ff_rx_a_full     : out std_logic;                                        -- ff_rx_a_full
			ff_rx_a_empty    : out std_logic;                                        -- ff_rx_a_empty
			ref_clk          : in  std_logic                     := 'X';             -- clk
			gxb_cal_blk_clk  : in  std_logic                     := 'X';             -- clk
			led_crs          : out std_logic;                                        -- crs
			led_link         : out std_logic;                                        -- link
			led_col          : out std_logic;                                        -- col
			led_an           : out std_logic;                                        -- an
			led_char_err     : out std_logic;                                        -- char_err
			led_disp_err     : out std_logic;                                        -- disp_err
			rx_recovclkout   : out std_logic;                                        -- rx_recovclkout
			reconfig_clk     : in  std_logic                     := 'X';             -- reconfig_clk
			reconfig_togxb   : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- reconfig_togxb
			reconfig_fromgxb : out std_logic_vector(4 downto 0);                     -- reconfig_fromgxb
			reconfig_busy    : in  std_logic                     := 'X';             -- reconfig_busy
			txp              : out std_logic;                                        -- txp
			rxp              : in  std_logic                     := 'X'              -- rxp
		);
	end component tse_mac;

component recon
	PORT
	(
		reconfig_clk		: IN STD_LOGIC ;	
		reconfig_fromgxb	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		busy					: OUT STD_LOGIC ;
		reconfig_togxb		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
end component;



component G_CLK
	PORT
	(
		inclk		: IN STD_LOGIC ;
		outclk		: OUT STD_LOGIC 
	);
end component;


SIGNAL	reconfig_clk		: STD_LOGIC ;	
SIGNAL	reconfig_fromgxb	: STD_LOGIC_VECTOR (4 DOWNTO 0);
SIGNAL	busy					: STD_LOGIC ;
SIGNAL	reconfig_togxb		: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL	clk_40MHz 			: STD_LOGIC;
SIGNAL	rd_strb_in 			: STD_LOGIC;
SIGNAL	reg_addr 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	reg_bsy 				: STD_LOGIC;
SIGNAL	reg_data_in 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	reg_data_out 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	reg_rd 				: STD_LOGIC;
SIGNAL	reg_wr 				: STD_LOGIC;
SIGNAL	rx_data_in 			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	rx_dval 				: STD_LOGIC;
SIGNAL	rx_eop 				: STD_LOGIC;
SIGNAL	rx_sop 				: STD_LOGIC;
SIGNAL	src_ip 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	src_mac 				: STD_LOGIC_VECTOR(47 DOWNTO 0);
SIGNAL	tx_eop 				: STD_LOGIC;
SIGNAL	tx_packet_data 	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	tx_sop 				: STD_LOGIC;
SIGNAL	tx_wren 				: STD_LOGIC;
SIGNAL	tx_rdy				: STD_LOGIC;
SIGNAL	address_s			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	data_s		 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL   arp_req				: STD_LOGIC;
SIGNAL	arp_src_IP			: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	arp_src_MAC			: STD_LOGIC_VECTOR(47 downto 0);
SIGNAL   reg_RDOUT_num		: STD_LOGIC_VECTOR(3 downto 0);

SIGNAL	UDP_SYS_clk			: STD_LOGIC;

BEGIN 

clk_40MHz 		<= config_clk_40MHz;
WR_address 		<= address_s;
data				<= data_s;
reg_RDOUT_num	<= data_s(3 downto 0);
rd_strb 			<= rd_strb_in;



G_CLK_INST : G_CLK
	PORT MAP
	(
		inclk			=> clk_io,
		outclk		=> UDP_SYS_clk
	);

	 
mac_reg_cntl_inst : mac_reg_cntl
PORT MAP(clk 				=> clk_40MHz,
		 reset 				=> reset,
		 start 				=> start,
		 IP_LOC				=> x"01",
		 reg_busy 			=> reg_bsy,
		 mac_addr 			=> x"AABBCCDDEE00",
		 reg_data_out 		=> reg_data_out,
		 reg_rd 				=> reg_rd,
		 reg_wr 				=> reg_wr,
		 reg_addr 			=> reg_addr,
		 reg_data_in 		=> reg_data_in);		 
		 
		  
rx_frame_inst : rx_frame
PORT MAP(clk 				=> UDP_SYS_clk,
		 reset 				=> reset,
		 BRD_IP				=> BRD_IP,
		 rx_dval 			=> rx_dval,
		 rx_eop 				=> rx_eop,
		 rx_sop 				=> rx_sop,
		 rx_data_in 		=> rx_data_in,
		 WR_strb 			=> wr_strb,
		 RD_strb 			=> rd_strb_in,
		 IO_address 		=> address_s,
		 IO_data 			=> data_s,
		 src_IP 				=> src_ip,
		 src_MAC 			=> src_mac,
		 arp_req				=> arp_req,
		 ping_req			=> OPEN);

		 
		
		
tx_frame_inst : tx_frame
PORT MAP(clk 				=> UDP_SYS_clk,
		 reset 				=> reset, 
		 BRD_IP				=> BRD_IP,
		 BRD_MAC				=> BRD_MAC,		
		 
  		 system_status		=> system_status, 
		 header_user_info	=> header_user_info, 		 
		 FRAME_SIZE			=> FRAME_SIZE,
		 tx_fifo_clk 		=> tx_fifo_clk,
		 tx_fifo_in 		=> tx_fifo_in,		 		 
		 tx_fifo_wr 		=> tx_fifo_wr,
		 tx_fifo_full 		=> tx_fifo_full,
		 tx_fifo_used		=> tx_fifo_used,		 
		 tx_dst_rdy			=> '1',		 
		 tx_rdy				=>	tx_rdy,
		 tx_data_out 		=> tx_packet_data,		 
		 tx_eop_out 		=> tx_eop,
		 tx_sop_out 		=> tx_sop,
		 tx_src_rdy 		=> tx_wren,		 

		 ip_dest_addr 		=> src_ip,
		 mac_dest_addr 	=> src_mac,

		 reg_rd_strb 			=> rd_strb_in,		 
		 reg_start_address 	=> address_s,
		 reg_RDOUT_num			=> reg_RDOUT_num,
		 reg_address			=> RD_address,
		 reg_data 				=> rdout,
		 
		 TIME_OUT_wait		=> TIME_OUT_wait,
		 arp_req				=> arp_req);


tse_mac_inst : tse_mac
PORT MAP(
		 ff_tx_data 		=> tx_packet_data,
		 ff_tx_eop 			=> tx_eop,
		 ff_tx_err 			=> '0',
		 ff_tx_sop 			=> tx_sop,
		 ff_tx_wren 		=> tx_wren,
		 ff_tx_clk 			=> UDP_SYS_clk,	 
		 ff_rx_rdy 			=> '1',
		 ff_rx_clk 			=> UDP_SYS_clk,	 
		 address 			=> reg_addr,
		 read 				=> reg_rd,
		 writedata 			=> reg_data_in,
		 write 				=> reg_wr,
		 clk 					=> clk_40MHz,
		 reset 				=> reset,
		 rxp 					=> SPF_OUT,
		 ref_clk 			=> clk_125MHz,
		 ff_tx_crc_fwd 	=> '0',
		 reconfig_togxb	=> reconfig_togxb,
		 ff_tx_rdy 			=> tx_rdy,
		 ff_rx_data 		=> rx_data_in,
		 ff_rx_dval 		=> rx_dval,
		 ff_rx_eop 			=> rx_eop,
		 ff_rx_sop 			=> rx_sop,
		 rx_err 				=> open,
		 readdata 			=> reg_data_out,
		 waitrequest 		=> reg_bsy, 
		 led_an 				=> LED(0),
		 led_char_err 		=> LED(1),
		 led_link 			=> LED(2),
		 led_disp_err 		=> LED(3),
		 led_crs          => LED(4),
		 led_col          => open,
		 txp 					=> SFP_IN,
		 rx_recovclkout 	=> open,	 
		 ff_tx_septy 		=> open,
		 tx_ff_uflow 		=> open,
		 ff_tx_a_full 		=> open,
		 ff_tx_a_empty 	=> open,		 
		 rx_err_stat 		=> open,
		 rx_frm_type 		=> open,		 
		 ff_rx_dsav 		=> open,
		 ff_rx_a_full 		=> open,
		 ff_rx_a_empty 	=> open,	 
		 reconfig_fromgxb	=> reconfig_fromgxb,
		 gxb_cal_blk_clk  => gxb_cal_blk_clk, -- 125Mh
		 reconfig_clk     => clk_40MHz,   
		 reconfig_busy    => busy	 	 
		 );
	 		
			LED(5) <= clk_40MHz;
			
recon_inst : recon
PORT MAP(	
		reconfig_clk		=> clk_40MHz, 
		reconfig_fromgxb	=> reconfig_fromgxb,
		busy					=> busy,
		reconfig_togxb		=> reconfig_togxb	
	);

	 
END UDP_IO_arch;