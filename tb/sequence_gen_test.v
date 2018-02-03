// Module: sequence_gen_test.v
// Created by: Tareque Ahmad
// Modified by: Rehan Iqbal
// Date: January 16th, 2018
//
// Description:	
//
// This is the testbench for the 'sequence_gen' module as part of Lab 1.
// The file has been edited for formatting/indentation, and also adjusts
// the timing of the 'int_order' and 'int_data' signals being applied.
//
// The lab specification states that "both inputs 'data_in' and 'order' must
// be driven on the same cycle when 'load' is asserted in order to be latched
// by the sequence generator." I interpreted this to mean that 'data' and 'order'
// should be sampled on the first rising edge that 'load' is
// high. The original, unedited testbench drove these two signals on the second
// clock edge. The phrasing is ambiguous and no timing diagram was provided,
// so I have modified the testbench to move the assignments to 'int_order' and
// 'int_data' one cycle earlier.
//
// All other lines should be identical to the original copy... just formatting 
// and commenting changes.
//
// NOTE: USE THIS TESTBENCH FILE WITH SEQUENCE_GEN.SV - ORIGINAL FILE WILL NOT WORK
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

`define DATA_WIDTH 64
`define ORDER_WIDTH  16

module sequence_gen_test (

	// Global inputs
	input	clk,
	output	reset_n,

	// Inputs
	input					done,
	input					error,
	input					overflow,
	input [`DATA_WIDTH-1:0]	data_out,

	// Control outputs
	output	load,
	output	fibonacci,
	output	triangle,
	output	clear,

	// Data output
	output [`ORDER_WIDTH-1:0]	order,
	output [`DATA_WIDTH-1:0]	data_in

	);

	parameter RESET_DURATION = 500;
	parameter MAX_ORDER = 80;
	parameter MAX_INIT_VAL = 80;
	parameter INIT_VAL = 8'h1;

	///////////////////////////////
	// Define internal registers //
	///////////////////////////////

	reg						int_reset_n;
	reg						int_load;
	reg						int_fibonacci;
	reg						int_triangle;
	reg						int_clear;
	reg [`ORDER_WIDTH-1:0]	int_order;
	reg [`ORDER_WIDTH-1:0]	order_count;
	reg [`DATA_WIDTH-1:0]	int_data;
	reg [`DATA_WIDTH-1:0]	first_data;
	reg [31:0]				test_seq;
	reg [3:0]				delay;

	initial begin

		/////////////////////////////////////////////
		// Generate one-time internal reset signal //
		/////////////////////////////////////////////

		int_reset_n		= 0;
		int_load		= 0;
		int_fibonacci	= 0;
		int_triangle	= 0;
		int_clear		= 0;
		int_order		= 0;
		int_data		= 8'h00;
		first_data		= INIT_VAL;

		# RESET_DURATION int_reset_n = 1;
		$display ("\n@ %0d ns The chip is out of reset", $time);

		repeat (10) @(posedge clk);

		test_seq = 0;

		//////////////////////////////////////////////
		// Loop to iterate different sequence types //
		//////////////////////////////////////////////

		for  (int seq_type = 0; seq_type < 2; seq_type++) begin

			case (seq_type) 
				
				0 : begin
						$display ("@ %0d ns: Running Triangle sequences", $time);
						int_fibonacci = 0;
						int_triangle = 1;
					end

				1 : begin
						$display ("@ %0d ns: Running Fibonacci sequences", $time);
						int_fibonacci = 1;
						int_triangle = 0;
					end

			endcase

			repeat (MAX_INIT_VAL) begin

				order_count = 0;

				repeat (MAX_ORDER) begin

					test_seq = test_seq + 1;
					order_count = order_count + 1;
					int_load = 1;
					int_order = order_count;
					int_data = first_data;

					repeat (1) @(posedge clk);

					$display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Order= %0d ", $time, test_seq, int_data, int_order);

					while (done == 0) @(posedge clk);

					$display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
					
					int_load = 0;
					int_order = 0;
					int_data = 8'h0;
					delay = ({$random} % 4'hf);

					repeat (delay + 2) @(posedge clk);

				end // repeat (MAX_ORDER)
				
				first_data = first_data + 1;

			end // repeat (MAX_INIT_VAL)

			first_data = INIT_VAL;

			///////////////////////////////////
			// Test error case w/ zero order //
			///////////////////////////////////

			test_seq = test_seq + 1;
			int_load = 1;
			int_order = 0;
			int_data = 1;

			repeat (1) @(posedge clk);

			$display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Order= %0d ", $time, test_seq, int_data, int_order);

			while (error == 0) @(posedge clk);

			$display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
			
			delay = ({$random} % 4'hf);

			repeat (delay + 20) @(posedge clk);

			int_load = 0;
			int_order = 0;
			int_data = 8'h0;
			int_clear = 1;
			delay = ({$random} % 4'hf);

			repeat (delay + 2) @(posedge clk);

			/////////////////////////////////////////////////////////
			// Test to make sure FSM recovers from error condition //
			/////////////////////////////////////////////////////////

			test_seq = test_seq + 1;
			int_clear = 0;
			int_load = 1;
			int_order = 10;
			int_data = 1;

			repeat (1)  @(posedge clk);

			$display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Order= %0d ", $time, test_seq, int_data, int_order);

			while (done == 0) @(posedge clk);

			$display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
			
			int_load = 0;
			int_order = 0;
			int_data = 8'h0;
			delay = ({$random} % 4'hf);

			repeat (delay + 2) @(posedge clk);

			if (seq_type == 1) begin

				//////////////////////////////////
				// Test error case w/ zero data //
				//////////////////////////////////

				test_seq = test_seq+1;
				int_load = 1;
				int_order = 5;
				int_data = 0;

				repeat (1)  @(posedge clk);

				$display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Order= %0d ", $time, test_seq, int_data, int_order);

				while (error == 0) @(posedge clk);

				$display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
				
				delay = ({$random} % 4'hf);
				
				repeat (delay + 20) @(posedge clk);

				int_load = 0;
				int_order = 0;
				int_data = 8'h0;
				int_clear = 1;

				delay = ({$random} % 4'hf);

				repeat (delay + 2) @(posedge clk);

				/////////////////////////////////////////////////////////
				// Test to make sure FSM recovers from error condition //
				/////////////////////////////////////////////////////////

				test_seq = test_seq+1;
				int_clear = 0;
				int_load = 1;
				int_order = 10;
				int_data = 2;

				repeat (1) @(posedge clk);

				$display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Order= %0d ", $time, test_seq, int_data, int_order);

				while (done == 0) @(posedge clk);

				$display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
				
				int_load = 0;
				int_order = 0;
				int_data = 8'h0;
				delay = ({$random} % 4'hf);

				repeat (delay + 2) @(posedge clk);

				///////////////////////////////////////
				// Test  overflow case w/ high order //
				///////////////////////////////////////

				test_seq = test_seq+1;
				int_load = 1;
				int_order = 1500;
				int_data = 1;

				repeat (1)  @(posedge clk);

				$display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Order= %0d ", $time, test_seq, int_data, int_order);

				while (overflow == 0) @(posedge clk);

				repeat (1)  @(posedge clk);

				$display ("@ %0d ns: Result: %h. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
				
				delay = ({$random} % 4'hf);

				repeat (delay+20)  @(posedge clk);

				int_load = 0;
				int_order = 0;
				int_data = 8'h0;
				int_clear = 1;
				delay = ({$random} % 4'hf);

				repeat (delay + 2) @(posedge clk);

				////////////////////////////////////////////////////////////
				// Test to make sure FSM recovers from overflow condition //
				////////////////////////////////////////////////////////////

				test_seq = test_seq+1;
				int_clear = 0;
				int_load = 1;
				int_order = 15;
				int_data = 1;

				repeat (1)  @(posedge clk);

				$display ("@ %0d ns: Test sequence: %0d: Initial data= %0d. Order= %0d ", $time, test_seq, int_data, int_order);

				while (done == 0) @(posedge clk);

				$display ("@ %0d ns: Result: %0d. Overflow bit: %h. Error bit: %h\n", $time, data_out, overflow, error);
				
				int_load = 0;
				int_order = 0;
				int_data = 8'h0;
				delay = ({$random} % 4'hf);

				repeat (delay + 2) @(posedge clk);

			end // Fibonacci overflow / zero data checking 

		end // for loop seq_type

		$finish;

	end // initial block

	/////////////////////////////////////
	// Continuous assignment to output //
	/////////////////////////////////////

	assign reset_n		= int_reset_n;
	assign load			= int_load;
	assign fibonacci	= int_fibonacci;
	assign triangle		= int_triangle;
	assign clear		= int_clear;
	assign order		= int_order;
	assign data_in		= int_data;

endmodule //  sequence_gen_test