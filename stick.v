module stick(
//system interface
		clk,
		alt_rdy,
		reset_n,
//phy 1 intrface second defectoscope connection
		rxd_1x,
		rxer_1x,
		rxdv_1x,
		rxclk_1x,
		col_1x,
		crs_1x,
		txd_1x,
		txer_1x,
		txen_1x,
		txclk_1x,
		mdio_1x,
		mdc_1x,
		nrst_1x,
//phy 2 interface head connection
		rxd_2x,
		rxer_2x,
		rxdv_2x,
		rxclk_2x,
		col_2x,
		crs_2x,
		txd_2x,
		txer_2x,
		txen_2x,
		txclk_2x,
		mdio_2x,
		mdc_2x,
		nrst_2x,
//com ports
		com0_tx,
		com0_rx,
		com1_tx,
		com1_rx,
//test leds
		led,
//whell synchronization input
		adp,
		bdp,
//high voltage control 3'b111 - 90V; 3'b011 (3'b101, 3b110) - 60V; 3'b001 (3'b010, 3'b100) - 30V; 3'b000 - 0V
		hpwon,
//external rs422 synchronization
		sync,
//stm8s003 interface
		intst,
		outtst,
//channals interface
		phase_ax,
		phase_bx,
		phase_cx,
		phase_dx,
		nenz_0x,
		nenz_1x,
		nenz_2x,
		nenz_3x,
		en_0x,
		en_1x,
		en_2x,
		en_3x,
		pdwn_x,
		doffs_x,
		soffs_nx,
		mclk_x,
		d_0x,
		d_1x,
		d_2x,
		d_3x
);
//system interface
input clk;
output alt_rdy;
input reset_n;
//phy 1 intrface second defectoscope connection
input [3:0] rxd_1x;
input rxer_1x;
input rxdv_1x;
input rxclk_1x;
input col_1x;
input crs_1x;
output [3:0] txd_1x;
output txer_1x;
output txen_1x;
input	txclk_1x;
inout mdio_1x;
output mdc_1x;
output nrst_1x;
//phy 2 interface head connection
input [3:0] rxd_2x;
input rxer_2x;
input rxdv_2x;
input rxclk_2x;
input col_2x;
input crs_2x;
output [3:0] txd_2x;
output txer_2x;
output txen_2x;
input txclk_2x;
inout mdio_2x;
output mdc_2x;
output nrst_2x;
//com ports
output com0_tx;
input com0_rx;
output com1_tx;
input com1_rx;
//test leds
output [3:0] led;
//whell synchronization input
input adp;
input bdp;
//high voltage control 3'b111 - 90V; 3'b011 (3'b101, 3b110) - 60V; 3'b001 (3'b010, 3'b100) - 30V; 3'b000 - 0V
output [2:0] hpwon;
//external rs422 synchronization
input sync;
//stm8s003 interface
input intst;
output outtst;
//channals interface
output [3:0] phase_ax;
output [3:0] phase_bx;
output [3:0] phase_cx;
output [3:0] phase_dx;
output [3:0] nenz_0x;
output [3:0] nenz_1x;
output [3:0] nenz_2x;
output [3:0] nenz_3x;
output [3:0] en_0x;
output [3:0] en_1x;
output [3:0] en_2x;
output [3:0] en_3x;
output [3:0] pdwn_x;						//sleep mode to physical channals !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
output [3:0] doffs_x;
output [3:0] soffs_nx;
output [3:0] mclk_x;
input [11:0] d_0x;
input [11:0] d_1x;
input [11:0] d_2x;
input [11:0] d_3x;

//============================================================================
//	ETHRTNRT
//============================================================================

reg			[15:0]			phy_rst_delay;
initial phy_rst_delay = 16'd0;

wire								phy_rst_n;
assign phy_rst_n = &{phy_rst_delay};

always @ (posedge sysclk)
	if(~phy_rst_n)
		phy_rst_delay <= phy_rst_delay + 16'd1;

//----------------------------------------------------------------------------

