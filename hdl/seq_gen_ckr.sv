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
// 1) When 'reset_n' is asserted (goes to 0), all outputs become 0 within 1 cycle.
//
// 2) When 'load' is asserted, valid 'data_in' and 'order' must be driven
// on the same cycle (no X or Z signals)
//
// 3) When 'load' is asserted, one and only one of 'fibonacci' and 'triangle'
// must be driven on the same cycle.
//
// 4) Once 'done' is asserted, 'data_out' must be correct on the same cycle.
//
// 5) Once 'overflow' is asserted, 'data_out' must be all 1's on the same cycle.
//
// 6) Once 'error' is asserted, 'data_out' must be all X's on the same cycle.
//
// 7) Unless it's error or overflow condition, 'done' and correct 'data_out'
// must show up on the output <order+2> cycles after 'load' is asserted.
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

module seq_gen_chkr (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	input	ulogic1		clk,		// clock signal
	input	ulogic1		reset_n,	// active-low reset

	input	ulogic1		fibonacci,	// mode: perform fibonacci calculation
	input	ulogic1		triangle,	// mode: perform triangle calculation
	
	input	ulogic1		load,		// active (2 cycles) --> load data into FSM
	input	ulogic1		clear,		// clear results off 'data_out' bus

	input	ulogic16	order,		// calculate the Nth value of the sequence
	input	ulogic64	data_in,	// initial value of the sequence

	input	ulogic1		done,		// active (1 cycle) --> data is ready
	input	ulogic64	data_out,	// calculated value of the sequence
	input	ulogic1		overflow,	// calculation exceeds bus max
	input	ulogic1		error		// indicates bad control input or bad data

	);

	/*************************************************************************/
	/* Parameters and variables												 */
	/*************************************************************************/

	parameter	CHKR_RULE_1 = 1'b1;
	parameter	CHKR_RULE_2 = 1'b1;
	parameter	CHKR_RULE_3 = 1'b1;
	parameter	CHKR_RULE_4 = 1'b1;
	parameter	CHKR_RULE_5 = 1'b1;
	parameter	CHKR_RULE_6 = 1'b1;
	parameter	CHKR_RULE_7 = 1'b1;

	/*************************************************************************/
	/* Checker Rule #1														 */
	/*************************************************************************/

	// When 'reset_n' is asserted (goes to 0), all outputs become 0 within 1 cycle

endmodule // seq_gen_chkr