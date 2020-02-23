// This module tester is designed to check the functionality of LATDFF module which include (A)Syncronous Latch and DFF 
module LATDFF_tb();
	
	reg clk;
	
	reg GSR;

	reg CE;
	reg D;
	reg SR;

	reg SYNCASYNC_01;
	reg FFLAT_01;
	reg INIT01;
	reg SRHILO;

	wire Q;

	initial begin
		clk = 1'b0;
		forever begin
			#10 clk = !clk;
		end
	end
	initial begin
		CE = 1'b0;
		#1
		forever begin
			#20 CE = !CE;
		end
	end
	initial begin
		D = 1'b0;
		#2
		forever begin
			#30 D = !D;
		end
	end
	initial begin
		SR = 1'b0;
		#3
		forever begin
			#40 SR = !SR;
		end
	end

	// to check the different modes please check the all four combination of the two following signals:
	// SYNCASYNC_01 and FFLAT_01
	initial begin
		SYNCASYNC_01 = 1'b0;
		//#4
		//forever begin
		//	#50 SYNCASYNC_01 = !SYNCASYNC_01;
		//end
	end
	initial begin
		FFLAT_01 = 1'b0;
		//#5
		//forever begin
		//	#60 FFLAT_01 = !FFLAT_01;
		//end
	end



	initial begin
		INIT01 = 1'b0;
		#6
		forever begin
			#70 INIT01 = !INIT01;
		end
	end
	initial begin
		SRHILO = 1'b0;
		#7
		forever begin
			#80 SRHILO = !SRHILO;
		end
	end
	initial begin
		GSR = 1'b0;
		#8
		forever begin
			#90 GSR = !GSR;
		end
	end

	// Design under the test instanciation
	LATDFF 	LATDFF_inst(
		.clk(clk),

		.GSR(GSR),

		.CE(CE),
		.D(D),
		.SR(SR),

		.SYNCASYNC_01(SYNCASYNC_01),
		.FFLAT_01(FFLAT_01),
		.INIT01(INIT01),
		.SRHILO(SRHILO),

		.Q(Q)
	);


endmodule 