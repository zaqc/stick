module eth_top(
	input						rst_n,
	input						clk,		// sysclk 100 MHz
	
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

	output	[9:0]			o_rd_addr,
	input		[31:0]		i_rd_data,
	
	input						i_msync_n,
	
	output	[31:0]		o_pkt_counter,
		
	output					o_cmd_flag,
	output	[1:0]			o_cmd_phy_channel,
	output	[31:0]		o_cmd_data,

	
	output	[3:0]			o_led	// for debug purpose
);

eth_pump eth_pump_unit(
	.rst_n(rst_n),
	.clk(clk),
	
	.i_txclk_1(i_txclk_1),			// pcs_mac_tx_clock_connection.clk
	.i_rxclk_1(i_rxclk_1),			// pcs_mac_rx_clock_connection.clk
	.i_rxd_1(i_rxd_1),				// mac_mii_connection
	.i_rxdv_1(i_rxdv_1),
	.i_rxer_1(i_rxer_1),
	
	.o_txd_1(o_txd_1),
	.o_txen_1(o_txen_1),
	.o_txer_1(o_txer_1),
	
	.i_crs_1(i_crs_1),
	.i_col_1(i_col_1),

	.io_mdio_1(io_mdio_1),
	.o_mdc_1(o_mdc_1),
	
	
	.i_txclk_2(i_txclk_2),			// pcs_mac_tx_clock_connection.clk
	.i_rxclk_2(i_rxclk_2),			// pcs_mac_rx_clock_connection.clk
	.i_rxd_2(i_rxd_2),				// mac_mii_connection
	.i_rxdv_2(i_rxdv_2),
	.i_rxer_2(i_rxer_2),
	
	.o_txd_2(o_txd_2),
	.o_txen_2(o_txen_2),
	.o_txer_2(o_txer_2),
	
	.i_crs_2(i_crs_2),
	.i_col_2(i_col_2),

	.io_mdio_2(io_mdio_2),
	.o_mdc_2(o_mdc_2),


	//.o_rx_mod(2'b00),		// signals from/to eth_top
	.o_rx_data(rx_data),
	.i_rx_rdy(rx_rdy),
	.o_rx_vld(rx_vld),
	.o_rx_sop(rx_sop),
	.o_rx_eop(rx_eop),
	
	.i_tx_mod(2'b00),			// signals for transmit
	.i_tx_data(tx_data),
	.i_tx_vld(tx_vld),
	.o_tx_rdy(tx_rdy),
	.i_tx_sop(tx_sop),
	.i_tx_eop(tx_eop)
);


/*
eth eth_unit(
	.reset(~rst_n),
	.clk(clk),
	
	.address(phy_ctr_addr),
	.read(phy_ctr_rd),
	.readdata(phy_ctr_rd_data),
	.write(phy_ctr_wr),
	.writedata(phy_ctr_wr_data),
	.waitrequest(phy_ctr_waitreqest),
	
	.set_10(1'b0),				// mac_status_connection
	.set_1000(1'b0),			//

	.tx_clk(i_txclk),			// pcs_mac_tx_clock_connection.clk
	.rx_clk(i_rxclk),			// pcs_mac_rx_clock_connection.clk
	.m_rx_d(i_rxd),			// mac_mii_connection
	.m_rx_en(i_rxdv),
	.m_rx_err(i_rxer),
	.m_tx_d(o_txd),
	
	.m_tx_en(o_txen),
	.m_tx_err(o_txer),
	.m_rx_crs(i_crs),
	.m_rx_col(i_col),

	.mdc(o_mdc),	           	// mac_mdio_connection
	.mdio_in(mdio_in_phy),
	.mdio_out(mdio_out_phy),
	.mdio_oen(mdio_oen_phy),

	.ff_rx_clk(clk),
	.ff_rx_data(rx_data),
	.ff_rx_rdy(rx_rdy),
	.ff_rx_dval(rx_vld),
	.ff_rx_sop(rx_sop),
	.ff_rx_eop(rx_eop),
	
	.ff_tx_clk(clk),
	.ff_tx_mod(2'b00),
	.ff_tx_wren(tx_vld),
	.ff_tx_data(tx_data),
	.ff_tx_rdy(tx_rdy),
	.ff_tx_sop(tx_sop),
	.ff_tx_eop(tx_eop)
);
*/
//============================================================================
//	Initial param 
//============================================================================

parameter	[47:0]		self_mac = {8'h00, 8'h23, 8'h54, 8'h3C, 8'h47, 8'h1B};
//parameter	[47:0]		target_mac = {8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF};	// Broadcast MAC address

parameter	[31:0]		self_ip = {8'd192, 8'd168, 8'd1, 8'd15};
parameter	[31:0] 		target_ip = {8'd192, 8'd168, 8'd1, 8'd153};

//============================================================================

wire			[31:0]		rx_data;
wire							rx_vld;
wire							rx_rdy;
wire							rx_sop;
wire							rx_eop;

eth_recv eth_recv_unit(
	.rst_n(rst_n),
	.clk(clk),
	
	.i_self_mac(self_mac),		// const
	.i_self_ip(self_ip),			// const
	
	//.i_target_mac(target_mac),	// get by ARP request
	.i_target_ip(target_ip),	// const
	
	.i_data(rx_data),
	.i_vld(rx_vld),
	.o_rdy(rx_rdy),
	.i_sop(rx_sop),
	.i_eop(rx_eop),
	
	.o_arp_operation(res_arp_operation),	// set if ARP Resp accepted from target IP
	.o_arp_target_mac(res_target_mac),
	.o_arp_target_ip(res_target_ip),
	
	.o_cmd_flag(o_cmd_flag),
	.o_cmd_phy_channel(o_cmd_phy_channel),
	.o_cmd_data(o_cmd_data),

	.o_led(o_led)
);

//----------------------------------------------------------------------------

reg			[23:0]		tick_divider;	// 100 MHz
reg			[0:0]			ms_tick;

always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		tick_divider <= 24'd0;
		ms_tick <= 1'b0;
	end
	else
		if(tick_divider < 24'd100000)
			tick_divider <= tick_divider + 24'd1;
		else begin
			tick_divider <= 24'd0;
			ms_tick <= ~ms_tick;
		end
		
reg			[0:0]			prev_ms_tick;
always @ (posedge clk or negedge rst_n) 
	if(~rst_n)
		prev_ms_tick <= 1'b0;
	else
		prev_ms_tick <= ms_tick;
		
reg			[31:0]		ms_counter;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		ms_counter <= 32'd0;
	else
		if(prev_ms_tick != ms_tick)
			ms_counter <= ms_counter + 32'd1;
		
reg			[11:0]		arp_delay;	// 3000
reg			[0:0]			arp_tick;

always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		arp_delay <= 12'd0;
		arp_tick <= 1'b0;
	end
	else
		if(arp_req_sended) begin
			arp_delay <= 12'd0;
			arp_tick <= 1'b0;
		end
		else
			if(arp_delay < 12'd3000) begin
				arp_tick <= 1'b0;
				if(prev_ms_tick != ms_tick)
					arp_delay <= arp_delay + 12'd1;
			end
			else begin
				arp_delay <= 12'd0;
				arp_tick <= 1'b1;		// flash on clk period
			end

wire			[1:0]			res_arp_operation;
wire			[47:0]		res_target_mac;
wire			[31:0]		res_target_ip;

reg			[47:0]		udp_target_mac;	// get by ARP request
reg			[47:0]		arp_resp_mac;		// mac for arp responce
reg			[31:0]		arp_resp_ip;		// ip for arp responce

reg			[0:0]			arp_wait_answer;

reg			[0:0]			arp_accepted_flag;
reg			[0:0]			arp_timeout;
reg			[0:0]			arp_waiting_flag;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		arp_timeout <= 1'b1;
	else
		if(res_arp_operation == 2'd02)	// ARP resp
			arp_timeout <= 1'b0;
		else
			if(arp_tick && arp_waiting_flag)
				arp_timeout <= 1'b1;
				
always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		arp_accepted_flag <= 1'b0;
		udp_target_mac <= 48'd0;
	end
	else
		if(res_arp_operation == 2'd02) begin	// for udp packets
			udp_target_mac <= res_target_mac;
			arp_accepted_flag <= 1'b1;
		end
		else
			if(arp_tick && arp_waiting_flag)		// ARP TIMEOUT is exceeded here
				arp_accepted_flag <= 1'b0;			// and accepted ARP destination MAC goes invalid state
				
always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		arp_wait_answer <= 1'b0;
	end
	else
		if(res_arp_operation == 2'd01) begin	// ARP request accepted
			arp_resp_mac <= res_target_mac;
			arp_resp_ip <= res_target_ip;
			arp_wait_answer <= 1'b1;
		end
		else
			if(arp_resp_sended)
				arp_wait_answer <= 1'b0;
		
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		arp_waiting_flag <= 1'b0;		
	else
		if(res_arp_operation == 2'd02)		// for udp packets
			arp_waiting_flag <= 1'b0;
		else
			if(arp_req_sended)
				arp_waiting_flag <= 1'b1;							
					
wire							arp_req_sended;
assign arp_req_sended = tx_sop == 1'b1 && tx_pkt_type == ARP_REQ_PKT_TYPE ? 1'b1 : 1'b0;

wire							arp_resp_sended;
assign arp_resp_sended = tx_sop == 1'b1 && tx_pkt_type == ARP_RESP_PKT_TYPE ? 1'b1 : 1'b0;
						
// send ARP Req each 3 Sec
// send UDP packet if data ready & distanation address resolved (by ARP)
// send ARP Resp if ARP Request received
// all decision takeing on send eop (selection next step)
// all flags sets on recveive eop


parameter	[3:0]			ETH_NONE = 4'h00;
parameter	[3:0]			ETH_SEND_ARP_REQ = 4'h01;
parameter	[3:0]			ETH_SEND_ARP_RESP = 4'h02;
parameter	[3:0]			ETH_UDP_SEND= 4'h03;

reg			[3:0]			eth_state;
initial eth_state = ETH_NONE;

parameter	[3:0]			ARP_REQ_PKT_TYPE = 4'd1;
parameter	[3:0]			ARP_RESP_PKT_TYPE = 4'd2;
parameter	[3:0]			UDP_PKT_TYPE = 4'd3;

reg			[3:0]			tx_pkt_type;
initial tx_pkt_type = 4'd0;


reg			[0:0]			arp_req_needed;

always @ (posedge clk or negedge rst_n)
	if(~rst_n) 
		arp_req_needed <= 1'b1;
	else begin
		if(arp_tick)
			arp_req_needed <= 1'b1;
		else
			if(arp_req_sended)
				arp_req_needed <= 1'b0;
	end
	
reg			[0:0]			sender_ready;	

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		sender_ready <= 1'b1;
	else
		if(tx_eop)
			sender_ready <= 1'b1;
		else
			if(tx_sop)
				sender_ready <= 1'b0;

	
always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		tx_pkt_type <= ARP_REQ_PKT_TYPE;
		send_target_mac <= 48'hFFFFFFFFFFFF;
		send_target_ip <= self_ip;
	end
	else
		if(sender_ready)
			if(arp_wait_answer) begin
				tx_pkt_type <= ARP_RESP_PKT_TYPE;
				send_target_mac <= arp_resp_mac;
				send_target_ip <= arp_resp_ip;
			end
			else
				if(arp_req_needed) begin
					tx_pkt_type <= ARP_REQ_PKT_TYPE;
					if(arp_timeout) begin  
						send_target_mac <= 48'hFFFFFFFFFFFF;
						send_target_ip <= target_ip;
					end 
					else begin
						send_target_mac <= udp_target_mac;
						send_target_ip <= target_ip;					
					end
				end
				else
					if(arp_accepted_flag) begin
						tx_pkt_type <= UDP_PKT_TYPE;
						send_target_mac <= udp_target_mac;
						send_target_ip <= target_ip;
					end
					else
						tx_pkt_type <= 4'd0;

//----------------------------------------------------------------------------

wire			[31:0]		tx_data;
wire							tx_vld;
wire							tx_rdy;
wire							tx_sop;
wire							tx_eop;

wire							tx_pkt_complite;

reg			[47:0]		send_target_mac;
reg			[31:0]		send_target_ip;

eth_send eth_send_unit(
	.rst_n(rst_n),
	.clk(clk),
	
	.i_pkt_type(tx_pkt_type),
	
	.i_self_mac(self_mac),
	.i_self_ip(self_ip),
	
	.i_target_mac(send_target_mac),
	.i_target_ip(send_target_ip),
	
	.o_data(tx_data),		// signals for send by TSE module (eth_pump) from eth_send
	.o_vld(tx_vld),
	.i_rdy(tx_rdy),
	.o_sop(tx_sop),
	.o_eop(tx_eop),
	
	.o_pkt_complite(tx_pkt_complite),
	
	.o_rd_addr(o_rd_addr),
	.i_rd_data(i_rd_data),
	
	.i_msync_n(i_msync_n)
);

//----------------------------------------------------------------------------

endmodule
