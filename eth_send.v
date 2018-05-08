module eth_send(
	input						rst_n,
	input						clk,
	
	input		[3:0]			i_pkt_type,
	
	input		[47:0]		i_self_mac,
	input		[31:0]		i_self_ip,
	input		[47:0]		i_target_mac,
	input		[31:0]		i_target_ip,
	
	output	[31:0]		o_data,
	output					o_vld,
	input						i_rdy,
	output					o_eop,
	output					o_sop,
	
	output					o_pkt_complite,
	
	output	[9:0]			o_rd_addr,
	input		[31:0]		i_rd_data,
		
	input						i_msync_n	// Main Sync
);

reg			[9:0]			rd_addr;
assign o_rd_addr = rd_addr;

wire							udp_data_stream;
assign udp_data_stream = send_step >= 16'h0B ? 1'b1 : 1'b0; 

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		rd_addr <= 10'd0;
	else
		if(udp_data_stream)
			rd_addr <= rd_addr + 10'd1;
		else
			if(prev_msync_n != i_msync_n && ~i_msync_n && i_pkt_type == UDP_PKT_TYPE)
				rd_addr <= 10'd0;

//============================================================================
// GLOBAL PARAMETERS
//============================================================================

parameter	[3:0]			ARP_REQ_PKT_TYPE = 4'd1;
parameter	[3:0]			ARP_RESP_PKT_TYPE = 4'd2;
parameter	[3:0]			UDP_PKT_TYPE = 4'd3;

//============================================================================
// ARP PARAMETERS
//============================================================================

wire			[1:0]			i_operation = 
	i_pkt_type == ARP_REQ_PKT_TYPE ? 2'd01 :
	i_pkt_type == ARP_RESP_PKT_TYPE ? 2'd02 : 2'd0;

