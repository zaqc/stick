module control_blk(
	clk20,
	res_n,
	data,
	valid,
	frq_div,
	pulse_w,
	diag_data,
	smax_num,
	words_num,
	offset,
	mul_c,
	znd_delay0,
	znd_delay1,
	znd_delay2,
	znd_delay3,
	num_order_z,
	data_delay0,
	data_delay1,
	data_delay2,
	data_delay3,
	num_order_x,
	pdwn_x,
	hpwon
);

input clk20;
input res_n;
input [31:0] data;
input valid;
output [127:0] frq_div;
output [127:0] pulse_w;
output [127:0] diag_data;
output [127:0] smax_num;
output [127:0] words_num;
output [127:0] offset;
output [95:0] mul_c;
output [95:0] znd_delay0;
output [95:0] znd_delay1;
output [95:0] znd_delay2;
output [95:0] znd_delay3;
output [31:0] num_order_z;
output [95:0] data_delay0;
output [95:0] data_delay1;
output [95:0] data_delay2;
output [95:0] data_delay3;
output [31:0] num_order_x;
output [3:0] pdwn_x;
output [2:0] hpwon;
reg [127:0] frq_div;
reg [127:0] pulse_w;
reg [127:0] diag_data;
reg [127:0] smax_num;
reg [127:0] words_num;
reg [127:0] offset;
reg [95:0] mul_c;
reg [95:0] znd_delay0;
reg [95:0] znd_delay1;
reg [95:0] znd_delay2;
reg [95:0] znd_delay3;
reg [31:0] num_order_z;
reg [95:0] data_delay0;
reg [95:0] data_delay1;
reg [95:0] data_delay2;
reg [95:0] data_delay3;
reg [31:0] num_order_x;
reg [3:0] pdwn_x;
reg [2:0] hpwon;
//--------------------------------------------------------------------------------------------------------------
//default values for virtual channals
wire [7:0] frq_div_d = 8'd49;		 			//zond pulse frequency = 2.5 MHz
wire [7:0] pulse_w_d = 8'd25;					//zond pulse width = 100 ns
wire [7:0] diag_data_d = 8'h84;				//4 zond pulse + 8 blanch pulse
wire [7:0] smax_num_d = 8'd25;				//26 input points to select maximum
wire [7:0] words_num_d = 8'd31;				//32 words of data to transmit
wire [7:0] offset_d = 8'h83;					//offset = 131
wire [5:0] mul_c_d = 6'd16;					//multiply data by 19/16 
//--------------------------------------------------------------------------------------------------------------
//default values for physical channals 
wire [23:0] znd_delay0_d = 24'd0;			//0 us delay from main sync to zond pulse N0
wire [23:0] znd_delay1_d = 24'd4000;		//200 us delay from main sync to zond pulse N1
wire [23:0] znd_delay2_d = 24'd8000;		//400 us delay from main sync to zond pulse N2
wire [23:0] znd_delay3_d = 24'd12000;		//600 us delay from main sync to zond pulse N3
wire [7:0] num_order_z_d = 8'b11100100;	//zond channals order 0 -> 1 -> 2 -> 3
wire [23:0] data_delay0_d = 24'd0;			//0 us delay data acquire from main sync to cycle N0
wire [23:0] data_delay1_d = 24'd4000;		//200 us delay data acquire from main sync to cycle N1
wire [23:0] data_delay2_d = 24'd8000;		//400 us delay data acquire from main sync to cycle N2
wire [23:0] data_delay3_d = 24'd12000;		//600 us delay data acquire from main sync to cycle N3
wire [7:0] num_order_x_d = 8'b11100100;	//data channals order 0 -> 1 -> 2 -> 3
wire pdwn_x_d = 1'b0;							//sleep mode off
wire hpwon_d = 3'b000;							//high voltage off
//-------------------------------------------------------------------------------------------------------------
always@(posedge clk20 or negedge res_n)
begin
	if (!res_n)
	begin
		frq_div <= {16{frq_div_d}};
		pulse_w <= {16{pulse_w_d}};
		diag_data <= {16{diag_data_d}};
		smax_num <= {16{smax_num_d}};
		words_num <= {16{words_num_d}};
		offset <= {16{offset_d}};
		mul_c <= {16{mul_c_d}};
		znd_delay0 <= {4{znd_delay0_d}};
		znd_delay1 <= {4{znd_delay1_d}};
		znd_delay2 <= {4{znd_delay2_d}};
		znd_delay3 <= {4{znd_delay3_d}};
		num_order_z <= {4{num_order_z_d}};
		data_delay0 <= {4{data_delay0_d}};
		data_delay1 <= {4{data_delay1_d}};
		data_delay2 <= {4{data_delay2_d}};
		data_delay3 <= {4{data_delay3_d}};
		num_order_x <= {4{num_order_x_d}};
		pdwn_x <= {4{pdwn_x_d}};
		hpwon <= hpwon_d;
	end
	else
	begin
		casex({valid,data[31:24]})
