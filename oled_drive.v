module oled_drive(
	input clk,			//时钟信号 50MHz
	input rst_n,		//按键复位
	input ram_rst,		//ram复位 高电平复位
	
	input [2:0] count,       //input count_number
	input inputing,             //key_lock
	input input_finish,
	input [2:0] key_num,
	input success,
	
	output oled_rst,	//oled res 复位信号
	output oled_dc,	//oled dc 0：写命令 1：写数据
	output oled_sclk,	//oled do 时钟信号
	output oled_mosi	//oled d1 数据信号
);
 
wire clk_1m;			//分频后的1M时钟
wire ena_write;		//spi写使能信号
wire [7:0] data;		//spi写的数据
 
wire init_done;		//初始化完成信号
wire [7:0] init_data;//初始化输出给spi的数据
wire init_ena_wr;		//初始化的spi写使能信号
wire init_oled_dc;
 
wire [7:0] ram_data;	//读到的ram数据
wire [7:0] show_data;//输出给spi写的数据
wire rden;				//ram的读使能信号
wire [9:0] rdaddress;//ram读地址信号
wire ram_ena_wr;		//ram使能写信号
wire ram_oled_dc;		//ram模块中的oled dc信号
 
wire wren;				//ram写使能信号
wire [9:0] wraddress;//ram写地址
wire [7:0] wrdata;	//写到ram中的数据
 
//一个信号只能有由一个信号来驱动，所以需要选择一下
assign data = init_done ? show_data : init_data;
assign ena_write = init_done ? ram_ena_wr : init_ena_wr;
assign oled_dc = init_done ? ram_oled_dc : init_oled_dc;
 
//时钟分频模块 产生1M的时钟
clk_fenpin clk_fenpin_inst(
	.clk(clk),
	.rst_n(rst_n),
	.clk_1m(clk_1m)
);
 
//spi传输模块
spi_writebyte spi_writebyte_inst(
	.clk(clk_1m),
	.rst_n(rst_n),
	.ena_write(ena_write),
	.data(data),
	.sclk(oled_sclk),
	.mosi(oled_mosi),
	.write_done(write_done)
);
 
//oled初始化模块 产生初始化数据
oled_init oled_init_inst(
	.clk(clk_1m),
	.rst_n(rst_n),
	.write_done(write_done),
	.oled_rst(oled_rst),
	.oled_dc(init_oled_dc),
	.data(init_data),
	.ena_write(init_ena_wr),
	.init_done(init_done)
);
 
//ram读模块
ram_read ram_read_inst(
	.clk(clk_1m),
	.rst_n(rst_n),
	.write_done(write_done),
	.init_done(init_done),
	.ram_data(ram_data),
	.rden(rden),
	.rdaddress(rdaddress),
	.ena_write(ram_ena_wr),
	.oled_dc(ram_oled_dc),
	.data(show_data)
);
 
//ram写模块
ram_write ram_write_inst(
	.clk(clk_1m),
	.rst_n(rst_n),
	.en_ram_wr(1'b1),
	.wren(wren),
	.wraddress(wraddress),
	.data(wrdata),
	.count(count),
	.success(success),
	.inputing(inputing),
	.key_num(key_num),
	.finish_flag(input_finish),
);

//ram ip核
ram_show ram_show_inst(
	.clock(clk_1m),
	.aclr(!ram_rst),
	.data(wrdata),
	.rdaddress(rdaddress),
	.rden(rden),
	.wraddress(wraddress),
	.wren(wren),
	.q(ram_data)
);
endmodule