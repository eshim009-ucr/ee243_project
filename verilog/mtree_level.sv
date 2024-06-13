`timescale 1ns / 1ps

// Instantiates a single level of an comparison tree
// Convenience model to clean up higher level code
module mtree_level #(
	// Width in bits of each input
	parameter IN_WIDTH = 32,
	// Number of adders on this level of the tree
	parameter NUM_COMPS = 1,
	localparam NUM_INPUTS = 2 * NUM_COMPS
)(
	// First index refers to nth input
	// Second index refers to mth bit of nth input
	input wire[NUM_INPUTS - 1 : 0][IN_WIDTH - 1 : 0] inputs,
	// First index refers to nth output
	// Second index refers to mth bit of nth output
	output wire[NUM_COMPS - 1 : 0][IN_WIDTH - 1 : 0] outputs
);
	genvar i;
	generate
		for (i = 0; i < NUM_COMPS; i = i+1) begin
			max #(
				.IN_WIDTH(IN_WIDTH)
			) comp (
				.a(inputs[2 * i]),
				.b(inputs[(2 * i) + 1]),
				.out(outputs[i])
			);
		end
	endgenerate
endmodule
