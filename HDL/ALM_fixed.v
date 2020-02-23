// This file represent an fixer on top of ALM.v

module ALM_fixed (
		input clk,
		
		input clear_async,
		
		input clear_sync_0,
		input clear_sync_1,
		input clk_en_0,
		input clk_en_1,

		input DataA,
		input DataB,

		input DataC0,
		input DataC1,
		
		input DataD0,
		input DataD1,

		input DataE,
		input DataF,

		input carry_in,
		output reg carry_out,

		output reg out_0,
		output reg out_1,
		output reg out_2,
		output reg out_3,

		input config_clk,
		input config_in,
		input config_en,
		output config_out
	);
	
	////////////////////////////
	// parameters
	////////////////////////////
	parameter param_XOR6_en = 1'b0;
	parameter param_MajAdd_en = 1'b0;
	parameter param_fixed = 1'b1;


	// registers 
	wire out_0_temp;
	wire out_1_temp;
	wire out_2_temp;
	wire out_3_temp;

	wire carry_out_temp;

	reg DataA_reg;
	reg DataB_reg;
	reg DataC0_reg;
	reg DataC1_reg;
	reg DataD0_reg;
	reg DataD1_reg;
	reg DataE_reg;
	reg DataF_reg;

	reg carry_in_reg;

	reg clear_sync_0_reg;
	reg clear_sync_1_reg;
	reg clk_en_0_reg;
	reg clk_en_1_reg;

	always @ (posedge clk)begin
		out_0 <= out_0_temp;
		out_1 <= out_1_temp;
		out_2 <= out_2_temp;
		out_3 <= out_3_temp;

		DataA_reg <= DataA;
		DataB_reg <= DataB;
		DataC0_reg <= DataC0;
		DataC1_reg <= DataC1;
		DataD0_reg <= DataD0;
		DataD1_reg <= DataD1;
		DataE_reg <= DataE;
		DataF_reg <= DataF;

		carry_in_reg <= carry_in;
		carry_out <= carry_out_temp;

		clear_sync_0_reg <= clear_sync_0;
		clear_sync_1_reg <= clear_sync_1;
		clk_en_0_reg <= clk_en_0;
		clk_en_1_reg <= clk_en_1;
	end

	defparam ALM_inst.param_XOR6_en = param_XOR6_en;
	defparam ALM_inst.param_MajAdd_en = param_MajAdd_en;
	defparam ALM_inst.param_fixed = param_fixed;
	ALM 	ALM_inst(
		.clk(clk),
		
		.clear_async(clear_async),
		
		.clear_sync_0(clear_sync_0_reg),
		.clear_sync_1(clear_sync_1_reg),
		.clk_en_0(clk_en_0_reg),
		.clk_en_1(clk_en_1_reg),

		.DataA(DataA_reg),
		.DataB(DataB_reg),
		.DataC0(DataC0_reg),
		.DataC1(DataC1_reg),
		.DataD0(DataD0_reg),
		.DataD1(DataD1_reg),
		.DataE(DataE_reg),
		.DataF(DataF_reg),

		.carry_in(carry_in_reg),
		.carry_out(carry_out_temp),

		.out_0(out_0_temp),
		.out_1(out_1_temp),
		.out_2(out_2_temp),
		.out_3(out_3_temp),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_out)
	);

endmodule