assign nrst_2x = 1'b1;

//----------------------------------------------------------------------------

assign nrst_1x = 1'b1;

//----------------------------------------------------------------------------

//============================================================================
//		Pump test
//============================================================================
/*
eth_pump eth_pump_unit(
	.rst_n(phy_rst_n),
	.clk(sysclk),
	
	.i_rxd_1(rxd_1x),
	.i_rxer_1(rxer_1x),
	.i_rxdv_1(rxdv_1x),
	.i_rxclk_1(rxclk_1x),
	.i_col_1(col_1x),
	.i_crs_1(crs_1x),
	
	.o_txd_1(txd_1x),
	.o_txer_1(txer_1x),
	.o_txen_1(txen_1x),
	.i_txclk_1(txclk_1x),
	
	.io_mdio_1(mdio_1x),
	.o_mdc_1(mdc_1x),
		
	.i_rxd_2(rxd_2x),
	.i_rxer_2(rxer_2x),
	.i_rxdv_2(rxdv_2x),
	.i_rxclk_2(rxclk_2x),
	.i_col_2(col_2x),
	.i_crs_2(crs_2x),
	
	.o_txd_2(txd_2x),
	.o_txer_2(txer_2x),
	.o_txen_2(txen_2x),
	.i_txclk_2(txclk_2x),
	
	.io_mdio_2(mdio_2x),
	.o_mdc_2(mdc_2x)
);
*/
//============================================================================

/*
	.i_ch_clk(clk20),
	.i_ch_data(data_out[0]),
	.i_ch_vld(data_valid[0]),
	.i_ch_cntr(data_count[0]),
	.i_ch_complete(chan_cmpl[0]),
*/



//*  --- debug ---
mem_fill mem_fill_unit(
	.clk(sysclk),
	.rst_n(phy_rst_n),
	
	.i_ch_clk(clk20),
	
	.i_ch_data_1(data_out[0]),
	.i_ch_vld_1(data_valid[0]),
	.i_ch_cntr_1(data_count[0]),
	
	.i_ch_data_2(data_out[1]),
	.i_ch_vld_2(data_valid[1]),
	.i_ch_cntr_2(data_count[1]),
	
	.i_ch_data_3(data_out[2]),
	.i_ch_vld_3(data_valid[2]),
	.i_ch_cntr_3(data_count[2]),
	
	.i_ch_data_4(data_out[3]),
	.i_ch_vld_4(data_valid[3]),
	.i_ch_cntr_4(data_count[3]),
	
	.i_rd_addr(rd_addr),
	.o_rd_data(rd_data),
	
	.i_sync_counter(sync_counter),
	
	.i_msync_n(eth_msync_n)
);

wire			[9:0]			rd_addr;
wire			[31:0]		rd_data;

eth_top eth_top_unit(
	.rst_n(phy_rst_n),
	.clk(sysclk),
	
	.i_rxd_1(rxd_1x),			// phy_1
	.i_rxer_1(rxer_1x),
	.i_rxdv_1(rxdv_1x),
	.i_rxclk_1(rxclk_1x),
	.i_col_1(col_1x),
	.i_crs_1(crs_1x),
	
	.o_txd_1(txd_1x),
	.o_txer_1(txer_1x),
	.o_txen_1(txen_1x),
	.i_txclk_1(txclk_1x),
	
	.io_mdio_1(mdio_1x),
	.o_mdc_1(mdc_1x),
	
	.i_rxd_2(rxd_2x),			// phy_2
	.i_rxer_2(rxer_2x),
	.i_rxdv_2(rxdv_2x),
	.i_rxclk_2(rxclk_2x),
	.i_col_2(col_2x),
	.i_crs_2(crs_2x),
	
	.o_txd_2(txd_2x),
	.o_txer_2(txer_2x),
	.o_txen_2(txen_2x),
	.i_txclk_2(txclk_2x),
	
	.io_mdio_2(mdio_2x),
	.o_mdc_2(mdc_2x),

		
	.o_rd_addr(rd_addr),
	.i_rd_data(rd_data),
	
	.i_msync_n(eth_msync_n),
	
	.o_cmd_flag(recv_cmd_valid),
	.o_cmd_phy_channel(recv_cmd_phy_channel),
	.o_cmd_data(recv_cmd)//,
	
	//.o_led(led)	// for debug purpose
);

