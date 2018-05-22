module eth_pump(
	input						rst_n,
	input						clk,
	
	input 	[3:0] 		i_rxd_1,
	input 					i_rxer_1,
	input 					i_rxdv_1,
	input 					i_rxclk_1,
	input 					i_col_1,
	input 					i_crs_1,
	
	output	[3:0] 		o_txd_1,
	output 					o_txer_1,
	output 					o_txen_1,
	input						i_txclk_1,
	
	inout 					io_mdio_1,
	output 					o_mdc_1,
	
	input 	[3:0] 		i_rxd_2,
	input 					i_rxer_2,
	input 					i_rxdv_2,
	input 					i_rxclk_2,
	input 					i_col_2,
	input 					i_crs_2,
	
	output	[3:0] 		o_txd_2,
	output 					o_txer_2,
	output 					o_txen_2,
	input						i_txclk_2,
	
	inout 					io_mdio_2,
	output 					o_mdc_2,
	
	output	[1:0]			o_rx_mod,		// signals from/to eth_top
	output	[31:0]		o_rx_data,
	input						i_rx_rdy,
	output					o_rx_vld,
	output					o_rx_sop,
	output					o_rx_eop,
	
	input		[1:0]			i_tx_mod,
	input		[31:0]		i_tx_data,
	input						i_tx_vld,
	output					o_tx_rdy,
	input						i_tx_sop,
	input						i_tx_eop
);

