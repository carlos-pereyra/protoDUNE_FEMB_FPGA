
library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



--  Entity Declaration

entity rx_frame is
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
end rx_frame;


--  Architecture Body

architecture rx_frame_arch OF rx_frame is

    type state_type is (IDLE,RX_DATA,DLY);
    signal state: state_type;
	 
	 
    signal framebytenum 		: INTEGER RANGE 0 TO 65535;
	 signal databytenum 			: INTEGER RANGE 0 TO 127;
	 signal len   					: std_logic_vector(15 downto 0);
	 signal cntvalsig     		: std_logic_vector(15 downto 0);
	 signal mac_lentype			: std_logic_vector(15 downto 0);
	 signal ip_version			: std_logic_vector(3 downto 0);
	 signal ip_ihl 				: std_logic_vector(3 downto 0);
	 signal ip_tos					: std_logic_vector(7 downto 0);
	 signal ip_totallen			: std_logic_vector(15 downto 0);		
	 signal ip_ident				: std_logic_vector(15 downto 0);		
	 signal ip_flags				: std_logic_vector(2 downto 0);		
	 signal ip_fragoffset		: std_logic_vector(12 downto 0);		
	 signal ip_ttl					: std_logic_vector(7 downto 0);					
	 signal ip_protocol			: std_logic_vector(7 downto 0);							
	 signal ip_header_chksum 	: std_logic_vector(15 downto 0);							
	 signal ip_src_addr			: std_logic_vector(31 downto 0);							
	 signal ip_dest_addr			: std_logic_vector(31 downto 0);							
	 signal udp_src_port			: std_logic_vector(15 downto 0);							
	 signal udp_dest_port		: std_logic_vector(15 downto 0);			
	 signal udp_len				: std_logic_vector(15 downto 0);			
	 signal udp_chksum			: std_logic_vector(15 downto 0);				 
	 signal key         			: std_logic_vector(31 downto 0);
 	 signal dest_addr				: std_logic_vector(47 downto 0);
	 signal src_addr				: std_logic_vector(47 downto 0);
	 signal address				: std_logic_vector(15 downto 0);
	 signal data					: std_logic_vector(31 downto 0);
	 signal strb					: std_logic; 
	 signal strb_dly				: std_logic; 
	 signal First_Packet_set	: std_logic; 
	 signal arp_IP_SRC			: std_logic_vector(31 downto 0); 
	 signal arp_IP_DST			: std_logic_vector(31 downto 0); 
 
BEGIN




