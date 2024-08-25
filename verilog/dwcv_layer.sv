`timescale 1ns / 1ps

// Depthwise-Separable Convolutional Layer
module dwcv_layer #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 32,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
	// Input image channels/features
	parameter OUTPUT_CHANNELS = 8,
	// Kernel size, assumed to be square
	parameter KERNEL_SIZE = 3,
	// Bits per pixel
	parameter PX_SIZE = 8,
    // Kernel size used for pooling
    parameter POOL_KERNEL_SIZE = 2,
    // Coefficient file holding hex kernel values
    parameter DEPTH_KERNEL_MEM_FILE = "fixed_weights/conv.weight.coe",
    // Coefficient file holding hex bias values
    parameter DEPTH_BIAS_MEM_FILE = "fixed_weights/conv.weight.coe",
    // Coefficient file holding hex kernel values
    parameter POINT_KERNEL_MEM_FILE = "fixed_weights/conv.weight.coe",
    // Coefficient file holding hex bias values
    parameter POINT_BIAS_MEM_FILE = "fixed_weights/conv.weight.coe",
    // Size of the raw output from the convolutional layer
	localparam RAW_SIZE = (INPUT_SIZE - (KERNEL_SIZE-1)),
	localparam POOL_SIZE = RAW_SIZE / POOL_KERNEL_SIZE,
	localparam OUTPUT_SIZE = POOL_SIZE
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_in,
	output wire
		[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_out
);

	wire[OUTPUT_CHANNELS-1:0]
		[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
		[PX_SIZE-1:0] out;

	wire[INPUT_CHANNELS-1:0]
		[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
		[PX_SIZE-1:0] depth_kernels;
	reg[7:0] depth_kernels_mem[
		INPUT_CHANNELS *
		KERNEL_SIZE * KERNEL_SIZE *
		PX_SIZE / 8
		-1:0
	];
	wire[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] depth_biases;
	reg[7:0] depth_biases_mem[
		INPUT_CHANNELS *
		PX_SIZE / 8
		-1:0
	];
	wire[OUTPUT_CHANNELS-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] point_kernels;
	reg[7:0] point_kernels_mem[
		OUTPUT_CHANNELS *
		INPUT_CHANNELS *
		PX_SIZE / 8
		-1:0
	];
	wire[CONV_OUTPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] point_biases;
	reg[7:0] point_biases_mem[
		CONV_OUTPUT_CHANNELS *
		PX_SIZE / 8
		-1:0
	];
	initial $readmemh("fixed_weights/conv2.depthwise.weight.coe", depth_kernels_mem);
	initial $readmemh("fixed_weights/conv2.depthwise.bias.coe", depth_biases_mem);
	initial $readmemh("fixed_weights/conv2.pointwise.weight.coe", point_kernels_mem);
	initial $readmemh("fixed_weights/conv2.pointwise.bias.coe", point_biases_mem);
	assign depth_kernels = depth_kernels_mem;
	assign depth_biases = depth_biases_mem;
	assign point_kernels = point_kernels_mem;
	assign point_biases = point_biases_mem;

	wire[OUTPUT_CHANNELS-1:0]
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
			wire[RAW_SIZE-1:0][RAW_SIZE-1:0]
				[INPUT_CHANNELS-1:0]
				[PX_SIZE-1:0] raw_out;
			wire[RAW_SIZE-1:0][RAW_SIZE-1:0]
				[PX_SIZE-1:0] relu_out;
			relu_layer #(
				.INPUT_SIZE(RAW_SIZE),
				.PX_SIZE(PX_SIZE)
			) relu (
				.img_in(raw_out),
				.img_out(relu_out)
			);
			pool_layer #(
				.INPUT_SIZE(RAW_SIZE),
				.KERNEL_SIZE(2),
				.PX_SIZE(PX_SIZE)
			) pool (
				.img_in(relu_out),
				.img_out(out[j])
			);
		end
	endgenerate
endmodule
