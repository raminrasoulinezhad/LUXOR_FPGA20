// This moduel is designed to model a LAB in intel architecture including 10 ALMs in two 5-ALM groups
// It is designed according to 

module LAB (

		input [5:0] Dedicated_lane_LAB_clocks,
		input [6:0] Local_interconnect,

		input [7:0] Data_0,
		input [7:0] Data_1,
		input [7:0] Data_2,
		input [7:0] Data_3,
		input [7:0] Data_4,
		input [7:0] Data_5,
		input [7:0] Data_6,
		input [7:0] Data_7,
		input [7:0] Data_8,
		input [7:0] Data_9,

		output [3:0] out_0,
		output [3:0] out_1,
		output [3:0] out_2,
		output [3:0] out_3,
		output [3:0] out_4,
		output [3:0] out_5,
		output [3:0] out_6,
		output [3:0] out_7,
		output [3:0] out_8,
		output [3:0] out_9,

		input carry_in,
		input carry_in_previous_LAB,
		output carry_out,

		input config_clk,
		input config_in,
		input config_en,
		output config_out
	);

	// parameter 
	parameter param_XOR6_en = 10'b0000000000;
	parameter param_MajAdd_en = 10'b0000000000;
	parameter param_fixed = 10'b0000000000;


	// configurations 
	reg [2:0] mux_controller_0;
	reg [2:0] mux_controller_1;
	reg [2:0] mux_controller_2;
	reg mux_controller_3;
	reg mux_controller_4;
	reg mux_controller_5;
	reg mux_controller_6;
	reg mux_controller_7;
	reg mux_controller_8;
	reg mux_controller_9;
	reg mux_controller_10;
	reg mux_controller_11;
	reg mux_controller_12;
	reg carry_controller_0;
	reg carry_controller_1;

	// wires
	reg mux_0;
	reg mux_1;
	reg mux_2;
	wire mux_3;
	wire mux_4;
	wire mux_5;
	wire mux_6;
	wire mux_7;
	wire mux_8;
	wire mux_9;
	wire mux_10;
	wire mux_11;
	wire mux_12;
	
	// control_signals = clear_sync_0,clk,clk_HF_Controls,clk_HF_Data,clk_en_0,clk_en_1,clear_sync_1,clear_async
	wire [7:0] control_signals;

	wire [9:0] carry_in_temp;
	wire carry_middle;
	wire [9:0] config_in_temp;


	// controller circuits
	always @ (*)begin
		case (mux_controller_0)
			3'b000: mux_0 = Dedicated_lane_LAB_clocks[0];
			3'b001: mux_0 = Dedicated_lane_LAB_clocks[1];
			3'b010: mux_0 = Dedicated_lane_LAB_clocks[2];
			3'b011: mux_0 = Dedicated_lane_LAB_clocks[3];
			3'b100: mux_0 = Dedicated_lane_LAB_clocks[4];
			3'b101: mux_0 = Dedicated_lane_LAB_clocks[5];
			3'b110: mux_0 = Local_interconnect[0];
			3'b111: mux_0 = Local_interconnect[1];
		endcase
	end
	always @ (*)begin
		case (mux_controller_1)
			3'b000: mux_1 = Dedicated_lane_LAB_clocks[0];
			3'b001: mux_1 = Dedicated_lane_LAB_clocks[1];
			3'b010: mux_1 = Dedicated_lane_LAB_clocks[2];
			3'b011: mux_1 = Dedicated_lane_LAB_clocks[3];
			3'b100: mux_1 = Dedicated_lane_LAB_clocks[4];
			3'b101: mux_1 = Dedicated_lane_LAB_clocks[5];
			3'b110: mux_1 = Local_interconnect[0];
			3'b111: mux_1 = Local_interconnect[1];
		endcase
	end
	always @ (*)begin
		case (mux_controller_2)
			3'b000: mux_2 = Dedicated_lane_LAB_clocks[0];
			3'b001: mux_2 = Dedicated_lane_LAB_clocks[1];
			3'b010: mux_2 = Dedicated_lane_LAB_clocks[2];
			3'b011: mux_2 = Dedicated_lane_LAB_clocks[3];
			3'b100: mux_2 = Dedicated_lane_LAB_clocks[4];
			3'b101: mux_2 = Dedicated_lane_LAB_clocks[5];
			3'b110: mux_2 = Local_interconnect[0];
			3'b111: mux_2 = Local_interconnect[1];
		endcase
	end
	assign mux_3 = (mux_controller_3)? Local_interconnect[4] : mux_0;
	assign mux_4 = (mux_controller_4)? Local_interconnect[2] : mux_0;
	assign mux_5 = (mux_controller_5)? (!mux_3) : mux_3;
	assign mux_6 = (mux_controller_6)? (!mux_4) : mux_4;
	assign mux_7 = (mux_controller_7)? (!Local_interconnect[5]) : Local_interconnect[5];
	assign mux_8 = (mux_controller_8)? (!Local_interconnect[3]) : Local_interconnect[3];
	assign mux_9 = (mux_controller_9)? (!mux_2) : mux_2;
	assign mux_10 = (mux_controller_10)? (!mux_1) : mux_1;
	assign mux_11 = (mux_controller_11)? (!mux_0) : mux_0;
	assign mux_12 = (mux_controller_12)? (!Local_interconnect[6]) : Local_interconnect[6];

	// control_signals = clear_sync_0,clk,clk_HF_Controls,clk_HF_Data,clk_en_0,clk_en_1,clear_sync_1,clear_async
	assign control_signals = {{mux_12},{mux_11},{mux_10},{mux_9},{mux_8},{mux_7},{mux_6},{mux_5}};

	assign carry_in_temp[0] = (carry_controller_0)? carry_in : carry_in_previous_LAB;
	assign carry_in_temp[5] = (carry_controller_1)? carry_in : carry_middle;





	// ALM instanciations

	defparam ALM_HF_inst_0.param_XOR6_en = param_XOR6_en[0];
	defparam ALM_HF_inst_0.param_MajAdd_en = param_MajAdd_en[0];
	defparam ALM_HF_inst_0.param_fixed = param_fixed[0];
	ALM_HF	ALM_HF_inst_0(
		.control_signals(control_signals),

		.Data(Data_0),

		.carry_in(carry_in_temp[0]),
		.carry_out(carry_in_temp[1]),

		.out(out_0),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_in_temp[0])
	);
	defparam ALM_HF_inst_1.param_XOR6_en = param_XOR6_en[1];
	defparam ALM_HF_inst_1.param_MajAdd_en = param_MajAdd_en[1];
	defparam ALM_HF_inst_1.param_fixed = param_fixed[1];
	ALM_HF	ALM_HF_inst_1(
		.control_signals(control_signals),

		.Data(Data_1),

		.carry_in(carry_in_temp[1]),
		.carry_out(carry_in_temp[2]),

		.out(out_1),

		.config_clk(config_clk),
		.config_in(config_in_temp[0]),
		.config_en(config_en),
		.config_out(config_in_temp[1])
	);
	defparam ALM_HF_inst_2.param_XOR6_en = param_XOR6_en[2];
	defparam ALM_HF_inst_2.param_MajAdd_en = param_MajAdd_en[2];
	defparam ALM_HF_inst_2.param_fixed = param_fixed[2];
	ALM_HF	ALM_HF_inst_2(
		.control_signals(control_signals),

		.Data(Data_2),

		.carry_in(carry_in_temp[2]),
		.carry_out(carry_in_temp[3]),

		.out(out_2),

		.config_clk(config_clk),
		.config_in(config_in_temp[1]),
		.config_en(config_en),
		.config_out(config_in_temp[2])
	);
	defparam ALM_HF_inst_3.param_XOR6_en = param_XOR6_en[3];
	defparam ALM_HF_inst_3.param_MajAdd_en = param_MajAdd_en[3];
	defparam ALM_HF_inst_3.param_fixed = param_fixed[3];
	ALM_HF	ALM_HF_inst_3(
		.control_signals(control_signals),

		.Data(Data_3),

		.carry_in(carry_in_temp[3]),
		.carry_out(carry_in_temp[4]),

		.out(out_3),

		.config_clk(config_clk),
		.config_in(config_in_temp[2]),
		.config_en(config_en),
		.config_out(config_in_temp[3])
	);
	defparam ALM_HF_inst_4.param_XOR6_en = param_XOR6_en[4];
	defparam ALM_HF_inst_4.param_MajAdd_en = param_MajAdd_en[4];
	defparam ALM_HF_inst_4.param_fixed = param_fixed[4];
	ALM_HF	ALM_HF_inst_4(
		.control_signals(control_signals),

		.Data(Data_4),

		.carry_in(carry_in_temp[4]),
		.carry_out(carry_middle),

		.out(out_4),

		.config_clk(config_clk),
		.config_in(config_in_temp[3]),
		.config_en(config_en),
		.config_out(config_in_temp[4])
	);




	defparam ALM_HF_inst_5.param_XOR6_en = param_XOR6_en[5];
	defparam ALM_HF_inst_5.param_MajAdd_en = param_MajAdd_en[5];
	defparam ALM_HF_inst_5.param_fixed = param_fixed[5];
	ALM_HF	ALM_HF_inst_5(
		.control_signals(control_signals),

		.Data(Data_5),

		.carry_in(carry_in_temp[5]),
		.carry_out(carry_in_temp[6]),

		.out(out_5),

		.config_clk(config_clk),
		.config_in(config_in_temp[4]),
		.config_en(config_en),
		.config_out(config_in_temp[5])
	);
	defparam ALM_HF_inst_6.param_XOR6_en = param_XOR6_en[6];
	defparam ALM_HF_inst_6.param_MajAdd_en = param_MajAdd_en[6];
	defparam ALM_HF_inst_6.param_fixed = param_fixed[6];
	ALM_HF	ALM_HF_inst_6(
		.control_signals(control_signals),

		.Data(Data_6),

		.carry_in(carry_in_temp[6]),
		.carry_out(carry_in_temp[7]),

		.out(out_6),

		.config_clk(config_clk),
		.config_in(config_in_temp[5]),
		.config_en(config_en),
		.config_out(config_in_temp[6])
	);
	defparam ALM_HF_inst_7.param_XOR6_en = param_XOR6_en[7];
	defparam ALM_HF_inst_7.param_MajAdd_en = param_MajAdd_en[7];
	defparam ALM_HF_inst_7.param_fixed = param_fixed[7];
	ALM_HF	ALM_HF_inst_7(
		.control_signals(control_signals),

		.Data(Data_7),

		.carry_in(carry_in_temp[7]),
		.carry_out(carry_in_temp[8]),

		.out(out_7),

		.config_clk(config_clk),
		.config_in(config_in_temp[6]),
		.config_en(config_en),
		.config_out(config_in_temp[7])
	);
	defparam ALM_HF_inst_8.param_XOR6_en = param_XOR6_en[8];
	defparam ALM_HF_inst_8.param_MajAdd_en = param_MajAdd_en[8];
	defparam ALM_HF_inst_8.param_fixed = param_fixed[8];
	ALM_HF	ALM_HF_inst_8(
		.control_signals(control_signals),

		.Data(Data_8),

		.carry_in(carry_in_temp[8]),
		.carry_out(carry_in_temp[9]),

		.out(out_8),

		.config_clk(config_clk),
		.config_in(config_in_temp[7]),
		.config_en(config_en),
		.config_out(config_in_temp[8])
	);
	defparam ALM_HF_inst_9.param_XOR6_en = param_XOR6_en[9];
	defparam ALM_HF_inst_9.param_MajAdd_en = param_MajAdd_en[9];
	defparam ALM_HF_inst_9.param_fixed = param_fixed[9];
	ALM_HF	ALM_HF_inst_9(
		.control_signals(control_signals),

		.Data(Data_9),

		.carry_in(carry_in_temp[9]),
		.carry_out(carry_out),

		.out(out_9),

		.config_clk(config_clk),
		.config_in(config_in_temp[8]),
		.config_en(config_en),
		.config_out(config_in_temp[9])
	);

	always @(posedge config_clk)begin
		if (config_en)begin
			mux_controller_0 <= {{mux_controller_0[1:0]},{config_in_temp[9]}};
			mux_controller_1 <= {{mux_controller_1[1:0]},{mux_controller_0[2]}};
			mux_controller_2 <= {{mux_controller_2[1:0]},{mux_controller_1[2]}};
			mux_controller_3 <= mux_controller_2[2];
			mux_controller_4 <= mux_controller_3;
			mux_controller_5 <= mux_controller_4;
			mux_controller_6 <= mux_controller_5;
			mux_controller_7 <= mux_controller_6;
			mux_controller_8 <= mux_controller_7;
			mux_controller_9 <= mux_controller_8;
			mux_controller_10 <= mux_controller_9;
			mux_controller_11 <= mux_controller_10;
			mux_controller_12 <= mux_controller_11;
			carry_controller_0 <= mux_controller_12;
			carry_controller_1 <= carry_controller_0;
		end
	end

	assign config_out = carry_controller_1;

endmodule 
