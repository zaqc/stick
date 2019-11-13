module eth_send(
	input						rst_n,
	input						clk,
	
	input		[3:0]			i_pkt_type,
	
	input		[47:0]			i_self_mac,
	input		[31:0]			i_self_ip,
	input		[47:0]			i_target_mac,
	input		[31:0]			i_target_ip,
	
	output		[31:0]			o_data,
	output						o_vld,
	input						i_rdy,
	output						o_eop,
	output						o_sop,
	
	output						o_pkt_complite,
	
	output		[9:0]			o_rd_addr,
	input		[31:0]			i_rd_data,
	
	input						i_msync_n	// Main Sync
);

reg				[3:0]			sender_ready;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		sender_ready <= 4'd1;
	else
		if(ff_sop)
			sender_ready <= 4'd0;
		else
			if(ff_eop)
				sender_ready <= 4'd1;
			else
				if(|sender_ready && ~&sender_ready)
					sender_ready <= sender_ready + 4'd1;
			
reg				[3:0]			pkt_type;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		pkt_type <= 4'd0;
	else
		if(&sender_ready)
			pkt_type <= i_pkt_type;
		else
			if(ff_eop)
				pkt_type <= 4'd0;


reg				[9:0]			rd_addr;
assign o_rd_addr = rd_addr;

wire							udp_data_stream;
//assign udp_data_stream = (send_step >= (16'h0B - (rd_addr == 10'd0 ? 16'd1 : 16'd0)) && ~o_eop && o_vld && i_rdy) ? 1'b1 : 1'b0; 
assign udp_data_stream = (((first_udp_part && send_step >= 16'h0B) || (~first_udp_part && send_step >= 16'h09))
	&& ~o_eop && o_vld && i_rdy) ? 1'b1 : 1'b0; 

reg				[31:0]			test_data;

