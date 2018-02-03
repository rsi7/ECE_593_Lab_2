// Module: seq_gen_chkr.sv
// Author: Rehan Iqbal
// Date: February 1st, 2018
// Organization: Portland State University
//
// Description:
//
// This module acts as a checker for 'sequence_gen.sv' and the associated
// testbench 'sequence_gen_test_lab2.v'. There are 7 checker rules,
// each of which can be manually disabled by passing the appropriate
// parameter into the checker module (which is instantiated in 'top_hdl').
//
// Bugs have been deliberately introduced into 'sequence_gen.sv' to demonstrate
// the rules in action. These are hardware threads rather than SystemVerilog
// assertions (intentional). Disabling the checker's rules will cause
// simulation to pass.
//
// Checker rules:
//
// 1) When 'reset_n' is asserted (goes to 0), all outputs become 0 within 1 cycle
//
// 2) When 'load' is asserted, valid 'data_in' and 'order' must be driven
// on the same cycle (no X or Z signals)
//
// 3) When 'load' is asserted, one and only one of 'fibonacci' and 'triangle'
// must be driven on the same cycle
//
// 4) Once 'done' is asserted, 'data_out' must be correct on the same cycle
//
// 5) Once 'overflow' is asserted, 'data_out' must be all 1's on the same cycle
//
// 6) Once 'error' is asserted, 'data_out' must be all X's on the same cycle
//
// 7) Unless it's error or overflow condition, 'done' and correct 'data_out'
// must show up on the output <order+2> cycles after 'load' is asserted
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"
`timescale 1ns/1ps


module seq_gen_chkr (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	// inputs to 'sequence_gen' module

	input	ulogic1		clk,		// I [0] clock signal
	input	ulogic1		reset_n,	// I [0] active-low reset

	input	ulogic1		fibonacci,	// I [0] mode: perform fibonacci calculation
	input	ulogic1		triangle,	// I [0] mode: perform triangle calculation
	
	input	ulogic1		load,		// I [0] active (2 cycles) --> load data into FSM
	input	ulogic1		clear,		// I [0] clear results off 'data_out' bus

	input	ulogic16	order,		// I [15:0] calculate the Nth value of the sequence
	input	ulogic64	data_in,	// I [63:0] initial value of the sequence

	// outputs from 'sequence_gen' module

	input	ulogic1		done,		// O [0] active (1 cycle) --> data is ready
	input	ulogic64	data_out,	// O [63:0] calculated value of the sequence
	input	ulogic1		overflow,	// O [0] calculation exceeds bus max
	input	ulogic1		error		// O [0] indicates bad control input or bad data

	);

	/*************************************************************************/
	/* Parameters and variables												 */
	/*************************************************************************/

	parameter	CHKR_RULE_1 = 1'b0;
	parameter	CHKR_RULE_2 = 1'b0;
	parameter	CHKR_RULE_3 = 1'b0;
	parameter	CHKR_RULE_4 = 1'b0;
	parameter	CHKR_RULE_5 = 1'b0;
	parameter	CHKR_RULE_6 = 1'b0;
	parameter	CHKR_RULE_7 = 1'b0;

	parameter	CLK_CYCLE = 10;

	/*************************************************************************/
	/* Checker Rule #1														 */
	/*************************************************************************/

	// When 'reset_n' is asserted (goes to 0), all outputs become 0 within 1 cycle

	always@(negedge reset_n) begin

		if (CHKR_RULE_1) begin

			// synchronize 'reset_n' to clock
			@(posedge clk);

			// wait a half-cycle for combinational logic to propagate
			#(0.5*CLK_CYCLE);

			// check all four outputs are zero
			if ((!done) && (!overflow) && (!error) && (~|data_out)) begin
				$display("@ %0d ns: Checker Rule #1 Pass: Outputs cleared within 1 cycle of reset!",$time);
			end

			else begin
				$display("@ %0d ns: Checker Rule #1 Fail: Outputs not cleared within 1 cycle of reset!", $time);
			end

		end // CHKR_RULE_1

	end // always@(negedge reset_n)

	/*************************************************************************/
	/* Checker Rule #2														 */
	/*************************************************************************/

	// When 'load' is asserted, valid 'data_in' and 'order' must be driven
	// on the same cycle (no X or Z signals)

	always@(posedge load) begin

		if (CHKR_RULE_2) begin

			// synchronize 'load' to clock'
			@(posedge clk);

			// wait a half-cycle for combinational logic to propagate
			#(0.5*CLK_CYCLE);

			// check for X or Z bits with reduction XOR operator
			if ((^data_in === 1'bx) || (^order === 1'bx)) begin
				$display("@ %0d ns: Checker Rule #2 Fail: Unknown bits (x or z) on input busses!",$time);
			end

			else begin
				$display("@ %0d ns: Checker Rule #2 Pass: Valid bits (1's and 0's) on input busses!",$time);
			end

		end // CHKR_RULE_2

	end // always@(posedge load)

	/*************************************************************************/
	/* Checker Rule #3														 */
	/*************************************************************************/

	// When 'load' is asserted, one and only one of 'fibonacci' and 'triangle'
	// must be driven on the same cycle

	always@(posedge load) begin

		if (CHKR_RULE_3) begin

			// wait a half-cycle for combinational logic to propagate
			#(0.5*CLK_CYCLE);

			// check fibonacci xor triangle is asserted
			if (fibonacci ^ triangle) begin
				$display("@ %0d ns: Checker Rule #3 Pass: Input 'mode' correctly applied!",$time);
			end

			else begin
				$display("@ %0d ns: Checker Rule #3 Fail: Input 'mode' not correctly applied!", $time);
			end

		end // CHKR_RULE_3

	end // always@(posedge load)

	/*************************************************************************/
	/* Checker Rule #4														 */
	/*************************************************************************/

	// Once 'done' is asserted, 'data_out' must be correct on the same cycle

	always@(posedge done) begin

		if (CHKR_RULE_4) begin

			// wait a half-cycle for combinational logic to propagate
			#(0.5*CLK_CYCLE);

			// check if 'data_out' is non-zero
			if (|data_out) begin
				$display("@ %0d ns: Checker Rule #4 Pass: Output data is non-zero after calculation!",$time);
			end

			else begin
				$display("@ %0d ns: Checker Rule #4 Fail: Output data is zero after calculation!",$time);
			end

		end // CHKR_RULE_4

	end // always@(posedge done)

	/*************************************************************************/
	/* Checker Rule #5														 */
	/*************************************************************************/
	
	// Once 'overflow' is asserted, 'data_out' must be all 1's on the same cycle

	always@(posedge overflow) begin

		if (CHKR_RULE_5) begin

			// wait a half-cycle for combinational logic to propagate
			#(0.5*CLK_CYCLE);

			if (&data_out) begin
				$display("@ %0d ns: Checker Rule #5 Pass: Overflow sets 'data_out' to all 1's!",$time);
			end

			else begin
				$display("@ %0d ns: Checker Rule #5 Fail: Overflow did not set 'data_out' to all 1's!",$time);
			end

		end // CHKR_RULE_5

	end // always@(posedge overflow)

	/*************************************************************************/
	/* Checker Rule #6														 */
	/*************************************************************************/

	// Once 'error' is asserted, 'data_out' must be all X's on the same cycle

	always@(posedge error) begin

		if (CHKR_RULE_6) begin

			// wait a half-cycle for combinational logic to propagate
			#(0.5*CLK_CYCLE);

			// check for unknown results in reduction OR and NOR
			if ((|data_out === 1'bx) && (~|data_out === 1'bx)) begin
				$display("@ %0d ns: Checker Rule #6 Pass: Error creates 'x' bits on 'data_out' bus!",$time);
			end

			else begin
				$display("@ %0d ns: Checker Rule #6 Fail: Error did not create 'x' bits on 'data_out' bus!",$time);
			end

		end // CHKR_RULE_6

	end // always@(posedge error)

	/*************************************************************************/
	/* Checker Rule #7														 */
	/*************************************************************************/
	
	// Unless it's error or overflow condition, 'done' and correct 'data_out'
	// must show up on the output <order+2> cycles after 'load' is asserted

	always@(posedge load) begin

		if (CHKR_RULE_7) begin

			// synchronize 'load' to clock
			@(posedge clk);

			// wait a half-cycle for combinational logic to propagate
			#(0.5*CLK_CYCLE);

			fork: check_output_timing

				// running two parallel hardware threads and see which finishes first
				// winner will disable the losing thread
				begin: cycle_counter
					repeat (order+3) @(posedge clk);
					#(0.5*CLK_CYCLE);
					$display("@ %0d ns: Checker Rule #7 Fail: 'data_out' not asserted within <order+2> cycles of input!",$time);
					disable check_for_results;
				end

				begin: check_for_results
					@(data_out);
					$display("@ %0d ns: Checker Rule #7 Pass: 'data_out' asserted within <order+2> cycles of input!",$time);
					disable cycle_counter;
				end

			join: check_output_timing

		end // CHKR_RULE_7

	end // always@(posedge load)

endmodule // seq_gen_chkr