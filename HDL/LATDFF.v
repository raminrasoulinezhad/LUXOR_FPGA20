// This file models the LATCH/DFF component in the Xilinx Slices

module LATDFF (
		input clk,

		input GSR,

		input CE,
		input D,
		input SR,

		input SYNCASYNC_01,
		input FFLAT_01,
		input INIT01,
		input SRHILO,

		output Q
	);

	// parameter 
	parameter param_force_async = 1'b0;
	parameter param_force_sync = 1'b0;
	
	// registers
	reg reg_latch;
	reg reg_ff;

	// wires 
	wire reset_async;
	reg SYNCASYNC_01_local; 

	// SYNCASYNC_01_local
	always @(*)begin
		case ({{param_force_async},{param_force_sync}})
			2'b00  : SYNCASYNC_01_local = SYNCASYNC_01;
			2'b01  : SYNCASYNC_01_local = 1'b0;
			2'b10  : SYNCASYNC_01_local = 1'b1;
			2'b11  : SYNCASYNC_01_local = SYNCASYNC_01;
			default : SYNCASYNC_01_local = SYNCASYNC_01; 
		endcase
	end

	// Latch Sync/Async section
	always@(*) begin
		if (GSR) begin 
			reg_latch = INIT01;
		end 
		else begin 
			if (SYNCASYNC_01_local) begin
				// it is Async 
				if (SR) begin
					reg_latch = SRHILO;
				end
				else if (clk) begin
					if (CE) begin
						reg_latch = D;
					end
				end 
			end 
			else begin
				// it is Sync 
				if (clk) begin
					if (SR) begin
						reg_latch = SRHILO;	
					end
					else if (CE) begin
						reg_latch = D;
					end
				end 
			end
		end
	end

	// there is an issue:
	// if GSR is asserted and INIT01 is changed? The output value (Q) will not update up to the next trigger of the clk
	// So, to deal with that (GSR & INIT01) | (GSR & !INIT01) should be placed instead of GSR in the reset_async calculation to triger the always block for each transition on INIT01 
	assign reset_async = (GSR | (SYNCASYNC_01_local & SR));

	// DFF Sync/Async section
	always @(posedge clk, posedge reset_async)begin
		if (reset_async) begin
			if (GSR) begin
				reg_ff <= INIT01;
			end 
			else if (SYNCASYNC_01_local & SR) begin
				reg_ff <= SRHILO;
			end
		end
		else begin
			if ((!SYNCASYNC_01_local) & SR) begin
				reg_ff <= SRHILO;
			end
			else if (CE) begin
				reg_ff <= D;
			end
		end
	end

	assign Q = (FFLAT_01)? reg_latch : reg_ff;

endmodule 
