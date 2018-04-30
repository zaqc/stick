module spi_dac(
	clk20,
	data_spi,
	start,
	ddac,
	sdac_n
);

input	clk20;
input	[7:0] data_spi;
input	start;
output	ddac;
output	sdac_n;

reg		[15:0] Reg_d, Reg_s;

assign	ddac = Reg_d[15];
assign	sdac_n = Reg_s[15];

always@(posedge clk20)
begin
	if (start)
	begin
		Reg_d <= {4'b0000,data_spi,4'b0000};
		Reg_s <= 0;
	end
	else
	begin
		Reg_d <= {Reg_d[14:0],1'b0};
		Reg_s <= {Reg_s[14:0],1'b1};			
	end
end

endmodule
