module zndgen(
	clk250,
	sync_n,
	clk_znd,
	pulse,
	diag_data,
	res_n,
	imp_a,
	imp_b_n,
	imp_c,
	imp_d_n,
	znd_rdy
);

input clk250;
input sync_n;
input clk_znd;
input pulse;
input	[7:0] diag_data;
input res_n;
output imp_a;
reg imp_a;
output imp_b_n;
reg imp_b_n;
output imp_c;
reg imp_c;
output imp_d_n;
reg imp_d_n;
output znd_rdy;

reg Aint;
reg Bint;
reg Cint;
reg [4:0] Z_count;
reg [4:0] G_count;
reg En_z;
reg Cycle_end;
reg synctmp;
wire syncrise;
wire Z_eq, G_eq;
wire cpls,np;
wire imp_at, imp_bt_n, imp_ct;
reg znd_ready;


assign imp_at = &{Aint,pulse,~Bint,~Cint};
assign imp_bt_n = ~(&{Bint,pulse,~Aint,~Cint});
assign np = |{Aint,Bint};
assign cpls = &{~pulse,np};
assign imp_ct = |{cpls,Cint};

assign Z_eq = (Z_count[4:1] == diag_data[3:0]);
assign G_eq = (G_count[4:1] == diag_data[7:4]);
assign syncrise = ({synctmp,sync_n} == 2'b01);
assign znd_rdy = &{sync_n,znd_ready};

always@(posedge clk250 or negedge res_n)
begin
	if(!res_n) znd_ready <= 1'b1;
	else
	begin
		casex({sync_n,Cycle_end})
			2'b0x: znd_ready <= 0;
			2'b10: znd_ready <= znd_ready;
			2'b11: znd_ready <= 1;
		endcase
	end
end

always@(posedge clk250 or negedge res_n)
begin
	if (!res_n) {synctmp,imp_a,imp_b_n,imp_c,imp_d_n} <= 5'b10101;
	else {synctmp,imp_a,imp_b_n,imp_c,imp_d_n} <= {sync_n,imp_at,imp_bt_n,imp_ct,~imp_ct};
end

always@(posedge clk250 or negedge res_n)
begin
	if (!res_n) En_z <= 0;
	else
	begin
		casex ({Cycle_end,syncrise})
			2'b1x: En_z <= 0;
			2'b01: En_z <= 1;
		endcase
	end
end

always@(posedge clk250)
begin
	casex ({En_z,clk_znd,Z_eq,G_eq})
		4'b0xxx:
		begin
			{Aint,Bint,Cint} <= 3'b000;
			Z_count <= 0;
			G_count <= 0;
			Cycle_end <= 0;
		end
		4'b1100:
		begin
			{Aint,Bint,Cint} <= {~Aint,Aint,1'b0};
			Z_count <= Z_count + 1'b1;
			G_count <= G_count;
			Cycle_end <= Cycle_end;
		end
		4'b1110:
		begin
			{Aint,Bint,Cint} <= 3'b001;
			Z_count <= Z_count;
			G_count <= G_count + 1'b1;
			Cycle_end <= Cycle_end;
		end
		4'b1111:
		begin
			{Aint,Bint,Cint} <= 3'b000;
			Z_count <= Z_count;
			G_count <= G_count;
			Cycle_end <= 1;
		end		
		default:
		begin
			{Aint,Bint,Cint} <= {Aint,Bint,Cint};
			Z_count <= Z_count;
			G_count <= G_count;
			Cycle_end <= Cycle_end;
		end
	endcase
end

endmodule
