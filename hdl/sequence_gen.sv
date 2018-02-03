// Module: sequence_gen.sv
// Author: Rehan Iqbal
// Date: January 15th, 2018
// Organization: Portland State University
//
// Description:
//
// This module calculates the Nth term of Fibonacci/triangle sequence given
// some initial data value. The input data (data_in) and Nth term desired
// (order) should be provided ON THE CYCLE AFTER 'load' signal goes high
// (i.e. data_in & order are latched on the clock edge after 'load' goes high).
//
// 'load' needs to be asserted for 2 cycles, while the other inputs (data_in, 
// order, fibonacci, triangle) only need to be provided for 1 cycle. 
// The 'clear' signal will take the FSM out of its ERROR & OVRFLOW states after
// a single cycle. No behavior was specified for both 'fibonacci' and 'triangle'
// being active simultaneously; the 'case' statement will prioritize 'triangle'
// first as a result.
//
// When the result is calculated, 'done' will assert for one clock cycle.
// During this cycle the results on 'data_out' can be sampled - these
// results will change to zero on the following cycle, so make sure to capture!
//
// See the FSM diagram and lab writeup for additional details.
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"
`timescale 1ns/1ps

module sequence_gen (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	input	ulogic1		clk,		// clock signal
	input	ulogic1		reset_n,	// active-low reset

	input	ulogic1		fibonacci,	// mode: perform fibonacci calculation
	input	ulogic1		triangle,	// mode: perform triangle calcuation

	input	ulogic1		load,		// active (2 cycles) --> load data into FSM
	input	ulogic1		clear,		// clear results off 'data_out' bus

	input	ulogic16	order,		// calculate the Nth value of the sequence
	input	ulogic64	data_in,	// initial value of the sequence

	output	ulogic1		done,		// active (1 cycle) --> data is ready
	output	ulogic64	data_out,	// calculated value of the sequence
	output	ulogic1		overflow,	// calculation exceeds bus max
	output	ulogic1		error		// indicates bad control input or bad data

	);

	/*************************************************************************/
	/* Local parameters and variables										 */
	/*************************************************************************/

	state_t		state;
	state_t		next;

	// signals for n_bit_full_adder module

	ulogic64	nbit_op_a;
	ulogic64	nbit_op_b;
	ulogic64	nbit_sum;
	ulogic1		nbit_overflow;


	// signals for Fibonacci and triangle calculations

	ulogic1		flag_done;
	ulogic16	count;
	ulogic64	reg_data_in;
	ulogic64	reg_order;

	//

	parameter	BUG_ENABLE_1 = 1'b0;
	parameter	BUG_ENABLE_4 = 1'b0;
	parameter	BUG_ENABLE_5 = 1'b0;	
	parameter	BUG_ENABLE_6 = 1'b0;

	/************************************************************************/
	/* Module instantiations												*/
	/************************************************************************/

	n_bit_full_adder i_n_bit_full_adder (

		.op_a		(nbit_op_a),		// I [64] operand a
		.op_b		(nbit_op_b),		// I [64] operand b
		.sum		(nbit_sum),			// O [64] sum
		.overflow	(nbit_overflow)		// O [0]  overflow

		);

	/*************************************************************************/
	/* FSM Block 1: reset & state advancement								 */
	/*************************************************************************/

	always_ff@(posedge clk) begin

		// synchronous reset the FSM to idle state
		if (!reset_n) begin
			state <= RESET;
		end

		// otherwise, advance the state
		else begin
			state <= next;
		end

	end

	/*************************************************************************/
	/* FSM Block 2: state transistions & outputs							 */
	/*************************************************************************/

	always_comb begin

		case (state)

			RESET : begin
				if (!reset_n) next = RESET;
				else next = IDLE;

				done = (BUG_ENABLE_1) ? 1'bx : 1'b0;
				data_out = (BUG_ENABLE_1) ? 'x : '0;
				overflow = (BUG_ENABLE_1) ? 1'bx : 1'b0;
				error = (BUG_ENABLE_1) ? 1'bx : 1'b0;

			end

			IDLE : begin
				if (load && triangle) next = LOAD_TRI;
				else if (load && fibonacci) next = LOAD_FIB;
				else next = IDLE;

				done = 1'b0;
				data_out = '0;
				overflow = 1'b0;
				error = 1'b0;
			end

			LOAD_TRI : begin
				if (!load) next = IDLE;
				else if (~|order) next = ERROR;
				else next = TRI_ADD;
			end

			LOAD_FIB : begin
				if (!load) next = IDLE;
				else if ((~|order) || (~|data_in)) next = ERROR;
				else next = FIB_ADD;
			end

			ERROR : begin
				if (clear) next = IDLE;
				else next = ERROR;

				error = 1'b1;
				data_out = (BUG_ENABLE_6) ? '0 : 'x;

			end

			TRI_ADD : begin
				if (nbit_overflow) next = OVRFLOW;
				else if (flag_done) next = DONE;
				else next = TRI_ADD;
			end

			FIB_ADD : begin
				if (nbit_overflow) next = OVRFLOW;
				else if (flag_done) next = DONE;
				else next = FIB_ADD;
			end

			DONE : begin
				next = IDLE;

				done = 1'b1;
				data_out = (BUG_ENABLE_4) ? 'x : nbit_sum;

			end

			OVRFLOW : begin
				if (clear) next = IDLE;
				else next = OVRFLOW;

				overflow = 1'b1;
				data_out = (BUG_ENABLE_5) ? 'x : '1;
			end

		endcase // state

	end // always_comb

	/*************************************************************************/
	/* Fibonacci & triangle calculation block								 */
	/*************************************************************************/

	always_ff@(posedge clk) begin

		nbit_op_a <= nbit_op_a;
		nbit_op_b <= nbit_op_b;

		reg_data_in <= reg_data_in;
		reg_order <= reg_order;

		count <= count;
		flag_done <= 1'b0;

		case (state)

			IDLE : begin

				count <= '0;
				reg_data_in <= '0;
				reg_order <= '0;
				nbit_op_a <= '0;
				nbit_op_b <= '0;

			end // IDLE

			LOAD_TRI, LOAD_FIB : begin

				reg_data_in <= data_in;
				reg_order <= order;

			end // LOAD_TRI, LOAD_FIB

			TRI_ADD : begin

				if (count < reg_order) begin

					if (count == 16'd0) begin
						nbit_op_a <= reg_data_in;
						nbit_op_b <= count;
					end

					else begin
						nbit_op_a <= nbit_sum;
						nbit_op_b <= count;
					end
					
					count <= count + 1'b1;

				end // if

				else begin
					flag_done <= 1'b1;
				end

			end // TRI_ADD

			FIB_ADD : begin

				if (count < reg_order) begin

					if (count == 16'd0) begin
						nbit_op_a <= reg_data_in;
						nbit_op_b <= '0;
					end

					else begin
						nbit_op_a <= nbit_sum;
						nbit_op_b <= nbit_op_a;
					end

					count <= count + 1'b1;

				end // if

				else begin
					flag_done <= 1'b1;
				end

			end // FIB_ADD

		endcase

	end // always_ff

endmodule // sequence_gen