module mem_fill(
	input						clk,
	input						rst_n,
	
	input		[9:0]			i_rd_addr,
	output	[31:0]		o_rd_data,

	input						i_ch_clk,	// channel data clock 20 MHz
	input		[31:0]		i_ch_data_1,
	input						i_ch_vld_1,
	input		[9:0]			i_ch_cntr_1,
	
	input						i_msync_n	// Main Sync
);

reg			[0:0]			prev_msync_n;
always @ (posedge clk) prev_msync_n = i_msync_n;

wire							msync;
assign msync = prev_msync_n != i_msync_n && ~i_msync_n ? 1'b1 : 1'b0;

ch_data_fifo ch_data_fifo_unit(
	.aclr(msync || ~rst_n),
	.wrclk(i_ch_clk),
	.data({6'd0, i_ch_data_1, i_ch_cntr_1}),
	.wrreq(i_ch_vld_1),
	
	.rdclk(clk),
	.q(q_ch_data),
	.rdreq(q_ch_rd),
	.rdempty(q_ch_empty)
);

wire			[47:0]		q_ch_data;
wire							q_ch_empty;
wire							q_ch_rd;
assign q_ch_rd = ~q_ch_empty && phy_channel == 2'd0 ? 1'b1 : 1'b0;

wire			[9:0]			wr_addr;
assign wr_addr = {3'd0, q_ch_data[9:8], q_ch_data[4:0]};

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
	.data(q_ch_data[41:10]),
	
	.rdaddress(i_rd_addr),
	.q(rd_data_1)
);

wire			[31:0]		rd_data_1;

udp_pkt_data udp_pkt_data_unit_2(
	.clock(clk),
	
	.wren(q_ch_rd && flip == 1'b1),
	.wraddress(wr_addr),
	.data(q_ch_data[41:10]),
	
	.rdaddress(i_rd_addr),
	.q(rd_data_2)
);

wire			[31:0]		rd_data_2;

assign o_rd_data = flip == 1'b0 ? rd_data_2 : rd_data_1;

endmodule
