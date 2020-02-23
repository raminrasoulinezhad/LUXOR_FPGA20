// This module is designed to verify the ALM.v implementation
// Source(file handeling):	https://stackoverflow.com/questions/16630319/how-to-read-a-text-file-line-by-line-in-verilog
`define NULL 0 

module ALM_tb();
	
	parameter param_XOR6_en = 1'b1;
	parameter param_MajAdd_en = 1'b0;
	parameter param_fixed = 1'b1;

	parameter bitstream_size = 86 + (param_XOR6_en | param_MajAdd_en) + param_MajAdd_en;


	// integers (file)
	integer data_file; // file handler
	reg [bitstream_size-1:0] captured_data;
	   
	// file handler 
	initial begin
		data_file = $fopen("./../bitstream.bst", "r");
		if (data_file == `NULL) begin
		  	$display("data_file handle was NULL");
		  	$stop;
		end
		$fscanf(data_file, "%b\n", captured_data); 
	end


	// register and wires
	reg clk; 
	reg clear_async;
	reg clear_sync_0;
	reg clear_sync_1;
	reg clk_en_0;
	reg clk_en_1;

	reg DataA;
	reg DataB;
	reg DataC0;
	reg DataC1;
	reg DataD0;
	reg DataD1;
	reg DataE;
	reg DataF;

	reg carry_in;
	

	wire carry_out;

	wire out_0;
	wire out_1;
	wire out_2;
	wire out_3;

	reg config_clk;
	reg config_in;
	reg config_en;
	wire config_out;

	// clock generators
	initial begin
		clk = 1'b0;
		forever #5 clk = ~clk;
	end
	initial begin
		config_clk = 1'b0;
		forever #5 config_clk = ~config_clk;
	end

	// initialization of the inputs 
	initial begin
		clear_async = 1'b0;
		clear_sync_0 = 1'b0;
		clear_sync_1 = 1'b0;
		clk_en_0 = 1'b1;
		clk_en_1 = 1'b1;

		DataA = 1'b0;
		DataB = 1'b0;
		DataC0 = 1'b0;
		DataC1 = 1'b0;
		DataD0 = 1'b0;
		DataD1 = 1'b0;
		DataE = 1'b0;
		DataF = 1'b0;

		carry_in = 1'b0;
		config_in = 1'b0;
		config_en = 1'b0;
	end

	

	integer counter;
	// Test bench senario
	initial begin 
		// to reset the output registers
		clear_async = 1'b1;
		@(posedge clk)
		clear_async = 1'b0;

		// to configure the ALM using bitstream
		for (counter = bitstream_size-1; counter >= 0; counter = counter - 1) begin 
			@(posedge clk)
			#1
			config_en = 1'b1;
			config_in = captured_data[counter];
		end
		@(posedge clk)
		config_en = 1'b0;
		config_in = 1'b0;
		

		repeat(100) begin
			@(posedge clk)
			{DataF, DataE, DataD0, DataC0, DataB, DataA} = $random;
			#1
			counter = DataF + DataE + DataD0 + DataC0 + DataB + DataA;
			if ((counter/2)%2 != out_2) begin
				$display("Error. C6:111, 2nd bit is NOT on out_2");
			end
			if ((counter%2) != out_0) begin
				$display("Error. C6:111, 1st bit is NOT on out_0");
			end
		end

		$stop;

	end


	// Designe under test
	defparam ALM_inst.param_XOR6_en = param_XOR6_en;
	defparam ALM_inst.param_MajAdd_en = param_MajAdd_en;
	defparam ALM_inst.param_fixed = param_fixed;
	ALM 	ALM_inst(
		.clk(clk),
		
		.clear_async(clear_async),	

		.clear_sync_0(clear_sync_0),
		.clear_sync_1(clear_sync_1),
		.clk_en_0(clk_en_0),
		.clk_en_1(clk_en_1),

		.DataA(DataA),
		.DataB(DataB),
		
		.DataC0(DataC0),
		.DataC1(DataC1),
		
		.DataD0(DataD0),
		.DataD1(DataD1),

		.DataE(DataE),
		.DataF(DataF),

		.carry_in(carry_in),
		.carry_out(carry_out),

		.out_0(out_0),
		.out_1(out_1),
		.out_2(out_2),
		.out_3(out_3),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_out)
	);

endmodule 

