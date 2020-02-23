// This module is designed to model ALM and it's hyperflex registers. ALM model is just instanciated from ALM.v 
// This file is prepared according to the "Intel® Stratix® 10 Logic Array Blocks and Adaptive Logic Modules User Guide", UG-S10-Lab-2018.09.21 and "Intel Stratix 10 GX/SX Device Overview"

module ALM_HF(
		// control_signals = clear_sync_0,clk,clk_HF_Controls,clk_HF_Data,clk_en_0,clk_en_1,clear_sync_1,clear_async
		input [7:0] control_signals,

		// Data = {{DataF},{DataE},{DataD1},{DataD0},{DataC1},{DataC0},{DataB},{DataA}};
		input [7:0] Data,

		input carry_in,
		output carry_out,

		// out = {{out_3},{out_2},{out_1},{out_0}};
		output [3:0] out,

		input config_clk,
		input config_in,
		input config_en,
		output config_out
	);

	// Parameters
	parameter param_XOR6_en = 1'b0;
	parameter param_MajAdd_en = 1'b0;
	parameter param_fixed = 1'b0;

	// Configuration bits 
	reg HF_unit_selector_Data;

	reg HF_unit_selector_clear_sync_0;
	reg HF_unit_selector_clear_sync_1;
	reg HF_unit_selector_clk_en_0;
	reg HF_unit_selector_clk_en_1;

	// configuration wires 
	wire config_out_local;


	// wires 
	wire [7:0] Data_local;
	wire clear_sync_0_local;
	wire clear_sync_1_local;
	wire clk_en_0_local;
	wire clk_en_1_local;


	wire clk;
	wire clk_HF_Data;
	wire clk_HF_Controls;
	wire clear_async;
	wire clear_sync_0;
	wire clear_sync_1;
	wire clk_en_0;
	wire clk_en_1;



	// control_signals wirings, page 9 (LSB is on the right of the figure)
	// control_signals = clear_sync_0,clk,clk_HF_Controls,clk_HF_Data,clk_en_0,clk_en_1,clear_sync_1,clear_async
	assign clk = control_signals[6];
	assign clk_HF_Data = control_signals[4];
	assign clk_HF_Controls = control_signals[5];
	assign clear_async = control_signals[0];
	assign clear_sync_0 = control_signals[7];
	assign clear_sync_1 = control_signals[1];
	assign clk_en_0 = control_signals[3];
	assign clk_en_1 = control_signals[2];



	// HF on ALM inputs 
	defparam HF_unit_Data.size = 8;
	HF_unit		HF_unit_Data(
		.clk(clk_HF_Data),
		.in(Data),
		.selector(HF_unit_selector_Data),
		.out(Data_local)
	);

	// HF on Control signals
	HF_unit		HF_unit_clear_sync_0(
		.clk(clk_HF_Controls),
		.in(clear_sync_0),
		.selector(HF_unit_selector_clear_sync_0),
		.out(clear_sync_0_local)
	);
	HF_unit		HF_unit_clear_sync_1(
		.clk(clk_HF_Controls),
		.in(clear_sync_1),
		.selector(HF_unit_selector_clear_sync_1),
		.out(clear_sync_1_local)
	);
	HF_unit		HF_unit_clk_en_0(
		.clk(clk_HF_Controls),
		.in(clk_en_0),
		.selector(HF_unit_selector_clk_en_0),
		.out(clk_en_0_local)
	);
	HF_unit		HF_unit_clk_en_1(
		.clk(clk_HF_Controls),
		.in(clk_en_1),
		.selector(HF_unit_selector_clk_en_1),
		.out(clk_en_1_local)
	);


	// ALM instanciation 
	defparam ALM_inst.param_XOR6_en = param_XOR6_en;
	defparam ALM_inst.param_MajAdd_en = param_MajAdd_en;
	defparam ALM_inst.param_fixed = param_fixed;
	ALM 	ALM_inst(
		.clk(clk),
		
		.clear_async(clear_async),		
		
		.clear_sync_0(clear_sync_0_local),
		.clear_sync_1(clear_sync_1_local),
		.clk_en_0(clk_en_0_local),
		.clk_en_1(clk_en_1_local),

		.DataA(Data_local[0]),
		.DataB(Data_local[1]),

		.DataC0(Data_local[2]),
		.DataC1(Data_local[3]),
		
		.DataD0(Data_local[4]),
		.DataD1(Data_local[5]),

		.DataE(Data_local[6]),
		.DataF(Data_local[7]),

		.carry_in(carry_in),
		.carry_out(carry_out),

		.out_0(out[0]),
		.out_1(out[1]),
		.out_2(out[2]),
		.out_3(out[3]),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_out_local)
	);

	always @(posedge config_clk)begin
		if (config_en)begin
			HF_unit_selector_Data <= config_out_local;
			HF_unit_selector_clear_sync_0 <= HF_unit_selector_Data;
			HF_unit_selector_clear_sync_1 <= HF_unit_selector_clear_sync_0;
			HF_unit_selector_clk_en_0 <= HF_unit_selector_clear_sync_1;
			HF_unit_selector_clk_en_1 <= HF_unit_selector_clk_en_0;
		end
	end
	assign config_out = HF_unit_selector_clk_en_1; 

endmodule