//*/
//============================================================================

//-------------------------------------------------------------------------------------
//initial settings
assign alt_rdy = 1'b1;
wire clk250;
wire clk20;
wire sysclk;
//system pll
syspll sys_pll(
	.areset(~reset_n),
	.inclk0(clk),
	.c0(clk20), 			//channal master clock 20 MHz do not change please
	.c1(sysclk), 			//system clock to nios etc. 100 MHz may be changed if necesary
	.c2(clk250)				//channal znd base clock 250 MHz do not change please
);
assign mclk_x[0] = pdwn_x[0] ? 1'b0 : clk20;
assign mclk_x[1] = pdwn_x[1] ? 1'b0 : clk20;
assign mclk_x[2] = pdwn_x[2] ? 1'b0 : clk20;
assign mclk_x[3] = pdwn_x[3] ? 1'b0 : clk20;
//------------------------------------------------------------------------------------
wire msync_n;										//master sync pulse min 80 ns low
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//--------------------------------------
//virtual channals [0:15] parameters 
wire [7:0] frq_div [0:15];						//zond pulse frequency divisor
wire [7:0] pulse_w [0:15];						//zond pulse width
wire [7:0] diag_data [0:15];					//zond pulse diagramm
wire [7:0] smax_num [0:15];					//number of input points to select maximum
wire [7:0] words_num [0:15];					//number of words of data to transmit
wire [7:0] offset [0:15];						//offset
wire [5:0] mul_c [0:15];						//multiplyer for data
//-------------------------------------
//physical channals [0:3] parameters
wire [23:0] znd_delay0 [0:3];					//delay from main sync to zond pulse N0
wire [23:0] znd_delay1 [0:3];					//delay from main sync to zond pulse N1
wire [23:0] znd_delay2 [0:3];					//delay from main sync to zond pulse N2
wire [23:0] znd_delay3 [0:3];					//delay from main sync to zond pulse N3
wire [7:0] num_order_z [0:3];					//zond channals order
wire [23:0] data_delay0 [0:3];				//delay data acquire from main sync to cycle N0
wire [23:0] data_delay1 [0:3];				//delay data acquire from main sync to cycle N1
wire [23:0] data_delay2 [0:3];				//delay data acquire from main sync to cycle N2
wire [23:0] data_delay3 [0:3];				//delay data acquire from main sync to cycle N3
wire [7:0] num_order_x [0:3];					//data channals order
//----------------------------------
//data & valid to set parameters (reference clock clk20)

wire			[31:0]			recv_cmd;
wire								recv_cmd_valid;
wire			[1:0]				recv_cmd_phy_channel;

wire			[31:0]			fix_cmd;
assign fix_cmd = recv_cmd[31] == 1'b0 ? {recv_cmd[31:26], ~recv_cmd[25:24], recv_cmd[23:0]} : recv_cmd;

cmd_fifo cmd_fifo_unit(
	.wrclk(sysclk),
	.data(fix_cmd),
	.wrreq(recv_cmd_valid),
	
	.rdclk(clk20),
	.q(data_cntr),
	.rdreq(cntr_valid),
	.rdempty(cmd_fifo_rd_empty)
);

wire								cmd_fifo_rd_empty;
assign cntr_valid = ~cmd_fifo_rd_empty;

