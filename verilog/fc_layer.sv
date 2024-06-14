`timescale 1ns / 1ps

// Fully connceted linear layer
module fc_layer #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 5,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
	// Output image channels/features
	parameter OUTPUT_CHANNELS = 3,
	// Bits per pixel
	parameter PX_SIZE = 8,
	localparam FLAT_INPUT_SIZE = INPUT_SIZE*INPUT_SIZE*INPUT_CHANNELS
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_in,
	input wire
		[OUTPUT_CHANNELS-1:0]
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] weights,
	input wire
		[OUTPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] biases,
	output wire
		[OUTPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_out
);
	genvar x, y, c;

	generate
		for (x = 0; x < INPUT_SIZE; x += 1) begin
			for (y = 0; y < INPUT_SIZE; y += 1) begin
				for (c = 0; c < OUTPUT_CHANNELS; c += 1) begin
					perceptron #(
						.INPUT_SIZE(FLAT_INPUT_SIZE),
						.PX_SIZE(PX_SIZE)
					) p (
						.img_in(img_in),
						.weights(weights[c]),
						.bias(biases[c])
					);
				end
			end
		end
	endgenerate
endmodule
