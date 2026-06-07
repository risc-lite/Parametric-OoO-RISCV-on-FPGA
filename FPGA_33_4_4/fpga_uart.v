module fpga_uart
#(parameter KHZ     = 50000,
            BAUD    = 115200,
			PARITY  = 0,
			EVEN    = 0,
			STOP    = 1
  )
 (
            clk,
			rst_n,
			rx,
			tx_req,
			tx_byte,
			
			rx_req,
			rx_byte,
			rx_valid,
			tx,
			tx_ready
			);

input        clk;
input        rst_n;
input        rx;
input        tx_req;
input  [7:0] tx_byte;

output       rx_req;
output [7:0] rx_byte;
output       rx_valid;
output       tx;
output       tx_ready;


/***********************************/

localparam PERIOD = (KHZ*1000)/(BAUD),
           HALF   = PERIOD/2,
           PERI_LEN = $clog2(PERIOD+1);

localparam [3:0]  data_length = 8 + PARITY + STOP; 
localparam [3:0]  recv_length = data_length - 1;

/***********************************/
reg            rx_dly;
reg    [PERI_LEN-1:0]  rx_cnt;
reg            data_vld;
reg    [3:0]   data_cnt;
reg            rx_vld;
reg    [7:0]   rx_byte;
reg    [7:0]   tx_rdy_data;
reg            tran_vld;
reg    [3:0]   tran_cnt;
reg            tx;
/***********************************/
wire           rx_change;
wire           rx_en;

wire         rst    = ~rst_n;
wire         tx_vld = tx_req;
assign       rx_req = rx_vld;

/***********************************/

reg rx1,rx2,rx3,rxx;
always @ ( posedge clk ) begin
    rx1 <=  rx;
	rx2 <=  rx1;
	rx3 <=  rx2;
	rxx <=  rx3;
	end

always @ ( posedge clk  )
   rx_dly <=  rxx;

assign rx_change = (rxx != rx_dly );

always @ ( posedge clk or posedge rst )
if ( rst )
    rx_cnt <=  0;
else if ( rx_change | ( rx_cnt==PERIOD ) )
    rx_cnt <=  0;
else
    rx_cnt <=  rx_cnt + 1'b1;

assign rx_en = ( rx_cnt==HALF );

always @ ( posedge clk or posedge rst )
if ( rst )
    data_vld <=  1'b0;
else if ( rx_en & ~rxx & ~data_vld )
    data_vld <=  1'b1;
else if ( data_vld & ( data_cnt==recv_length ) & rx_en )
    data_vld <=  1'b0;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    data_cnt <=  4'b0;
else if ( data_vld )
    if ( rx_en )
        data_cnt <=  data_cnt + 1'b1;
	else;
else 	
    data_cnt <=  4'b0;

always @ ( posedge clk or posedge rst )
if ( rst )
    rx_byte <=  7'b0;
else if ( data_vld & rx_en & ~data_cnt[3] )
    rx_byte <=  {rxx,rx_byte[7:1]}; 
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    rx_vld <=  1'b0;
else
    rx_vld <=  data_vld & rx_en & ( data_cnt==recv_length);

always @ ( posedge clk or posedge rst )
if ( rst )
    tx_rdy_data <=  8'b0;
else if ( tx_vld & tx_ready )
    tx_rdy_data <=  tx_byte;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    tran_vld <=  1'b0;
else if ( tx_vld )
    tran_vld <=  1'b1;
else if ( tran_vld & rx_en & ( tran_cnt== data_length ) )
    tran_vld <=  1'b0;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    tran_cnt <=  4'b0;
else if ( tran_vld )
    if( rx_en )
	    tran_cnt <=  tran_cnt + 1'b1;
	else;
else
    tran_cnt <=  4'b0;

wire  parity_bit = EVEN ? ( ^tx_rdy_data ) : ~(^tx_rdy_data);

wire [15:0] tx_packet = (tx_rdy_data<<1)|(( PARITY ? {6'b11111,parity_bit} : 7'b111111 )<<9);	
	
always @ ( posedge clk or posedge rst )
if ( rst )
    tx <=  1'b1;
else if ( tran_vld )
    if ( rx_en )
        tx <= tx_packet[tran_cnt];
	else;
else
    tx<=  1'b1;

assign tx_ready = ~tran_vld;

reg [2:0] rx_log;
always @ ( posedge clk or posedge rst )
if ( rst )
    rx_log <= 0;
else if ( rx_en )
    rx_log <= { rx_log,data_vld };
else;	

assign rx_valid = |rx_log;	

endmodule