wire [31:0] data_cntr;							//data to set parameters !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
wire cntr_valid;									//data valid to set parameters !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
//-------------------------------------------
//set parameters block
control_blk cntr_blk(
	.clk20(clk20),
	.res_n(reset_n),
	.data(data_cntr),
	.valid(cntr_valid),
	.frq_div({frq_div[15],frq_div[14],frq_div[13],frq_div[12],frq_div[11],frq_div[10],frq_div[9],frq_div[8],frq_div[7],frq_div[6],frq_div[5],
frq_div[4],frq_div[3],frq_div[2],frq_div[1],frq_div[0]}),
	.pulse_w({pulse_w[15],pulse_w[14],pulse_w[13],pulse_w[12],pulse_w[11],pulse_w[10],pulse_w[9],pulse_w[8],pulse_w[7],pulse_w[6],pulse_w[5],
pulse_w[4],pulse_w[3],pulse_w[2],pulse_w[1],pulse_w[0]}),
	.diag_data({diag_data[15],diag_data[14],diag_data[13],diag_data[12],diag_data[11],diag_data[10],diag_data[9],diag_data[8],diag_data[7],
diag_data[6],diag_data[5],diag_data[4],diag_data[3],diag_data[2],diag_data[1],diag_data[0]}),
	.smax_num({smax_num[15],smax_num[14],smax_num[13],smax_num[12],smax_num[11],smax_num[10],smax_num[9],smax_num[8],smax_num[7],smax_num[6],
smax_num[5],smax_num[4],smax_num[3],smax_num[2],smax_num[1],smax_num[0]}),
	.words_num({words_num[15],words_num[14],words_num[13],words_num[12],words_num[11],words_num[10],words_num[9],words_num[8],words_num[7],
words_num[6],words_num[5],words_num[4],words_num[3],words_num[2],words_num[1],words_num[0]}),
	.offset({offset[15],offset[14],offset[13],offset[12],offset[11],offset[10],offset[9],offset[8],offset[7],offset[6],offset[5],offset[4],offset[3],offset[2],offset[1],offset[0]}),
	.mul_c({mul_c[15],mul_c[14],mul_c[13],mul_c[12],mul_c[11],mul_c[10],mul_c[9],mul_c[8],mul_c[7],mul_c[6],mul_c[5],mul_c[4],mul_c[3],mul_c[2],mul_c[1],mul_c[0]}),
	.znd_delay0({znd_delay0[3],znd_delay0[2],znd_delay0[1],znd_delay0[0]}),
	.znd_delay1({znd_delay1[3],znd_delay1[2],znd_delay1[1],znd_delay1[0]}),
	.znd_delay2({znd_delay2[3],znd_delay2[2],znd_delay2[1],znd_delay2[0]}),
	.znd_delay3({znd_delay3[3],znd_delay3[2],znd_delay3[1],znd_delay3[0]}),
	.num_order_z({num_order_z[3],num_order_z[2],num_order_z[1],num_order_z[0]}),
	.data_delay0({data_delay0[3],data_delay0[2],data_delay0[1],data_delay0[0]}),
	.data_delay1({data_delay1[3],data_delay1[2],data_delay1[1],data_delay1[0]}),
	.data_delay2({data_delay2[3],data_delay2[2],data_delay2[1],data_delay2[0]}),
	.data_delay3({data_delay3[3],data_delay3[2],data_delay3[1],data_delay3[0]}),
	.num_order_x({num_order_x[3],num_order_x[2],num_order_x[1],num_order_x[0]}),
	.pdwn_x(pdwn_x),
	.hpwon(hpwon)
); 
//----------------------------------
//physical channals [0:3] outputs
wire [31:0] data_out [0:3];					//output data from channal
wire [3:0] data_valid;							//data valid from channal
wire [9:0] data_count [0:3];					//[7:0] current number of data word from channal [9:8] virtual channal number [1:0] 
wire [3:0] chan_cmpl;							//end of current cycle 
//----------------------------------
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
//zond pulse blocks
znd_blk znd_x4_0(
	.clk250(clk250),
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.frq_div({frq_div[3],frq_div[2],frq_div[1],frq_div[0]}),
	.pulse_w({pulse_w[3],pulse_w[2],pulse_w[1],pulse_w[0]}),
	.diag_data({diag_data[3],diag_data[2],diag_data[1],diag_data[0]}),
	.znd_delay0(znd_delay0[0]),
	.znd_delay1(znd_delay1[0]),
	.znd_delay2(znd_delay2[0]),
	.znd_delay3(znd_delay3[0]),
	.num_order(num_order_z[0]),
	.imp_a(phase_ax[0]),
	.imp_b_n(phase_bx[0]),
	.imp_c(phase_cx[0]),
	.imp_d_n(phase_dx[0]),
	.enz_n(nenz_0x)
);
znd_blk znd_x4_1(
	.clk250(clk250),
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.frq_div({frq_div[7],frq_div[6],frq_div[5],frq_div[4]}),
	.pulse_w({pulse_w[7],pulse_w[6],pulse_w[5],pulse_w[4]}),
	.diag_data({diag_data[7],diag_data[6],diag_data[5],diag_data[4]}),
	.znd_delay0(znd_delay0[1]),
	.znd_delay1(znd_delay1[1]),
	.znd_delay2(znd_delay2[1]),
	.znd_delay3(znd_delay3[1]),
	.num_order(num_order_z[1]),
	.imp_a(phase_ax[1]),
	.imp_b_n(phase_bx[1]),
	.imp_c(phase_cx[1]),
	.imp_d_n(phase_dx[1]),
	.enz_n(nenz_1x)
);
znd_blk znd_x4_2(
	.clk250(clk250),
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.frq_div({frq_div[11],frq_div[10],frq_div[9],frq_div[8]}),
	.pulse_w({pulse_w[11],pulse_w[10],pulse_w[9],pulse_w[8]}),
	.diag_data({diag_data[11],diag_data[10],diag_data[9],diag_data[8]}),
	.znd_delay0(znd_delay0[2]),
	.znd_delay1(znd_delay1[2]),
	.znd_delay2(znd_delay2[2]),
	.znd_delay3(znd_delay3[2]),
	.num_order(num_order_z[2]),
	.imp_a(phase_ax[2]),
	.imp_b_n(phase_bx[2]),
	.imp_c(phase_cx[2]),
	.imp_d_n(phase_dx[2]),
	.enz_n(nenz_2x)
);
znd_blk znd_x4_3(
	.clk250(clk250),
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.frq_div({frq_div[15],frq_div[14],frq_div[13],frq_div[12]}),
	.pulse_w({pulse_w[15],pulse_w[14],pulse_w[13],pulse_w[12]}),
	.diag_data({diag_data[15],diag_data[14],diag_data[13],diag_data[12]}),
	.znd_delay0(znd_delay0[3]),
	.znd_delay1(znd_delay1[3]),
	.znd_delay2(znd_delay2[3]),
	.znd_delay3(znd_delay3[3]),
	.num_order(num_order_z[3]),
	.imp_a(phase_ax[3]),
	.imp_b_n(phase_bx[3]),
	.imp_c(phase_cx[3]),
	.imp_d_n(phase_dx[3]),
	.enz_n(nenz_3x)
);


