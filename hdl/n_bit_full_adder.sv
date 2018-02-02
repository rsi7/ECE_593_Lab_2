// Module: n_bit_full_adder.sv
// Author: Rehan Iqbal
// Date: January 16th, 2018
// Organziation: Portland State University
//
// Description:
//
// This module implements an n-bit full adder. It is composed of multiple
// copies of the 'one_bit_full_adder' module, with their carry-in & carry-out
// signals chained. The Nth adder provides its carry-out as the 'overflow'
// output for the module. This will be high if the sum exceeds the width
// of the data bus inputs.
//
// To adjust the width, override parameter 'N' when instantiating this module.
// Note that it may break the 'n_bit_full_adder_test' testbench, as that
// module is hardcoded for 64-bit operation.
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

module n_bit_full_adder #(parameter N = 64) (

		input logic unsigned	[N-1:0]	op_a,		// operand a
		input logic unsigned	[N-1:0]	op_b,		// operand b

		output logic unsigned	[N-1:0]	sum,		// sum
		output logic unsigned			overflow	// overflow

	);

	/*************************************************************************/
	/* Local parameters and variables										 */
	/*************************************************************************/

	logic unsigned [N:0]	carry;

	/*************************************************************************/
	/* Full adder instantiation												 */
	/*************************************************************************/

	// No carry input on first full adder
	assign carry[0] = 1'b0;

	genvar i;
	generate
		for (i = 0; i < N; i = i+1) begin

			one_bit_full_adder i_one_bit_full_adder (

				.op_a	(op_a[i]),		// I [0] operand a
				.op_b	(op_b[i]),		// I [0] operand b
				.c_in	(carry[i]),		// I [0] carry-in
				
				.sum	(sum[i]),		// O [0] sum
				.c_out	(carry[i+1])	// O [0] carry-out

				);
		end
	endgenerate

	// Tie overflow to highest order carry bit
	assign overflow = carry[N];

endmodule // n_bit_full_adder