always @ (posedge clk or negedge rst_n)
	if(~rst_n) begin
		rd_addr <= 10'd0;
		test_data <= 32'd0;
	end
	else
		if(udp_data_stream && pkt_type == UDP_PKT_TYPE) begin
			rd_addr <= rd_addr + 10'd1;
			test_data <= {22'd0, rd_addr};
		end
		else
			if(prev_msync_n != i_msync_n && ~i_msync_n && pkt_type == UDP_PKT_TYPE) begin
				rd_addr <= 10'd0;				
				test_data <= 32'd0;
			end
			

//============================================================================
// GLOBAL PARAMETERS
//============================================================================

parameter		[3:0]			ARP_REQ_PKT_TYPE = 4'd1;
parameter		[3:0]			ARP_RESP_PKT_TYPE = 4'd2;
parameter		[3:0]			UDP_PKT_TYPE = 4'd3;

//============================================================================
// ARP PARAMETERS
//============================================================================

wire			[1:0]			i_operation = 
	pkt_type == ARP_REQ_PKT_TYPE ? 2'd01 :
	pkt_type == ARP_RESP_PKT_TYPE ? 2'd02 : 2'd0;

wire 			[63:0]			arp_header;
parameter		[15:0]			ARP_HTYPE = 16'h0001;
parameter		[15:0]			ARP_PTYPE = 16'h0800;
parameter		[7:0]			ARP_HLEN = 8'h06;	//	MAC size
parameter		[7:0]			ARP_PLEN = 8'h04;	// for IPv4
assign arp_header = {ARP_HTYPE, ARP_PTYPE, ARP_HLEN, ARP_PLEN, {14'd0, i_operation}};

//============================================================================
// UDP PARAMETERS
//============================================================================

wire			[15:0]			fragment_size;
assign fragment_size = udp_data_len - udp_sended;

wire							fragment_flag;
assign fragment_flag = fragment_size < 16'd1400 ? 1'b0 : 1'b1;

parameter		[3:0]			ip_header_ver = 4'h4;			// 4 - for IPv4
parameter		[3:0]			ip_header_size = 4'h5;			// size in 32bit word's
parameter		[7:0]			ip_DSCP_ECN = 8'h00;			// ?
wire			[15:0]			ip_pkt_size;
assign  ip_pkt_size = (fragment_flag ? 16'd1400 : fragment_size) + (first_udp_part ? 16'h001C : 16'h0014);	// 16'h002E size of UDP packet
wire			[31:0]			ip_hdr1;
assign ip_hdr1 = {ip_header_ver, ip_header_size, ip_DSCP_ECN, ip_pkt_size};

//parameter		[15:0]			ip_pkt_id = 16'h0;				// pkt id
reg				[15:0]			ip_pkt_id;// = 16'h0;			// pkt id
wire			[2:0]			ip_pkt_flags;					// pkt flags
assign ip_pkt_flags = {2'd0, fragment_flag};
wire			[12:0]			ip_pkt_offset;					// pkt offset
assign ip_pkt_offset = {3'd0, udp_sended[15:3]} + (first_udp_part ? 13'd0 : 13'd1);
wire			[31:0]			ip_hdr2;
assign ip_hdr2 = {ip_pkt_id, ip_pkt_flags, ip_pkt_offset};

parameter		[7:0]			ip_pkt_TTL = 8'hC8;				// pkt TTL
parameter		[7:0]			ip_pkt_type = 8'd17;			// pkt UDP == 17
wire			[15:0]			ip_pkt_CRC;						// pkt flags
wire			[31:0]			tmp_crc;
assign tmp_crc = ip_hdr1[31:16] + ip_hdr1[15:0] +
	ip_hdr2[31:16] + ip_hdr2[15:0] + ip_hdr3[31:16] + 			// ip_hdr3[15:0] +
	src_ip[31:16] + src_ip[15:0] + dst_ip[31:16] + dst_ip[15:0];
assign ip_pkt_CRC = ~(tmp_crc[31:16] + tmp_crc[15:0]);
wire			[31:0]			ip_hdr3;	
assign ip_hdr3 = {ip_pkt_TTL, ip_pkt_type, ip_pkt_CRC};

//============================================================================
// MISC PARAMETERS
//============================================================================

wire			[47:0]			src_mac;
wire			[31:0]			src_ip;
wire			[47:0]			dst_mac;
wire			[31:0]			dst_ip;
assign src_mac = i_self_mac;
assign src_ip = i_self_ip;
assign dst_mac = i_target_mac;
assign dst_ip = i_target_ip;

wire			[15:0]			src_port;
wire			[15:0]			dst_port;
assign src_port = 16'd2179;
assign dst_port = 16'd5152;

wire			[47:0]			SHA;
wire			[31:0]			SPA;
wire			[47:0]			THA;
wire			[31:0]			TPA;
assign SHA = src_mac;
assign SPA = src_ip;
assign THA = dst_mac;
assign TPA = dst_ip;

wire							ff_vld;
wire							ff_sop;
wire							ff_eop;

reg				[15:0]			udp_frame_size;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		udp_frame_size <= 16'd1400;
	else
		if(pkt_type == UDP_PKT_TYPE && ff_sop)
			udp_frame_size <= fragment_flag ? 16'd1400 : fragment_size;

wire			[15:0]			len;
assign len = 16'h0B + udp_frame_size[15:2];

assign {ff_vld, ff_sop, ff_eop} =
	(pkt_type == ARP_REQ_PKT_TYPE || pkt_type == ARP_RESP_PKT_TYPE) ?
			{send_step >= 16'h01 && send_step <= 16'h0B ? 1'b1 : 1'b0,
			send_step == 16'h01 ? 1'b1 : 1'b0,
			send_step == 16'h0B ? 1'b1 : 1'b0} :
		
	(pkt_type == UDP_PKT_TYPE) ?
			{send_step >= 16'h01 && send_step <= len ? 1'b1 : 1'b0,
			send_step == 16'h01 ? 1'b1 : 1'b0,
			send_step == len ? 1'b1 : 1'b0} : 3'd0;

assign o_vld = ff_vld;
assign o_sop = ff_sop;
assign o_eop = ff_eop;

// !TODO: add code for UDP_PKT_TYPE
assign o_pkt_complite = ff_eop && (pkt_type == ARP_REQ_PKT_TYPE || pkt_type == ARP_RESP_PKT_TYPE) ? 1'b1 : 1'b0;

reg				[15:0]			send_step;
//reg			[25:0]			send_delay;

reg				[0:0]			prev_msync_n;
always @ (posedge clk) prev_msync_n <= i_msync_n;

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		ip_pkt_id <= 16'd0;
	else	
		if(prev_msync_n != i_msync_n && ~i_msync_n)
			ip_pkt_id <= ip_pkt_id + 16'd1;

reg				[15:0]			udp_sended;
always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		udp_sended <= 16'd0;
	else
		if(pkt_type == UDP_PKT_TYPE) begin
			if(prev_msync_n != i_msync_n && ~i_msync_n)
				udp_sended <= 16'd0;
			else
				if(send_step > 16'h0B && i_rdy && udp_sended < udp_data_len)
					udp_sended <= udp_sended + 16'd4;
		end
		
		
	reg			[0:0]			first_udp_part;
	
	always @ (posedge clk or negedge rst_n)	// for correct packet size
		if(~rst_n)
			first_udp_part <= 1'b0;
		else
			if(prev_msync_n != i_msync_n && ~i_msync_n)
				first_udp_part <= 1'b1;
			else
				if(ff_eop)
					first_udp_part <= 1'b0;
					

always @ (posedge clk or negedge rst_n)
	if(~rst_n)
		send_step <= 16'd0;
	else
		if(|{send_step}) begin
			if(i_rdy)			
				send_step <= ff_eop ? 16'd0 :
				(~first_udp_part && send_step == 16'h09 && pkt_type == UDP_PKT_TYPE) ? 16'h0C : send_step + 16'd1;
		end
		else
			if((((prev_msync_n != i_msync_n && ~i_msync_n) || (udp_sended < udp_data_len)) && pkt_type == UDP_PKT_TYPE) || 
						pkt_type == ARP_REQ_PKT_TYPE || 
						pkt_type == ARP_RESP_PKT_TYPE)
				send_step <= 16'd1;
				
wire			[31:0]			data;
assign o_data = data;


assign data = (pkt_type == ARP_REQ_PKT_TYPE || pkt_type == ARP_RESP_PKT_TYPE) ?
		send_step == 16'h01 ? {16'd0, dst_mac[47:32]} :
		send_step == 16'h02 ? dst_mac[31:0] :
		send_step == 16'h03 ? src_mac[47:16] :		
		send_step == 16'h04 ? {src_mac[15:0], 16'h0806} :	// packet type = ARP (16'h0806)
		send_step == 16'h05 ? arp_header[63:32] :
		send_step == 16'h06 ? arp_header[31:0] :
		send_step == 16'h07 ? SHA[47:16] :
		send_step == 16'h08 ? {SHA[15:0], SPA[31:16]} :
		send_step == 16'h09 ? {SPA[15:0], THA[47:32]} :
		send_step == 16'h0A ? THA[31:0] :
		send_step == 16'h0B ? TPA[31:0] : 32'd0 :
	(pkt_type == UDP_PKT_TYPE) ?
		send_step == 16'h00 ? 32'd0 :
		send_step == 16'h01 ? {16'd0, dst_mac[47:32]} :
		send_step == 16'h02 ? dst_mac[31:0] :
		send_step == 16'h03 ? src_mac[47:16] :
		send_step == 16'h04 ? {src_mac[15:0], 16'h0800} :	// packet type = IPv4 (16'h0800)
		send_step == 16'h05 ? ip_hdr1 :
		send_step == 16'h06 ? ip_hdr2 :
		send_step == 16'h07 ? ip_hdr3 :
		send_step == 16'h08 ? src_ip :
		send_step == 16'h09 ? dst_ip :
		send_step == 16'h0A ? {src_port, dst_port} :
		send_step == 16'h0B ? {udp_length, 16'd0} :			// udp crc = 0
		i_rd_data : 0;
		//test_data : 0;

parameter		[15:0]			udp_data_len = 16'd4800; //1024;

wire			[15:0]			udp_length;
assign udp_length = udp_data_len; // + 16'd8;

//============================================================================
// UDP SEND
//============================================================================

endmodule
