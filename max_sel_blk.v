module max_sel_blk(
	sysclk,
	sync_n,
	smax_num,
	data_in,
	mul_c,
	data_out,
	data_valid
);

input	sync_n;
input	sysclk;
input	[7:0] smax_num;
input	[11:0] data_in;
input	[5:0] mul_c;
output	[7:0] data_out;
reg		[7:0] data_out;
output	data_valid;
reg		data_valid;

reg		[7:0] Data_count;
wire	[7:0] Ds_in;
reg		[7:0] A_reg, B_reg;
wire	[17:0] tmp_data;
wire	[7:0] tmp_data_ovf;
wire	smeq;
wire	AgB;


assign	Ds_in = (tmp_data[16] | tmp_data[17]) ? 8'b11111111 : tmp_data[15:8];
//assign 	Ds_in = data_in[11:4];
assign	smeq = (Data_count == smax_num);
assign	AgB = (A_reg > B_reg);

mult12x6 mult12x6_inst(
	.dataa(data_in),
	.datab(mul_c),
	.result(tmp_data)
);

always@(posedge sysclk)
begin
	A_reg <= Ds_in;
	casex({sync_n,smeq,AgB})
		3'b0xx:
		begin
			Data_count <= 0;
			data_out <= data_out;
			data_valid <= 0;
			B_reg <= 0;
		end
		3'b100:
		begin
			Data_count <= Data_count + 1'b1;
			data_out <= data_out;
			data_valid <= 0;
			B_reg <= B_reg;
		end
		3'b101:
		begin
			Data_count <= Data_count + 1'b1;
			data_out <= data_out;
			data_valid <= 0;
			B_reg <= A_reg;
		end
		3'b110:
		begin
			Data_count <= 0;
			data_out <= B_reg;
			data_valid <= 1;
			B_reg <= 0;
		end
		3'b111:
		begin
			Data_count <= 0;
			data_out <= A_reg;
			data_valid <= 1;
			B_reg <= 0;
		end
	endcase
end
	
endmodule
