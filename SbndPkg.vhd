LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

package SbndPkg is
   type SL_ARRAY_1_TO_0 	is array (natural range <>) of STD_LOGIC_VECTOR(1 downto 0);	
   type SL_ARRAY_7_TO_0	  	is array (natural range <>) of STD_LOGIC_VECTOR(7 downto 0);		
   type SL_ARRAY_15_TO_0	is array (natural range <>) of STD_LOGIC_VECTOR(15 downto 0);	
   type SL_ARRAY_16_TO_0	is array (natural range <>) of STD_LOGIC_VECTOR(16 downto 0);		
	type ADC_array 	 		is array (natural range <>) of std_logic_vector(191 downto 0);
	type I2C_data_type      is array (natural range <>) of STD_LOGIC_VECTOR(31 downto 0);	
	type I2C_address_type   is array (natural range <>) of STD_LOGIC_VECTOR(11 downto 0); 
	type I2C_WR_type    	 	is array (natural range <>) of STD_LOGIC;	
	type I2C_data_out_type  is array (natural range <>) of STD_LOGIC_VECTOR(31 downto 0);	
	
	
	
	
   function PRBS_GEN (input : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR;
end package;

package body SbndPkg is

   function PRBS_GEN (input : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
      variable temp : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
   begin
      for i in (14) downto 0 loop
         temp(i) := input(i+1);
      end loop;	
      temp(15) := input(15) xor input(4) xor input(2) xor input(1);
      return temp;
   end function;

end package body SbndPkg;