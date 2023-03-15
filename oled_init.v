module oled_init(
	input clk,					//ʱ���ź� 1m��ʱ��
	input rst_n,				//��λ�ź� 
	input write_done,			//spiд����ź� ��ø��źź�����һ��д
	output reg oled_rst,		//oled�ĸ�λ�����ź�
	output reg oled_dc,		//oled��dcд���� д��������ź�
	output reg [7:0] data,	//�����������spi��д������
	output reg ena_write,	//spiдʹ���ź�
	output init_done			//��ʼ������ź�
);
 
reg [20:0] us_cnt;			//us������ �ϵ���ʱ�ȴ�
reg us_cnt_clr;				//�����������ź�
parameter RST_NUM = 10;		//1000_000 //�ȴ�1s
//״̬˵��
//��λ״̬ ��ʼ��д����״̬ oled��д����״̬ oled��ʾ����д����״̬ oled��ʾ����д����״̬
//�ȴ���ʼ��д������� �ȴ�oled��д������� �ȴ�����д������� �ȴ�����д�������
parameter Rst=0,Init=1,OledOn=2,ClearCmd=3,ClearData=4,WaitInit=5,WaitOn=6,WaitClearCmd=7,WaitClearData=8,Done=9;
 
reg[3:0] state,next_state;//״̬���ĵ�ǰ״̬����һ��״̬
 
 
	
reg [7:0] init_cmd[27:0];	//��ʼ������洢
reg [4:0] init_cmd_cnt;		//��ʼ���������
 
reg [7:0] oled_on_cmd[2:0];//oled������洢
reg [1:0] oled_on_cmd_cnt;	//oled���������
 
reg [7:0] clear_cmd[24:0];	//��������洢
reg [4:0] clear_cmd_cnt;	//�����������
 
reg [10:0] clear_data_cnt;	//����д���ݼ���
 
 
//��ʼ������
//�����ʼ���ĵ���ܼ�
initial begin	
	init_cmd[0] = 8'hAE;				init_cmd[1] = 8'hD5;				init_cmd[2] = 8'h80;				init_cmd[3] = 8'hA8;
	init_cmd[4] = 8'h3F;				init_cmd[5] = 8'hD3;				init_cmd[6] = 8'h00;				init_cmd[7] = 8'h40;
	init_cmd[8] = 8'h8D;				init_cmd[9] = 8'h10|8'h04;		init_cmd[10] = 8'h20;			init_cmd[11] = 8'h02;
	init_cmd[12] = 8'hA0|8'h01;	init_cmd[13] = 8'hC0;			init_cmd[14] = 8'hDA;			init_cmd[15] = 8'h02|8'h10;
	init_cmd[16] = 8'h81;			init_cmd[17] = 8'hCF;			init_cmd[18] = 8'hD9;			init_cmd[19] = 8'hF1;
	init_cmd[20] = 8'hDB;			init_cmd[21] = 8'h40;			init_cmd[22] = 8'hA4|8'h00;	init_cmd[23] = 8'hA6|8'h00;
	init_cmd[24] = 8'hAE|8'h01;
end
/*
//��ʼ������
//�����ʼ�������ĵ�Ƚ�ϡ��
//Ӧ���Ƿֱ��ʵ����ò�ͬ�ѣ��²⣩
initial begin
	init_cmd[0] = 8'hAE;	init_cmd[1] = 8'h00;	init_cmd[2] = 8'h10;	init_cmd[3] = 8'h00;
	init_cmd[4] = 8'hB0;	init_cmd[5] = 8'h81;	init_cmd[6] = 8'hFF;	init_cmd[7] = 8'hA1;
	init_cmd[8] = 8'hA6;	init_cmd[9] = 8'hA8;	init_cmd[10] = 8'h1F;init_cmd[11] = 8'hC8;
	init_cmd[12] = 8'hD3;init_cmd[13] = 8'h00;init_cmd[14] = 8'hD5;init_cmd[15] = 8'h80;
	init_cmd[16] = 8'hD9;init_cmd[17] = 8'h1f;init_cmd[18] = 8'hD9;init_cmd[19] = 8'hF1;
	init_cmd[20] = 8'hDA;init_cmd[21] = 8'h00;init_cmd[22] = 8'hDB;init_cmd[23] = 8'h40;
end
*/
//oled������
initial begin
	oled_on_cmd[0] = 8'h8D;oled_on_cmd[1] = 8'h14;oled_on_cmd[2] = 8'hAF;
