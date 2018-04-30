module data_blk(
	clk20,
	res_n,
	msync_n,
	smax_num,
	words_num,
	offset,
	mul_c,
	data_delay0,
	data_delay1,
	data_delay2,
	data_delay3,
	num_order,
	data_in,
	data_out,
	data_valid,
	data_count,
	chan_cmpl,
	doffs,
	soffs_n,
	enx
);

input	clk20;
input	res_n;
input	msync_n;
input	[31:0] smax_num;
input	[31:0] words_num;
input [31:0] offset;
input	[23:0] mul_c;
input [23:0] data_delay0;
input [23:0] data_delay1;
input [23:0] data_delay2;
input [23:0] data_delay3;
input [7:0] num_order;
input	[11:0] data_in;
output [31:0] data_out;
output data_valid;
output [9:0] data_count;
output chan_cmpl;
output doffs;
output soffs_n;
output [3:0] enx;

wire [7:0] smax_num_m [0:3];
wire [7:0] words_num_m [0:3];
wire [7:0] offset_m [0:3];
wire [5:0] mul_c_m [0:3];
wire [1:0] num_order_m [0:3];
assign smax_num_m[0] = smax_num[7:0];
assign smax_num_m[1] = smax_num[15:8];
assign smax_num_m[2] = smax_num[23:16];
assign smax_num_m[3] = smax_num[31:24];
assign words_num_m[0] = words_num[7:0];
assign words_num_m[1] = words_num[15:8];
assign words_num_m[2] = words_num[23:16];
assign words_num_m[3] = words_num[31:24];
assign offset_m[0] = offset[7:0];
assign offset_m[1] = offset[15:8];
assign offset_m[2] = offset[23:16];
assign offset_m[3] = offset[31:24];
assign mul_c_m[0] = mul_c[5:0];
assign mul_c_m[1] = mul_c[11:6];
assign mul_c_m[2] = mul_c[17:12];
assign mul_c_m[3] = mul_c[23:18];
assign num_order_m[0] = num_order[1:0];
assign num_order_m[1] = num_order[3:2];
assign num_order_m[2] = num_order[5:4];
assign num_order_m[3] = num_order[7:6];
reg [1:0] c_count;
wire [3:0] eq_del;
reg [23:0] delay_cnt;
reg int_sync_n;
wire end_cycle;
wire eq_d;
assign eq_del[0] = (delay_cnt == data_delay0);
assign eq_del[1] = (delay_cnt == data_delay1);
assign eq_del[2] = (delay_cnt == data_delay2);
assign eq_del[3] = (delay_cnt == data_delay3);
assign end_cycle = (delay_cnt == 24'hffffff);
assign eq_d = |eq_del;
wire [7:0] smax_num_i;
wire [7:0] words_num_i;
wire [7:0] offset_i;
wire [5:0] mul_c_i;
wire [1:0] ch_num;
wire [7:0] dcnt;
assign ch_num = num_order_m[c_count];
assign data_count = {ch_num,dcnt};
assign smax_num_i = smax_num_m[ch_num];
assign words_num_i = words_num_m[ch_num];
assign mul_c_i = mul_c_m[ch_num];
assign offset_i = offset_m[ch_num];
assign enx = 1'b1 << ch_num;

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
		casex({msync_n,eq_d,chan_cmpl,end_cycle})
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

wire valid_max;
wire [7:0] data_max;
wire valid_pack;

spi_dac spi_offs(
	.clk20(clk20),
	.data_spi(offset_i),
	.start(~int_sync_n),
	.ddac(doffs),
	.sdac_n(soffs_n)
);

max_sel_blk	max_sel_inst(
	.sysclk(clk20),
	.sync_n(int_sync_n),
	.smax_num(smax_num_i),
	.data_in(data_in),
	.mul_c(mul_c_i),
	.data_out(data_max),
	.data_valid(valid_max)
);
	
dpack_4x8	dpack_4x8_inst(
	.sysclk(clk20),
	.sync_n(int_sync_n),
	.data_in(data_max),
	.data_in_valid(valid_max),
	.data_out(data_out),
	.data_out_valid(valid_pack));
	
data_cnt_blk dat_cnt(
	.clk20(clk20),
	.res_n(res_n),
	.sync_n(int_sync_n),
	.words_num(words_num_i),
	.word_stb(valid_pack),
	.data_count(dcnt),
	.data_valid(data_valid),
	.chan_cmpl(chan_cmpl)
);

endmodule
