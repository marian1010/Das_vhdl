
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- simulation library
library UNISIM;
use UNISIM.VComponents.all;

-- the mouse_controller entity declaration
-- read above for behavioral description and port definitions.
entity MouseCtl is
generic
(
   SYSCLK_FREQUENCY_HZ : integer := 100000000;
   CHECK_PERIOD_MS     : integer := 500; -- Period in miliseconds to check if the mouse is present
   TIMEOUT_PERIOD_MS   : integer := 100 -- Timeout period in miliseconds when the mouse presence is checked
);
port(
   clkFPGA     : in std_logic;
   reset       : in std_logic;
   xpos        : out std_logic_vector(11 downto 0);
   ypos        : out std_logic_vector(11 downto 0);
   zpos        : out std_logic_vector(3 downto 0);
   left        : out std_logic;
   middle      : out std_logic;
   right       : out std_logic;
   new_event   : out std_logic;
   value       : in std_logic_vector(11 downto 0);
   setx        : in std_logic;
   sety        : in std_logic;
   setmax_x    : in std_logic;
   setmax_y    : in std_logic;
   
   debug    :out std_logic_vector(7 downto 0);
   
   ps2_clk     : inout std_logic;
   ps2_data    : inout std_logic
   
);
end MouseCtl;

architecture Behavioral of MouseCtl is


component Ps2Interface is
port(
   ps2_clk  : inout std_logic;
   ps2_data : inout std_logic;

   clk      : in std_logic;
   rst      : in std_logic;

   tx_data  : in std_logic_vector(7 downto 0);
   write_data : in std_logic;
   
   rx_data  : out std_logic_vector(7 downto 0);
   read_data  : out std_logic;
   busy     : out std_logic;
   err      : out std_logic

);
END COMPONENT;

    type states  is (send_reset,reciv_ack,reciv_bat,reciv_device_id,send_stream,reciv_ack_stream,reciv_ack1,reciv_ack2,reciv_ack3,reciv_ack4,new_data);
    signal state, next_state:states;
    
    signal tx_data        :  std_logic_vector(7 downto 0);
    signal write_data     :  std_logic;
    signal rx_data        :  std_logic_vector(7 downto 0);
    signal read_data      :  std_logic;
    signal err            :  std_logic;
    signal busy           :  std_logic;
    signal more_states       :  std_logic;
    signal new_mouse_data : std_logic;
    signal mouse_state    :std_logic_vector(7 downto 0) ;
    signal x_mov    :std_logic_vector(7 downto 0) ;
    signal x_pos    :std_logic_vector(11 downto 0) ;
    signal y_mov    :std_logic_vector(7 downto 0) ;
    signal y_pos    :std_logic_vector(11 downto 0) ;
    signal z_mov    :std_logic_vector(7 downto 0) ;
    signal z_pos    :std_logic_vector(3 downto 0) ;
    
    signal max_x      :std_logic_vector(11 downto 0):=x"52D" ; 
    signal max_y      :std_logic_vector(11 downto 0):=x"3FF" ; 
