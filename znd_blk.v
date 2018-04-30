module znd_blk(
	clk250,
	clk20,
	res_n,
	msync_n,
	frq_div,
	pulse_w,
	diag_data,
	znd_delay0,
	znd_delay1,
	znd_delay2,
	znd_delay3,
	num_order,
	imp_a,
	imp_b_n,
	imp_c,
	imp_d_n,
	enz_n
);


input	clk250;
input	clk20;
input	res_n;
input	msync_n;
input	[31:0] frq_div;
input	[31:0] pulse_w;
input	[31:0] diag_data;
input	[23:0] znd_delay0;
input	[23:0] znd_delay1;
input	[23:0] znd_delay2;
input	[23:0] znd_delay3;
input [7:0] num_order;
output imp_a;
output imp_b_n;
output imp_c;
output imp_d_n;
output [3:0] enz_n;

wire [7:0] frq_div_m [0:3];
wire [7:0] pulse_w_m [0:3];
wire [7:0] diag_data_m [0:3];
wire [1:0] num_order_m [0:3];
assign frq_div_m[0] = frq_div[7:0];
assign frq_div_m[1] = frq_div[15:8];
assign frq_div_m[2] = frq_div[23:16];
assign frq_div_m[3] = frq_div[31:24];
assign pulse_w_m[0] = pulse_w[7:0];
assign pulse_w_m[1] = pulse_w[15:8];
assign pulse_w_m[2] = pulse_w[23:16];
assign pulse_w_m[3] = pulse_w[31:24];
assign diag_data_m[0] = diag_data[7:0];
assign diag_data_m[1] = diag_data[15:8];
assign diag_data_m[2] = diag_data[23:16];
assign diag_data_m[3] = diag_data[31:24];
assign num_order_m[0] = num_order[1:0];
assign num_order_m[1] = num_order[3:2];
assign num_order_m[2] = num_order[5:4];
assign num_order_m[3] = num_order[7:6];
reg [1:0] c_count;
wire [3:0] eq_del;
reg [23:0] delay_cnt;
reg int_sync_n;
wire znd_rdy;
wire end_cycle;
wire eq_d;
assign eq_del[0] = (delay_cnt == znd_delay0);
assign eq_del[1] = (delay_cnt == znd_delay1);
assign eq_del[2] = (delay_cnt == znd_delay2);
assign eq_del[3] = (delay_cnt == znd_delay3);
assign end_cycle = (delay_cnt == 24'hffffff);
assign eq_d = |eq_del;
wire [7:0] frq_div_i;
wire [7:0] pulse_w_i;
wire [7:0] diag_data_i;
wire [1:0] ch_num;
assign ch_num = num_order_m[c_count];
assign frq_div_i = frq_div_m[ch_num];
assign pulse_w_i = pulse_w_m[ch_num];
assign diag_data_i = diag_data_m[ch_num];
assign enz_n = ~(1'b1 << ch_num);

always@(posedge clk20 or negedge res_n)
begin
	if(!res_n)
	begin
		c_count <= 0;
		delay_cnt <= 24'hffffff;
		int_sync_n <= 1'b1;
	end
	else
	begin
		casex({msync_n,eq_d,znd_rdy,end_cycle})
			4'b0xxx:
			begin
				c_count <= 2'b11;
				delay_cnt <= 0;
				int_sync_n <= 1'b1;
			end
			4'b1xx1:
			begin
				c_count <= c_count;
				delay_cnt <= delay_cnt;
				int_sync_n <= 1'b1;
			end
			4'b1110:
			begin
				c_count <= c_count + 1'b1;
				delay_cnt <= delay_cnt + 1'b1;
				int_sync_n <= 1'b0;
			end
			default:
			begin
				c_count <= c_count;
				delay_cnt <= delay_cnt + 1'b1;
				int_sync_n <= 1'b1;
			end
		endcase
	end
end



wire	clk_znd;
wire	pulse;


frq_pw_blk	frq_pw_inst(
	.sync_n(int_sync_n),
	.clk250(clk250),
	.frq_div(frq_div_i),
	.pw(pulse_w_i),
	.clk_znd(clk_znd),
	.pulse(pulse)
);


zndgen	znd_gen_inst(
	.clk250(clk250),
	.sync_n(int_sync_n),
	.clk_znd(clk_znd),
	.pulse(pulse),
	.res_n(res_n),
	.diag_data(diag_data_i),
	.imp_a(imp_a),
	.imp_b_n(imp_b_n),
	.imp_c(imp_c),
	.imp_d_n(imp_d_n),
	.znd_rdy(znd_rdy)
);



endmodule
