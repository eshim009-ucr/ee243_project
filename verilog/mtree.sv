`timescale 1ns / 1ps

// Adder tree to sum a large number of integers in parallel
module mtree #(
	// Width in bits of each input
	parameter IN_WIDTH = 32,
	// Number of levels that the tree will have
	parameter LEVELS = 4,
	// A tree with n levels will have 2^n inputs
	localparam NUM_INPUTS = (1 << LEVELS)
)(
	// First index refers to nth input
	// Second index refers to mth bit of nth input
	input wire[NUM_INPUTS - 1 : 0][IN_WIDTH - 1 : 0] inputs,
	// Final sum of all values
	output wire[IN_WIDTH - 1 : 0] out
);
	// Instantiate comparison
	genvar i;
	generate
		for (i = 0; i < LEVELS; i = i+1) begin: levels
			wire[(2<<i) - 1: 0][IN_WIDTH - 1 : 0] incoming;
			wire[(1<<i) - 1 : 0][IN_WIDTH - 1 : 0] outgoing;
			mtree_level #(
				.IN_WIDTH(IN_WIDTH),
				.NUM_COMPS(1 << i)
			) lvl (
				.inputs(incoming),
				.outputs(outgoing)
			);
		end
	endgenerate

	// External connections
	assign levels[LEVELS-1].incoming = inputs;
	assign out = levels[0].outgoing;

	// Connect levels
	genvar j;
	generate
		for (j = 1; j < LEVELS; j = j+1) begin: connections
			assign levels[j - 1].incoming = levels[j].outgoing;
		end
	endgenerate
endmodule
