module nios_eth(
	input					rst_n,
	input					clk,		// sysclk 100 MHz
	
	input 	[3:0] 	i_rxd,
	input 				i_rxer,
	input 				i_rxdv,
	input 				i_rxclk,
	input 				i_col,
	input 				i_crs,
	
	output	[3:0] 	o_txd,
	output 				o_txer,
	output 				o_txen,
	input					i_txclk,
	
	inout 				io_mdio,
	output 				o_mdc,
	
	output				o_phy_rst,
	
	output	[3:0]		o_led	// for debug purpose
);

// enable 1Gbit disable Ethernet RX TX
// IOWR(ETH_TSE_BASE, 0x02, 0x08);

// Initialize the MAC address
// IOWR(ETH_TSE_BASE, 3, 0x11362200);
// IOWR(ETH_TSE_BASE, 4, 0x00000F02);

nios_sys nios_sys_unit(
	.clk_clk(clk),
	
	.mac_tx_clk_clk(i_txclk),     	// mac_tx_clk.clk
	.mac_rx_clk_clk(i_rxclk),     	// mac_rx_clk.clk
	.mac_mii_mii_rx_d(i_rxd),   		//    mac_mii.mii_rx_d
	.mac_mii_mii_rx_dv(i_rxdv),  		//           .mii_rx_dv
	.mac_mii_mii_rx_err(i_rxer), 		//           .mii_rx_err
	
	.mac_mii_mii_tx_d(o_txd),   		//           .mii_tx_d
	.mac_mii_mii_tx_en(o_txen),  		//           .mii_tx_en
	.mac_mii_mii_tx_err(o_txer), 		//           .mii_tx_err
	
	.mac_mii_mii_crs(i_crs),    		//           .mii_crs
	.mac_mii_mii_col(i_col),    		//           .mii_col
	
	.mdio_mdc(o_mdc),           		//       mdio.mdc
	.mdio_mdio_in(mdio_in_phy),      //           .mdio_in
	.mdio_mdio_out(mdio_out_phy),    //           .mdio_out
	.mdio_mdio_oen(mdio_oen_phy),		//           .mdio_oen

	.status_set_10(1'b0),      		// status.set_10
	.status_set_1000(1'b0),    		//       .set_1000
	
/*
		output wire [31:0] rx_data,            //         rx.data
		output wire        rx_endofpacket,     //           .endofpacket
		output wire [5:0]  rx_error,           //           .error
		output wire [1:0]  rx_empty,           //           .empty
		input  wire        rx_ready,           //           .ready
		output wire        rx_startofpacket,   //           .startofpacket
		output wire        rx_valid,           //           .valid
		input  wire [31:0] tx_data,            //         tx.data
		input  wire        tx_endofpacket,     //           .endofpacket
		input  wire        tx_error,           //           .error
		input  wire [1:0]  tx_empty,           //           .empty
		output wire        tx_ready,           //           .ready
		input  wire        tx_startofpacket,   //           .startofpacket
		input  wire        tx_valid,           //           .valid
		input  wire        rx_clk_clk,         //     rx_clk.clk
		input  wire        tx_clk_clk,         //     tx_clk.clk
*/

	.rx_ready(1'b1),
	.rx_valid(rx_vld),
	
	.rx_clk_clk(clk),
	.tx_clk_clk(clk),
	
	.out_reset_reset(o_phy_rst)    //  out_reset.reset
);

reg			[31:0]		r_led_cnt;

wire							rx_vld;
always @ (posedge clk)
	if(rx_vld)
		r_led_cnt <= r_led_cnt + 4'd1;
	
assign o_led = r_led_cnt[3:0];

endmodule
