`timescale 1ns / 1ps

// Actual network
module minimobilenet #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 16,
	// Input image channels/features
	parameter INPUT_CHANNELS = 1,
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
	localparam KERNEL_SIZE = 3;
	localparam POOL_KERNEL_SIZE = 2;
	localparam CONV_OUTPUT_SIZE = (INPUT_SIZE - (KERNEL_SIZE-1)) / POOL_KERNEL_SIZE;
	localparam CONV_OUTPUT_CHANNELS = 3;
	localparam DWCV_OUTPUT_SIZE = ((CONV_OUTPUT_SIZE - (KERNEL_SIZE-1)) / 2);
	localparam DWCV_OUTPUT_CHANNELS = 8;

	full_conv_layer # (
		.OUTPUT_CHANNELS(3),
		.INPUT_SIZE(INPUT_SIZE),
		.INPUT_CHANNELS(INPUT_CHANNELS),
		.KERNEL_SIZE(3),
		.PX_SIZE(PX_SIZE),
		.POOL_KERNEL_SIZE(2),
		.KERNEL_MEM_FILE("fixed_weights/conv1.weight.coe"),
		.BIAS_MEM_FILE("fixed_weights/conv1.weight.coe")
	) conv (
		.img_in(img_in),
		.img_out(conv_out)
	);
	
	dwcv_layer #(
		// Legal but unsupported syntax :(
		// .INPUT_SIZE(conv.OUTPUT_SIZE),
		// .INPUT_CHANNELS(conv.OUTPUT_CHANNELS),
		.INPUT_SIZE(CONV_OUTPUT_SIZE),
		.INPUT_CHANNELS(CONV_OUTPUT_CHANNELS),
		.KERNEL_SIZE(3),
		.PX_SIZE(PX_SIZE)
	) dwcv (
		.img_in(conv_out),
		.img_out(dwcv_out)
	);

	fc_layer #(
		// Legal but unsupported syntax :(
		// .INPUT_SIZE(dwcv.OUTPUT_SIZE),
		// .INPUT_CHANNELS(dwcv.OUTPUT_CHANNELS),
		.INPUT_SIZE(DWCV_OUTPUT_SIZE),
		.INPUT_CHANNELS(DWCV_OUTPUT_CHANNELS),
		.PX_SIZE(PX_SIZE)
	) fc (
		.img_in(dwcv_out),
		.img_out(img_out)
	);
endmodule
