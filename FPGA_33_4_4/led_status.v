	`define N(n)                            [(n)-1:0]
	`define IDX(x,n)                        ((x)*(n))+:(n)	
	`define FFdef(signal,val)               always @(posedge clk or negedge rst_n) if ( ~rst_n )  signal <= val; else 
module led_status #(
	    parameter  LED_NUM    = 9,
		           MHZ        = 50,
				   MULT_MS    = 4000
	)
	(
        input              clk,
        input              rst_n,	    
	    input              enable,
	    input              pulse,
		output `N(LED_NUM) led
	);

    parameter   MS         = 1000*MHZ,
				SECOND_MUL = MULT_MS*MS;
    reg `N(32) idle_count;
	wire   idle_max = (idle_count==SECOND_MUL);
	`FFdef(idle_count,0) idle_count <= idle_max ? 0 : (idle_count+1);
	reg        led_idle;
	`FFdef(led_idle,0) led_idle <= idle_max ? (~led_idle) : led_idle;
	
	
	reg `N(2) pulse_time;
	`FFdef(pulse_time,0) pulse_time <= pulse ? 2'b11 : ( idle_max ? (pulse_time>>1) : pulse_time );
    wire pulse_flag = |pulse_time;
	
	reg  `N(LED_NUM) led_pulse;
	wire `N(LED_NUM) led_pulse_max = 1'b1<<(LED_NUM-1);
	wire `N(LED_NUM) led_pulse_next = (led_pulse==led_pulse_max) ? 1 : (led_pulse<<1);
	`FFdef(led_pulse,1) led_pulse <= pulse ? led_pulse_next : led_pulse;
	
	assign led = enable ? (pulse_flag ? led_pulse : {(LED_NUM){led_idle}}) : 1'b0;
endmodule	