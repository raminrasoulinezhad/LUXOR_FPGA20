// This file is for putting the slice in a shell of Register for synthesis

module slice_fixed(
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
		
		output reg A,
		output reg B,
		output reg C,
		output reg D,

		output reg AQ,
		output reg BQ,
		output reg CQ,
		output reg DQ,

		output reg AMUX,
		output reg BMUX,
		output reg CMUX,
		output reg DMUX,

		input CIN,
		output reg COUT,

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
	parameter param_mux_optimizer = 1'b0;

	// wires and regs
	reg [6:1] A_61_reg;
	reg [6:1] B_61_reg;
	reg [6:1] C_61_reg;
	reg [6:1] D_61_reg;

	reg AX_reg;
	reg BX_reg;
	reg CX_reg;
	reg DX_reg;

	wire A_temp;
	wire B_temp;
	wire C_temp;
	wire D_temp;

	wire AQ_temp;
	wire BQ_temp;
	wire CQ_temp;
	wire DQ_temp;

	wire AMUX_temp;
	wire BMUX_temp;
	wire CMUX_temp;
	wire DMUX_temp;

	reg CIN_reg;
	wire COUT_temp;

	always @ (posedge clk)begin
		A_61_reg <= A_61;
		B_61_reg <= B_61;
		C_61_reg <= C_61;
		D_61_reg <= D_61;

		AX_reg <= AX;
		BX_reg <= BX;
		CX_reg <= CX;
		DX_reg <= DX;

		A <= A_temp;
		B <= B_temp;
		C <= C_temp;
		D <= D_temp;

		AQ <= AQ_temp;
		BQ <= BQ_temp;
		CQ <= CQ_temp;
		DQ <= DQ_temp;

		AMUX <= AMUX_temp;
		BMUX <= BMUX_temp;
		CMUX <= CMUX_temp;
		DMUX <= DMUX_temp;

		CIN_reg <= CIN;
		COUT <= COUT_temp;
	end

	defparam slice_inst.param_mode_QSlice_A = param_mode_QSlice_A;
	defparam slice_inst.param_mode_QSlice_B = param_mode_QSlice_B;
	defparam slice_inst.param_mode_QSlice_C = param_mode_QSlice_C;
	defparam slice_inst.param_mode_QSlice_D = param_mode_QSlice_D;
	defparam slice_inst.param_mux_optimizer = param_mux_optimizer;
	slice 	slice_inst(
		.clk(clk),

		.GSR(GSR),
		.CE(CE),
		.SR(SR),

		.A_61(A_61_reg),
		.B_61(B_61_reg),
		.C_61(C_61_reg),
		.D_61(D_61_reg),

		.AX(AX_reg),
		.BX(BX_reg),
		.CX(CX_reg),
		.DX(DX_reg),
		
		.A(A_temp),
		.B(B_temp),
		.C(C_temp),
		.D(D_temp),

		.AQ(AQ_temp),
		.BQ(BQ_temp),
		.CQ(CQ_temp),
		.DQ(DQ_temp),

		.AMUX(AMUX_temp),
		.BMUX(BMUX_temp),
		.CMUX(CMUX_temp),
		.DMUX(DMUX_temp),

		.CIN(CIN_reg),
		.COUT(COUT_temp),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_out)
	);


endmodule 
