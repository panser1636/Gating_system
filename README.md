# Gating_system
FPGA 多功能门控系统实现

## 开发板和外设
开发板：ALTERA 公司的 Cyclone IV 系列 FPGA，型号为 EP4CE10F17C8
OLED显示屏：0.96寸，ssd1306驱动，7针spi协议
红外检测：HC-SR501人体红外感应模块
步进电机

## 主要功能：
1. 通过矩阵键盘输入密码（我们设置的正确密码为“4321”）
2. OLED屏幕显示输入密码、WELCOME!!!、密码错误、以“*”代替密码实时显示。
3. 密码输入正确，OLED屏幕显示欢迎界面，步进电机转动90°并控制门模型打开，延迟一段时间后，门模型自动关闭；密码输入错误，则OLED屏幕显示密码错误，步进电机不会控制门模型打开。
4. 按下RESET键可以重新输入密码，OLED屏幕显示“输入密码”提示用户输入密码。
5. 按下KEY1键，蜂鸣器会响铃。
6. 数码管上实时当前显示时间，作电子时钟。
7. 两个红外传感器通过检测，检测到人进入门则人数增加，检测到人出门则人数减少。并通过OLED屏幕显示当前人数。


## 工程打开注意事项
1.由于整个工程是在17.0版本综合的，所以整个工程要在更高版本的QUARTUS打开，我们使用的是17.0版本
2.打开的路径下，不能含有中文和非法字符
