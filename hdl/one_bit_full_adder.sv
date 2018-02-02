// Module: one_bit_full_adder.sv
// Author: Rehan Iqbal
// Date: January 16th, 2018
// Organziation: Portland State University
//
// Description:
//
// This module implements a 1-bit full adder using Verilog gate-level primitives
// (OR, NOR, AND, NAND, XOR, XNOR). Several of these can be chained together
// to create a larger adder... this is how "n_bit_full_adder.sv" is implemented.
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

module one_bit_full_adder (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	input	ulogic1		op_a,	// operand a
	input	ulogic1		op_b,	// operand b
	input	ulogic1		c_in,	// carry-in

	output	ulogic1		sum,	// sum
	output	ulogic1		c_out	// carry-out

	);

	/*************************************************************************/
	/* Local parameters and variables										 */
	/*************************************************************************/

	ulogic1 f1, f2, f3;

	/*************************************************************************/
	/* Combinational logic													 */
	/*************************************************************************/

	xor U1(f1,op_a, op_b);
	xor U2(sum, f1, c_in);

	and U3(f2, op_a, op_b);
	and U4(f3, f1, c_in);

	or U5(c_out, f2, f3);

endmodule // one_bit_full_adder