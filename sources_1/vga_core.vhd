library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity vgacore is
	port
	(
		reset: in std_logic;	-- reset
		clk_in: in std_logic;
		hsyncb: buffer std_logic;	-- horizontal (line) sync
		vsyncb: out std_logic;	-- vertical (frame) sync
		rgb: out std_logic_vector(11 downto 0) -- 4 red, 4 green,4 blue colors
	);
end vgacore;

architecture vgacore_arch of vgacore is



begin



  
end vgacore_arch;
