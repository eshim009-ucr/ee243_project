`timescale 1ns / 1ps

// Actual network
module minimobilenet #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 32,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
	// Bits per pixel
	parameter PX_SIZE = 8,
	// Number of classes
	parameter OUTPUT_CHANNELS = 10
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_in,
	output reg
		[OUTPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_out
);
	genvar i, j;
	localparam CONV_OUT_CHANNELS = 6;
	localparam CONV_KERNEL_SIZE = 3;
	localparam CONV_OUT_SIZE = INPUT_SIZE - (CONV_KERNEL_SIZE-1);
	wire[CONV_OUT_CHANNELS-1:0]
		[CONV_OUT_SIZE-1:0][CONV_OUT_SIZE-1:0]
		[PX_SIZE-1:0] relu_conv_out;

	generate
		for (i = 0; i < CONV_OUT_CHANNELS; i += 1) begin
			wire[CONV_OUT_SIZE-1:0][CONV_OUT_SIZE-1:0]
				[INPUT_CHANNELS-1:0]
				[PX_SIZE-1:0] raw_conv_out;
			conv_layer #(
				.INPUT_SIZE(INPUT_SIZE),
				.INPUT_CHANNELS(INPUT_CHANNELS),
				.KERNEL_SIZE(3),
				.PX_SIZE(8)
			) layer (
				.img_in(img_in),
				.kernel(kernels[i]),
				.img_out(raw_conv_out)
			);
			relu_layer #(
				.INPUT_SIZE(CONV_OUT_SIZE),
				.INPUT_CHANNELS(1),
				.PX_SIZE(PX_SIZE)
			) relu (
				.img_in(raw_conv_out),
				.img_out(relu_conv_out[i])
			);
		end
	endgenerate
endmodule
