module data_cnt_blk(
	clk20,
	res_n,
	sync_n,
	words_num,
	word_stb,
	data_count,
	data_valid,
	chan_cmpl
);

input	clk20;
input	res_n;
input	sync_n;
input	[7:0] words_num;
input word_stb;
output [7:0] data_count;
reg [7:0] data_count;
output data_valid;
output chan_cmpl;

wire words_eq;
assign words_eq = (data_count == words_num);
assign chan_cmpl = &{sync_n,cmpl};
assign data_valid = &{~chan_cmpl,word_stb};
reg cmpl;

always@(posedge clk20 or negedge res_n)
begin
	if(!res_n) 
	begin
		data_count <= 0;
		cmpl <= 1'b1;
	end
	else
	begin
		casex({sync_n,word_stb,words_eq})
			3'b0xx:
			begin
				data_count <= 0;
				cmpl <= 0;
			end
			3'b110:
			begin
				data_count <= data_count + 1'b1;
				cmpl <= cmpl;
			end
			3'b111:
			begin
				data_count <= data_count;
				cmpl <= 1'b1;
			end
			default:
			begin
				data_count <= data_count;
				cmpl <= cmpl;
			end			
		endcase
	end
end
endmodule
