 
/****************************************
��ģ���������϶�ȡram�е����ݣ�Ȼ��ˢ��OLED����ʾ
****************************************/
module ram_read(
	input clk,					//ʱ���ź�
	input rst_n,				//������λ�ź�
	input write_done,			//spiд����ź�
	input init_done,			//��ʼ�����
	input[7:0] ram_data,		//��ȡ����ram����
	output reg rden,			//ram ip�˵Ķ�ʹ���ź�
	output [9:0] rdaddress,	//ram ip�˶���ַ
	output reg ena_write,	//spi дʹ���ź�
	output reg oled_dc,		//oled��dcд���� д��������ź�
	output reg[7:0] data		//���� spiд������
);
 
parameter DELAY = 100_000;	//ˢ����1000_000/100_000 = 10Hz
reg [20:0] us_cnt;			//us������ �ϵ���ʱ�ȴ�
reg us_cnt_clr;				//�����������ź�
 
//״̬˵��
//�ȴ���ʼ����� д���� �ȴ�д�������
//��ram���� д���� �ȴ�д�������
//���ݶ�ȡ���һ��
parameter WaitInit=0,WriteCmd=1,WaitWriteCmd=2,ReadData=3,WriteData=4,WaitWriteData=5,Done=6;
reg[2:0] state,next_state;	//��ǰ״̬ �� ��һ��״̬
 
reg [7:0] write_cmd[24:0];	//��������洢
reg [4:0] write_cmd_cnt;	//�����������
reg [10:0] address_cnt;		//��ַ������ 
 
//����ַ��ൽ1023 ����״̬ת����Ҫ1024 ����ʹ�ö����һ������������Ϊ״̬ת����ͬʱҲ�ṩ��ַ�ź�
//ֻ���ڵ�ַ����������1024ʱ������ַ��Ϊ0
assign rdaddress = (address_cnt >= 11'd1024) ? 10'd0 : address_cnt;
 
//oled��������
//Ҳ��������ҳ��ַ��������ʾ�ĵ͵�ַ��������ʾ�ĸߵ�ַ
//��7ҳ�ڿ������ŵ�λ�ã��Ӹ�ҳд����ҳ����ôд�����Լ��鿴
initial begin
	write_cmd[0] = 8'hB7;write_cmd[1] = 8'h00;write_cmd[2] = 8'h10;//��7ҳ
	write_cmd[3] = 8'hB6;write_cmd[4] = 8'h00;write_cmd[5] = 8'h10;//��6ҳ
	write_cmd[6] = 8'hB5;write_cmd[7] = 8'h00;write_cmd[8] = 8'h10;//��5ҳ
	write_cmd[9] = 8'hB4;write_cmd[10] = 8'h00;write_cmd[11] = 8'h10;//��4ҳ
	write_cmd[12] = 8'hB3;write_cmd[13] = 8'h00;write_cmd[14] = 8'h10;//��3ҳ
	write_cmd[15] = 8'hB2;write_cmd[16] = 8'h00;write_cmd[17] = 8'h10;//��2ҳ
	write_cmd[18] = 8'hB1;write_cmd[19] = 8'h00;write_cmd[20] = 8'h10;//��1ҳ
	write_cmd[21] = 8'hB0;write_cmd[22] = 8'h00;write_cmd[23] = 8'h10;//��0ҳ
end
	
//1΢�������
always @ (posedge clk,negedge rst_n) begin
    if (!rst_n)
        us_cnt <= 21'd0;
    else if (us_cnt_clr)
        us_cnt <= 21'd0;
    else 
        us_cnt <= us_cnt + 1'b1;
end 
//��һ��״̬ȷ��
always @(*) begin
	if(!rst_n) 
		next_state = WaitInit;
	else begin
		case(state)
			//�ȴ���ʼ��
			WaitInit: next_state = init_done ? WriteCmd : WaitInit;
			
			//д����
			WriteCmd:
				next_state = WaitWriteCmd;
			
			//�ȴ�д����
			//��Щ�ͳ�ʼ���ĵط���д����һ����
			WaitWriteCmd:
				next_state = (write_cmd_cnt % 2'd3 == 0 && write_done) ? ReadData : (write_done ? WriteCmd: WaitWriteCmd);
			
			//������
			ReadData: 
				next_state = WriteData;
			
			//д����
			WriteData:
				next_state = WaitWriteData;
			
			//�ȴ�д����
			//��Щ�ͳ�ʼ���ĵط���д����һ����
			WaitWriteData: 
				next_state = (address_cnt == 11'd1024&&write_done) ? Done : (address_cnt % 11'd128 == 0&&write_done ? WriteCmd : (write_done ? ReadData : WaitWriteData));
			
			//һ�ζ�д��ɣ��ȴ�100ms��������һ�ζ�д
			Done:begin
				if(us_cnt>DELAY)
					next_state = WriteCmd;
				else
					next_state = Done;
			end
				
		endcase
	end
end
 
//�Ĵ�����ֵ������߼���״̬ת���ֿ�
always @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		oled_dc <= 1'b1;
		ena_write <= 1'b0;
		rden <= 1'b0;
		us_cnt_clr <= 1'b1;
		data <= 8'd0;
	end
	else begin
		case(state)			
			WriteCmd:begin
				ena_write <= 1'b1;						//д���� ʹ��д�ź�
				oled_dc <= 1'b0;							//д���� dc��0
				data <= write_cmd[write_cmd_cnt];	//��ȡд������
			end
			
			WaitWriteCmd:begin
				ena_write <= 1'b0;						//дʹ���ź����ͣ��ȴ�д���
			end
			
			ReadData: begin
			rden <= 1'b1;									//ram��ʹ���ź����� ��ʼ������ ����źſ���һֱ���ߣ���Ϊ��ַ���䣬�����������ݶ��Ǳ��ֲ����
			end
			
			WriteData:begin
				ena_write <= 1'b1;						//д���� дʹ���ź�����
				oled_dc <= 1'b1;							//д�������� dc��1
				data <= ram_data;							//Ϊ����Ҫд�����ݸ�ֵ
			end
			
			WaitWriteData: begin
				ena_write <= 1'b0;						//�ȴ�д��� дʹ���ź�����
			end
			
			Done:begin
				us_cnt_clr <= 1'b0;						//��������λ�ź����ͣ���ʼ����
			end
				
		endcase
	end
end	
//״̬ת��
always @(posedge clk,negedge rst_n) begin
	if(!rst_n)
		state <= WaitInit;
	else
		state <= next_state;
end
//����������
always @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		write_cmd_cnt <= 5'd0;
		address_cnt <= 11'd0;
	end
	else begin
		case(state)
			Done:begin						//���״̬ ����������λ
				write_cmd_cnt <= 5'd0;
				address_cnt <= 11'd0;
			end
												
			WriteCmd: //д����״̬ д�������������
				write_cmd_cnt <= write_cmd_cnt + 1'b1;
			
			ReadData: //������״̬ ����ַ����
				address_cnt <= address_cnt + 1'b1;
			
			default:begin//����״̬ ������ֵ���ֲ���
				write_cmd_cnt <= write_cmd_cnt;
				address_cnt <= address_cnt;
			end
		endcase
	end
end
endmodule