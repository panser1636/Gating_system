LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY leds7 IS
PORT(clk,RST,EN:IN STD_LOGIC;
  KR:OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --行
  KC:IN STD_LOGIC_VECTOR(3 DOWNTO 0);  --列
  code:out std_logic_vector(15 downto 0);
  input_flag:out std_logic;
  finish_flag:out std_logic;
  num:inout std_logic_vector(2 downto 0)); 
END leds7;

ARCHITECTURE bhv OF leds7 IS
BEGIN
 PROCESS(clk,RST,EN)
 VARIABLE RC:STD_LOGIC_VECTOR(7 DOWNTO 0);
 VARIABLE ROW:STD_LOGIC_VECTOR(3 DOWNTO 0);
 VARIABLE Q:STD_LOGIC_VECTOR(1 DOWNTO 0);
 VARIABLE count:integer range 0 to 4;
 VARIABLE n:integer range 0 to 50;
 BEGIN
 IF RST = '0'THEN
   input_flag<='0';
   finish_flag<='0';
   count :=0;
   num<="000";
   code<="1111111111111111";
   ELSIF clk'EVENT AND clk = '1'THEN  --获取时钟上升沿信号
   input_flag<='1';
   Q:=Q+1;
   CASE Q IS
    WHEN "00"=>ROW:="1110";KR<=ROW;  --扫描第一列
    WHEN "01"=>ROW:="1101";KR<=ROW;  --扫描第二列
    WHEN "10"=>ROW:="1011";KR<=ROW;  --扫描第三列
    WHEN "11"=>ROW:="0111";KR<=ROW;  --扫描第四列
    WHEN OTHERS=>NULL;
   END CASE;
   IF EN = '1' THEN
    CASE ROW IS 
     WHEN "1110" =>
                     CASE KC IS
                        WHEN "0111" =>RC:= "11101110";input_flag<='1';  --扫描第一行，按键按下则为4
									  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="0100";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
                        WHEN "1011" =>RC:= "11101101";input_flag<='1';  --扫描第二行，按键按下则为3
									  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="0011";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
                        WHEN "1101" =>RC:= "11101011";input_flag<='1';  --扫描第三行，按键按下则为2  
									  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="0010";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
                        WHEN "1110" =>RC:= "11100111";input_flag<='1';  --扫描第四行，按键按下则为1  
                                      if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="0001";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
                        WHEN OTHERS => NULL;
                     END CASE;
     WHEN "1101" =>
       CASE KC IS
        WHEN "0111" =>RC:= "01111110";input_flag<='1';   --扫描第一行，按键按下则为A 
        WHEN "1011" =>RC:= "01111101";input_flag<='1';   --扫描第二行，按键按下则为B
        WHEN "1101" =>RC:= "01111011";input_flag<='1';   --扫描第三行，按键按下则为C
        WHEN "1110" =>RC:= "01110111";input_flag<='1';   --扫描第四行，按键按下则为D  
        WHEN OTHERS =>NULL;
       END CASE;
     WHEN "1011" =>
       CASE KC IS
        WHEN "0111" =>RC:= "10111110";input_flag<='1';   
        WHEN "1011" =>RC:= "10111101";input_flag<='1';   
        WHEN "1101" =>RC:= "10111011";input_flag<='1';    
        WHEN "1110" =>RC:= "01111011";input_flag<='1';   
					  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="1001";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
        WHEN OTHERS =>NULL;
       END CASE;
     WHEN "0111" =>
       CASE KC IS 
        WHEN "0111" =>RC:= "11011110";input_flag<='1';  
					  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="1000";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
        WHEN "1011" =>RC:= "11011101";input_flag<='1';   
					  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="0111";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
        WHEN "1101" =>RC:= "11011011";input_flag<='1';   --扫描第三行，按键按下则为8
					  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="0110";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
        WHEN "1110" =>RC:= "11010111";input_flag<='1';   --扫描第四行，按键按下则为0 
					  if count <4 then
										if n>=40 then
										code(4*count+3 downto 4*count)<="0101";
										count:=count+1;
										num<=num+1;
										n:=0;
										else
										n:=n+1;
										end if;
									  else
										count:=4;
										finish_flag<='1';
									  end if;
        WHEN OTHERS =>NULL;
       END CASE;
     WHEN OTHERS  =>NULL;
    END CASE;
   END IF;
 end if;
 end process;
 end bhv;