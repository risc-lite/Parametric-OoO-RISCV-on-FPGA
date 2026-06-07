
module  uart_buffer(
    input              clk,
    input              rst_n,

    input              raw_vld,
    input  `N(8)       raw_byte,

    input              uart_tx_rdy,
    output             uart_tx_vld,
    output `N(8)       uart_tx_byte

);

    parameter    RAM_WIDTH  = 14,
                 RAM_DEPTH  = (1<<RAM_WIDTH);

    (* ram_style="block" *) reg `N(8) mem `N(RAM_DEPTH);

    reg  `N(RAM_WIDTH) wr_addr;
    reg  `N(RAM_WIDTH) rd_addr;

    wire        wr_vld = raw_vld;
    wire `N(8) wr_byte = raw_byte;

    `FFabbr(wr_addr,0) wr_addr <= wr_vld ? (wr_addr+1'b1) : wr_addr;
   
    reg rd_rdy;
    wire        rd_vld = uart_tx_rdy & ~rd_rdy & ( wr_addr!=rd_addr );
    `FFabbr(rd_rdy,0) rd_rdy <= rd_vld;
    `FFabbr(rd_addr,0) rd_addr <= rd_vld ? (rd_addr+1'b1) : rd_addr;

    always @ ( posedge clk )  
    if ( wr_vld )
        mem[wr_addr] <= wr_byte;
    else;

    reg `N(8) mem_dout;
    always @ ( posedge clk )
    if ( rd_vld )
        mem_dout <= mem[rd_addr];
    else;

    assign uart_tx_vld  = rd_rdy;
    assign uart_tx_byte = mem_dout;

endmodule