//------------------------------------
//data blocks
data_blk dat_x4_0(
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.smax_num({smax_num[3],smax_num[2],smax_num[1],smax_num[0]}),
	.words_num({words_num[3],words_num[2],words_num[1],words_num[0]}),
	.offset({offset[3],offset[2],offset[1],offset[0]}),
	.mul_c({mul_c[3],mul_c[2],mul_c[1],mul_c[0]}),
	.data_delay0(data_delay0[0]),
	.data_delay1(data_delay1[0]),
	.data_delay2(data_delay2[0]),
	.data_delay3(data_delay3[0]),
	.num_order(num_order_x[0]),
	.data_in(d_0x),
	.data_out(data_out[0]),
	.data_valid(data_valid[0]),
	.data_count(data_count[0]),
	.chan_cmpl(chan_cmpl[0]),
	.doffs(doffs_x[0]),
	.soffs_n(soffs_nx[0]),
	.enx(en_0x)
);
data_blk dat_x4_1(
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.smax_num({smax_num[7],smax_num[6],smax_num[5],smax_num[4]}),
	.words_num({words_num[7],words_num[6],words_num[5],words_num[4]}),
	.offset({offset[7],offset[6],offset[5],offset[4]}),
	.mul_c({mul_c[7],mul_c[6],mul_c[5],mul_c[4]}),
	.data_delay0(data_delay0[1]),
	.data_delay1(data_delay1[1]),
	.data_delay2(data_delay2[1]),
	.data_delay3(data_delay3[1]),
	.num_order(num_order_x[1]),
	.data_in(d_1x),
	.data_out(data_out[1]),
	.data_valid(data_valid[1]),
	.data_count(data_count[1]),
	.chan_cmpl(chan_cmpl[1]),
	.doffs(doffs_x[1]),
	.soffs_n(soffs_nx[1]),
	.enx(en_1x)
);
data_blk dat_x4_2(
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.smax_num({smax_num[11],smax_num[10],smax_num[9],smax_num[8]}),
	.words_num({words_num[11],words_num[10],words_num[9],words_num[8]}),
	.offset({offset[11],offset[10],offset[9],offset[8]}),
	.mul_c({mul_c[11],mul_c[10],mul_c[9],mul_c[8]}),
	.data_delay0(data_delay0[2]),
	.data_delay1(data_delay1[2]),
	.data_delay2(data_delay2[2]),
	.data_delay3(data_delay3[2]),
	.num_order(num_order_x[2]),
	.data_in(d_2x),
	.data_out(data_out[2]),
	.data_valid(data_valid[2]),
	.data_count(data_count[2]),
	.chan_cmpl(chan_cmpl[2]),
	.doffs(doffs_x[2]),
	.soffs_n(soffs_nx[2]),
	.enx(en_2x)
);
data_blk dat_x4_3(
	.clk20(clk20),
	.res_n(reset_n),
	.msync_n(msync_n),
	.smax_num({smax_num[15],smax_num[14],smax_num[13],smax_num[12]}),
	.words_num({words_num[15],words_num[14],words_num[13],words_num[12]}),
	.offset({offset[15],offset[14],offset[13],offset[12]}),
	.mul_c({mul_c[15],mul_c[14],mul_c[13],mul_c[12]}),
	.data_delay0(data_delay0[3]),
	.data_delay1(data_delay1[3]),
	.data_delay2(data_delay2[3]),
	.data_delay3(data_delay3[3]),
	.num_order(num_order_x[3]),
	.data_in(d_3x),
	.data_out(data_out[3]),
	.data_valid(data_valid[3]),
	.data_count(data_count[3]),
	.chan_cmpl(chan_cmpl[3]),
	.doffs(doffs_x[3]),
	.soffs_n(soffs_nx[3]),
	.enx(en_3x)
);
//-------------------------------------------------------------------------

ext_sync ext_sync_unut(
	.rst_n(phy_rst_n),
	.clk(sysclk),
	
	.i_ch_a(adp),
	.i_ch_b(bdp),

	.o_sync(dp_sync),
	.o_sync_counter(sync_counter)
);

wire								dp_sync;
wire			[31:0]			sync_counter;
assign led = sync_counter[3:0];

reg			[0:0]			int_sync_on;
always @ (posedge sysclk or negedge phy_rst_n)
	if(~phy_rst_n)
		int_sync_on <= 1'b0;
	else
		if(recv_cmd_valid && recv_cmd[31] == 1'b1 && recv_cmd[30:26] == 5'h10)
			int_sync_on <= recv_cmd[0];

wire							eth_msync_n;
assign eth_msync_n = int_sync_on ? test_counter[20] : ~dp_sync; //1'b1;

reg			[0:0]			sync_bit;

always @ (posedge clk20) sync_bit <= eth_msync_n;

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//remove this block
//leds test
reg [31:0] test_counter;
//assign led = test_counter[26:23];
assign msync_n = sync_bit; //int_sync_on ? 1'b1 : test_counter[20];

always@(posedge sysclk)
begin
	test_counter <= test_counter + 1'b1;
end
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

endmodule
