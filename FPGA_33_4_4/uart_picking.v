	`define N(n)                            [(n)-1:0]
	`define IDX(x,n)                        ((x)*(n))+:(n)	
	`define FFdef(signal,val)               always @(posedge clk or negedge rst_n) if ( ~rst_n )  signal <= val; else 
module uart_picking 
#(
    parameter                   PICKING_NUM = 4
)
(
    input                       clk,
	input                       rst_n,
	input                       rx_valid,
	input                       rx_req,
	input  `N(8)                rx_byte,
	
	output                      rx_pk_valid,
	output `N(PICKING_NUM+1)    rx_pk_req_group,
	output `N(8)                rx_pk_byte
);

    reg  `N(PICKING_NUM)    delay_req;
	reg  `N(PICKING_NUM*8)  delay_byte;
	`FFdef(delay_req,0)    delay_req <= rx_valid ? ( rx_req ? {delay_req,1'b1}     : delay_req ) : {delay_req,1'b0};
    `FFdef(delay_byte,0)  delay_byte <= rx_valid ? ( rx_req ? {delay_byte,rx_byte} : delay_byte) : {delay_byte,8'h0};

    assign rx_pk_valid =  rx_valid|(|delay_req);
	assign rx_pk_byte  = delay_byte[`IDX(PICKING_NUM-1,8)];
	
	reg  rx_valid_delay;
	`FFdef(rx_valid_delay,0) rx_valid_delay <= rx_valid;
	wire  rx_valid_rising = ~rx_valid_delay & rx_valid;
	
    reg  `N($clog2(PICKING_NUM+2)) rx_count;
	`FFdef (rx_count,0)  rx_count <= rx_valid_rising     ?                                                               0  : (
	                                 (rx_valid & rx_req) ? ( (rx_count==(PICKING_NUM+1)) ? (PICKING_NUM+1) : (rx_count+1) ) :
									                                                                             rx_count );

    genvar i;
    generate 
        for ( i=0;i<(PICKING_NUM+1);i=i+1 ) begin:gen_main
		    wire         rx_sel = rx_count==(i+1);
			assign rx_pk_req_group[i] = rx_valid ? ( (i==PICKING_NUM) & (&delay_req) & rx_req ) : ( rx_sel ? delay_req[PICKING_NUM-1] : 0 );		
        end
    endgenerate	

endmodule