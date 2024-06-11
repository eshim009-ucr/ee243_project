`timescale 1ns / 1ps

// Processing Element
// A parallel processing element for convolution
// Processes a single image pixel and its neighborhood
module proc_elem #(
	// Width of the kernel, assumed to be square
	parameter KERNEL_SIZE = 3,
	// Number of bits in each pixel
	parameter PX_SIZE = 8,
	localparam NUM_INPUTS = KERNEL_SIZE * KERNEL_SIZE,
	// Product of two N-bit inputs
	localparam ADDER_IN_SIZE = 2*PX_SIZE,
	localparam ADDER_OUT_SIZE = ADDER_IN_SIZE + $clog2(NUM_INPUTS)
) (
	input wire[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0][PX_SIZE-1:0] img_in,
	input wire[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0][PX_SIZE-1:0] kernel_in,
	output reg[ADDER_OUT_SIZE-1:0] img_out
);
	wire[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0][2*PX_SIZE-1:0] adder_inputs;
	atree #(
		.IN_WIDTH(ADDER_IN_SIZE),
		.LEVELS(int'($ceil($clog2(NUM_INPUTS))))
	) adder (
		.inputs(adder_inputs),
		.out(img_out)
	);
	
	genvar x, y;
	generate
		// For each kernel pixel
		for (x = 0; x < KERNEL_SIZE; x += 1) begin
			for (y = 0; y < KERNEL_SIZE; y += 1) begin
				assign adder_inputs[x][y] = img_in[x][y] * kernel_in[x][y];
			end
		end
	endgenerate
	
endmodule
