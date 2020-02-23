// This module models a quartuer of an Xilinx slice excluding 6-input LUT


module QuarterSlice(
		input clk,

		input AX,
		input F78MUX,
		input [6:1] A_61,

		output O6_out,
		output AMUX,
		output A,
		output AQ,

		input CIN,
		output COUT,

		input SYNCASYNC_01,
		input FFLAT_01_S2,
		input CE,
		input SR,
		input GSR,

		input config_clk,
		input config_in,
		input config_en,
		output config_out
	);
	
	////////////////////////////
	// parameters
	////////////////////////////
	parameter param_mode_QSlice = 2'b00;

	parameter param_XOR6_en = (param_mode_QSlice > 2'b00)? 1'b1 : 1'b0;
	parameter param_XOR6_carry_en = (param_mode_QSlice > 2'b01)? 1'b1 : 1'b0;
	//parameter param_XOR6_en = 1'b0;
	//parameter param_XOR6_carry_en = 1'b0;
	parameter param_F78MUX_en = 1'b1;
	parameter param_mux_optimizer = 1'b0;
	parameter param_cout_to_A = 1'b0;

	////////////////////////////
	// Wiring
	////////////////////////////
	// Distributed multiplexers & FA and carry chain
	wire mux_1;
	wire mux_2;
	wire mux_3;
	reg mux_4;
	reg mux_5;
	wire mux_8;

	reg mux_cntr_1;
	reg mux_cntr_3;
	reg [2:0] mux_cntr_4;
	reg [2:0] mux_cntr_5;
	reg mux_cntr_8;

	wire XOR2;

	// Registers
	wire storage1_Q;
	wire storage2_Q;

	reg INIT01_S1;
	reg SRHILO_S1;
	reg INIT01_S2;
	reg SRHILO_S2;

	// Extra circuits (modifications)
	wire XOR6_extra;
	wire XOR2_extra;
	wire CIN_temp;
	wire mux_6;
	wire mux_7;
	reg mux_cntr_7;

	// LUT
	wire config_in_LUT;
	wire config_in_mux7or5;
	wire O5;
	wire O6;

	////////////////////////////
	// Circuits
	////////////////////////////
	assign mux_1 = (mux_cntr_1)? O5 : AX;
	assign mux_2 = (O6)? CIN : mux_1;
	assign mux_3 = (mux_cntr_3)? O5 : AX;
	always @(*)begin
		case(mux_cntr_4)
			3'b000  : mux_4 = storage1_Q;
			3'b001  : mux_4 = mux_2;
			3'b010  : mux_4 = (param_F78MUX_en)? F78MUX : 1'bx;
			3'b011  : mux_4 = XOR2;
			3'b100  : mux_4 = O5;
			3'b101  : mux_4 = O6;
			3'b110  : mux_4 = ((!param_mux_optimizer) & param_XOR6_en)? XOR6_extra: 1'bx;
			3'b111  : mux_4 = (param_XOR6_carry_en)? XOR2_extra: 1'bx;
			default: mux_4 = 1'bx; 
		endcase
	end
	always @(*)begin
		case(mux_cntr_5)
			3'b000  : mux_5 = O6;
			3'b001  : mux_5 = O5;
			3'b010  : mux_5 = AX;
			3'b011  : mux_5 = XOR2;
			3'b100  : mux_5 = (param_F78MUX_en)? F78MUX : 1'bx;
			3'b101  : mux_5 = mux_2;
			3'b110  : mux_5 = (param_XOR6_en)? XOR6_extra: 1'bx;
			3'b111  : mux_5 = ((!param_mux_optimizer) & param_XOR6_carry_en)? XOR2_extra: 1'bx;
			default: mux_5 = 1'bx; 
		endcase
	end
	assign mux_8 = (mux_cntr_8)? COUT : O6;

	assign XOR2 = O6 ^ CIN;

	////////////////////////////
	// Registers
	////////////////////////////
	LATDFF storage1(
		.clk(clk),

		.GSR(GSR),

		.CE(CE),
		.D(mux_3),
		.SR(SR),

		.SYNCASYNC_01(SYNCASYNC_01),
		.FFLAT_01(1'b0),
		.INIT01(INIT01_S1),
		.SRHILO(SRHILO_S1),

		.Q(storage1_Q)
	);

	LATDFF storage2(
		.clk(clk),

		.GSR(GSR),

		.CE(CE),
		.D(mux_5),
		.SR(SR),

		.SYNCASYNC_01(SYNCASYNC_01),
		.FFLAT_01(FFLAT_01_S2),
		.INIT01(INIT01_S2),
		.SRHILO(SRHILO_S2),

		.Q(storage2_Q)
	);

	////////////////////////////
	// Outputs
	////////////////////////////
	assign COUT = mux_2;
	assign AQ = storage2_Q;
	assign A = (param_cout_to_A)? mux_8 : O6;
	assign AMUX = mux_4;

	////////////////////////////
	// Extra Circuits
	////////////////////////////
	assign XOR6_extra = ^A_61;
	assign XOR2_extra = XOR6_extra ^ CIN;
	assign mux_6 = (XOR6_extra)? CIN : A_61[1];
	assign mux_7 = (mux_cntr_7)? mux_6 : CIN ;
	assign CIN_temp = (param_XOR6_carry_en)? mux_7 : CIN;


	// LUTs
	LUT6_2 	LUT6_2_inst(
		.in(A_61),
		.O6(O6),
		.O5(O5),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_in_LUT)	
	);
	assign O6_out = O6;

	// configuration stream
	always @(posedge config_clk)begin
		if (config_en)begin
			INIT01_S1 <= config_in_LUT;
			INIT01_S2 <= INIT01_S1;
			SRHILO_S1 <= INIT01_S2;
			SRHILO_S2 <= SRHILO_S1;
			mux_cntr_1 <= SRHILO_S2;
			mux_cntr_3 <= mux_cntr_1;
			mux_cntr_4[0] <= mux_cntr_3;
			{{mux_cntr_5[0]},{mux_cntr_4[2:1]}} <= mux_cntr_4;
			mux_cntr_5[2:1] <= mux_cntr_5[1:0];
			mux_cntr_7 <= mux_cntr_5[2];
			mux_cntr_8 <= config_in_mux7or5;
		end
	end

	assign config_in_mux7or5 = (param_XOR6_carry_en)? mux_cntr_7: mux_cntr_5[2];
	assign config_out = (param_cout_to_A)? mux_cntr_8 : config_in_mux7or5;

endmodule 
