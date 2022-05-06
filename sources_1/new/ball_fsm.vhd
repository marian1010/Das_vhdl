----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2022 14:17:46
-- Design Name: 
-- Module Name: bell_fsm - Behavioral
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

entity ball_fsm is
      Port (clkFPGA : in std_logic ;
            reset   : in std_logic ;
            posY    : in std_logic_vector(11 downto 0);
            posX    : in std_logic_vector(11 downto 0);
            mouseY  : in std_logic_vector(11 downto 0);
            mouseX  : in std_logic_vector(11 downto 0);
            click   : in std_logic;
            rebote  : out std_logic;
            newBallMove: out std_logic_vector(1 downto 0));
end ball_fsm;

architecture Behavioral of ball_fsm is

    type states  is (S0,S1,S2,S3);
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
    if(click='1' and mouseY>=posY and mouseY<posY+20 and mouseX>=posX and mouseX<posX+20) then       --Rebote con la barra
       rebote<='1';         
    else 
       rebote<='0';
    end if;
    case state is
        when S0=>               --Diagolal derecha inferior
        newBallMove<="00";
        when S1=>               --Diagonal drecha superior
        newBallMove<="01";
   
        when S2=>                --Diagonal izq inferior  
        newBallMove<="10";
        
        when S3=>                 --Diagonal iz sup
        newBallMove<="11";
        
      end case;
      end process output;   
 
    change_state: process (state,posX,posY) 
    begin 
    case state is 
        when S0=>
        if(posX=X"500") then    
            next_state <=S2;
        elsif(posY=X"3d1")then
            next_state <=S1;
        else 
            next_state <=S0;
        end if;
        when S1=>
            if(posY=X"019") then
            next_state <=S0;
            elsif(posX=X"500") then
            next_state <=S3;
            else            
            next_state <=S1;
            end if;
        when S2=>
             if (posY=X"3d1") then
             next_state <=S3; 
             elsif (posX=X"019" )then

             next_state <=S0;
             else
             next_state <=S2;
             end if;
        when S3=>
             if(posY=X"019")then
             next_state <=S2;
             elsif (posX=X"019")then
             next_state <=S1;
             else 
             next_state <=S3;
             end if;                       
        end case;
                         
    end process change_state;  

end Behavioral;
