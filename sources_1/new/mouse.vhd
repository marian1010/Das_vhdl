
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

entity mouse is 
   Port (   ps2_clk        : inout std_logic;
   ps2_data       : inout std_logic;
   clkFPGA            : in std_logic;
   reset          : in std_logic;
   tx_data        : in std_logic_vector(7 downto 0);
   write_data     : in std_logic;
   rx_data        : out std_logic_vector(7 downto 0);
   read_data      : out std_logic;
   busy           : out std_logic;
   debug    :out std_logic_vector(7 downto 0);
   err            : out std_logic          
         );
end mouse;

architecture Behavioral of mouse is
 
    type states_send  is (idle,rts,start,start2,data,stop,reading,send_error,stop2);
    signal state_send, next_state_send:states_send;
    
    constant DEBOUNCE_DELAY : std_logic_vector(3 downto 0)  := "1111";
    
    signal send0,send: std_logic; 
  
    signal cont: std_logic_vector(19 downto 0);
    signal cont20hz: std_logic_vector(11 downto 0);
    signal cont63hz,cont10clk: std_logic_vector(7 downto 0);
       
    signal read:   std_logic_vector(10 downto 0);
    --signal Regread:   std_logic_vector(32 downto 0);
    --signal xdir:   std_logic_vector(7 downto 0);
    signal scrol:   std_logic_vector(7 downto 0);
    
    --signal rst :std_logic ;
    
    signal check:   std_logic_vector(9 downto 0); --anadimos el bit de paridad y stop
    signal mouse_rst:   std_logic_vector(9 downto 0); 
     
    signal new_data_cont:   std_logic_vector(7 downto 0); 
    signal ready_new_data:   std_logic; 
    
    signal active,active_data: std_logic;
    
    signal clk_count,data_count: std_logic_vector(3 downto 0);
    signal ps2_clk_clean,ps2_data_clean: std_logic := '1';
    
    signal done,done20hz,done63hz,done10:std_logic;
 
    signal ps2_clk_s,ps2_data_s :std_logic;
    
    signal ps2_clk_out,ps2_data_out:std_logic;
    signal tristate_c,tristate_d:std_logic;
    signal send_rst: std_logic;
    
    signal rueda:std_logic;
    
    signal clk_inter,data_inter: std_logic := '1';
    

    
begin
 