wire 			[63:0]		arp_header;
parameter	[15:0]		ARP_HTYPE = 16'h0001;
parameter	[15:0]		ARP_PTYPE = 16'h0800;
parameter	[7:0]			ARP_HLEN = 8'h06;	//	MAC size
parameter	[7:0]			ARP_PLEN = 8'h04;	// for IPv4
assign arp_header = {ARP_HTYPE, ARP_PTYPE, ARP_HLEN, ARP_PLEN, {14'd0, i_operation}};

//============================================================================
// UDP PARAMETERS
//============================================================================

wire			[15:0]		fragment_size;
assign fragment_size = udp_data_len - udp_sended;

wire							fragment_flag;
assign fragment_flag = fragment_size < 16'd1400 ? 1'b0 : 1'b1;

parameter	[3:0]			ip_header_ver = 4'h4;		// 4 - for IPv4
parameter	[3:0]			ip_header_size = 4'h5;		// size in 32bit word's
parameter	[7:0]			ip_DSCP_ECN = 8'h00;			// ?
wire			[15:0]		ip_pkt_size;
assign  ip_pkt_size = (fragment_flag ? 16'd1400 : fragment_size) + 16'h001C;	// 16'h002E size of UDP packet
wire			[31:0]		ip_hdr1;
assign ip_hdr1 = {ip_header_ver, ip_header_size, ip_DSCP_ECN, ip_pkt_size};

parameter	[15:0]		ip_pkt_id = 16'h0;			// pkt id
wire			[2:0]			ip_pkt_flags;					// pkt flags
assign ip_pkt_flags = {2'd0, fragment_flag};
wire			[12:0]		ip_pkt_offset;					// pkt offset
assign ip_pkt_offset = {3'd0, udp_sended[15:3]};
wire			[31:0]		ip_hdr2;
assign ip_hdr2 = {ip_pkt_id, ip_pkt_flags, ip_pkt_offset};

parameter	[7:0]			ip_pkt_TTL = 8'hC8;			// pkt TTL
parameter	[7:0]			ip_pkt_type = 8'd17;			// pkt UDP == 17
wire			[15:0]		ip_pkt_CRC;						// pkt flags
wire			[31:0]		tmp_crc;
assign tmp_crc = ip_hdr1[31:16] + ip_hdr1[15:0] +
	ip_hdr2[31:16] + ip_hdr2[15:0] + ip_hdr3[31:16] + // ip_hdr3[15:0] +
	src_ip[31:16] + src_ip[15:0] + dst_ip[31:16] + dst_ip[15:0];
assign ip_pkt_CRC = ~(tmp_crc[31:16] + tmp_crc[15:0]);
wire			[31:0]		ip_hdr3;	
assign ip_hdr3 = {ip_pkt_TTL, ip_pkt_type, ip_pkt_CRC};

//============================================================================
// MISC PARAMETERS
//============================================================================

wire			[47:0]		src_mac;
wire			[31:0]		src_ip;
wire			[47:0]		dst_mac;
wire			[31:0]		dst_ip;
assign src_mac = i_self_mac;
assign src_ip = i_self_ip;
assign dst_mac = i_target_mac;
assign dst_ip = i_target_ip;

wire			[15:0]		src_port;
wire			[15:0]		dst_port;
assign src_port = 16'd2179;
assign dst_port = 16'd5152;

wire			[47:0]		SHA;
wire			[31:0]		SPA;
wire			[47:0]		THA;
wire			[31:0]		TPA;
assign SHA = src_mac;
assign SPA = src_ip;
assign THA = dst_mac;
assign TPA = dst_ip;

/*
SEND_PREAMBLE: ds <= 64'h55555555555555d5;
				SEND_DST_MAC: ds <= {i_dst_mac, 16'd0};
				SEND_SRC_MAC: ds <= {i_src_mac, 16'd0};
				SEND_ETHER_TYPE: ds <= {16'h0806, 48'd0};	// ARP frame
				SEND_ARP_HEADER: ds <= arp_header;
				SEND_SHA: ds <= {i_SHA, 16'd0};
				SEND_SPA: ds <= {i_SPA, 32'd0};
				SEND_THA: ds <= {i_THA, 16'd0};
				SEND_TPA: ds <= {i_TPA, 32'd0};
				SEND_DUMMY_BYTES: ds <= 64'd0;
				SEND_CRC32: ds <= 64'd0;
DELAY: ds <= 64'd0;
*/

reg			[0:0]			ff_vld;
reg			[0:0]			ff_sop;
reg			[0:0]			ff_eop;

reg			[15:0]		udp_frame_size;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		udp_frame_size <= 16'd1400;
	else
		if(i_pkt_type == UDP_PKT_TYPE && ff_sop)
			udp_frame_size <= fragment_flag ? 16'd1400 : fragment_size;

always
	case(i_pkt_type)
		ARP_REQ_PKT_TYPE, ARP_RESP_PKT_TYPE: begin
			ff_vld = send_step >= 16'h01 && send_step <= 16'h0B ? 1'b1 : 1'b0;
			ff_sop = send_step == 16'h01 ? 1'b1 : 1'b0;
			ff_eop = send_step == 16'h0B ? 1'b1 : 1'b0;
		end
		UDP_PKT_TYPE: begin
			reg	[15:0]		len;
			len = 16'h0B + udp_frame_size[15:2]; //udp_data_len[15:2];
			ff_vld = send_step >= 16'h01 && send_step <= len ? 1'b1 : 1'b0;;
			ff_sop = send_step == 16'h01 ? 1'b1 : 1'b0;
			ff_eop = send_step == len ? 1'b1 : 1'b0;
		end
		default: begin
			ff_vld = 1'b0;
			ff_sop = 1'b0;
			ff_eop = 1'b0;
		end
	endcase

assign o_vld = ff_vld;
assign o_sop = ff_sop;
assign o_eop = ff_eop;

// !TODO: add code for UDP_PKT_TYPE
assign o_pkt_complite = ff_eop && (i_pkt_type == ARP_REQ_PKT_TYPE || i_pkt_type == ARP_RESP_PKT_TYPE) ? 1'b1 : 1'b0;

reg			[15:0]		send_step;
//reg			[25:0]		send_delay;

reg			[0:0]			prev_msync_n;
always @ (posedge clk) prev_msync_n = i_msync_n;


reg			[15:0]		udp_sended;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		udp_sended <= 16'd0;
	else
		if(i_pkt_type == UDP_PKT_TYPE) begin
			if(prev_msync_n != i_msync_n && ~i_msync_n)
				udp_sended <= 16'd0;
			else
				if(send_step > 16'h0B && i_rdy)
					udp_sended <= udp_sended + 16'd4;
		end
			


always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		send_step <= 16'd0;
	else
		if(|{send_step}) begin
			if(i_rdy)			
				send_step <= ff_eop ? 16'd0 : send_step + 16'd1;
		end
		else
			if((((prev_msync_n != i_msync_n && ~i_msync_n) || (udp_sended < udp_data_len)) && i_pkt_type == UDP_PKT_TYPE) || 
						i_pkt_type == ARP_REQ_PKT_TYPE || 
						i_pkt_type == ARP_RESP_PKT_TYPE)
				send_step <= 16'd1;

/*
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		send_step <= 16'd0;
	else begin
		if(~&{send_step}) begin
			if(i_rdy)
				send_step <= send_step + 16'd1;
		end
		else begin
			if(~&{send_delay})
				send_delay <= send_delay + 26'd1;
			else begin
				send_delay <= 26'd0;
				send_step <= 16'd0;
			end
		end
	end
*/

reg			[31:0]		data;
assign o_data = data;

always begin
	data = 32'd0;
	
	if(i_pkt_type == ARP_REQ_PKT_TYPE || i_pkt_type == ARP_RESP_PKT_TYPE)
		case(send_step)
			16'h01: data = {16'd0, dst_mac[47:32]};
			16'h02: data = dst_mac[31:0];
			16'h03: data = src_mac[47:16];		
			16'h04: data = {src_mac[15:0], 16'h0806};	// packet type = ARP (16'h0806)
			16'h05: data = arp_header[63:32];
			16'h06: data = arp_header[31:0];
			16'h07: data = SHA[47:16];
			16'h08: data = {SHA[15:0], SPA[31:16]};
			16'h09: data = {SPA[15:0], THA[47:32]};
			16'h0A: data = THA[31:0];
			16'h0B: data = TPA[31:0];
			default: data = 32'd0;
		endcase
	else
		if(i_pkt_type == UDP_PKT_TYPE)
			case(send_step)
				16'h00: data = 32'd0;
				16'h01: data = {16'd0, dst_mac[47:32]};
				16'h02: data = dst_mac[31:0];
				16'h03: data = src_mac[47:16];		
				16'h04: data = {src_mac[15:0], 16'h0800};	// packet type = IPv4 (16'h0800)
				16'h05: data = ip_hdr1;
				16'h06: data = ip_hdr2;
				16'h07: data = ip_hdr3;
				16'h08: data = src_ip;
				16'h09: data = dst_ip;
				16'h0A: data = {src_port, dst_port};
				16'h0B: data = {udp_length, 16'd0};			// udp crc = 0
				default: data = i_rd_data;
			endcase
		else
			data = 32'd0;
end

parameter	[15:0]	udp_data_len = 16'd4800; //1024;

wire			[15:0]	udp_length;
assign udp_length = udp_data_len + 16'd8;

//============================================================================
// UDP SEND
//============================================================================

endmodule
