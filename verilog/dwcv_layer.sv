`timescale 1ns / 1ps

// Depthwise-Separable Convolutional Layer
module dwcv_layer #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 32,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
	// Input image channels/features
	parameter OUTPUT_CHANNELS = 3,
	// Kernel size, assumed to be square
	parameter KERNEL_SIZE = 3,
	// Bits per pixel
	parameter PX_SIZE = 8,
	localparam OUTPUT_SIZE = (INPUT_SIZE - (KERNEL_SIZE-1))
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_in,
	input wire
		[INPUT_CHANNELS-1:0]
		[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
		[PX_SIZE-1:0] depth_kernels,
	input wire
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] depth_biases,
	input wire
		[OUTPUT_CHANNELS-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] point_kernels,
	input wire
		[OUTPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] point_biases,
	output reg
		[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_out
);
	wire[OUT_CHANNELS-1:0]
		[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
		[PX_SIZE-1:0] dw_out;

	genvar i;
	generate
		for (i = 0; i < INPUT_CHANNELS; i += 1) begin
			wire[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
				[OUTPUT_CHANNELS-1:0]
				[PX_SIZE-1:0] raw_dw_out;
			conv_layer #(
				.INPUT_SIZE(INPUT_SIZE),
				.INPUT_CHANNELS(1),
				.KERNEL_SIZE(3),
				.PX_SIZE(PX_SIZE)
			) depthwise (
				.img_in(conv_out),
				.kernel(depth_kernels[i]),
				.bias(depth_biases[i]),
				.img_out(dw_out)
			);
		end
	endgenerate

	genvar j;
	generate
		for (j = 0; j < OUTPUT_CHANNELS; j += 1) begin
			conv_layer #(
				.INPUT_SIZE(INPUT_SIZE),
				.INPUT_CHANNELS(INPUT_CHANNELS),
				.KERNEL_SIZE(1),
				.PX_SIZE(PX_SIZE)
			) pointwise (
				.img_in(dw_out),
				.kernel(point_kernels[j]),
				.bias(point_biases[j]),
				.img_out(img_out)
			);
		end
	endgenerate
endmodule
