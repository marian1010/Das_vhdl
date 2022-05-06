----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.03.2022 14:27:12
-- Design Name: 
-- Module Name: keypad - Behavioral
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

entity keypad is
     Port ( 
        PS2Clk : in std_logic;
        PS2Data: in std_logic;
        reset  : in std_logic;
        keypush   : out std_logic_vector(7 downto 0);
        newkey    : out std_logic
     );
end keypad;

architecture Behavioral of keypad is

   signal scancode : std_logic_vector (21 downto 0);

begin
    keypush(7 downto 0) <= scancode(19 downto 12);

    newkey <= '1' when (scancode(8 downto 1) = X"F0") else '0';    
    
    key:process(PS2Clk,PS2Data) is
        begin
        if(reset='1') then 
        scancode(21 downto 0)<=(others =>'0');
        elsif(PS2Clk'event and PS2Clk = '0') then
 
        scancode(21 downto 0) <= PS2Data & scancode(21 downto 1);        

        end if;
    end process;
    
end Behavioral;
