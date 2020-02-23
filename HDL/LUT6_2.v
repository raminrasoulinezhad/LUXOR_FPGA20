// This module models the Xilinx LUT6_2 block including two 5-input LUTs which shares the inputs and to generate O6 and O5 as two port outputs

module LUT6_2 (
		input [5:0] in,
		output O6,
		output O5,

		input config_clk,
		input config_in,
		input config_en,
		output config_out	
	);

	// wires
	wire LUT5_1_out;
	wire LUT5_2_out;

	wire config_in_temp;

	// instanciation of 5-input LUTs
	defparam LUT5_1.K = 5;
	LUT LUT5_1(
		.in(in[4:0]),
		.out(LUT5_1_out),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_in_temp)
	);

	defparam LUT5_2.K = 5;
	LUT LUT5_2(
		.in(in[4:0]),
		.out(LUT5_2_out),

		.config_clk(config_clk),
		.config_in(config_in_temp),
		.config_en(config_en),
		.config_out(config_out)
	);

	assign O6 = (in[5])? LUT5_2_out : LUT5_1_out;
	assign O5 = LUT5_1_out;
	
endmodule
