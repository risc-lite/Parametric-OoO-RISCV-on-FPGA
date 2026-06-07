module ram_dual
    #(
        parameter MEM_BLOCK_WIDTH = 14,
                  MEM_BLOCK_LEN   = (2**MEM_BLOCK_WIDTH)		
    )
    (
	address_a,
	address_b,
	byteena_b,
	clock,
	data_a,
	data_b,
	wren_a,
	wren_b,
	q_a,
	q_b
	);

	input	`N(MEM_BLOCK_WIDTH)  address_a;
	input	`N(MEM_BLOCK_WIDTH)  address_b;
	input	[1:0]                byteena_b;
	input	                     clock;
	input	[15:0]               data_a;
	input	[15:0]               data_b;
	input	                     wren_a;
	input	                     wren_b;
	output	[15:0]               q_a;
	output	[15:0]               q_b;
	
	reg     `N(16)               q_a;
	reg     `N(16)               q_b;
	
	reg     [7:0]  mem_byte0 `N(MEM_BLOCK_LEN);
	reg     [7:0]  mem_byte1 `N(MEM_BLOCK_LEN);	
	
	always @ (posedge clock)  begin
		q_a <= {mem_byte1[address_a],mem_byte0[address_a]};
    end	
	
	always @ (posedge clock) begin
	    if ( wren_b & byteena_b[0] ) begin
		    mem_byte0[address_b] <= data_b[7:0];
		end 
	    if ( wren_b & byteena_b[1] ) begin
		    mem_byte1[address_b] <= data_b[15:8];
		end 		
		q_b <= {mem_byte1[address_b],mem_byte0[address_b]};
	end

endmodule