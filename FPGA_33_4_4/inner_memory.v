
`include "rwa_define.v"
`define RAM_RTL
module  inner_memory (
	input                         clk,
	input                         rst_n,
	
	input                         imem_requ_vd,
	input  `N(`XLEN)              imem_requ_addr,
	
	output                        imem_resp_vd,
	output `N(`INUM*`XLEN)        imem_resp_rdata,
	
	input                         dmem_requ_vd,
	input                         dmem_requ_cmd,
	input  `N(2)                  dmem_requ_width,
	input  `N(`XLEN)              dmem_requ_addr,
	input  `N(`XLEN)              dmem_requ_wdata,
	
	output                        dmem_resp_vd,
	output `N(`XLEN)              dmem_resp_rdata
	
);


    localparam          MEM_BYTE_WIDTH   = 16,
	                    MEM_INUM_WIDTH   = 2 + $clog2(`INUM),
						MEM_BLOCK_WIDTH  = MEM_BYTE_WIDTH - MEM_INUM_WIDTH,
						MEM_BYTE_LEN     = 1<<MEM_BYTE_WIDTH,
						MEM_INUM_LEN     = 1<<MEM_INUM_WIDTH,
						MEM_BLOCK_LEN    = 1<<MEM_BLOCK_WIDTH,
						MEM_NUM          = MEM_INUM_LEN>>1;
						
	wire `N(MEM_NUM*MEM_BLOCK_WIDTH)     memory_porta_addr;
	wire `N(MEM_NUM*16)                  memory_porta_rdata;
	
	reg                                  imem_status_vd;
	reg `N(MEM_INUM_WIDTH-1)             imem_status_shift;

    wire `N(MEM_NUM)                     memory_portb_wen;
	wire `N(MEM_NUM*2)                   memory_portb_byte_enable;
	wire `N(MEM_NUM*MEM_BLOCK_WIDTH)     memory_portb_addr;
	wire `N(MEM_NUM*16)                  memory_portb_wdata;
	wire `N(MEM_NUM*16)                  memory_portb_rdata;
	
    reg                                  dmem_status_vd;
	reg  `N(MEM_INUM_WIDTH)              dmem_status_shift;	

    genvar   i;


    generate
	    for ( i=0;i<MEM_NUM;i=i+1 ) begin:gen_porta_addr
`ifdef TCM_MISALLIGNED
	        assign memory_porta_addr[`IDX(i,MEM_BLOCK_WIDTH)] = imem_requ_addr[MEM_BYTE_WIDTH-1:MEM_INUM_WIDTH] + (i<imem_requ_addr[MEM_INUM_WIDTH-1:1]);
`else
            assign memory_porta_addr[`IDX(i,MEM_BLOCK_WIDTH)] = imem_requ_addr[MEM_BYTE_WIDTH-1:MEM_INUM_WIDTH];
`endif 
	    end
	endgenerate

    always @ ( posedge clk or negedge rst_n ) 
	if ( ~rst_n ) begin
	    imem_status_vd    <= 0;
		imem_status_shift <= 0;
	end else begin
	    imem_status_vd    <= imem_requ_vd & ( imem_requ_addr[`XLEN-1:MEM_BYTE_WIDTH]==0 );
		imem_status_shift <= imem_requ_addr[MEM_INUM_WIDTH-1:1];
	end
	
	assign  imem_resp_vd    = imem_status_vd;
	assign  imem_resp_rdata = memory_porta_rdata;//{2{memory_porta_rdata}}>>(imem_status_shift*16);


    wire `N(4)  dmem_byte_enable  =  ( dmem_requ_width==2 ) ? 4'b1111 : (
	                                 ( dmem_requ_width==1 ) ? ( 2'b11<<{dmem_requ_addr[1],1'b0} ) : 
									                          ( 1'b1<<dmem_requ_addr[1:0] )
															  );

    wire `N(32) dmem_wdata        =  ( dmem_requ_width==2 ) ? dmem_requ_wdata : (
	                                 ( dmem_requ_width==1 ) ? {2{dmem_requ_wdata[15:0]}} : 
									                          {4{dmem_requ_wdata[7:0]}}
															  );
    
	assign  memory_portb_byte_enable = dmem_byte_enable<<(4*(dmem_requ_addr[MEM_INUM_WIDTH-1:0]>>2));
    assign  memory_portb_wdata       = dmem_wdata<<(32*(dmem_requ_addr[MEM_INUM_WIDTH-1:0]>>2));

    generate
	    for ( i=0;i<MEM_NUM;i=i+1 ) begin:gen_portb_wen
		    assign memory_portb_wen[i] = dmem_requ_vd & dmem_requ_cmd & (dmem_requ_addr[`XLEN-1:MEM_BYTE_WIDTH]==0) & ( |memory_portb_byte_enable[`IDX(i,2)] );
            assign memory_portb_addr[`IDX(i,MEM_BLOCK_WIDTH)] = dmem_requ_addr[MEM_BYTE_WIDTH-1:MEM_INUM_WIDTH];			
	    end
	endgenerate

    always @ ( posedge clk or negedge rst_n ) 
	if ( ~rst_n ) begin
	    dmem_status_vd    <= 0;
		dmem_status_shift <= 0;
	end else begin
	    dmem_status_vd    <= dmem_requ_vd;
		dmem_status_shift <= dmem_requ_addr[MEM_INUM_WIDTH-1:0];
	end	
	
    assign  dmem_resp_vd    = dmem_status_vd;
	assign  dmem_resp_rdata = memory_portb_rdata>>(dmem_status_shift*8);

    generate
	    for ( i=0;i<MEM_NUM;i=i+1 ) begin:gen_i_bram
`ifdef RAM_RTL
            ram_dual #(
			    .MEM_BLOCK_WIDTH   (    MEM_BLOCK_WIDTH                            )
			) i_bram(
`else		
	        bram i_bram(
`endif
	            .address_a   (    memory_porta_addr[`IDX(i,MEM_BLOCK_WIDTH)]       ),
	            .address_b   (    memory_portb_addr[`IDX(i,MEM_BLOCK_WIDTH)]       ),
	            .byteena_b   (    memory_portb_byte_enable[`IDX(i,2)]              ),
	            .clock       (    clk                                              ),
	            .data_a      (    0                                                ),
	            .data_b      (    memory_portb_wdata[`IDX(i,16)]                   ),
	            .wren_a      (    0                                                ),
	            .wren_b      (    memory_portb_wen[i]                              ),
	            .q_a         (    memory_porta_rdata[`IDX(i,16)]                   ),
	            .q_b         (    memory_portb_rdata[`IDX(i,16)]                   )
	        );
	    end
	endgenerate	

endmodule	
	
	
	