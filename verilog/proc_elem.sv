`timescale 1ns / 1ps

// Processing Element
// A parallel processing element for convolution
// Processes a single image pixel and its neighborhood
module proc_elem #(
	// Width of the kernel, assumed to be square
	parameter KERNEL_SIZE = 3,
	// Number of bits in each pixel
	parameter PX_SIZE = 8,
	parameter INPUT_CHANNELS = 1,
	// N x N kernel with C channels
	localparam NUM_INPUTS = KERNEL_SIZE * KERNEL_SIZE * INPUT_CHANNELS + 1,
	localparam ADDER_OUT_SIZE = PX_SIZE + $clog2(NUM_INPUTS)
) (
	input wire
		[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
		[INPUT_CHANNELS-1:0][PX_SIZE-1:0] img_in,
	input wire
		[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
		[INPUT_CHANNELS-1:0][PX_SIZE-1:0] kernel,
	input wire[PX_SIZE-1:0] bias,
	output wire[PX_SIZE-1:0] img_out
);
	wire
		[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
		[INPUT_CHANNELS-1:0][PX_SIZE-1:0] adder_inputs;
	wire[ADDER_OUT_SIZE-1:0] adder_output;
	atree #(
		.IN_WIDTH(PX_SIZE),
		.LEVELS($rtoi($ceil($clog2(NUM_INPUTS))))
	) adder (
		.inputs({adder_inputs, bias}),
		.out(adder_output)
	);

	assign img_out = adder_output[ADDER_OUT_SIZE-1:ADDER_OUT_SIZE-PX_SIZE-1];

	genvar x, y, c;
	generate
		// For each kernel pixel
		for (x = 0; x < KERNEL_SIZE; x += 1) begin
			for (y = 0; y < KERNEL_SIZE; y += 1) begin
				for (c = 0; c < INPUT_CHANNELS; c += 1) begin
					// Could bit shift for larger kernels
					assign adder_inputs[x][y][c] = img_in[x][y][c] * kernel[x][y][c];
				end
			end
		end
	endgenerate
endmodule