end
 
//oled��������
//Ҳ��������ҳ��ַ��������ʾ�ĵ͵�ַ��������ʾ�ĸߵ�ַ
initial begin
	clear_cmd[0] = 8'hB0;clear_cmd[1] = 8'h00;clear_cmd[2] = 8'h10;//��0ҳ
	clear_cmd[3] = 8'hB1;clear_cmd[4] = 8'h00;clear_cmd[5] = 8'h10;//��1ҳ
	clear_cmd[6] = 8'hB2;clear_cmd[7] = 8'h00;clear_cmd[8] = 8'h10;//��2ҳ
	clear_cmd[9] = 8'hB3;clear_cmd[10] = 8'h00;clear_cmd[11] = 8'h10;//��3ҳ
	clear_cmd[12] = 8'hB4;clear_cmd[13] = 8'h00;clear_cmd[14] = 8'h10;//��4ҳ
	clear_cmd[15] = 8'hB5;clear_cmd[16] = 8'h00;clear_cmd[17] = 8'h10;//��5ҳ
	clear_cmd[18] = 8'hB6;clear_cmd[19] = 8'h00;clear_cmd[20] = 8'h10;//��6ҳ
	clear_cmd[21] = 8'hB7;clear_cmd[22] = 8'h00;clear_cmd[23] = 8'h10;//��7ҳ
end
 
 
//1΢�������
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        us_cnt <= 21'd0;
    else if (us_cnt_clr)
        us_cnt <= 21'd0;
    else 
        us_cnt <= us_cnt + 1'b1;
