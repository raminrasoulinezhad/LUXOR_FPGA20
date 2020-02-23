// This file models an slice in Xilinx architecture based on UG474_7series

module slice(
		input clk,
		
		input GSR,
		input CE,
		input SR,

		input [6:1] A_61,
		input [6:1] B_61,
		input [6:1] C_61,
		input [6:1] D_61,

		input AX,
		input BX,
		input CX,
		input DX,
		
		output A,
		output B,
		output C,
		output D,

		output AQ,
		output BQ,
		output CQ,
		output DQ,

		output AMUX,
		output BMUX,
		output CMUX,
		output DMUX,

		input CIN,
		output COUT,

		input config_clk,
		input config_in,
		input config_en,
		output config_out
	);
	
	////////////////////////////
	// parameters
	////////////////////////////
	parameter param_mode_QSlice_A = 2'b00;
	parameter param_mode_QSlice_B = 2'b00;
	parameter param_mode_QSlice_C = 2'b00;
	parameter param_mode_QSlice_D = 2'b00;
	//parameter param_XOR6_en = 4'b0111;
	//parameter param_XOR6_carry_en = 4'b0111;
	parameter param_mux_optimizer = 1'b0;


	////////////////////////////
	// Wiring
	////////////////////////////
	// Controlling signals
	wire clk_local;
	wire CE_local;
	wire SR_local;

	reg clk_controller;		// 0 --> clk, 1 --> ~clk
	reg CE_controller;		// 0 --> CE, 1 --> ~CE
	reg SR_controller;		// 0 --> SR, 1 --> ~SR

	reg SYNCASYNC_01;
	reg FFLAT_01_S2;


	// instanciation of four quarters
	wire O6_out_A;
	wire O6_out_B;
	wire O6_out_C;
	wire O6_out_D;

	wire F78MUX_A;
	wire F78MUX_B;
	wire F78MUX_C;
	wire F78MUX_D;

	// carry chain
	wire mux_carry_cons;
	wire mux_carry;

	reg carry_const;
	reg mux_carry_cons_controller;
	reg mux_carry_controller;

	wire CIN_A;
	wire CIN_B;
	wire CIN_C;
	wire CIN_D;
	
	wire COUT_A;
	wire COUT_B;
	wire COUT_C;
	wire COUT_D;


	// configuration chain
	wire config_in_A;
	wire config_in_B;
	wire config_in_C;
	wire config_in_D;

	wire config_out_A;
	wire config_out_B;
	wire config_out_C;
	wire config_out_D;

	
	////////////////////////////
	// Circuits
	////////////////////////////
	assign clk_local = (clk_controller)? (!clk): clk;
	assign CE_local = (CE_controller)? (!CE): CE;
	assign SR_local = (SR_controller)? (!SR): SR;

	//defparam QuarterSlice_A.param_XOR6_en = param_XOR6_en[0];
	//defparam QuarterSlice_A.param_XOR6_carry_en = param_XOR6_carry_en[0];
	defparam QuarterSlice_A.param_mode_QSlice = param_mode_QSlice_A;
	defparam QuarterSlice_A.param_F78MUX_en = 1'b1;
	defparam QuarterSlice_A.param_mux_optimizer = param_mux_optimizer;
	QuarterSlice	QuarterSlice_A(
		.clk(clk_local),

		.O6_out(O6_out_A),
		.AX(AX),
		.F78MUX(F78MUX_A),
		.A_61(A_61),

		.AMUX(AMUX),
		.A(A),
		.AQ(AQ),

		.CIN(CIN_A),
		.COUT(COUT_A),

		.SYNCASYNC_01(SYNCASYNC_01),
		.FFLAT_01_S2(FFLAT_01_S2),
		.CE(CE_local),
		.SR(SR_local),
		.GSR(GSR),

		.config_clk(config_clk),
		.config_in(config_in_A),
		.config_en(config_en),
		.config_out(config_out_A)
	);
	
	
	//defparam QuarterSlice_B.param_XOR6_en = param_XOR6_en[1];
	//defparam QuarterSlice_B.param_XOR6_carry_en = param_XOR6_carry_en[1];
	defparam QuarterSlice_B.param_mode_QSlice = param_mode_QSlice_B;
	defparam QuarterSlice_B.param_F78MUX_en = 1'b1;
	defparam QuarterSlice_B.param_mux_optimizer = param_mux_optimizer;
	QuarterSlice	QuarterSlice_B(
		.clk(clk_local),

		.O6_out(O6_out_B),
		.AX(BX),
		.F78MUX(F78MUX_B),
		.A_61(B_61),

		.AMUX(BMUX),
		.A(B),
		.AQ(BQ),

		.CIN(CIN_B),
		.COUT(COUT_B),

		.SYNCASYNC_01(SYNCASYNC_01),
		.FFLAT_01_S2(FFLAT_01_S2),
		.CE(CE_local),
		.SR(SR_local),
		.GSR(GSR),

		.config_clk(config_clk),
		.config_in(config_in_B),
		.config_en(config_en),
		.config_out(config_out_B)
	);
	
	
	//defparam QuarterSlice_C.param_XOR6_en = param_XOR6_en[2];
	//defparam QuarterSlice_C.param_XOR6_carry_en = param_XOR6_carry_en[2];
	defparam QuarterSlice_C.param_mode_QSlice = param_mode_QSlice_C;
	defparam QuarterSlice_C.param_F78MUX_en = 1'b1;
	defparam QuarterSlice_C.param_mux_optimizer = param_mux_optimizer;
	QuarterSlice	QuarterSlice_C(
		.clk(clk_local),

		.O6_out(O6_out_C),
		.AX(CX),
		.F78MUX(F78MUX_C),
		.A_61(C_61),

		.AMUX(CMUX),
		.A(C),
		.AQ(CQ),

		.CIN(CIN_C),
		.COUT(COUT_C),

		.SYNCASYNC_01(SYNCASYNC_01),
		.FFLAT_01_S2(FFLAT_01_S2),
		.CE(CE_local),
		.SR(SR_local),
		.GSR(GSR),

		.config_clk(config_clk),
		.config_in(config_in_C),
		.config_en(config_en),
		.config_out(config_out_C)
	);

	
	//defparam QuarterSlice_D.param_XOR6_en = param_XOR6_en[3];
	//defparam QuarterSlice_D.param_XOR6_carry_en = param_XOR6_carry_en[3];
	defparam QuarterSlice_D.param_mode_QSlice = param_mode_QSlice_D;
	// QuarterSlice_D.param_F78MUX_en must be zero. There is no 7/8MUX signal for this case 
	defparam QuarterSlice_D.param_F78MUX_en = 1'b0;
	defparam QuarterSlice_D.param_mux_optimizer = param_mux_optimizer;
	defparam QuarterSlice_D.param_cout_to_A = 1'b1;
	QuarterSlice	QuarterSlice_D(
		.clk(clk_local),

		.O6_out(O6_out_D),
		.AX(DX),
		.F78MUX(F78MUX_D),
		.A_61(D_61),

		.AMUX(DMUX),
		.A(D),
		.AQ(DQ),

		.CIN(CIN_D),
		.COUT(COUT_D),

		.SYNCASYNC_01(SYNCASYNC_01),
		.FFLAT_01_S2(FFLAT_01_S2),
		.CE(CE_local),
		.SR(SR_local),
		.GSR(GSR),

		.config_clk(config_clk),
		.config_in(config_in_D),
		.config_en(config_en),
		.config_out(config_out_D)
	);


	
	// F78MUX signals
	assign F78MUX_A = (AX)? O6_out_B : O6_out_A;
	assign F78MUX_B = (BX)? F78MUX_C : F78MUX_A;
	assign F78MUX_C = (CX)? O6_out_D : O6_out_C;
	assign F78MUX_D = 1'bx;

	// carry chain conection
	assign mux_carry_cons = (mux_carry_cons_controller)? carry_const: AX;
	assign mux_carry = (mux_carry_controller)? mux_carry_cons : CIN;
	assign CIN_A = mux_carry;
	assign CIN_B = COUT_A;
	assign CIN_C = COUT_B;
	assign CIN_D = COUT_C;
	assign COUT = COUT_D;


	// configuration 
	always @ (posedge config_clk)begin
		if (config_en)begin
			clk_controller <= config_in;
			CE_controller <= clk_controller;
			SR_controller <= CE_controller;
			SYNCASYNC_01 <= SR_controller;
			FFLAT_01_S2 <= SYNCASYNC_01;
			carry_const <= FFLAT_01_S2;
			mux_carry_cons_controller <= carry_const;
			mux_carry_controller <= mux_carry_cons_controller;
		end
	end

	assign config_in_A = mux_carry_controller;
	assign config_in_B = config_out_A;
	assign config_in_C = config_out_B;
	assign config_in_D = config_out_C;
	assign config_out = config_out_D;

endmodule 