eth eth_unit_1(
	.reset(~rst_n),
	.clk(clk),

	.address(phy_ctr_addr_1),
	.read(phy_ctr_rd_1),
	.readdata(phy_ctr_rd_data_1),
	.write(phy_ctr_wr_1),
	.writedata(phy_ctr_wr_data_1),
	.waitrequest(phy_ctr_waitreqest_1),
	
	.set_10(1'b0),					// mac_status_connection
	.set_1000(1'b0),				//

	.tx_clk(i_txclk_1),			// pcs_mac_tx_clock_connection.clk
	.rx_clk(i_rxclk_1),			// pcs_mac_rx_clock_connection.clk
	.m_rx_d(i_rxd_1),				// mac_mii_connection
	.m_rx_en(i_rxdv_1),
	.m_rx_err(i_rxer_1),
	.m_tx_d(o_txd_1),
	
	.m_tx_en(o_txen_1),
	.m_tx_err(o_txer_1),
	.m_rx_crs(i_crs_1),
	.m_rx_col(i_col_1),

	.mdc(o_mdc_1),	           	// mac_mdio_connection
	.mdio_in(mdio_in_phy_1),
	.mdio_out(mdio_out_phy_1),
	.mdio_oen(mdio_oen_phy_1),

	.ff_rx_clk(clk),
	.ff_rx_mod(rx_mod_1),
	.ff_rx_data(rx_data_1),
	.ff_rx_rdy(rx_rdy_1),
	.ff_rx_dval(rx_vld_1),
	.ff_rx_sop(rx_sop_1),
	.ff_rx_eop(rx_eop_1),
	
	.ff_tx_clk(clk),
	.ff_tx_mod(tx_mod_1),
	.ff_tx_wren(tx_vld_1),
	.ff_tx_data(tx_data_1),
	.ff_tx_rdy(tx_rdy_1),
	.ff_tx_sop(tx_sop_1),
	.ff_tx_eop(tx_eop_1)
);

//----------------------------------------------------------------------------

wire							mdio_in_phy_1;
wire							mdio_out_phy_1;
wire							mdio_oen_phy_1;

assign mdio_in_phy_1 = io_mdio_1;
assign io_mdio_1 = mdio_oen_phy_1 ? 1'bZ : mdio_out_phy_1;

//----------------------------------------------------------------------------

wire			[1:0]			rx_mod_1;
wire			[31:0]		rx_data_1;
wire							rx_rdy_1;
wire							rx_vld_1;
wire							rx_sop_1;
wire							rx_eop_1;
	
wire			[1:0]			tx_mod_1;
wire			[31:0]		tx_data_1;
wire							tx_vld_1;
wire							tx_rdy_1;
wire							tx_sop_1;
wire							tx_eop_1;

//----------------------------------------------------------------------------
	
eth eth_unit_2(
	.reset(~rst_n),
	.clk(clk),

	.address(phy_ctr_addr_2),
	.read(phy_ctr_rd_2),
	.readdata(phy_ctr_rd_data_2),
	.write(phy_ctr_wr_2),
	.writedata(phy_ctr_wr_data_2),
	.waitrequest(phy_ctr_waitreqest_2),
	
	.set_10(1'b0),					// mac_status_connection
	.set_1000(1'b0),				//

	.tx_clk(i_txclk_2),			// pcs_mac_tx_clock_connection.clk
	.rx_clk(i_rxclk_2),			// pcs_mac_rx_clock_connection.clk
	.m_rx_d(i_rxd_2),				// mac_mii_connection
	.m_rx_en(i_rxdv_2),
	.m_rx_err(i_rxer_2),
	.m_tx_d(o_txd_2),
	
	.m_tx_en(o_txen_2),
	.m_tx_err(o_txer_2),
	.m_rx_crs(i_crs_2),
	.m_rx_col(i_col_2),

	.mdc(o_mdc_2),	           	// mac_mdio_connection
	.mdio_in(mdio_in_phy_2),
	.mdio_out(mdio_out_phy_2),
	.mdio_oen(mdio_oen_phy_2),

	.ff_rx_clk(clk),
	.ff_rx_mod(rx_mod_2),
	.ff_rx_data(rx_data_2),
	.ff_rx_rdy(rx_rdy_2),
	.ff_rx_dval(rx_vld_2),
	.ff_rx_sop(rx_sop_2),
	.ff_rx_eop(rx_eop_2),
	
	.ff_tx_clk(clk),
	.ff_tx_mod(tx_mod_2),
	.ff_tx_wren(tx_vld_2),
	.ff_tx_data(tx_data_2),
	.ff_tx_rdy(tx_rdy_2),
	.ff_tx_sop(tx_sop_2),
	.ff_tx_eop(tx_eop_2)
);

//----------------------------------------------------------------------------

wire							mdio_in_phy_2;
wire							mdio_out_phy_2;
wire							mdio_oen_phy_2;

assign mdio_in_phy_2 = io_mdio_2;
assign io_mdio_2 = mdio_oen_phy_2 ? 1'bZ : mdio_out_phy_2;

//----------------------------------------------------------------------------

wire			[1:0]			rx_mod_2;
wire			[31:0]		rx_data_2;
wire							rx_rdy_2;
wire							rx_vld_2;
wire							rx_sop_2;
wire							rx_eop_2;

wire			[1:0]			tx_mod_2;
wire			[31:0]		tx_data_2;
wire							tx_vld_2;
wire							tx_rdy_2;
wire							tx_sop_2;
wire							tx_eop_2;

//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//		PUMP FIFO 1
//----------------------------------------------------------------------------
wire			[35:0]		in_data_1;
assign in_data_1 = {rx_data_1, rx_mod_1, rx_sop_1, rx_eop_1};

wire							in_full_1;
assign rx_rdy_1 = ~in_full_1;

pump_fifo pump_fifo_unit_1(
	.clock(clk),
	
	.data(in_data_1),		// input from eth1 (comp)
	.wrreq(rx_vld_1),
	.full(in_full_1),
	
	.q(out_data_1),		// output to eth2 (inet)
	.rdreq(tx_rdy_2 & i_rx_rdy),
	.empty(out_empty_1)
);

wire			[35:0]		out_data_1;
assign {tx_data_2, tx_mod_2, tx_sop_2, tx_eop_2} = out_data_1;
assign {o_rx_data, o_rx_mod, o_rx_sop, o_rx_eop} = out_data_1;

wire 							out_empty_1;
assign tx_vld_2 = ~out_empty_1;	// translate input stream both to eth2
assign o_rx_vld = ~out_empty_1;	// & to local
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//		PUMP FIFO 2
//----------------------------------------------------------------------------

reg 			[0:0]			p_out;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		p_out <= 1'b1;
	else
		if(~p_out) begin
			if(~out_empty_3 && (out_empty_2 || tx_eop_1))
				p_out <= 1'b1;
		end
		else begin
			if(~out_empty_2 && (out_empty_3 || tx_eop_1))
				p_out <= 1'b0;
		end
wire			[35:0]		in_data_2;
assign in_data_2 = {rx_data_2, rx_mod_2, rx_sop_2, rx_eop_2};

wire							in_full_2;
assign rx_rdy_2 = ~in_full_2;

pump_fifo pump_fifo_unit_2(
	.clock(clk),
	
	.data(in_data_2),		// input from eth2 (inet)
	.wrreq(rx_vld_2),
	.full(in_full_2),
	
	.q(out_data_2),		// output to eth1 (comp)
	.rdreq(tx_rdy_1 & p_out == 1'b0),
	.empty(out_empty_2)
);

wire			[35:0]		out_data_2;
//assign {tx_data_1, tx_mod_1, tx_sop_1, tx_eop_1} = out_data_2;

wire 							out_empty_2;
//assign tx_vld_1 = ~out_empty_2;// & p_out == 1'b0;
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
//		PUMP FIFO 3
//----------------------------------------------------------------------------
wire			[35:0]		in_data_3;
assign in_data_3 = {i_tx_data, i_tx_mod, i_tx_sop, i_tx_eop};

wire							in_full_3;
assign o_tx_rdy = ~in_full_3;

pump_fifo pump_fifo_unit_3(
	.clock(clk),
	
	.data(in_data_3),		// input from eth2 (inet)
	.wrreq(i_tx_vld),
	.full(in_full_3),
	
	.q(out_data_3),		// output to eth1 (comp)
	.rdreq(tx_rdy_1 & p_out == 1'b1),
	.empty(out_empty_3)
);

wire			[35:0]		out_data_3;
assign {tx_data_1, tx_mod_1, tx_sop_1, tx_eop_1} =  p_out == 1'b0 ? out_data_2 : out_data_3;

wire 							out_empty_3;
assign tx_vld_1 = p_out == 1'b0 ? ~out_empty_2 : ~out_empty_3;
//----------------------------------------------------------------------------

/*
assign tx_mod_2 = rx_mod_1;
assign tx_mod_1 = rx_mod_2;

assign rx_rdy_2 = tx_rdy_1;
assign rx_rdy_1 = tx_rdy_2;

assign tx_vld_2 = rx_vld_1;
assign tx_vld_1 = rx_vld_2;

assign tx_data_2 = rx_data_1;
assign tx_data_1 = rx_data_2;

assign tx_sop_2 = rx_sop_1;
assign tx_sop_1 = rx_sop_2;

assign tx_eop_2 = rx_eop_1;
assign tx_eop_1 = rx_eop_2;
*/

//----------------------------------------------------------------------------
//	init phy 1
//----------------------------------------------------------------------------

wire			[7:0]			phy_ctr_addr_1;
wire			[31:0]		phy_ctr_wr_data_1;
wire							phy_ctr_wr_1;
wire			[31:0]		phy_ctr_rd_data_1;
wire							phy_ctr_rd_1;
wire							phy_ctr_waitreqest_1;

init_phy init_phy_unit_1(
	.clk(clk),
	.rst_n(rst_n),

	.o_phy_ctr_addr(phy_ctr_addr_1),
	.o_phy_ctr_wr_data(phy_ctr_wr_data_1),
	.o_phy_ctr_wr(phy_ctr_wr_1),
	.i_phy_ctr_rd_data(phy_ctr_rd_data_1),
	.o_phy_ctr_rd(phy_ctr_rd_1),
	
	.i_phy_ctr_waitreqest(phy_ctr_waitreqest_1)
);

wire			[7:0]			phy_ctr_addr_2;
wire			[31:0]		phy_ctr_wr_data_2;
wire							phy_ctr_wr_2;
wire			[31:0]		phy_ctr_rd_data_2;
wire							phy_ctr_rd_2;
wire							phy_ctr_waitreqest_2;

init_phy init_phy_unit_2(
	.clk(clk),
	.rst_n(rst_n),

	.o_phy_ctr_addr(phy_ctr_addr_2),
	.o_phy_ctr_wr_data(phy_ctr_wr_data_2),
	.o_phy_ctr_wr(phy_ctr_wr_2),
	.i_phy_ctr_rd_data(phy_ctr_rd_data_2),
	.o_phy_ctr_rd(phy_ctr_rd_2),
	
	.i_phy_ctr_waitreqest(phy_ctr_waitreqest_2)
);

endmodule
