----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.03.2022 13:04:13
-- Design Name: 
-- Module Name: Pong - Behavioral
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

entity Pong is
  Port (
    clkFPGA : in std_logic ;
    PS2Clk  : inout std_logic ; 
    PS2Data : inout std_logic ;
    reset   : in std_logic ;
    vsync   : out std_logic;
    hsync   : buffer std_logic;
    rgb     : out std_logic_vector(11 downto 0);
    clickaux: out std_logic;
    new_data: out std_logic;
    debug    :out std_logic_vector(7 downto 0);
    display : out std_logic_vector(11 downto 0)                  
   );
end Pong;

architecture Behavioral of Pong is
    
    
    component key_fsm is
      Port (clkFPGA : in std_logic ;
            reset   : in std_logic ;
            key     : in std_logic_vector(7 downto 0);
            newkey  : in std_logic;
            action  :  out std_logic_vector(1 downto  0);
            rst     : out std_logic);
     end component;

    component ball_fsm is
      Port (clkFPGA : in std_logic ;
            reset   : in std_logic ;
            posY    : in std_logic_vector(11 downto 0);
            posX    : in std_logic_vector(11 downto 0);
            mouseY  : in std_logic_vector(11 downto 0);
            mouseX  : in std_logic_vector(11 downto 0);
            click   : in std_logic;
            rebote  : out std_logic;
            newBallMove: out std_logic_vector(1 downto 0));
    end component;
        
    component  div_frec is
    Port (clkFPGA  :in std_logic;
        cuentamax:in std_logic_vector(26 downto 0);
        reset    :in std_logic;
        clkOUT   :out std_logic);
      
    end component;
    
    component MouseCtl is
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
       
       --new_data    : out std_logic_vector(7 downto 0);
        debug    :out std_logic_vector(7 downto 0);
       
       ps2_clk     : inout std_logic;
       ps2_data    : inout std_logic
       
    );
    end component;
    
    component cont_mod8 is
    Port ( clk:    in std_logic;
         e: in std_logic;
         rst : in std_logic;
         cont  : out std_logic_vector(2 downto 0)  );
    end component;
    
    component conversor_display is
      Port (bin :in std_logic_vector (2 downto 0);
            disp:out std_logic_vector(7 downto 0)
       );
    end component;

    component clk_wiz_0 is
    port
     (-- Clock in ports
      clk_in1           : in     std_logic;
      -- Clock out ports
      clk_out1          : out    std_logic
     );
    end component;
    
    component Ram is
     Port (clkFPGA:in std_logic;
           we:in std_logic;
           data_in:in std_logic_vector(11 downto 0);
           data_out:out std_logic_vector(11 downto 0);
           addr:in std_logic_vector(2 downto 0));
    end component;

    signal newpushkey: std_logic;
    
    signal keypush :std_logic_vector(7 downto 0);
    
    signal hcnt: std_logic_vector(11 downto 0);	
    signal vcnt: std_logic_vector(11 downto 0);
    
    signal mouse_icon: std_logic;
    signal ball: std_logic;
    signal edge: std_logic;			
    signal base: std_logic;	
    
    signal mouseY: std_logic_vector(11 downto 0) ;
    signal mouseX: std_logic_vector(11 downto 0) ;
    signal click_left : std_logic;
    signal click_right : std_logic;
    signal click_central : std_logic;
    signal xdir:   std_logic_vector(7 downto 0);
    signal ydir:   std_logic_vector(7 downto 0);
    signal xdir_aux:   std_logic_vector(8 downto 0);
    signal ydir_aux:   std_logic_vector(8 downto 0);
    signal status: std_logic_vector(7 downto 0); 
    
    signal newBallMove: std_logic_vector(1 downto 0);
    signal posYaux: std_logic_vector(11 downto 0) ;
    
    signal ballY:std_logic_vector(11 downto 0) ;
    signal ballX:std_logic_vector(11 downto 0) ;
    signal ball_auxY:std_logic_vector(11 downto 0); 
    signal ball_auxX:std_logic_vector(11 downto 0) ;
    
    signal rst      : std_logic;
    signal cuentamax :  std_logic_vector(26 downto 0);
    signal cuenta50hz :  std_logic_vector(26 downto 0);
    signal clk      :std_logic;
    signal clk50hz,clk_wiz      :std_logic;
    

    
    signal rebote   :std_logic;
    signal cuenta   :std_logic_vector(2 downto 0);
    
    signal edge_color:std_logic_vector(11 downto 0) ;
    
   -- signal new_data:std_logic ;
