// This file is modeling a K-input logical LUT (it is not a MLAB LUT)
module LUT (
		in,
		out,

		config_clk,
		config_in,
		config_en,
		config_out
	);

	// parameters
	parameter K = 4;
	parameter reg_size = 2 ** K;

	input [K-1:0] in;
	output reg out;

	input config_clk;
	input config_in;
	input config_en;
	output config_out;

	// configuration registers
	reg [reg_size-1:0] LUT_reg;
	always @(posedge config_clk)begin
		if(config_en)begin
			LUT_reg <= {{LUT_reg[reg_size-2:0]},{config_in}};
		end
	end

	assign config_out = LUT_reg[reg_size-1];

	// LUT functionality
	always @(*)begin
		out = LUT_reg[in];
	end

endmodule
