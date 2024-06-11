`timescale 1ns / 1ps

// Instantiates a single level of an adder tree
// Convenience model to clean up higher level code
module atree_level #(
	// Width in bits of each input
	parameter IN_WIDTH = 32,
	// Number of adders on this level of the tree
	parameter NUM_ADDERS = 1,
	localparam NUM_INPUTS = 2 * NUM_ADDERS
)(
	// First index refers to nth input
	// Second index refers to mth bit of nth input
	input wire[NUM_INPUTS - 1 : 0][IN_WIDTH - 1 : 0] inputs,
	// First index refers to nth output
	// Second index refers to mth bit of nth output
	output wire[NUM_ADDERS - 1 : 0][IN_WIDTH : 0] outputs
);
	genvar i;
	generate
		for (i = 0; i < NUM_ADDERS; i = i+1) begin
			adder #(
				.IN_WIDTH(IN_WIDTH)
			) plus (
				.a(inputs[2 * i]),
				.b(inputs[(2 * i) + 1]),
				.sum(outputs[i])
			);
		end
	endgenerate
endmodule
