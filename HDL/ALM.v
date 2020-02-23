// incompleted points:
//		1- HyperFlex registers

// This file represent an ALM architecture modeled by Stratix-10
// Sources:
//		Brief:		https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/stratix-10/s10-overview.pdf, 	P23
//		Detailed:	https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/stratix-10/ug-s10-lab.pdf, 		P5
//

module ALM (
		input clk,
		
		input clear_async,		//labclr --> aclr (asynchronous)
		
		// the following signals has HeyperFlex registers --> should be implemented in LAB implementations 
		// please loock at "https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/wp/wp-01231-understanding-how-hyperflex-architecture-enables-high-performance-systems.pdf"
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
		output carry_out,

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


	////////////////////////////
	// Wiring
	////////////////////////////
	// Distributed multiplexers
	wire mux_1;
	wire mux_2;
	wire mux_3;
	wire mux_4;
	wire mux_5;
	wire mux_6;
	wire mux_7;
	wire mux_8;
	wire mux_9_old;
	reg mux_9_new;
	wire mux_9;
	wire mux_10;
	reg mux_11;
	wire mux_12;
	wire mux_13;
	wire mux_14_old;
	reg mux_14_new;
	wire mux_14;

	reg mux_controller_1;
	reg mux_controller_2;
	reg mux_controller_3;
	reg mux_controller_4;
	reg mux_controller_5;
	reg mux_controller_9_old;
	reg [1:0] mux_controller_9_new;
	reg [1:0] mux_controller_11;
	reg mux_controller_12;
	reg mux_controller_13;
	reg mux_controller_14_new;

	// LUTs
	wire [3:0] LUT4_0_in;
	wire [3:0] LUT4_1_in;
	wire [3:0] LUT4_2_in;
	wire [3:0] LUT4_3_in;

	wire LUT4_0_out;
	wire LUT4_1_out;
	wire LUT4_2_out;
	wire LUT4_3_out;

	wire config_in_0;
	wire config_in_1;
	wire config_in_2;
	wire config_in_3;

	// FA and carry chain
	wire FA_S_0;
	wire FA_C_0;
	wire FA_S_1;
	wire FA_C_1;

	// Registers
	wire reg_0_in;
	wire reg_1_in;
	wire reg_2_in;
	wire reg_3_in;
	
	wire reg_0_out_reg;
	wire reg_0_out_prereg;
	wire reg_1_out_reg;
	wire reg_1_out_prereg;
	wire reg_2_out_reg;
	wire reg_2_out_prereg;
	wire reg_3_out_reg;
	wire reg_3_out_prereg;

	// output muxs
	reg [2:0] out_0_controller;
	reg [2:0] out_1_controller;
	reg [2:0] out_2_controller;
	reg [2:0] out_3_controller;

	// Extra circuits (modifications)
	wire XOR6;
	wire maj_temp;
	wire MajAdd_S;
	wire MajAdd_C;

	
	////////////////////////////
	// Distributed multiplexers
	////////////////////////////
	assign mux_1 = (mux_controller_1 & (~param_fixed))? mux_12 : DataA;
	assign mux_2 = (mux_controller_2 & (~param_fixed))? mux_13 : DataB;
	assign mux_3 = (mux_controller_3)? DataC1 : DataD0;
	assign mux_4 = (mux_controller_4)? DataD1 : DataC0;
	assign mux_5 = (mux_controller_5)? DataF : DataC1;
	assign mux_6 = (DataE)? LUT4_1_out : LUT4_0_out;
	assign mux_7 = (DataE)? LUT4_3_out : LUT4_2_out;
	assign mux_8 = (mux_5)? LUT4_3_out : LUT4_2_out;

	assign mux_9_old = (mux_controller_9_old)? DataA : FA_S_0;
	always @ (*) begin
		case (mux_controller_9_new)
			2'b00  : mux_9_new = FA_S_0;
			2'b01  : mux_9_new = DataA;
			2'b10  : mux_9_new = (param_XOR6_en)? XOR6 : 1'bx;
			2'b11  : mux_9_new = (param_MajAdd_en)? MajAdd_S : 1'bx;
			default : mux_9_new = 1'bx; 
    	endcase
	end
	assign mux_9 = (param_XOR6_en | param_MajAdd_en) ? mux_9_new : mux_9_old;

	assign mux_10 = (mux_5)? mux_7 : mux_6;
	always @ (*) begin
		case (mux_controller_11)
			2'b00  : mux_11 = mux_10;
			2'b01  : mux_11 = FA_S_1;
			2'b10  : mux_11 = DataB;
			//2'b11  : mux_11 = ;
			default : mux_11 = 1'bx; 
    	endcase
	end
	assign mux_12 = (mux_controller_12)? reg_0_out_reg: reg_0_out_prereg;
	assign mux_13 = (mux_controller_13)? reg_2_out_reg: reg_2_out_prereg;

	assign mux_14_old = mux_8;
	always @ (*) begin
		case (mux_controller_14_new)
			1'b0  : mux_14_new = mux_8;
			1'b1  : mux_14_new = MajAdd_C;
			default : mux_14_new = 1'bx; 
    	endcase
	end
	assign mux_14 = (param_MajAdd_en)? mux_14_new : mux_14_old;


	////////////////////////////
	// LUTs
	////////////////////////////
	assign LUT4_0_in[0] = DataD0;
	assign LUT4_0_in[1] = DataC0;
	assign LUT4_0_in[2] = mux_2;
	assign LUT4_0_in[3] = mux_1;

	assign LUT4_1_in[0] = DataD0;
	assign LUT4_1_in[1] = DataC0;
	assign LUT4_1_in[2] = mux_2;
	assign LUT4_1_in[3] = mux_1;

	assign LUT4_2_in[0] = mux_1;
	assign LUT4_2_in[1] = mux_2;
	assign LUT4_2_in[2] = mux_3;
	assign LUT4_2_in[3] = mux_4;

	assign LUT4_3_in[0] = mux_1;
	assign LUT4_3_in[1] = mux_2;
	assign LUT4_3_in[2] = mux_3;
	assign LUT4_3_in[3] = mux_4;

	defparam LUT_0.K=4;
	LUT LUT_0(
		.in(LUT4_0_in),

		.out(LUT4_0_out),

		.config_clk(config_clk),
		.config_in(config_in),
		.config_en(config_en),
		.config_out(config_in_0)
	);

	defparam LUT_1.K=4;
	LUT LUT_1(
		.in(LUT4_1_in),

		.out(LUT4_1_out),

		.config_clk(config_clk),
		.config_in(config_in_0),
		.config_en(config_en),
		.config_out(config_in_1)
	);

	defparam LUT_2.K=4;
	LUT LUT_2(
		.in(LUT4_2_in),

		.out(LUT4_2_out),

		.config_clk(config_clk),
		.config_in(config_in_1),
		.config_en(config_en),
		.config_out(config_in_2)
	);

	defparam LUT_3.K=4;
	LUT LUT_3(
		.in(LUT4_3_in),

		.out(LUT4_3_out),

		.config_clk(config_clk),
		.config_in(config_in_2),
		.config_en(config_en),
		.config_out(config_in_3)
	);

	////////////////////////////
	// FA and carry chain
	////////////////////////////
	assign {FA_C_0,FA_S_0} = LUT4_0_out + LUT4_1_out + carry_in; 
	assign {FA_C_1,FA_S_1} = LUT4_3_out + LUT4_2_out + FA_C_0; 
	assign carry_out = FA_C_1;

	////////////////////////////
	// Registers 
	////////////////////////////
	assign reg_0_in = mux_9;
	assign reg_1_in = mux_6;
	assign reg_2_in = mux_11;
	assign reg_3_in = mux_14;

	Reg_ALM 	reg_0(
		.clk(clk),
		.clk_en(clk_en_1),

		.data_in(reg_0_in),
		.data_out_prereg(reg_0_out_prereg),
		.data_out_reg(reg_0_out_reg),
		
		.clear_sync(clear_sync_1),
		.clear_async(clear_async)
	);

	Reg_ALM 	reg_1(
		.clk(clk),
		.clk_en(clk_en_1),

		.data_in(reg_1_in),
		.data_out_prereg(reg_1_out_prereg),
		.data_out_reg(reg_1_out_reg),
		
		.clear_sync(clear_sync_1),
		.clear_async(clear_async)
	);

	Reg_ALM 	reg_2(
		.clk(clk),
		.clk_en(clk_en_0),

		.data_in(reg_2_in),
		.data_out_prereg(reg_2_out_prereg),
		.data_out_reg(reg_2_out_reg),
		
		.clear_sync(clear_sync_0),
		.clear_async(clear_async)
	);

	Reg_ALM 	reg_3(
		.clk(clk),
		.clk_en(clk_en_0),

		.data_in(reg_3_in),
		.data_out_prereg(reg_3_out_prereg),
		.data_out_reg(reg_3_out_reg),
		
		.clear_sync(clear_sync_0),
		.clear_async(clear_async)
	);

	////////////////////////////
	// output muxs
	////////////////////////////
	always @ (*) begin
		case (out_0_controller)
			3'b000  : out_0 = reg_1_out_reg;
			3'b001  : out_0 = reg_1_out_prereg;
			3'b010  : out_0 = reg_0_out_prereg;
			3'b011  : out_0 = reg_0_out_reg;
			3'b100  : out_0 = FA_S_0;
			3'b101  : out_0 = mux_6;
			3'b110  : out_0 = mux_10;
			//3'b111  : out_0 = ;
			default : out_0 = 1'bx; 
    	endcase
	end

	always @ (*) begin
		case (out_1_controller)
			3'b000  : out_1 = mux_10;
			3'b001  : out_1 = reg_1_out_prereg;
			3'b010  : out_1 = reg_1_out_reg;
			3'b011  : out_1 = mux_6;
			3'b100  : out_1 = FA_S_0;
			3'b101  : out_1 = reg_0_out_reg;
			3'b110  : out_1 = reg_0_out_prereg;
			//3'b111  : out_1 = ;
			default : out_1 = 1'bx; 
    	endcase
	end

	always @ (*) begin
		case (out_2_controller)
			3'b000  : out_2 = reg_2_out_prereg;
			3'b001  : out_2 = reg_2_out_reg;
			3'b010  : out_2 = FA_S_1;
			3'b011  : out_2 = reg_3_out_prereg;
			3'b100  : out_2 = reg_3_in;
			3'b101  : out_2 = reg_3_out_reg;
			//3'b110  : out_2 = ;
			//3'b111  : out_2 = ;
			default : out_2 = 1'bx; 
    	endcase
	end

	always @ (*) begin
		case (out_3_controller)
			3'b000  : out_3 = reg_2_out_prereg;
			3'b001  : out_3 = reg_3_in;
			3'b010  : out_3 = reg_3_out_reg;
			3'b011  : out_3 = reg_3_out_prereg;
			3'b100  : out_3 = FA_S_1;
			3'b101  : out_3 = reg_2_out_reg;
			//3'b110  : out_3 = ;
			//3'b111  : out_3 = ;
			default : out_3 = 1'bx; 
    	endcase
	end

	////////////////////////////
	// Extra circuits (modifications)
	////////////////////////////
	assign XOR6 = DataA ^ DataB ^ DataC0 ^ DataD0 ^ DataE ^ DataF;

	assign maj_temp = (DataC0 & DataD0) | (DataD0 & DataE) | (DataE & DataC0);
	assign {MajAdd_C,MajAdd_S} = maj_temp + DataC1 + DataD1;



	////////////////////////////
	// Configuration Circuits
	////////////////////////////

	always @ (posedge config_clk) begin
		if (config_en) begin
			mux_controller_1 <= config_in_3;
			mux_controller_2 <= mux_controller_1;
			mux_controller_3 <= mux_controller_2;
			mux_controller_4 <= mux_controller_3;
			mux_controller_5 <= mux_controller_4;
			mux_controller_9_old <= mux_controller_5;
			mux_controller_9_new[0] <= mux_controller_5;
			mux_controller_9_new[1] <= mux_controller_9_new[0];
			mux_controller_11[0] <= (param_XOR6_en | param_MajAdd_en)? mux_controller_9_new[1] : mux_controller_9_old;
			mux_controller_11[1] <= mux_controller_11[0];
			mux_controller_12 <= mux_controller_11[1];
			mux_controller_13 <= mux_controller_12;
			mux_controller_14_new <= mux_controller_13;
			out_0_controller[0] <= (param_MajAdd_en)? mux_controller_14_new : mux_controller_13;
			out_0_controller[2:1] <= out_0_controller[1:0];
			out_1_controller <= {{out_1_controller[1:0]},{out_0_controller[2]}};
			out_2_controller <= {{out_2_controller[1:0]},{out_1_controller[2]}};
			out_3_controller <= {{out_3_controller[1:0]},{out_2_controller[2]}};
		end
	end
	assign config_out = out_3_controller[2];

endmodule