begin
    
    debug<=(others=>'0');
    
    ps2Inter:Ps2Interface port map (ps2_clk,ps2_data,clkFPGA,reset,tx_data,write_data,rx_data,read_data,busy ,err);
    
    pos_actulice:process(clkFPGA)
    variable inter_x: std_logic_vector(11 downto 0);
    variable inter_y: std_logic_vector(11 downto 0);
    variable inc_x: std_logic_vector(11 downto 0);
    variable inc_y: std_logic_vector(11 downto 0);
    begin
    if(clkFPGA'event and clkFPGA='1')then
        if(sety='1')then 
           ypos<=value;
        elsif(setx='1')then
           xpos<=value;
        elsif(new_mouse_data='1')then   
          if (mouse_state(4)='1')then   --sign x
            if(mouse_state(6)='1')then --overflow x
              inc_x:= "1111"&x"00";
            else 
              inc_x:= "1111"&x_mov; 
            end if;
            inter_x:= x_pos + inc_x;
            if(inter_x(11)='1')then
                x_pos<= (others=>'0');
            else
                x_pos<= inter_x;
            end if;
          else
            if(mouse_state(6)='1')then --overflow x
            inc_x:="0001"&x"00";
             else
            inc_x:="0001"&x_mov; 
            end if;
            inter_x:= x_pos + inc_x;
            if(inter_x > (max_x))then
            x_pos<= max_x;
            else 
            x_pos<=inter_x;
            end if;
          end if;
          
          if(mouse_state(5)='1')then    --sign y
            if(mouse_state(7)='1')then --overflow y
                inc_y:= "1111"&x"00";
            else
                inc_y:= "1111"&y_mov;     
            end if;
            inter_y:= y_pos + inc_y;
            if(inter_y(11) = '1')then
                y_pos<= (others=>'0');
            else
                y_pos<= inter_y;
            end if;
          else
            if(mouse_state(7)='1')then --overflow y
                inc_y :="0001" &x"00";
            else
                inc_y :="0000" &y_mov;  
            end if;
            inter_y:= y_pos + inc_y;  
            
            if(inter_y >(max_y))then
                y_pos<= max_y;
            else
                y_pos<= inter_y;
            end if;
           end if;  
        end if;
    end if;    
    end process pos_actulice;
    
    left <=mouse_state(0) when (clkFPGA'event and clkFPGA='1');
    
    middle<=mouse_state(2) when (clkFPGA'event and clkFPGA='1');
    
    right<=mouse_state(1) when (clkFPGA'event and clkFPGA='1');
    
    ypos<= y_pos when (clkFPGA'event and clkFPGA='1');
    
    xpos<= x_pos when (clkFPGA'event and clkFPGA='1');
    
    sincronus: process(clkFPGA,reset)
    begin 
        if reset='1' then 
            state<=send_reset;
        elsif clkFPGA'event and clkFPGA ='1' then
            state<= next_state;
       end if;
    end process sincronus;
    
    output: process(state)
    begin
        write_data<='0';
    case state is
        when send_reset=>               
        tx_data<= X"00";
        write_data<='1';
        zpos<= (others=>'0');
        new_event<='0';
        more_states<='0';
        new_mouse_data<='0';
        
        when reciv_ack=>             

        when reciv_bat=>                  
   
        
        when reciv_device_id=>   
        if(read_data='1')then
            if(rx_data=x"00")then
            more_states<='0';
            elsif(rx_data=x"03")then
            
            more_states<='1';
            else 
            end if;
        end if;    
        when reciv_ack_stream=>
        when send_stream=> 
        write_data<='1';
        tx_data<= X"F4";
        when reciv_ack1=>             
            if(read_data='1')then 
            mouse_state<= rx_data;
            end if;
        when reciv_ack2=>
            if(read_data='1')then 
            x_mov<= rx_data;
            end if;
        when reciv_ack3=>
            if(read_data='1')then 
            y_mov<= rx_data;
                if(more_states='0')then
                new_mouse_data<='1';
                else 
                new_mouse_data<='0';
                end if;
            end if;
        when reciv_ack4=>
            if(read_data='1')then 
            z_mov<= rx_data;
            new_mouse_data<='1';
            end if;
         when new_data=>
            new_event<='1'; 
            
      end case;
      end process output;   
 
    change_state: process (state) 
    begin 
    case state is 
        when send_reset=>               
         next_state<=reciv_ack;
         
        when reciv_ack=>             
        if(read_data='1')then
            if(rx_data=x"FA")then
            next_state<=reciv_bat;
            else
            next_state<=send_reset;  
            end if;
        elsif(err='1')then
             next_state<=send_reset;  
        else 
             next_state<=reciv_ack;     
        end if;
        
        when reciv_bat=>                  
        if(read_data='1')then
            if(rx_data=x"AA")then
            next_state<=reciv_device_id;
            else
            next_state<=send_reset;  
            end if;
        elsif(err='1')then
             next_state<=send_reset;  
        else 
             next_state<=reciv_bat;     
        end if;
        
        
        when reciv_device_id=>   
         if(read_data='1')then
            if(rx_data=x"00")then
            next_state<=send_stream;
            elsif(rx_data=x"03")then
            next_state<=send_stream;
             
            else
            next_state<=send_reset;  
            end if;
        elsif(err='1')then
             next_state<=send_reset;  
        else 
             next_state<=reciv_bat;     
        end if;
        when send_stream=> 
            next_state<=reciv_ack_stream;
        when reciv_ack_stream=>
          if(read_data='1')then
            if(rx_data=x"FA")then
            next_state<=reciv_ack1;
            else
            next_state<=send_reset;  
            end if;
        elsif(err='1')then
             next_state<=send_reset;  
        else 
             next_state<=reciv_ack_stream;     
        end if;
        when reciv_ack1=>             
            if(read_data='1')then 
            next_state<= reciv_ack2; 
            elsif err='1' then
            next_state<= send_reset; 
            else
            next_state<= reciv_ack1;
            
            end if;
        when reciv_ack2=>
            if(read_data='1')then 
            next_state<= reciv_ack3; 
            elsif err='1' then
            next_state<= send_reset; 
            else
            next_state<= reciv_ack2;
            
            end if;
        when reciv_ack3=>
            if(read_data='1')then 
                if more_states='0'then 
                next_state<= reciv_ack1;
                else 
                next_state<= reciv_ack4;
                end if; 
            elsif err='1' then
            next_state<= send_reset; 
            else
            next_state<= reciv_ack3;
            
            end if;
        when reciv_ack4=>
            if(read_data='1')then 
            next_state<= new_data; 
            elsif err='1' then
            next_state<= send_reset; 
            else
            next_state<= reciv_ack4;
            
            end if;  
        when new_data=>    
           next_state<= reciv_ack1;               
        end case;
                         
    end process change_state;  
    
end architecture ;