--------------------------------------------------------------------
--  MODULE NAME: stretch

--  FUNCTIONAL DESCRIPTION:
--  This module will stretch a clock pulse by length clock ticks.
--  Useful for status LEDs.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



--  Entity Declaration

entity MAC_REG_CNTL is
	port
	(
		clk         		: in  std_logic;                     -- Input CLK from MAC Reciever
		reset					: in  std_logic;                     -- Synchronous reset signal
		start					: in  std_logic;                     -- Synchronous reset signal
		IP_LOC				: in std_logic_vector(7 downto 0);  
		mac_addr				: in  std_logic_vector(47 downto 0);
		reg_addr				: out std_logic_vector(7 downto 0);  
		reg_data_in			: out std_logic_vector(31 downto 0); 
		reg_rd				: out  std_logic;                    
		reg_wr				: out  std_logic;                    
		reg_data_out		: in std_logic_vector(31 downto 0);  
		reg_busy				: in  std_logic
		
		);
end MAC_REG_CNTL;


--  Architecture Body

architecture MAC_REG_CNTL_arch OF MAC_REG_CNTL is



component al_const_wren
	PORT
	(
		result		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
end component;



component mac_reg_read
	PORT
	(
		result		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;


component al_const_32bit
	PORT
	(
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;


      type stm_typ is (IDLE, READ_VER, WR_SCRATCH, RD_SCRATCH,WR_mac0,WR_mac1,WR_CMD_CONF,WR_CMD_CONF2,S_USER_WRITE,S_WAIT,WR_Dev_Ability,DONE) ;

       signal state            : stm_typ ;
       signal nextstate        : stm_typ ;
		 signal busy				 : std_logic;
		 signal busy_dly			 : std_logic; 
		 signal reg_rd_data		 : std_LOGIC_VECTOR( 15 downto 0);
		 
		 signal reg_rd_addr		 : std_LOGIC_VECTOR( 7 downto 0);
		 signal reg_wr_data		 : std_LOGIC_VECTOR( 31 downto 0);
		 signal wr_EN			 	 : std_LOGIC;	 

 		 signal ireg_rd_addr		 : std_LOGIC_VECTOR( 7 downto 0);
		 signal ireg_wr_data		 : std_LOGIC_VECTOR( 31 downto 0);
		 signal iwr_EN			 	 : std_LOGIC_VECTOR( 0 downto 0);
	 
BEGIN


 al_const_wren_inst :  al_const_wren
	PORT MAP (result				=> iwr_EN);
	
	
 al_const_addr_inst :  mac_reg_read
	PORT MAP (result				=> ireg_rd_addr);
	
	
 al_const_32bit_inst :  al_const_32bit
	PORT MAP (result				=> ireg_wr_data);
	
	
		 
        process(state,start, reg_busy,wr_EN)
        begin
                case state is
                
                        when IDLE =>
                        
                                if (start='1' ) then
                                
													nextstate <= READ_VER ;

                                else
                            
                                        nextstate <= IDLE ;
                                        
                                end if ;

                        when READ_VER =>
                        
                                if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <= WR_SCRATCH ;
                                        
                                else
                                
                                        nextstate <= READ_VER ;
                                        
                                end if ;
                                
                        when WR_SCRATCH =>
                        
                                if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <= RD_SCRATCH ;
                                        
                                else
                                
                                        nextstate <= WR_SCRATCH ;
                                        
                                end if ;
                                
                        when RD_SCRATCH =>
                        
                                if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <=  WR_mac0 ;
                                        
                                else
                                
                                        nextstate <= RD_SCRATCH ;
                                        
                                end if ; 
	
								when WR_mac0 =>
										  
								        if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <=  WR_mac1 ;
                                        
                                else
                                
                                        nextstate <= WR_mac0 ;
                                        
                                end if ; 		  
								when WR_mac1 =>
										  
								        if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <= WR_Dev_Ability ;
                                        
                                else
                                
                                        nextstate <= WR_mac1 ;
                                        
                                end if ; 		  
			
			
										  
								when WR_Dev_Ability =>
								
								        if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <=  WR_CMD_CONF ;													 
                                        
                                else
                                
                                        nextstate <= WR_Dev_Ability ;
                                        
                                end if ; 											  
										  
  
								when WR_CMD_CONF =>
										  
								        if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <=  WR_CMD_CONF2 ;
                                        
                                else
                                
                                        nextstate <= WR_CMD_CONF ;
                                        
                                end if ; 	
										  
										  
								when WR_CMD_CONF2 =>
										  
								        if (busy ='0' and busy_dly = '1') then
                                
                                        nextstate <=  DONE ;
                                        
                                else
                                
                                        nextstate <= WR_CMD_CONF2 ;
                                        
                                end if ; 	
										  										  
										  
										  
										  
										  
										  
										  
									when S_USER_WRITE =>
										  if (busy ='0' and busy_dly = '1') then
                                        nextstate <=  S_WAIT ;   
                                else
                                        nextstate <= S_USER_WRITE ;
                                end if ; 								
									when S_WAIT =>	  
										if (busy ='0' and busy_dly = '1') then
                                
													if(wr_EN = '1') then
														nextstate <=  S_WAIT ;
													else
														nextstate <=  DONE ;
													end if;
                                else
                                
                                         nextstate <=  S_WAIT ;
                                        
                                end if ; 	

									when DONE =>
									
										if (busy ='0' and busy_dly = '1') then
													if(wr_EN = '1') then
														nextstate <=  S_USER_WRITE ;
													else
														nextstate <=  DONE ;
													end if;
                                else
                                
                                         nextstate <=  DONE ;
                                        
                                end if ; 	
								  	  						  
                        when others  =>
                                                                                     
                                nextstate <= IDLE ;
                end case ;
                
        end process ;


        process(reset, clk)
        
        begin
                if (reset='1') then
                
                        reg_wr      <= '0' ;
                        reg_rd      <= '0' ;
                        reg_addr    <= (others=>'0') ;
                        reg_data_in <= (others=>'0') ;
                        
                elsif (clk='1') and (clk'event) then
					 
					
					 			if (nextstate=IDLE) then
                                reg_wr      <= '0'  ;
                                reg_rd      <= '0'  ;
                                reg_addr    <= x"00";
                                reg_data_in <= (others=>'0') ; 
					 
								elsif (nextstate=READ_VER) then
                                reg_wr      <= '0'  ;
                                reg_rd      <= '1'  ;
                                reg_addr    <= x"00";
                                reg_data_in <= (others=>'0') ; 
                        
                        elsif (nextstate=WR_SCRATCH) then
                
                                reg_wr      <= '1' ;
                                reg_rd      <= '0' ;
                                reg_addr    <= x"01";
                                reg_data_in <= X"AAAAAAAA" ;
                        
                        elsif (nextstate=RD_SCRATCH) then
                                reg_wr      <= '0' ;
                                reg_rd      <= '1' ;
                                reg_addr    <= x"01";
                                reg_data_in <= X"00000000" ; 

								elsif (nextstate=WR_mac0) then
                
                                reg_wr      <= '1' ;
                                reg_rd      <= '0' ;
                                reg_addr    <= x"03";
                                reg_data_in <= X"ddccbbaa" ;

								elsif (nextstate=WR_mac1) then
                
                                reg_wr      <= '1' ;
                                reg_rd      <= '0' ;
                                reg_addr    <= x"04";
                                reg_data_in <= X"0000" & IP_LOC & X"ee";
										  
								elsif (nextstate=WR_Dev_Ability ) then
								
                                reg_wr      <= '1' ;
                                reg_rd      <= '0' ;
                    --            reg_addr    <= x"80";
                     --           reg_data_in <= X"00000000" ; 										  
                                reg_addr    <= x"84";
                                reg_data_in <= X"000001E0" ; 										  

								elsif (nextstate=WR_CMD_CONF) then
                
                                reg_wr      <= '1' ;
                                reg_rd      <= '0' ;
                                reg_addr    <= x"02";
                            --    reg_data_in <= X"0400002B" ;
										  reg_data_in <= X"0000003B" ;
										  
								elsif (nextstate=S_USER_WRITE) then
                
                                reg_wr      <= '1' ;
                                reg_rd      <= '0' ;
                                reg_addr    <= reg_rd_addr;
										  reg_data_in <= reg_wr_data;
								elsif (nextstate=S_WAIT) then
								 
                                reg_wr      <= '0' ;
                                reg_rd      <= '1' ;
                                reg_addr    <= reg_rd_addr;
                            --    reg_data_in <= X"00000000" ; 										  
										  		  
								elsif (nextstate=DONE) then
								 
                                reg_wr      <= '0' ;
                                reg_rd      <= '1' ;
                                reg_addr    <= reg_rd_addr;
                        --        reg_data_in <= X"00000000" ; 	  
								end if ;
                        
                end if ;
                                
        end process ;


		  
		  
	   -- Control State Machine
   -- ---------------------
   
        process(reset, clk,reg_wr_data,wr_EN,reg_rd_addr)
        begin
        
                if (reset='1') then       
                        state <= IDLE ;
                elsif (clk='1') and (clk'event) then
								busy				<= reg_busy;	
								busy_dly			<= busy;	
								state 			<= nextstate ;
                     	reg_wr_data		<= ireg_wr_data;	
								reg_rd_addr		<=	ireg_rd_addr;
								wr_EN				<= iwr_EN(0);
								if(reg_busy	 = '0') then 
									reg_rd_data		<=  reg_data_out(15 downto 0);
								end if;
                end if ;  
        end process ;
        	  

END MAC_REG_CNTL_arch;
