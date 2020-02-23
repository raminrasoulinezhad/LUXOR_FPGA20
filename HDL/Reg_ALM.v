// This file modeled Stratix-10 ALM registers according to 
// https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/stratix-10/ug-s10-lab.pdf, 10 

module Reg_ALM (
		input clk,
		input clk_en,

		input data_in,
		output data_out_prereg,
		output reg data_out_reg,
		
		input clear_sync,
		input clear_async
	);

	wire data_in_clr;
	wire data_in_clr_en; 
	
	always @ (posedge clk, posedge clear_async) begin
		if (clear_async) begin 
			data_out_reg <= 1'b0;
		end
		else begin 
			data_out_reg <= data_in_clr_en;
		end
	end

	assign data_in_clr = data_in & (~clear_sync);
	assign data_in_clr_en = (clk_en == 1'b1)? data_in_clr: data_out_reg;
	assign data_out_prereg = data_in_clr_en;

endmodule
