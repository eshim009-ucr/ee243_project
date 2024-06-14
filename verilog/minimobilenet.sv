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
	localparam CONV_OUT_CHANNELS = 3;
	localparam CONV_KERNEL_SIZE = 3;
	localparam CONV_RAW_SIZE = INPUT_SIZE - (CONV_KERNEL_SIZE-1);
	localparam CONV_POOL_SIZE = CONV_RAW_SIZE / 2;
	localparam CONV_OUT_SIZE = CONV_POOL_SIZE;
	wire[CONV_OUT_CHANNELS-1:0]
		[CONV_OUT_SIZE-1:0][CONV_OUT_SIZE-1:0]
		[PX_SIZE-1:0] conv_out;

	reg[CONV_OUT_CHANNELS-1:0]
		[CONV_KERNEL_SIZE-1:0][CONV_KERNEL_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] conv_kernels;
	reg[CONV_OUT_CHANNELS-1:0]
		[PX_SIZE-1:0] conv_biases;
	initial $readmemb("fixed_weights/conv1.weight.coe", conv_kernels);
	initial $readmemb("fixed_weights/conv1.bias.coe", conv_biases);

	genvar i;
	generate
		for (i = 0; i < CONV_OUT_CHANNELS; i += 1) begin
			wire[CONV_RAW_SIZE-1:0][CONV_RAW_SIZE-1:0]
				[INPUT_CHANNELS-1:0]
				[PX_SIZE-1:0] raw_conv_out;
			wire[CONV_RAW_SIZE-1:0][CONV_RAW_SIZE-1:0]
				[PX_SIZE-1:0] relu_conv_out;
			conv_layer #(
				.INPUT_SIZE(INPUT_SIZE),
				.INPUT_CHANNELS(INPUT_CHANNELS),
				.KERNEL_SIZE(3),
				.PX_SIZE(PX_SIZE)
			) layer (
				.img_in(img_in),
				.kernel(conv_kernels[i]),
				.bias(conv_biases[i]),
				.img_out(raw_conv_out)
			);
			relu_layer #(
				.INPUT_SIZE(CONV_RAW_SIZE),
				.PX_SIZE(PX_SIZE)
			) relu (
				.img_in(raw_conv_out),
				.img_out(relu_conv_out)
			);
			pool_layer #(
				.INPUT_SIZE(CONV_RAW_SIZE),
				.KERNEL_SIZE(2),
				.PX_SIZE(PX_SIZE)
			) pool (
				.img_in(relu_conv_out),
				.img_out(conv_out[i])
			);
		end
	endgenerate


	localparam DWCV_INPUT_SIZE = CONV_OUT_SIZE;
	localparam DWCV_INPUT_CHANNELS = CONV_OUT_CHANNELS;
	localparam DWCV_OUT_CHANNELS = 8;
	localparam DWCV_KERNEL_SIZE = 3;
	localparam DWCV_RAW_SIZE = DWCV_INPUT_SIZE - (DWCV_KERNEL_SIZE-1);
	localparam DWCV_POOL_SIZE = DWCV_RAW_SIZE / 2;
	localparam DWCV_OUT_SIZE = DWCV_POOL_SIZE;
	wire[DWCV_OUT_CHANNELS-1:0]
		[DWCV_OUT_SIZE-1:0][DWCV_OUT_SIZE-1:0]
		[PX_SIZE-1:0] dwcv_out;

	reg[DWCV_INPUT_CHANNELS-1:0]
		[DWCV_KERNEL_SIZE-1:0][DWCV_KERNEL_SIZE-1:0]
		[PX_SIZE-1:0] depth_kernels;
	reg[DWCV_INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] depth_biases;
	reg[DWCV_OUT_CHANNELS-1:0]
		[DWCV_INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] point_kernels;
	reg[CONV_OUT_CHANNELS-1:0]
		[PX_SIZE-1:0] point_biases;
	initial $readmemb("fixed_weights/conv2.depthwise.weight.coe", depth_kernels);
	initial $readmemb("fixed_weights/conv2.depthwise.bias.coe", depth_biases);
	initial $readmemb("fixed_weights/conv2.pointwise.weight.coe", point_kernels);
	initial $readmemb("fixed_weights/conv2.pointwise.bias.coe", point_biases);

	dwcv_layer #(
		.INPUT_SIZE(DWCV_INPUT_SIZE),
		.INPUT_CHANNELS(DWCV_INPUT_CHANNELS),
		.KERNEL_SIZE(3),
		.PX_SIZE(PX_SIZE)
	) layer (
		.img_in(conv_out),
		.depth_kernels(depth_kernels),
		.depth_biases(depth_biases),
		.point_kernels(point_kernels),
		.point_biases(point_biases),
		.img_out(raw_dwcv_out)
	);
	genvar j;
	generate
		for (i = 0; i < DWCV_OUT_CHANNELS; i += 1) begin
			wire[DWCV_RAW_SIZE-1:0][DWCV_RAW_SIZE-1:0]
				[DWCV_INPUT_CHANNELS-1:0]
				[PX_SIZE-1:0] raw_dwcv_out;
			wire[DWCV_RAW_SIZE-1:0][DWCV_RAW_SIZE-1:0]
				[PX_SIZE-1:0] relu_dwcv_out;
			relu_layer #(
				.INPUT_SIZE(DWCV_RAW_SIZE),
				.PX_SIZE(PX_SIZE)
			) relu (
				.img_in(raw_dwcv_out),
				.img_out(relu_dwcv_out)
			);
			pool_layer #(
				.INPUT_SIZE(DWCV_RAW_SIZE),
				.KERNEL_SIZE(2),
				.PX_SIZE(PX_SIZE)
			) pool (
				.img_in(relu_dwcv_out),
				.img_out(dwcv_out[j])
			);
		end
	endgenerate


	localparam FC_INPUT_SIZE = DWCV_OUT_SIZE;
	localparam FC_INPUT_CHANNELS = DWCV_OUT_CHANNELS * 2*2;
	localparam FC_OUT_CHANNELS = 10;
	localparam FC_OUT_SIZE = DWCV_OUT_SIZE;
	wire[FC_OUT_CHANNELS-1:0]
		[FC_OUT_SIZE-1:0][FC_OUT_SIZE-1:0]
		[PX_SIZE-1:0] fc_out;

	fc_layer #(
		.INPUT_SIZE(FC_INPUT_SIZE),
		.INPUT_CHANNELS(FC_INPUT_CHANNELS),
		.PX_SIZE(PX_SIZE),
		.WEIGHT_FILE("fixed_weights/fc.weights.coe"),
		.BIAS_FILE("fixed_weights/fc.bias.coe")
	) fc (
		.img_in(dwcv_out),
		.img_out(img_out)
	);
endmodule