end 
//��һ�����¸������� always(*)�����ã����ᣩ
//���׳����⡣������ȻҲ��֪��Ϊʲô
//��ʲô��������һ�� ��ֵʲô�Ļ��Ǻ�״̬ת���ֿ�
//�Ž�ʱ���·����
//����״̬ת������һ��״̬Ҳ���ܷŽ�ʱ���·����
//����ɵ�ǰ״̬����һ��״̬�ӳ�һ��ʱ�����ڣ�ʱ����ܾͱȽ���
always @(*) begin
	if(!rst_n) begin
		next_state = Rst;
	end
	else begin
		case(state)
			//��λ�ȴ�״̬
			//�ȴ��ϵ縴λ
			Rst: 
				next_state = us_cnt > RST_NUM ? Init : Rst;
			
			//��ʼ��״̬
			Init: 
				next_state = WaitInit;	//����ȴ�д������ɵ�״̬
			
			//�ȴ���ʼ������д���״̬
			//�������״̬ʱcmd cnt�żӵ�1������Ҫ��һ��ֵ�ж�
			//�Ƿ�25������д��� д��ɽ�����һ��״̬
			//�����Ƿ�spiд��� spiд��ɼ���д��һ������ ����ͼ����ȴ�spiд���
			//�ǵü�&&write_done�ȴ����һ��д��
			WaitInit: 
				next_state = (init_cmd_cnt == 5'd25&&write_done) ? OledOn : (write_done ? Init : WaitInit);	
				
							
			
			//oled��д����״̬
			OledOn: 
				next_state = WaitOn;
			
			//�ȴ�oled��д�������״̬
			//�ж������Ƿ�д�� д�������һ��״̬
			//���� ���ж��Ƿ�spiд��� д��ɼ���д��һ������
			WaitOn: 
				next_state = (oled_on_cmd_cnt == 2'd3&&write_done) ? ClearCmd : (write_done ? OledOn : WaitOn);	
			
			//����д����״̬
			ClearCmd: 
				next_state = WaitClearCmd;
			
			//�ȴ�����д����״̬			
			//ÿ��д�������� ���Զ�3ȡ����
			//����0����ɽ������״̬����ת��
			WaitClearCmd: 
				next_state = (clear_cmd_cnt % 2'd3 == 0 && write_done) ? ClearData : (write_done ? ClearCmd : WaitClearCmd);
				
			
			//����д����״̬
			ClearData:
				next_state = WaitClearData;
			
			//�ȴ�����д����
			//1ҳ��Ҫд128�����ݣ�д��7ҳ����1024������
			//д��1ҳ��Ҳ����ÿд��128�����ݾ�Ҫдһ���������Ҫ��128ȡ�࣬Ȼ�����д�����״̬
			//����0�ǲ����״̬��ɸ��ŵģ���Ϊ�������״̬��ʱ��������Ѿ��ӹ�1��
			WaitClearData: 
				next_state = (clear_data_cnt == 11'd1024&&write_done) ? Done : (clear_data_cnt % 11'd128 == 0&&write_done ? ClearCmd : (write_done ? ClearData : WaitClearData));
			
			//���״̬
			Done: 
				next_state = Done;
 
			default: 
				next_state = Rst;
				
		endcase
	end
end
 
//����мɲ���д�����������߼���
//�����Latch
//����ԭ�򣬣���Ҳ��֪��
always @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		oled_rst <= 1'b0;
		us_cnt_clr <= 1'b1;
		oled_dc <= 1'b1;
		data <= 8'h10;
		ena_write <= 1'b0;
	end
	else begin
		case(state)
			//��λ�ȴ�״̬
			Rst:begin
					oled_rst <= 1'b0;
					us_cnt_clr <= 1'b0;
			end
			
			//��ʼ��״̬
			Init:begin
				oled_rst <= 1'b1;
				us_cnt_clr <= 1'b1;	//���������
				ena_write <= 1'b1;			//дʹ��
				oled_dc <= 1'b0;			//д����
				data <= init_cmd[init_cmd_cnt];//д���ݸ�ֵ
			end
			
			//�ȴ���ʼ������д���״̬
			WaitInit: begin
				ena_write <= 1'b0;			//дʧ��		
			end
			
			//oled��д����״̬
			OledOn:begin
				ena_write <= 1'b1;			//дʹ��
				oled_dc <= 1'b0;			//д����
				data <= oled_on_cmd[oled_on_cmd_cnt];	
			end
			
			//�ȴ�oled��д�������״̬
			WaitOn:begin
				ena_write <= 1'b0;			//дʧ��
			end
			
			//����д����״̬
			ClearCmd:begin
				ena_write <= 1'b1;
				oled_dc <= 1'b0;
				data <= clear_cmd[clear_cmd_cnt];
			end
			
			//�ȴ�����д����״̬
			WaitClearCmd:begin
				ena_write <= 1'b0;
			end
			
			//����д����״̬
			ClearData:begin
				ena_write <= 1'b1;
				oled_dc <= 1'b1;
				data <= 8'hff;
			end
			
			//�ȴ�����д����
			WaitClearData:begin
				ena_write <= 1'b0;
			end
		endcase
	end
end
 
//״̬ת��
always @(posedge clk,negedge rst_n) begin
	if(!rst_n)	
		state <= Rst;
	else
		state <= next_state;
end
 
//����������
always @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		init_cmd_cnt <= 5'd0;
		oled_on_cmd_cnt <= 4'd0;
		clear_cmd_cnt <=3'd0;
		clear_data_cnt <= 11'd0;
	end
	else begin
		case(state)
			Init:			init_cmd_cnt <= init_cmd_cnt + 1'b1;
			OledOn:		oled_on_cmd_cnt <= oled_on_cmd_cnt + 1'b1;
			ClearCmd:	clear_cmd_cnt <= clear_cmd_cnt + 1'b1;
			ClearData:	clear_data_cnt <= clear_data_cnt + 1'b1;
			default:begin
				init_cmd_cnt <= init_cmd_cnt;
				oled_on_cmd_cnt <= oled_on_cmd_cnt;
				clear_cmd_cnt <= clear_cmd_cnt;
				clear_data_cnt <= clear_data_cnt;
			end
		endcase
	end
end
 
assign init_done = (state == Done);
 
 
endmodule