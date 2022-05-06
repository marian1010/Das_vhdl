----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.02.2022 13:10:36
-- Design Name: 
-- Module Name: Ram - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ram is
     Port (clkFPGA:in std_logic;
           we:in std_logic;
           data_in:in std_logic_vector(11 downto 0);
           data_out:out std_logic_vector(11 downto 0);
           addr:in std_logic_vector(2 downto 0));
end Ram;

architecture Behavioral of Ram is
      type ram_type is array (7 downto 0) of std_logic_vector(11 downto 0);--definimos una ram de 8 palabras con 8 bits
      signal  RAM: ram_type:= (X"F00",X"FF0",X"F10",X"F50",X"F80",X"330",X"660",X"167");--inicializamos la ram a los coleres 
begin
    data_out<=RAM(to_integer(unsigned(addr)));--lectura asincrona de la ram

         wirite:process (clkFPGA)is
         begin
            if(clkFPGA'event and clkFPGA ='1') then --realizamos la  escritura sincrona
                if (we='1')then
                 RAM(to_integer(unsigned(addr)))<=data_in; --escribimos en la ram
                end if;
            end if;    
         end process;
      
      
end Behavioral;
