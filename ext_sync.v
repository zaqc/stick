module ext_sync(
	input					rst_n,
	input					clk,
	
	input					i_ch_a,
	input					i_ch_b,
	
	output				o_sync,
	output	[31:0]	o_sync_counter
);

reg			[1:0]			in_dp;
always @ (posedge clk) in_dp <= {i_ch_a, i_ch_b};

reg			[1:0]			unjit_dp;
reg			[15:0]		unjit_cntr;

always @ (posedge clk) unjit_dp <= in_dp;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		unjit_cntr <= 16'd0;
	else
		if(unjit_dp == in_dp) begin
			if(unjit_cntr < 16'd1000)
				unjit_cntr <= unjit_cntr + 16'd1;
			else
				dp <= in_dp;
		end
		else
			unjit_cntr <= 16'd0;
	
reg			[1:0]			dp;
reg			[1:0]			prev_dp;

always @ (posedge clk) prev_dp <= dp;

reg			[31:0]		tmp_sync_cntr;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		tmp_sync_cntr <= 32'd0;
	else
		case({prev_dp, dp})
			4'b0111, 
			4'b1110, 
			4'b1000, 
			4'b0001: 
				tmp_sync_cntr <= tmp_sync_cntr - 32'd1;
			
			4'b1101,
			4'b0100,
			4'b0010,
			4'b1011:
				tmp_sync_cntr <= tmp_sync_cntr + 32'd1;
		endcase
		
reg			[16:0]		freq_div;
reg			[31:0]		sync_cntr;
always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		freq_div <= 17'd0;
		sync_cntr <= 32'd0;
	end
	else
		if(freq_div < 17'd30000)
			freq_div <= freq_div + 17'd1;
		else begin
			sync_cntr <= tmp_sync_cntr / 4'd13;
			freq_div <= 17'd0;
		end

reg			[31:0]			prev_sync_cntr;
always @ (posedge clk) prev_sync_cntr <= sync_cntr;

assign o_sync = prev_sync_cntr != sync_cntr ? 1'b1 : 1'b0;

assign o_sync_counter = sync_cntr;

endmodule
