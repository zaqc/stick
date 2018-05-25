module mem_fill(
	input						clk,
	input						rst_n,
	
	input		[9:0]			i_rd_addr,
	output	[31:0]		o_rd_data,

	input						i_ch_clk,	// channel data clock 20 MHz
	
	input		[31:0]		i_ch_data_1,
	input						i_ch_vld_1,
	input		[9:0]			i_ch_cntr_1,
	
	input		[31:0]		i_ch_data_2,
	input						i_ch_vld_2,
	input		[9:0]			i_ch_cntr_2,

	input		[31:0]		i_ch_data_3,
	input						i_ch_vld_3,
	input		[9:0]			i_ch_cntr_3,

	input		[31:0]		i_ch_data_4,
	input						i_ch_vld_4,
	input		[9:0]			i_ch_cntr_4,
	
	input		[31:0]		i_sync_counter,

	input						i_msync_n	// Main Sync
);

reg			[31:0]		tick_counter;
always @ (posedge clk)
	if(msync)
		tick_counter <= tick_counter + 32'd1;

reg			[0:0]			prev_msync_n;
always @ (posedge clk) prev_msync_n = i_msync_n;

wire							msync;
assign msync = prev_msync_n != i_msync_n && ~i_msync_n ? 1'b1 : 1'b0;

reg			[3:0]			df_param;
wire							p_cmpl = &df_param;

always @ (posedge clk)
	if(msync)
		df_param <= 1'b0;
	else
		if(~p_cmpl)
			df_param <= df_param + 4'd1;

wire			[31:0]		p_data;
assign p_data = 
	df_param == 4'h0 ? i_sync_counter :
	df_param == 4'h1 ? tick_counter :
	df_param == 4'h2 ? 32'd0 :
	df_param == 4'h3 ? 32'd0 :
	df_param == 4'h4 ? 32'd0 :
	df_param == 4'h5 ? 32'd0 :
	df_param == 4'h6 ? 32'd0 :
	df_param == 4'h7 ? 32'd0 :
	df_param == 4'h8 ? 32'd0 :
	df_param == 4'h9 ? 32'd0 :
	df_param == 4'hA ? 32'd0 :
	df_param == 4'hB ? 32'd0 :
	df_param == 4'hC ? 32'd0 :
	df_param == 4'hD ? 32'd0 :
	df_param == 4'hE ? 32'd0 :
	df_param == 4'hF ? 32'd0 : 32'd0;

ch_data_fifo ch_data_fifo_unit_1(
	.aclr(msync || ~rst_n),
	.wrclk(i_ch_clk),
	.data({6'd0, i_ch_data_1, i_ch_cntr_1}),
	.wrreq(i_ch_vld_1),
	
	.rdclk(clk),
	.q(q_ch_data_1),
	.rdreq(q_ch_rd_1),
	.rdempty(q_ch_empty_1)
);

wire			[47:0]		q_ch_data_1;
wire							q_ch_empty_1;
wire							q_ch_rd_1;
assign q_ch_rd_1 = p_cmpl && ~q_ch_empty_1 && phy_channel == 2'd0 ? 1'b1 : 1'b0;

//----------------------------------------------------------------------------

ch_data_fifo ch_data_fifo_unit_2(
	.aclr(msync || ~rst_n),
	.wrclk(i_ch_clk),
	.data({6'd0, i_ch_data_2, i_ch_cntr_2}),
	.wrreq(i_ch_vld_2),
	
	.rdclk(clk),
	.q(q_ch_data_2),
	.rdreq(q_ch_rd_2),
	.rdempty(q_ch_empty_2)
);

wire			[47:0]		q_ch_data_2;
wire							q_ch_empty_2;
wire							q_ch_rd_2;
assign q_ch_rd_2 = p_cmpl && ~q_ch_empty_2 && phy_channel == 2'd1 ? 1'b1 : 1'b0;

//----------------------------------------------------------------------------

ch_data_fifo ch_data_fifo_unit_3(
	.aclr(msync || ~rst_n),
	.wrclk(i_ch_clk),
	.data({6'd0, i_ch_data_3, i_ch_cntr_3}),
	.wrreq(i_ch_vld_3),
	
	.rdclk(clk),
	.q(q_ch_data_3),
	.rdreq(q_ch_rd_3),
	.rdempty(q_ch_empty_3)
);

wire			[47:0]		q_ch_data_3;
wire							q_ch_empty_3;
wire							q_ch_rd_3;
assign q_ch_rd_3 = p_cmpl && ~q_ch_empty_3 && phy_channel == 2'd2 ? 1'b1 : 1'b0;

//----------------------------------------------------------------------------

ch_data_fifo ch_data_fifo_unit_4(
	.aclr(msync || ~rst_n),
	.wrclk(i_ch_clk),
	.data({6'd0, i_ch_data_4, i_ch_cntr_4}),
	.wrreq(i_ch_vld_4),
	
	.rdclk(clk),
	.q(q_ch_data_4),
	.rdreq(q_ch_rd_4),
	.rdempty(q_ch_empty_4)
);

wire			[47:0]		q_ch_data_4;
wire							q_ch_empty_4;
wire							q_ch_rd_4;
assign q_ch_rd_4 = p_cmpl && ~q_ch_empty_4 && phy_channel == 2'd3 ? 1'b1 : 1'b0;

//----------------------------------------------------------------------------

wire			[47:0]		q_ch_data;
assign q_ch_data = phy_channel == 2'd0 ? q_ch_data_1 :
						 phy_channel == 2'd1 ? q_ch_data_2 :
						 phy_channel == 2'd2 ? q_ch_data_3 : q_ch_data_4;

wire							q_ch_rd;
assign q_ch_rd = ~p_cmpl | q_ch_rd_1 | q_ch_rd_2 | q_ch_rd_3 | q_ch_rd_4;

wire			[9:0]			wr_addr;
assign wr_addr = ~p_cmpl ? {6'd0, df_param} : 10'h0F + {1'd0, phy_channel, 7'd0} + {3'd0, (2'd3 - q_ch_data[9:8]), q_ch_data[4:0]};

wire			[31:0]		wr_data;
assign wr_data = ~p_cmpl ? p_data : q_ch_data[41:10];

reg			[9:0]			rd_addr;
wire			[31:0]		rd_data;

reg			[1:0]			phy_channel;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		phy_channel <= 2'd0;
	else
		phy_channel <= phy_channel + 2'd1;
		
reg			[0:0]			flip;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		flip <= 1'b0;
	else
		if(msync) flip <= ~flip;

udp_pkt_data udp_pkt_data_unit_1(
	.clock(clk),
	
	.wren(q_ch_rd && flip == 1'b0),
	.wraddress(wr_addr),
	.data(wr_data),
	
	.rdaddress(i_rd_addr),
	.q(rd_data_1)
);

wire			[31:0]		rd_data_1;

udp_pkt_data udp_pkt_data_unit_2(
	.clock(clk),
	
	.wren(q_ch_rd && flip == 1'b1),
	.wraddress(wr_addr),
	.data(wr_data),
	
	.rdaddress(i_rd_addr),
	.q(rd_data_2)
);

wire			[31:0]		rd_data_2;

assign o_rd_data = flip == 1'b0 ? rd_data_2 : rd_data_1;

endmodule
