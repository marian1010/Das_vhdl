----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.02.2022 13:01:54
-- Design Name: 
-- Module Name: cont_mod8 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cont_mod8 is
  Port ( clk:    in std_logic;
         e: in std_logic;
         rst : in std_logic;
         cont  : out std_logic_vector(2 downto 0)  );
end cont_mod8;

architecture Behavioral of cont_mod8 is
       signal cuenta: std_logic_vector (2 downto 0);
begin
        cont<=cuenta;
      contador:process(clk,rst) is
       begin
       if(rst ='1') then 
        cuenta<="000";
       elsif(clk'event and clk='1' and e='1') then 
           cuenta<=cuenta+'1'; 
       end if;
       end process;
       
end Behavioral;
