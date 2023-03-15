library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity sm_display is
port(clk: in std_logic;
	 code:in std_logic_vector(15 downto 0);
	 result:in std_logic;
	 input_flag:in std_logic;--
	 finish_flag:in std_logic;--
	 judge_finish:in std_logic;--
	 led:out std_logic_vector(7 downto 0);
	 sel1:out std_logic;
	 sel2:out std_logic;
	 sel3:out std_logic;
	 sel4:out std_logic;
	 sel5:out std_logic);
end sm_display;
architecture behav of sm_display is
signal n:integer range 0 to 4;
signal a:std_logic_vector(31 downto 0);
begin

process(clk)
begin
if rising_edge(clk) then
for i in 0 to 3 loop
	case code(3+4*i downto 4*i) is
		when "0000"=>a(7+8*i downto 8*i)<="00000011";
		when "0001"=>a(7+8*i downto 8*i)<="10011111";
		when "0010"=>a(7+8*i downto 8*i)<="00100101";
		when "0011"=>a(7+8*i downto 8*i)<="00001101";
		when "0100"=>a(7+8*i downto 8*i)<="10011001";
		when "0101"=>a(7+8*i downto 8*i)<="01001001";
		when "0110"=>a(7+8*i downto 8*i)<="01000001";
		when "0111"=>a(7+8*i downto 8*i)<="00011111";
		when "1000"=>a(7+8*i downto 8*i)<="00000001";
		when "1001"=>a(7+8*i downto 8*i)<="00001001";
		when others=>a(7+8*i downto 8*i)<="11111111";
	end case;
end loop;
end if;
end process;

process(clk)
begin
	sel1<='1';
	sel2<='1';
	sel3<='1';
	sel4<='1';
	sel5<='1';
	if rising_edge(clk) then
		if n<4 and input_flag='1' then
			n<=n+1;
		else
			n<=0;
		end if;
	end if;
	case n is
	when 0=>
		sel1<='0';
		sel2<='1';
		sel3<='1';
		sel4<='1';
		sel5<='1';
		if judge_finish='0' then
			led<=a(7 downto 0);
		elsif result='1' then
			led<="10010001";--H
		else
			led<="01100001";--E
		end if;
	when 1=>
		sel1<='1';
		sel3<='1';
		sel4<='1';
		sel5<='1';
		if judge_finish='0' then
			led<=a(15 downto 8);
		elsif result='1' then
			led<="01100001";--E
		else
			led<="11110101";--R
		end if;
		sel2<='0';
	when 2=>
		sel2<='1';
		sel1<='1';
		sel4<='1';
		if judge_finish='0' then
			led<=a(23 downto 16);
		elsif result='1' then
			led<="11100011";--L
		else
			led<="11110101";--R
		end if;
		sel3<='0';
	when 3=>
		sel2<='1';
		sel3<='1';
		sel1<='1';
		sel5<='1';
		if judge_finish='0' then
			led<=a(31 downto 24);
		elsif result='1' then
			led<="11100011";--L
		else
			led<="11000101";--O
		end if;
		sel4<='0';
	when 4=>
		sel2<='1';
		sel3<='1';
		sel1<='1';
		sel4<='1';
		if judge_finish='0' then
			led<="11111111";
		elsif result='1' then
			led<="11000101";--O
		else
			led<="11110101";--R
		end if;
		sel5<='0';
	end case;
end process;
end behav;