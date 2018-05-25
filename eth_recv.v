module eth_recv(
	input						rst_n,
	input						clk,
	
	input		[47:0]		i_self_mac,
	input		[31:0]		i_self_ip,
	
	//input		[47:0]		i_target_mac,
	input		[31:0]		i_target_ip,
	
	input		[31:0]		i_data,
	input						i_vld,
	output					o_rdy,
	input						i_sop,
	input						i_eop,
	
	output	[1:0]			o_arp_operation,		// 01-req 02-resp
	output	[47:0]		o_arp_target_mac,
	output	[31:0]		o_arp_target_ip,
	
	output					o_cmd_flag,
	output	[1:0]			o_cmd_phy_channel,
	output	[31:0]		o_cmd_data,
		
	output	[3:0]			o_led
);

assign o_rdy = 1'b1;

reg			[8:0]			recv_step;

reg			[47:0]		dst_mac;
reg			[47:0]		src_mac;

reg			[15:0]		pkt_type;

parameter	[15:0]		ARP_PKT_TYPE = 16'h0806;
parameter	[15:0]		IPv4_PKT_TYPE = 16'h0800;

reg			[15:0]		hdr_dummy;

always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		recv_step <= 8'h00;
		{hdr_dummy, dst_mac[47:32]} <= 32'd0;
	end
	else
		if(i_vld)
			if(i_sop) begin
				{hdr_dummy, dst_mac[47:32]} <= i_data;
				recv_step <= 8'h01;
			end
			else
				if(i_eop)
					recv_step <= 8'h00;
				else
					if(|{recv_step} && ~&{recv_step})
						recv_step <= recv_step + 8'h01;

//----------------------------------------------------------------------------
//	Ethernet packet header
//----------------------------------------------------------------------------

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dst_mac[31:0] <= 32'd0;
		src_mac <= 48'd0;
		pkt_type <= 16'd0;
	end
	else
		if(i_vld)
			case(recv_step)
				8'h01: dst_mac[31:0] <= i_data;
				8'h02: src_mac[47:16] <= i_data;
				8'h03: {src_mac[15:0], pkt_type} <= i_data;
			endcase
end

//----------------------------------------------------------------------------
//	ARP packet header
//----------------------------------------------------------------------------


reg 			[63:0]		arp_header;
wire			[15:0]		ARP_HTYPE;		// 16'h0001
wire			[15:0]		ARP_PTYPE;		// 16'h0800
wire			[7:0]			ARP_HLEN;		// 8'h06;	//	MAC size
wire			[7:0]			ARP_PLEN;		// 8'h04;	// for IPv4

wire			[15:0]		ARP_OPERATION;	// 16'd01=ACK 16'd02=ANSWER

assign {ARP_HTYPE, ARP_PTYPE, ARP_HLEN, ARP_PLEN, ARP_OPERATION} = arp_header;


reg			[47:0]		SHA;
reg			[31:0]		SPA;
reg			[47:0]		THA;
reg			[31:0]		TPA;

//----------------------------------------------------------------------------
//	IPv4 packet header
//----------------------------------------------------------------------------

reg			[31:0]		ip_hdr_1;
reg			[31:0]		ip_hdr_2;
reg			[31:0]		ip_hdr_3;

wire			[7:0]			ip_protocol;
assign ip_protocol = ip_hdr_3[23:16];

reg			[31:0]		ip_hdr_src_ip;
reg			[31:0]		ip_hdr_dst_ip;

//----------------------------------------------------------------------------
//	UDP packet header
//----------------------------------------------------------------------------

reg			[15:0]		udp_src_port;
reg			[15:0]		udp_dst_port;
reg			[15:0]		udp_length;
reg			[15:0]		udp_crc;

reg			[1:0]			cmd_phy_channel;
reg			[31:0]		cmd_data;

always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		arp_header <= 64'd0;
		SHA <= 48'd0;
		SPA <= 32'd0;
		THA <= 48'd0;
		TPA <= 32'd0;
	end
	else
		if(i_vld)
			if(pkt_type == ARP_PKT_TYPE)
				case(recv_step)
					8'h04: arp_header[63:32] <= i_data;
					8'h05: arp_header[31:0] <= i_data;
					8'h06: SHA[47:16] <= i_data;
					8'h07: {SHA[15:0], SPA[31:16]} <= i_data;
					8'h08: {SPA[15:0], THA[47:32]} <= i_data;
					8'h09: THA[31:0] <= i_data;
					8'h0A: TPA <= i_data;
				endcase
			else
				if(pkt_type == IPv4_PKT_TYPE)
					case(recv_step)
						8'h04: ip_hdr_1 <= i_data;
						8'h05: ip_hdr_2 <= i_data;
						8'h06: ip_hdr_3 <= i_data;
						8'h07: ip_hdr_src_ip <= i_data;
						8'h08: ip_hdr_dst_ip <= i_data;
						8'h09: {udp_src_port, udp_dst_port} <= i_data;
						8'h0A: {udp_length, udp_crc} <= i_data;
						8'h0B: cmd_phy_channel <= i_data[1:0];
						8'h0C: cmd_data <= i_data;
					endcase
end

reg			[3:0]			led_cnt;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		led_cnt <= 4'd0;
	else
		if(o_cmd_flag) //o_arp_operation == 2'd02)
			led_cnt <= led_cnt + 4'd1;
			
assign o_led = led_cnt;

reg			[0:0]			prev_eop;
always @ (posedge clk) prev_eop <= i_eop;

assign o_arp_operation = i_eop && ~prev_eop &&
						pkt_type == ARP_PKT_TYPE && 
						//SPA == i_target_ip &&				// answer from target IP
						//THA == i_self_mac && 				// to my MAC
						TPA == i_self_ip	 					// and my IP
												? ARP_OPERATION[1:0] : 2'b0;
						
assign o_arp_target_mac = SHA;
assign o_arp_target_ip = SPA;

assign o_cmd_phy_channel = cmd_phy_channel;
assign o_cmd_data = cmd_data;

assign o_cmd_flag = i_eop && ~prev_eop &&
						pkt_type == IPv4_PKT_TYPE &&
						ip_protocol == 8'd17 && // UDP
						dst_mac == i_self_mac &&
						ip_hdr_dst_ip == i_self_ip &&
						udp_dst_port == 16'd1456 ? 1'b1 : 1'b0;

endmodule