//virtual channals settings
//N0----------------------------------------------
			9'h100: frq_div[7:0] <= data[7:0];
			9'h101: frq_div[15:8] <= data[7:0];
			9'h102: frq_div[23:16] <= data[7:0];
			9'h103: frq_div[31:24] <= data[7:0];
			9'h104: frq_div[39:32] <= data[7:0];
			9'h105: frq_div[47:40] <= data[7:0];
			9'h106: frq_div[55:48] <= data[7:0];
			9'h107: frq_div[63:56] <= data[7:0];
			9'h108: frq_div[71:64] <= data[7:0];
			9'h109: frq_div[79:72] <= data[7:0];
			9'h10a: frq_div[87:80] <= data[7:0];
			9'h10b: frq_div[95:88] <= data[7:0];
			9'h10c: frq_div[103:96] <= data[7:0];
			9'h10d: frq_div[111:104] <= data[7:0];
			9'h10e: frq_div[119:112] <= data[7:0];
			9'h10f: frq_div[127:120] <= data[7:0];
//N1-----------------------------------------------		
			9'h110: pulse_w[7:0] <= data[7:0];
			9'h111: pulse_w[15:8] <= data[7:0];
			9'h112: pulse_w[23:16] <= data[7:0];
			9'h113: pulse_w[31:24] <= data[7:0];
			9'h114: pulse_w[39:32] <= data[7:0];
			9'h115: pulse_w[47:40] <= data[7:0];
			9'h116: pulse_w[55:48] <= data[7:0];
			9'h117: pulse_w[63:56] <= data[7:0];
			9'h118: pulse_w[71:64] <= data[7:0];
			9'h119: pulse_w[79:72] <= data[7:0];
			9'h11a: pulse_w[87:80] <= data[7:0];
			9'h11b: pulse_w[95:88] <= data[7:0];
			9'h11c: pulse_w[103:96] <= data[7:0];
			9'h11d: pulse_w[111:104] <= data[7:0];
			9'h11e: pulse_w[119:112] <= data[7:0];
			9'h11f: pulse_w[127:120] <= data[7:0];
//N2-----------------------------------------------		
			9'h120: diag_data[7:0] <= data[7:0];
			9'h121: diag_data[15:8] <= data[7:0];
			9'h122: diag_data[23:16] <= data[7:0];
			9'h123: diag_data[31:24] <= data[7:0];
			9'h124: diag_data[39:32] <= data[7:0];
			9'h125: diag_data[47:40] <= data[7:0];
			9'h126: diag_data[55:48] <= data[7:0];
			9'h127: diag_data[63:56] <= data[7:0];
			9'h128: diag_data[71:64] <= data[7:0];
			9'h129: diag_data[79:72] <= data[7:0];
			9'h12a: diag_data[87:80] <= data[7:0];
			9'h12b: diag_data[95:88] <= data[7:0];
			9'h12c: diag_data[103:96] <= data[7:0];
			9'h12d: diag_data[111:104] <= data[7:0];
			9'h12e: diag_data[119:112] <= data[7:0];
			9'h12f: diag_data[127:120] <= data[7:0];
//N3-----------------------------------------------		
			9'h130: smax_num[7:0] <= data[7:0];
			9'h131: smax_num[15:8] <= data[7:0];
			9'h132: smax_num[23:16] <= data[7:0];
			9'h133: smax_num[31:24] <= data[7:0];
			9'h134: smax_num[39:32] <= data[7:0];
			9'h135: smax_num[47:40] <= data[7:0];
			9'h136: smax_num[55:48] <= data[7:0];
			9'h137: smax_num[63:56] <= data[7:0];
			9'h138: smax_num[71:64] <= data[7:0];
			9'h139: smax_num[79:72] <= data[7:0];
			9'h13a: smax_num[87:80] <= data[7:0];
			9'h13b: smax_num[95:88] <= data[7:0];
			9'h13c: smax_num[103:96] <= data[7:0];
			9'h13d: smax_num[111:104] <= data[7:0];
			9'h13e: smax_num[119:112] <= data[7:0];
			9'h13f: smax_num[127:120] <= data[7:0];		
//N4-----------------------------------------------		
			9'h140: words_num[7:0] <= data[7:0];
			9'h141: words_num[15:8] <= data[7:0];
			9'h142: words_num[23:16] <= data[7:0];
			9'h143: words_num[31:24] <= data[7:0];
			9'h144: words_num[39:32] <= data[7:0];
			9'h145: words_num[47:40] <= data[7:0];
			9'h146: words_num[55:48] <= data[7:0];
			9'h147: words_num[63:56] <= data[7:0];
			9'h148: words_num[71:64] <= data[7:0];
			9'h149: words_num[79:72] <= data[7:0];
			9'h14a: words_num[87:80] <= data[7:0];
			9'h14b: words_num[95:88] <= data[7:0];
			9'h14c: words_num[103:96] <= data[7:0];
			9'h14d: words_num[111:104] <= data[7:0];
			9'h14e: words_num[119:112] <= data[7:0];
			9'h14f: words_num[127:120] <= data[7:0];		
