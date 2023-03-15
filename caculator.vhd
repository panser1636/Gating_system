LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;

ENTITY caculator IS
     PORT(rst_n,clk,hongn,hongw:IN std_logic;
		   count:out std_logic_vector(2 downto 0);
		   ledn,ledw,led3,led4:out std_logic;  --ledn:led0;ledw:led1
											  --led3:led1 s1,s2,s5,s6,
											  --led4:led2 s0
		   cmg:out std_logic_vector(7 downto 0);
		   en:out std_logic
		   --feng:out std_logic
			);
END ENTITY;

ARCHITECTURE behav OF caculator IS
begin
	en<='0';
	PROCESS(hongn,hongw,clk)
		type state_type is(s0,s1,s2,s3,s4,s5,s6);
		variable state:state_type;
		variable cnt:std_logic_vector(2 downto 0);
		--variable n:integer:=100000000;
	begin
		if rst_n='0' then
			state:=s0; 
			cnt:=(others=>'0');
		elsif(rising_edge(clk)) then 
			case state is 
				when s0=>
					led4<='1';led3<='0';ledn<='0';ledw<='0';
					if hongw='1'and hongn='0' then
						ledw<='1';ledn<='0';
						state:=s1;
					elsif hongn='1' and hongw='0' then
						ledn<='1';
						state:=s2;
					else state:=s0;
					end if;
				when s1=>
					if hongw='0'and hongn='0' then
						led3<='1';led4<='0';
						ledw<='0';ledn<='0';
						state:=s3;
					else state:=s1;
					end if;
				when s2=>
					if hongw='0'and hongn='0' then
						led3<='1';led4<='0';
						ledw<='0';ledn<='0';
						state:=s4;
					else state:=s2;
					end if;
				when s3=>
					if hongn='1' then
						ledn<='1';ledw<='0';
						state:=s5;
					else 
						state:=s3;
					end if;
				when s4=>
					if hongw='1' then
						ledw<='1';ledn<='0';
						state:=s6;
					else 
						state:=s4;
					end if;	
				when s5=>
					if hongn='0' then
						led3<='1';
						cnt:=cnt+1;
						state:=s0;
					else state:=s5;
					end if;
				when s6=>
					if hongw='0' then
						led3<='1';
						cnt:=cnt-1;
						state:=s0;
					else state:=s6;
					end if;
			end case;
		end if;
		
		count<=cnt;
			--feng<=hongn; 
			case cnt is 
				when "000" => cmg<="11000000";
				when "001" => cmg<="11111001";
				when "010" => cmg<="10100100";
				when "011" => cmg<="10110000";
				when "100" => cmg<="10011001";
				when "101" => cmg<="10010010";
				when "110" => cmg<="10000010";
				when "111" => cmg<="11111000";
				when others=>cmg<="11111111";
			end case;
	--ledn<='0';
	--ledw<='0';
		end process;
	
END behav;