machine: process(clk,reset) 

  begin
     if (reset = '1') then
         state              		<= idle;
			First_Packet_set			<= '0';
			dest_addr 					<= x"00000000000A"; 
			src_addr 					<= x"00000000000B";  		
         mac_lentype             <= x"0800"; 
		   ip_version					<= x"4";
		   ip_ihl						<= x"5";
			ip_tos						<= x"00";
			ip_totallen					<= x"041C";
			ip_ident						<= x"3DAA";
			ip_flags						<= "000";
			ip_fragoffset				<= (others => '0');
			ip_ttl						<= x"80";
			ip_protocol					<= x"11";
			ip_header_chksum			<= x"F115";
			ip_src_addr					<= x"01020309";
			ip_dest_addr				<= x"01020305";
			udp_src_port				<= x"7D00";
			udp_dest_port				<= x"7D01";
			udp_len						<= x"0408"; --length of UDP header(src_port, dest_prot, len, chksum) and data
			udp_chksum					<= x"0000"; --set to zero to disable checksumming
         key                     <= x"00000000";
			framebytenum            <= 0;
			databytenum					<= 0;
		   address 						<= (others => '0');
			data							<= (others => '0');
			strb							<= '0';
			arp_req						<= '0';
     elsif (clk'event AND clk = '1') then
        CASE state is
          when IDLE =>
		         key         	<= x"00000000";
					strb				<= '0';
					arp_req			<= '0';
               if (rx_sop = '1') and (rx_dval = '1')then
						state <= rx_data;	
						dest_addr(47 downto 40) <= rx_data_in;
						framebytenum <= 0;
						databytenum <= 0;
               end if;
           when RX_DATA =>
  					framebytenum <= framebytenum + 1;
					case framebytenum is 
					   when 0 =>      dest_addr(39 downto 32)   <= rx_data_in;
					   when 1 =>      dest_addr(31 downto 24)   <= rx_data_in;
					   when 2 =>      dest_addr(23 downto 16)   <= rx_data_in;
					   when 3 =>      dest_addr(15 downto 8)	  <= rx_data_in;
					   when 4 =>      dest_addr(7 downto 0)	  <= rx_data_in;
					   when 5 =>      src_addr(47 downto 40)	  <= rx_data_in;
					   when 6 =>      src_addr(39 downto 32)	  <= rx_data_in;
					   when 7 =>      src_addr(31 downto 24)	  <= rx_data_in;
					   when 8 =>      src_addr(23 downto 16)	  <= rx_data_in;
					   when 9 =>      src_addr(15 downto 8)	  <= rx_data_in;
					   when 10 =>     src_addr(7 downto 0)		  <= rx_data_in;   
					   when 11 =>     mac_lentype(15 downto 8)  <= rx_data_in;
					   when 12 =>     mac_lentype(7 downto 0)   <= rx_data_in;
						when 13 =>     ip_version                <= rx_data_in(7 downto 4);
						               ip_ihl                    <= rx_data_in(3 downto 0);
						when 14 =>     ip_tos                    <= rx_data_in;
						when 15 =>     ip_totallen(15 downto 8)  <= rx_data_in;
						when 16 =>     ip_totallen(7 downto 0)   <= rx_data_in;
						when 17 =>     ip_ident(15 downto 8)     <= rx_data_in;
						when 18 =>     ip_ident(7 downto 0)      <= rx_data_in;
						when 19 =>     ip_flags(2 downto 0)       <= rx_data_in(7 downto 5);
	                              ip_fragoffset(12 downto 8) <= rx_data_in(4 downto 0);
						when 20 =>     ip_fragoffset(7 downto 0)  <= rx_data_in;
						when 21 =>     ip_ttl						   <= rx_data_in;
						when 22 =>     ip_protocol					   <= rx_data_in;
						when 23 =>     ip_header_chksum(15 downto 8) <= rx_data_in;
						when 24 =>     ip_header_chksum(7 downto 0)  <= rx_data_in;
						when 25 =>     ip_src_addr(31 downto 24)     <= rx_data_in;
						when 26 =>     ip_src_addr(23 downto 16)     <= rx_data_in;
						when 27 =>     ip_src_addr(15 downto 8)      <= rx_data_in;
											arp_IP_SRC(31 downto 24)      <= rx_data_in;
						when 28 =>     ip_src_addr(7 downto 0)       <= rx_data_in;
											arp_IP_SRC(23 downto 16)      <= rx_data_in;
						when 29 =>     ip_dest_addr(31 downto 24)    <= rx_data_in;
											arp_IP_SRC(15 downto 8)       <= rx_data_in;
						when 30 =>     ip_dest_addr(23 downto 16)    <= rx_data_in;
											arp_IP_SRC(7 downto 0)        <= rx_data_in;
						when 31 =>     ip_dest_addr(15 downto 8)     <= rx_data_in;
						when 32 =>     ip_dest_addr(7 downto 0)      <= rx_data_in;						
						when 33 =>     udp_src_port(15 downto 8)     <= rx_data_in;
						when 34 =>     udp_src_port(7 downto 0)      <= rx_data_in;
						when 35 =>     udp_dest_port(15 downto 8)    <= rx_data_in;
						when 36 =>     udp_dest_port(7 downto 0)     <= rx_data_in;				
						when 37 =>     udp_len(15 downto 8)			   <= rx_data_in;
											arp_IP_DST(31 downto 24)		<= rx_data_in;
						when 38 =>     udp_len(7 downto 0)       		<= rx_data_in;						
											arp_IP_DST(23 downto 16)		<= rx_data_in;
						when 39 =>     udp_chksum(15 downto 8)     	<= rx_data_in;
											arp_IP_DST(15 downto 8)			<= rx_data_in;
						when 40 =>     udp_chksum(7 downto 0)     	<= rx_data_in;
											arp_IP_DST(7 downto 0)			<= rx_data_in;			
					   when 41 => 		key(31 downto 24)					<= rx_data_in;
											if (mac_lentype = x"0806") AND (arp_IP_DST = BRD_IP) then										 
												 src_MAC			<= src_addr;
												 src_IP			<= arp_IP_SRC;
												 arp_req  		<= '1';												 
											end if;		
						when 42 =>     key(23 downto 16)					<= rx_data_in;
						when 43 =>     key(15 downto 8)              <= rx_data_in;
						when 44 =>     key(7 downto 0)					<= rx_data_in;
						when 45 =>     address(15 downto 8)  			<= rx_data_in;
											strb									<= '0';
											arp_req  							<= '0';			
											 if  (key = x"deadbeef") and  (ip_dest_addr =  BRD_IP)  then 
													src_MAC						<= src_addr;
													src_IP						<= ip_src_addr;
											  end if;
											databytenum							<= databytenum + 1;
						when 46 =>		address(7 downto 0)  			<= rx_data_in;
											databytenum							<= databytenum + 1;
						when 47 =>		data(31 downto 24)	  	 	   <= rx_data_in;
											databytenum							<= databytenum + 1;	
						when 48 =>		data(23 downto 16)	  	 	   <= rx_data_in;
											databytenum							<= databytenum + 1;																										
						when 49 =>		data(15 downto 8)	  	 	   	<= rx_data_in;
											databytenum	<= databytenum + 1;											
						when 50 =>		data(7 downto 0)					<= rx_data_in;
											databytenum							<= databytenum + 1;
											if  (key = x"deadbeef") and  (ip_dest_addr = BRD_IP) and  (address /= x"FFFF") then
												strb	<= '1';
												framebytenum <= 45;
											end if;
						when others => databytenum	<= databytenum + 1;
											strb			<= '0';
					end case;			
             if ((rx_eop = '1') OR (rx_dval = '0')) then
							cntvalsig <= x"0010";
							state <= dly; 
				  end if;
           when DLY =>	
					strb		<= '0';
					arp_req	<= '0';
			      if (cntvalsig = x"0000") then
                 state <= idle;			  
             	else 
						cntvalsig <= cntvalsig - 1;
					end if;
					
        end case;
     end if;
  end process machine;
  
   
  
   process(clk,reset) 

  begin
     if (reset = '1') then
    
		   IO_address 						<= (others => '0');
			IO_data							<= (others => '0');
			WR_strb							<= '0';
			RD_strb							<= '0';
     elsif (clk'event AND clk = '1') then
			strb_dly			<= strb;
			if((udp_dest_port = x"7D00")) then
				WR_strb			<= strb_dly;
			elsif((udp_dest_port = x"7D01")) then
				RD_strb			<= strb_dly;
			else
				WR_strb							<= '0';
				RD_strb							<= '0';
			end if;
			if (strb = '1') then
				IO_address	<= address;
				IO_data		<= data;
			end if;
			
     end if;
  end process ;
  

END rx_frame_arch;
