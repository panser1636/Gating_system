library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity judge is
port(clk: in std_logic;
	 finish_flag:in std_logic;--
	 judge_finish:out std_logic;--
	 code:in std_logic_vector(15 downto 0);
	 rst:in std_logic;
	 result:out std_logic);
end judge;
architecture behav of judge is
constant chushi_code:std_logic_vector(15 downto 0):="0001001000110100";--1234
begin
process(clk)
begin
if finish_flag='1'then
	if code=chushi_code then
		result<='1';
		judge_finish<='1';
	else
		result<='0';
		judge_finish<='1';
	end if;
else
	judge_finish<='0';
	result<='0';
end if;
if rst='0' then
	judge_finish<='0';
	result<='0';
end if;
end process;
end behav;