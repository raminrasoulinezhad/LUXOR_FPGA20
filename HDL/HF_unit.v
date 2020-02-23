// This module is design to model a bypassable register which is used in HyperFlex idea for Intel FPGAs

module HF_unit(
		clk,
		in,
		
		// 1 means that input is registered
		selector,

		out
	);

	// parameter 
	parameter size = 1;

	// input and outputs
	input clk;
	input [size-1:0] in;
	input selector;
	output [size-1:0] out;

	// register implementation
	reg [size-1:0] in_reg;
	always @(posedge clk)begin
		in_reg <= in;
	end

	// multiplexer 
	assign out = (selector)? in_reg : in; 

endmodule 
