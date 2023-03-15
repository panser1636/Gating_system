module spi_writebyte(
	input clk,			//ʱ���ź� 1m��ʱ��
	input rst_n,		//��λ�ź� ������λ
	input ena_write,	//spiдʹ���ź�
	input [7:0]data,	//spiд������
	output reg sclk,	//oled��ʱ���źţ�d0��
	output reg mosi,	//oled�������źţ�d1��
	output write_done //spiд����ź�
);
 
parameter S0=0,S1=1,S2=2,Done=3;
reg[1:0] state,next_state;
reg[3:0] cnt;		//д���ݵ�λ������
 
//״̬����һ��״̬ȷ��
always @(*) begin
	if(!rst_n) begin
		next_state <= 2'd0;
	end
	else begin
		case(state)
			S0: //�ȴ�дʹ���ź�
				next_state = ena_write ? S1 : S0;
			
			S1: 
				next_state = S2;
			
			S2: //��s1��s2��λ��cnt�ż�1������Ҫcnt��8�ٵ���һ��״̬
				next_state = (cnt == 4'd8) ? Done : S1;
			
			Done://���״̬��Ҫ��������done�ź����
				next_state = S0;
			
		endcase
	end
end
 
//��ֵ��״̬ת���ֿ�
//���reg���Latch������
always @(posedge clk,negedge rst_n) begin
	if(!rst_n) begin
		sclk = 1'b1;
		mosi = 1'b0;
	end
	else begin
		case(state)
			S0: begin//�ȴ�дʹ���ź�
				sclk = 1'b1;
				mosi = 1'b0;
			end
			S1: begin
				sclk = 1'b0;
				mosi = data[3'd7-cnt] ? 1'b1 : 1'b0;
			end
			S2: begin//��s1��s2��λ��cnt�ż�1������Ҫcnt��8�ٵ���һ��״̬
				sclk = 1'b1;
			end
		endcase
	end
end
//״̬��ת
always @(posedge clk,negedge rst_n) begin
	if(~rst_n)
		state <= S0;
	else
		state <= next_state;
end
//����������
always @(posedge clk,negedge rst_n) begin
	if(~rst_n) begin
		cnt <= 4'd0;
	end
	else begin
		if(state == S1)
			cnt <= cnt + 1'b1;
		else if(state == S0)
			cnt <= 4'd0;
		else
			cnt <= cnt;
	end
end
 
assign write_done = (state==Done);//done�ź����
	
endmodule
 
 