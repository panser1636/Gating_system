LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY bjdjqd IS
PORT(clk:in std_logic;
	 rst:in std_logic;
	 in1_4:out std_logic_vector(3 downto 0);
	 result:in std_logic);
end bjdjqd;
architecture bhav of bjdjqd is
type state_type is(s0,s1,s2,s3);
signal n:integer range 0 to 10000;--stop time
----signal dir:std_logic;
signal count:integer range 0 to 1024;--move time(1 circle)
signal door_close:std_logic:='0';
begin
process(clk)
variable state:state_type;
variable qy:integer range 0 to 7;
begin
if rising_edge(clk) then
	case state is
	when s0=>in1_4<="0000";
		n<=0;count<=0;
		if result='1' and door_close='0'then
			state:=s1;
		else
			state:=s0;
		end if;
	when s1=>qy:=count rem 8;
			case qy is
			when 0=>in1_4<="0001";
			when 1=>in1_4<="0011";
			when 2=>in1_4<="0010";
			when 3=>in1_4<="0110";
			when 4=>in1_4<="0100";
			when 5=>in1_4<="1100";
			when 6=>in1_4<="1000";
			when 7=>in1_4<="1001";
			end case;
			if count<1024 then
				count<=count+1;
				state:=s1;
			else
				count<=0;
				state:=s2;
			end if;
	when s2=>in1_4<="0000";
			if n<10001 then
				n<=n+1;
				state:=s2;
			else
				n<=0;
				state:=s3;
			end if;
	when s3=>qy:=count rem 8;
			case qy is
			when 7=>in1_4<="0001";
			when 6=>in1_4<="0011";
			when 5=>in1_4<="0010";
			when 4=>in1_4<="0110";
			when 3=>in1_4<="0100";
			when 2=>in1_4<="1100";
			when 1=>in1_4<="1000";
			when 0=>in1_4<="1001";
			end case;
			if count<1024 then
				count<=count+1;
				state:=s3;
			else
				count<=0;
				door_close<='1';
				state:=s0;
			end if;
	end case;
end if;
if rst='0' then
	door_close<='0';
end if;
end process;
end bhav;