--ydir(3 downto 0) <= read (26 downto 23);

    ps2_clk <= ps2_clk_out  when tristate_c ='1' else 'Z';
    ps2_data<= ps2_data_out when tristate_d ='1' else 'Z';
    
    err<= '0';
   
    ps2_clk_s <= ps2_clk_clean when (clkFPGA'event and clkFPGA ='1');
    ps2_data_s <= ps2_data_clean when (clkFPGA'event and clkFPGA ='1');
   
    --div:div_frec port map(clkFPGA,cont_clk,rst,clk);
    
   process(clkFPGA)
   begin
      if(rising_edge(clkFPGA)) then
         -- if the current bit on ps2_clk is different
         -- from the last value, then reset counter
         -- and retain value
         if(ps2_clk /= clk_inter) then
            clk_inter <= ps2_clk;
            clk_count <= (others => '0');
         -- if counter reached upper limit, then
         -- the signal is clean
         elsif(clk_count = DEBOUNCE_DELAY) then
            ps2_clk_clean <= clk_inter;
         -- ps2_clk did not change, but counter did not
         -- reach limit. Increment counter
         else
            clk_count <= clk_count + 1;
         end if;
      end if;
   end process;
    
   process(clkFPGA)
   begin
      if(rising_edge(clkFPGA)) then
         -- if the current bit on ps2_data is different
         -- from the last value, then reset counter
         -- and retain value
         if(ps2_data /= data_inter) then
            data_inter <= ps2_data;
            data_count <= (others => '0');
         -- if counter reached upper limit, then
         -- the signal is clean
         elsif(data_count = DEBOUNCE_DELAY) then
            ps2_data_clean <= data_inter;
         -- ps2_data did not change, but counter did not
         -- reach limit. Increment counter
         else
            data_count <= data_count + 1;
         end if;
      end if;
   end process;
    
    reg:process(clkFPGA,reset) is
    begin
    if reset='1' then
    rx_data<=(others=>'0');
    --ydir<=(others=>'0');
    elsif(clkFPGA'event and clkFPGA='1' )then
        if  ready_new_data='1' then
        rx_data <= read(8 downto 1) ;
        read_data <= '1'; 
        else
        read_data <= '0'; 
        end if;
    end if;
    end process;
    
   mouse:process(PS2_CLK,PS2_DATA,reset,read) is
        begin
        if(reset='1') then 
        new_data_cont<=X"0B"; 
        read(10 downto 0)<=(others =>'0');
        elsif(state_send=reading and  ps2_clk_s'event and ps2_clk_s = '0')then
        
            read(10 downto 0) <= ps2_data_s & read(10 downto 1);  
            
            if new_data_cont=X"00"  then
            ready_new_data<='1';
            new_data_cont<=X"0B"; 
            else
            ready_new_data<='0';
            new_data_cont<=new_data_cont-1;
            end if;
        end if;
    end process;
    
    tristate_control: process(state_send,active) is
    
    begin 
        if  send='1' or send0='1' then   
            if active='0' then 
             tristate_c<='1';
            else
             tristate_c<='0';   
            end if;
        tristate_d<='1';
        
        else
        tristate_c<='0';
        tristate_d<='0';
        
        end if;
        
        if active='0' then
            ps2_clk_out<='0';
            else
            ps2_clk_out<= ps2_clk;
        end if;
        
    end process;
    
    sendData:process(PS2_CLK,PS2_DATA) is
    begin

            if(send0='1')then
            ps2_data_out<='0';
            check(7 downto 0)<=tx_data;
            
            check(8) <=not(tx_data(7) xor tx_data(6) xor tx_data(5) xor tx_data(4) xor tx_data(3) xor tx_data(2) xor tx_data(1)xor tx_data(0));
            check(9)<= '1';
            elsif(send='1' and  ps2_clk_s'event and ps2_clk_s='0')then
          
                    ps2_data_out<=check(0);
                    check(9 downto 0)<='0' &check(9 downto 1);
  
        end if;
    end process;
    
    cuentaclk100khz: process(clkFPGA,state_send,reset) is
    begin

    if reset='1' then 
     done<='0';
     cont<=X"02710";
    elsif(state_send = rts and clkFPGA'event and clkFPGA='1' )   then
        if cont=0 then
        done<='1';
        cont<=X"02710";
        else 
        cont<=cont-1;
        done <='0'; 
        end if;   
    end if;
    end process;
    
    
    
    cuentaclk20khz: process(clkFPGA,state_send,reset) is
    begin

    if reset='1' then 
     done20hz<='0';
     cont20hz<=X"7D0";
    elsif(state_send=start and clkFPGA'event and clkFPGA='1' )   then
        if cont20hz=0 then
        done20hz<='1';
        cont20hz<=X"7D0";
        else 
        cont20hz<=cont20hz-1;
        done20hz <='0'; 
        end if;   
    end if;
    end process;
    
    cuentaclk63clk: process(clkFPGA,state_send,reset) is
    begin

    if reset='1' then 
     done63hz<='0';
     cont63hz<=X"7F";
    elsif(state_send=start2 and clkFPGA'event and clkFPGA='1' )   then
        if cont63hz=0 then
        done63hz<='1';
        cont63hz<=X"7F";
        else 
        cont63hz<=cont63hz-1;
        done63hz <='0'; 
        end if;   
    end if;
    end process;
    
        
    cuenta10clk: process(ps2_clk_s,state_send,reset) is
    begin

    if reset='1' then 
     done10<='0';
     cont10clk<=X"0A";
    elsif(send='1' and ps2_clk_s'event and ps2_clk_s = '0' )   then
        if cont10clk=0 then
        done10<='1';
        cont10clk<=X"0A";
        else 
        cont10clk<=cont10clk-1;
        done10 <='0'; 
        end if;   
    end if;
    end process;
    
    
    sincronus_send: process(clkFPGA,reset) is
    begin 
        if reset='1' then 
            state_send<= idle;
        elsif clkFPGA'event and clkFPGA ='1' then
            state_send<= next_state_send;
       end if;
    end process sincronus_send;
    
    output_send: process(state_send)
    begin
       active<='1';
       --active_data<='1';
       send<= '0';
       send0<='0'; 
       err<= '0'; 
    case state_send is
        when idle=>
        debug<=(others=>'0');
        when rts=>   
        debug<= x"01";   
        active<='0';
        when start=>
         debug<= x"02"; 
        send0<='1';
        active<='0';
       -- active_data<='0';
        when start2=>
         debug<= x"03"; 
        send0<='1';
        when data=>
         debug<= x"04"; 
        send<='1';
      --  active_data<='1';
        when stop=>
         debug<= x"05";
        when stop2=> 
        debug<= x"06";
        when reading=> 
        debug<= x"f0";
        when send_error=>
        debug<= x"ff";
        err<= '1';
        when others =>
        debug<= x"FF";
        err<= '1';
      end case;
      end process output_send;   
 
    change_state_send: process (state_send,ps2_clk_s,done,done20hz,done63hz,done10) 
    begin 
    case state_send is 
        when idle=>
        if ps2_clk_s ='0' then
        next_state_send<=reading;
        elsif(write_data='1' )then
        next_state_send<=rts;
        else
        next_state_send<=idle;
        end if;
        
        when rts=>
        if(done='1')then         --Se envia un 0 en el clk durando 100 micros 
        next_state_send<=start;
        else 
        next_state_send<=rts;
        end if;
        
        when start=>      
        if(done20hz='1')then       --Se envia un 0 en el data durando 100 micros 
        next_state_send <=start2;                                    
        else
        next_state_send<=start;
        end if;
        when start2=>
        if(done63hz='1')then
            if(ps2_clk_s='0')then
            next_state_send <=data; 
            else 
            next_state_send  <=start2;  
            end if;
        else  
         next_state_send  <=start2;  
        end if;    
        
        when data=>
        if(done10='1')then                       --Se inicia el envio de datos
        next_state_send<=stop;
        else 
        next_state_send<=data;
        end if;
        
        when stop=>
        if(ps2_clk_s='0')then
         if (ps2_data_s ='0')then
            next_state_send <=stop2;
          else
            next_state_send <=send_error;
          end if;
        else
        next_state_send <= stop;
        end if;
        
        when stop2=>
         if ( ps2_clk_s='1' and ps2_data_s ='1') then
         next_state_send <=idle;
        else  
        next_state_send <=stop2;  
        end if;
        
        when reading=>
        if ready_new_data='1' then 
        next_state_send <=idle;
        else
        next_state_send <= reading;
        end if;  
        
        when send_error=>
        if( ps2_clk_s='1' and ps2_data_s ='1') then
        next_state_send <=idle;
        else
        next_state_send <=send_error;
        end if;
        
        when others =>
        next_state_send <=idle;
        end case;
        
               
    end process change_state_send;  
    
  

end Behavioral;

