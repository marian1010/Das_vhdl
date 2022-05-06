----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.03.2022 13:08:05
-- Design Name: 
-- Module Name: conversor_display - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity conversor_display is
      Port (bin :in std_logic_vector (2 downto 0);
            disp:out std_logic_vector(7 downto 0)
       );
end conversor_display;

architecture Behavioral of conversor_display is

begin
    disp<= "11000000" when bin ="000" else
           "11111001" when bin ="001" else
           "10100100" when bin ="010" else
           "10110000" when bin ="011" else
           "10011001" when bin ="100" else
           "10010010" when bin ="101" else
           "10000010" when bin ="110" else
           "11111000" when bin ="111" else
           "11111111";
          

end Behavioral;
