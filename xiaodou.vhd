library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity xiaodou is
port(clk: in std_logic;
	 key_in:in std_logic;
	 key_out:out std_logic);
end xiaodou;
architecture behav of xiaodou is
signal n:integer range 0 to 29;
begin
process(clk)
begin
	if key_in='1' then
		n<=0;
		key_out<='1';
	elsif rising_edge(clk) then
		if n<29 then
			n<=n+1;
			key_out<='1';
		else
			n<=29;--
			key_out<='0';
		end if;
	end if;
end process;
end behav;