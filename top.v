
module top(
    //sys
    input        clk,   
    input        rst_n,
    output       rtc_sclk,
    output       rtc_ce,
    inout        rtc_data,
    output [5:0] seg_sel,
    output [7:0] seg_data,
	 
	 
                       
	 input key1,
	                    output buzzer
    );

wire[7:0] read_second;
wire[7:0] read_minute;
wire[7:0] read_hour;
wire[7:0] read_date;
wire[7:0] read_month;
wire[7:0] read_week;
wire[7:0] read_year;

parameter IDLE    = 0;
parameter BUZZER  = 1;
wire button_negedge;
wire pwm_out;
reg[31:0] period;
reg[31:0] duty;

reg[3:0] state;
reg[31:0] timer;
assign buzzer = ~(pwm_out & (state == BUZZER));//buzzer  low active

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		period <= 32'd0;
		timer <= 32'd0;
		duty <= 32'd429496729;
		state <= IDLE;
	end
	else
		case(state)
			IDLE:
			begin
				if(button_negedge)
				begin
					period <= 32'd8590;   //The pwm step value
					state <= BUZZER;
					duty <= duty + 32'd429496729;
					
				end
			end
			BUZZER:
			begin
				if(timer >= 32'd12_499_999)      //buzzer effictive time 250ms
				begin
					state <= IDLE;
					timer <= 32'd0;
				end
				else
				begin
					timer <= timer + 32'd1;
				end
			end
			default:
			begin
				state <= IDLE;		
			end			
		endcase
end

seg_bcd seg_bcd_m0(
    .clk          (clk),
    .rst_n        (rst_n),
    .seg_sel      (seg_sel),
    .seg_data     (seg_data),
    .seg_bcd      ({read_hour,read_minute,read_second})
);
ds1302_test ds1302_test_m0(
    .rst         (~rst_n),
    .clk         (clk),
    .ds1302_ce   (rtc_ce),
    .ds1302_sclk (rtc_sclk),
    .ds1302_io   (rtc_data),
    .read_second (read_second),
    .read_minute (read_minute),
    .read_hour   (read_hour),
    .read_date   (read_date),
    .read_month  (read_month),
    .read_week   (read_week),
    .read_year   (read_year)
);

ax_debounce ax_debounce_m0
(
    .clk             (clk),
    .rst             (~rst_n),
    .button_in       (key1),
    .button_posedge  (),
    .button_negedge  (button_negedge),
    .button_out      ()
);

ax_pwm#
(
    .N(32)
) 
ax_pwm_m0(
    .clk      (clk),
    .rst      (~rst_n),
    .period   (period),
    .duty     (duty),
    .pwm_out  (pwm_out)
    );
    
endmodule 
    
    