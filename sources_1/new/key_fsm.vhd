----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.03.2022 14:17:10
-- Design Name: 
-- Module Name: key_fsm - Behavioral
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

entity key_fsm is
      Port (clkFPGA : in std_logic ;
            reset   : in std_logic ;
            key     : in std_logic_vector(7 downto 0);
            newkey  : in std_logic;
            action  :  out std_logic_vector(1 downto  0);
            rst     : out std_logic);
   end key_fsm;

architecture Behavioral of key_fsm is
    type states  is (S0,S1,S2);
    signal state, next_state:states;

begin
    
    sincronus: process(clkFPGA,reset)
    begin 
        if reset='1' then 
            state<=S0;
        elsif clkFPGA'event and clkFPGA ='1' then
            state<= next_state;
       end if;
    end process sincronus;
    
    output: process(state)
    begin
    case state is
        when S0=>
        rst<='0';
        action<="00";
        when S1=>
        rst<='1';  
        action<="01";
        when S2=>
        rst<='1';
        action<="10";
      end case;
      end process output;   
 
    change_state: process (state,key) 
    begin 
    case state is 
        when S0=>
        if (newkey='1' and key(7 downto 0)=X"75") then
            next_state <=S1;
        elsif( newkey='1' and  key(7 downto 0) = X"72")then
            next_state <=S2;
        else 
            next_state <=S0;           
        end if;
        when S1=>                   --Movimiento superior
            next_state <=S0;           
        when S2=>                   --Movimiento inferior
             next_state <=S0;                             
        end case;
                         
    end process change_state;       
end Behavioral;