begin
    --posYaux<= posY+X"0FA";  
    cuentamax<="000000011110100001001000000";
    cuenta50hz<="000"&X"4c4b40";
    
    clickaux<=click_left;
    
    display(11 downto 8)<="1110";
                
    mouse1:MouseCtl GENERIC MAP( 100000000, 500, 100 ) port map(clkFPGA,reset,mouseX,mouseY,open,
    click_left,click_central,click_right,new_data,x"000",'0','0','0','0',debug,PS2Clk,PS2Data);  
    
    --barmove:key_fsm port map(clkFPGA,reset,keypush,newpushkey,action,rst);
    
    ball_move:ball_fsm port map(clkFPGA,reset,ballY,ballX,mouseX,mouseY,click_left,rebote,newBallMove);
    
    div:div_frec port map (clkFPGA,cuentamax,reset,clk);
    
    divMouse:div_frec port map (clkFPGA,cuenta50hz,reset,clk50hz);
    
    cont:cont_mod8 port map(rebote,'1',reset,cuenta);
    
    conver:conversor_display port map(cuenta,display(7 downto 0));
    
    edgecolor:Ram port map(clkFPGA,'0',(others=>'0'),edge_color,cuenta);
    
  
    
    actualice_pos_ball:process(clk,reset)   --Process para actualizar la posicion de la bola
    begin
     if(reset='1')then
     ballY<=X"019";
     ballX<=x"028";
     elsif(clk'event and clk='1')then
         if(newBallMove="00") then  -- Movimiento diagolal derecha inferior
            if(ballY+10<977) then
            ballY<=ballY+10;  
            else
            ballY<=X"3d1";   
            end if;
    
            if(ballX<1280) then
            ballX<=ballX+10;
            else
            ballX<=X"500";
            end if;
            
        elsif(newBallMove="01") then  --Diagonal drecha superior
            if(ballY>35) then
            ballY<=ballY-10;
            else
            ballY<=X"019";
            end if;
            
            if(ballX<1280) then
            ballX<=ballX+10;
            else
            ballX<=X"500";
            end if;   
            
         elsif(newBallMove="10") then   --Diagonal izq inferior 
            if(ballY+10<977) then
            ballY<=ballY+10;  
            else
            ballY<=X"3d1";   
            end if;
            
            if(ballX>35) then
            ballX<=ballX-10;
            else
            ballX<=X"019";
            end if;
            
         else                             --Diagonal iz sup
            if(ballY>35) then
            ballY<=ballY-10;
            else
            ballY<=X"019";
            end if;
            
            if(ballX>35) then
            ballX<=ballX-10;
            else
            ballX<=X"019"; 
            end if;
        end if;  
     end if;
    end process;
    
    A: process(clkFPGA,reset)
begin
	-- reset asynchronously clears pixel counter
	if reset='1' then
		hcnt <= "000000000000";
	-- horiz. pixel counter increments on rising edge of dot clock
	elsif (clkFPGA'event and clkFPGA='1') then
		-- horiz. pixel counter rolls-over after 381 pixels
		if hcnt<1687 then
			hcnt <= hcnt + 1;
		else
			hcnt <= "000000000000";
		end if;
	end if;
end process;


B: process(hsync,reset)
begin
	-- reset asynchronously clears line counter
	if reset='1' then
		vcnt <= "000000000000";
	-- vert. line counter increments after every horiz. line
	elsif (hsync'event and hsync='1') then
		-- vert. line counter rolls-over after 528 lines
		if vcnt<1065 then
			vcnt <= vcnt + 1;
		else
			vcnt <= "000000000000";
		end if;
	end if;
end process;

C: process(clkFPGA,reset)
begin
	-- reset asynchronously sets horizontal sync to inactive
	if reset='1' then
		hsync <= '1';
	-- horizontal sync is recomputed on the rising edge of every dot clock
	elsif (clkFPGA'event and clkFPGA='1') then
		-- horiz. sync is low in this interval to signal start of a new line
		if (hcnt>=1327 and hcnt<1439) then
			hsync <= '0';
		else
			hsync <= '1';
		end if;
	end if;
end process;

D: process(hsync,reset)
begin
	-- reset asynchronously sets vertical sync to inactive
	if reset='1' then
		vsync <= '1';
	-- vertical sync is recomputed at the end of every line of pixels
	elsif (hsync'event and hsync='1') then
		-- vert. sync is low in this interval to signal start of a new frame
		if (vcnt>=1024 and vcnt<1027) then
			vsync <= '0';
		else
			vsync <= '1';
		end if;
	end if;
end process;
-- A partir de aqui escribir la parte de dibujar en la pantalla
    

----------------------------------------------------------------



Rectangel:process(hcnt,vcnt)                    --Process para dibujado de la barra
begin
            
    if( hcnt >=mouseX and hcnt<mouseX+1 and vcnt>=mouseY and vcnt<mouseY+1)then 
        mouse_icon<='1';
    elsif( hcnt >=mouseX and hcnt<mouseX+2 and vcnt>=mouseY+1 and vcnt<mouseY+2)then 
        mouse_icon<='1';
    elsif( hcnt >=mouseX and hcnt<mouseX+3 and vcnt>=mouseY+2 and vcnt<mouseY+3)then 
        mouse_icon<='1';
    elsif( hcnt >=mouseX and hcnt<mouseX+4 and vcnt>=mouseY+3 and vcnt<mouseY+4)then 
        mouse_icon<='1';
    elsif( hcnt >=mouseX and hcnt<mouseX+5 and vcnt>=mouseY+4 and vcnt<mouseY+5)then 
        mouse_icon<='1';
    elsif( hcnt >=mouseX and hcnt<mouseX+6 and vcnt>=mouseY+5 and vcnt<mouseY+6)then 
        mouse_icon<='1';
    elsif( hcnt >=mouseX and hcnt<mouseX+7 and vcnt>=mouseY+6 and vcnt<mouseY+7)then 
        mouse_icon<='1';
    elsif( hcnt >=mouseX and hcnt<mouseX+8 and vcnt>=mouseY+7 and vcnt<mouseY+8)then 
        mouse_icon<='1';   
    else    
        mouse_icon<='0';  
    end if;
    
end process;

ball_p:process(hcnt,vcnt)                       --Process para dibujado de la pelota 
begin
            
    if( hcnt >ballX and hcnt<ballX+20 and vcnt>ballY and vcnt<ballY+20)then 
        ball<='1';
    else    
        ball<='0';  
    end if;
    
end process;
   
edg:process(hcnt,vcnt)                          --Process para dibujado del fondo                        
begin
    if(hcnt>25 and hcnt<1300 and vcnt>25 and vcnt<997)then
        edge<='1';
    else 
        edge<='0';
    end if;
end process;

bas:process(hcnt,vcnt)                          --Process para dibujado del fondo 
begin
    if(hcnt>=0 and hcnt<1325 and vcnt>=0 and vcnt<1022)then
        base<='1';
    else 
        base<='0';
    end if;
end process;

draw:process(mouse_icon,edge,base)                   --Process para dibujado 
begin
    if(ball='1') then
       rgb<=(others=>'0');
    elsif(mouse_icon='1')then
       rgb<=X"f0f";
    elsif(edge='1')then
       rgb<=edge_color;
    elsif(base='1') then
        rgb<=X"0ff";
    else
        rgb<=(others=>'0');
    end if;
end process;  

end Behavioral;
