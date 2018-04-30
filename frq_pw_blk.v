module frq_pw_blk(
	sync_n,
	clk250,
	frq_div,
	pw,
	clk_znd,
	pulse
);


input	sync_n;
input	clk250;
input	[7:0] frq_div;
input	[7:0] pw;
output clk_znd;
reg clk_znd;
output pulse;
reg pulse;
reg Pulse_int, Pulse_int1;
reg clk_z;

reg [7:0] Frq_count;
reg [7:0] Pulse_count;

always@(posedge clk250)
begin
	clk_znd <= clk_z;
	Pulse_int1 <= Pulse_int;
	pulse <= Pulse_int1;
end

always@(posedge clk250)
begin
	if (!sync_n)
	begin
		Frq_count <= 0;
		clk_z <= 0;
	end
	else
	begin
		if (Frq_count == frq_div)
		begin
			Frq_count <= 0;
			clk_z <= 1;
		end
		else
		begin 
			Frq_count <= Frq_count + 1'b1;
			clk_z <= 0;
		end
	end
end

always@(posedge clk250)
begin
	if (clk_z)
	begin
		Pulse_count <= 0;
		Pulse_int <= 1;
	end
	else
	begin
		if (Pulse_count == pw)
		begin
			Pulse_count <= Pulse_count;
			Pulse_int <= 0;
		end
		else
		begin
			Pulse_count <= Pulse_count + 1'b1;
		end
	end
end


endmodule