//N5-----------------------------------------------		
			9'h150: offset[7:0] <= data[7:0];
			9'h151: offset[15:8] <= data[7:0];
			9'h152: offset[23:16] <= data[7:0];
			9'h153: offset[31:24] <= data[7:0];
			9'h154: offset[39:32] <= data[7:0];
			9'h155: offset[47:40] <= data[7:0];
			9'h156: offset[55:48] <= data[7:0];
			9'h157: offset[63:56] <= data[7:0];
			9'h158: offset[71:64] <= data[7:0];
			9'h159: offset[79:72] <= data[7:0];
			9'h15a: offset[87:80] <= data[7:0];
			9'h15b: offset[95:88] <= data[7:0];
			9'h15c: offset[103:96] <= data[7:0];
			9'h15d: offset[111:104] <= data[7:0];
			9'h15e: offset[119:112] <= data[7:0];
			9'h15f: offset[127:120] <= data[7:0];		
//N6-----------------------------------------------		
			9'h160: mul_c[5:0] <= data[5:0];
			9'h161: mul_c[11:6] <= data[5:0];
			9'h162: mul_c[17:12] <= data[5:0];
			9'h163: mul_c[23:18] <= data[5:0];
			9'h164: mul_c[29:24] <= data[5:0];
			9'h165: mul_c[35:30] <= data[5:0];
			9'h166: mul_c[41:36] <= data[5:0];
			9'h167: mul_c[47:42] <= data[5:0];
			9'h168: mul_c[53:48] <= data[5:0];
			9'h169: mul_c[59:54] <= data[5:0];
			9'h16a: mul_c[65:60] <= data[5:0];
			9'h16b: mul_c[71:66] <= data[5:0];
			9'h16c: mul_c[77:72] <= data[5:0];
			9'h16d: mul_c[83:78] <= data[5:0];
			9'h16e: mul_c[89:84] <= data[5:0];
			9'h16f: mul_c[95:90] <= data[5:0];				
//physical channals settings
//N0------------------------------------------------
			9'h180: znd_delay0[23:0] <= data[23:0];
			9'h181: znd_delay0[47:24] <= data[23:0];
			9'h182: znd_delay0[71:48] <= data[23:0];
			9'h183: znd_delay0[95:72] <= data[23:0];
//N1------------------------------------------------
			9'h184: znd_delay1[23:0] <= data[23:0];
			9'h185: znd_delay1[47:24] <= data[23:0];
			9'h186: znd_delay1[71:48] <= data[23:0];
			9'h187: znd_delay1[95:72] <= data[23:0];
//N2------------------------------------------------
			9'h188: znd_delay2[23:0] <= data[23:0];
			9'h189: znd_delay2[47:24] <= data[23:0];
			9'h18a: znd_delay2[71:48] <= data[23:0];
			9'h18b: znd_delay2[95:72] <= data[23:0];
//N3------------------------------------------------
			9'h18c: znd_delay3[23:0] <= data[23:0];
			9'h18d: znd_delay3[47:24] <= data[23:0];
			9'h18e: znd_delay3[71:48] <= data[23:0];
			9'h18f: znd_delay3[95:72] <= data[23:0];		
//N4------------------------------------------------
			9'h190: data_delay0[23:0] <= data[23:0];
			9'h191: data_delay0[47:24] <= data[23:0];
			9'h192: data_delay0[71:48] <= data[23:0];
			9'h193: data_delay0[95:72] <= data[23:0];		
//N5------------------------------------------------
			9'h194: data_delay1[23:0] <= data[23:0];
			9'h195: data_delay1[47:24] <= data[23:0];
			9'h196: data_delay1[71:48] <= data[23:0];
			9'h197: data_delay1[95:72] <= data[23:0];			
//N6------------------------------------------------
			9'h198: data_delay2[23:0] <= data[23:0];
			9'h199: data_delay2[47:24] <= data[23:0];
			9'h19a: data_delay2[71:48] <= data[23:0];
			9'h19b: data_delay2[95:72] <= data[23:0];
//N7------------------------------------------------
			9'h19c: data_delay3[23:0] <= data[23:0];
			9'h19d: data_delay3[47:24] <= data[23:0];
			9'h19e: data_delay3[71:48] <= data[23:0];
			9'h19f: data_delay3[95:72] <= data[23:0];	
//N8------------------------------------------------
			9'h1a0: num_order_z[7:0] <= data[7:0];
			9'h1a1: num_order_z[15:8] <= data[7:0];
			9'h1a2: num_order_z[23:16] <= data[7:0];
			9'h1a3: num_order_z[31:24] <= data[7:0];
//N9------------------------------------------------
			9'h1a4: num_order_x[7:0] <= data[7:0];
			9'h1a5: num_order_x[15:8] <= data[7:0];
			9'h1a6: num_order_x[23:16] <= data[7:0];
			9'h1a7: num_order_x[31:24] <= data[7:0];	
//NA------------------------------------------------
			9'h1a8: pdwn_x[0] <= data[0];
			9'h1a9: pdwn_x[1] <= data[0];
			9'h1aa: pdwn_x[2] <= data[0];
			9'h1ab: pdwn_x[3] <= data[0];
//N1F------------------------------------------------
			9'b1111111xxx: hpwon <= data[2:0];
		endcase
	end
end

endmodule
