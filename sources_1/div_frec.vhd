----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.02.2022 13:51:48
-- Design Name: 
-- Module Name: div_frec - Behavioral
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

entity div_frec is
  Port (clkFPGA  :in std_logic;
        cuentamax:in std_logic_vector(26 downto 0);
        reset    :in std_logic;
        clkOUT   :out std_logic);
  
end div_frec;
-- cuentamax:in std_logic_vector(26 downto 0); 
---0101 1111 0101 1110 0001 0000 0000 
-- valor de cuentamax para frecuencia de 1hz
architecture Behavioral of div_frec is
       signal cuenta: std_logic_vector (26 downto 0); 
       signal clk: std_logic ;
        
begin
   
    clkOUT<=clk;
        
    cont:process(clkFPGA,reset) is  
    
    begin 
        if(reset = '1') then 
           cuenta<=(others=>'0');
           clk<='0';
        elsif(clkFPGA'event and clkFPGA='1') then 
           if(cuenta = cuentamax) then 
            clk<=not clk;
             cuenta<=(others=>'0');
           else 
              cuenta<=cuenta+1; 
           end if;
        end if;
    end process;
end Behavioral;
