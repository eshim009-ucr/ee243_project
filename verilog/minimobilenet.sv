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
	localparam CONV_OUT_SIZE = (INPUT_SIZE - (3-1)) / 2;
	wire[CONV_OUT_SIZE-1:0][CONV_OUT_SIZE-1:0]
		[3-1:0]
		[PX_SIZE-1:0] conv_out;
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
		.INPUT_SIZE(DWCV_INPUT_SIZE),
		.INPUT_CHANNELS(DWCV_INPUT_CHANNELS),
		.KERNEL_SIZE(3),
		.PX_SIZE(PX_SIZE)
	) layer (
		.img_in(conv_out),
		.img_out(raw_dwcv_out)
	);


	localparam FC_INPUT_SIZE = DWCV_OUT_SIZE;
	localparam FC_INPUT_CHANNELS = DWCV_OUT_CHANNELS * 2*2;
	localparam FC_OUT_CHANNELS = 10;
	localparam FC_OUT_SIZE = DWCV_OUT_SIZE;
	wire[FC_OUT_CHANNELS-1:0]
		[FC_OUT_SIZE-1:0][FC_OUT_SIZE-1:0]
		[PX_SIZE-1:0] fc_out;

	wire
		[FC_OUT_CHANNELS-1:0]
		[FC_INPUT_SIZE-1:0][FC_INPUT_SIZE-1:0]
		[FC_INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] fc_weights;
	reg[7:0] fc_weights_mem[
		FC_OUT_CHANNELS *
		FC_INPUT_SIZE * FC_INPUT_SIZE *
		FC_INPUT_CHANNELS *
		PX_SIZE / 8
		-1:0
	];
	wire
		[FC_OUT_CHANNELS-1:0]
		[PX_SIZE-1:0] fc_biases;
	reg[7:0] fc_biases_mem[
		FC_OUT_CHANNELS *
		PX_SIZE / 8
		-1:0
	];
	initial $readmemh("fixed_weights/fc.weight.coe", fc_weights_mem);
	initial $readmemh("fixed_weights/fc.bias.coe", fc_biases_mem);
	assign fc_biases = fc_biases_mem;
	assign fc_weights = fc_weights_mem;

	fc_layer #(
		.INPUT_SIZE(FC_INPUT_SIZE),
		.INPUT_CHANNELS(FC_INPUT_CHANNELS),
		.PX_SIZE(PX_SIZE)
	) fc (
		.img_in(dwcv_out),
		.img_out(img_out)
	);
endmodule
