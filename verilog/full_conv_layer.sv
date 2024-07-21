`timescale 1ns / 1ps

// Mutli-Channel Convolutional Layer with Pool and Rectifier
module full_conv_layer #(
    // Number of channels in the resulting image
    parameter OUTPUT_CHANNELS = 3;
	// Input size, assumed to be square
	parameter INPUT_SIZE = 32,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
	// Kernel size, assumed to be square
	parameter KERNEL_SIZE = 3,
	// Bits per pixel
	parameter PX_SIZE = 8,
    // Kernel size used for pooling
    parameter POOL_KERNEL_SIZE = 2,
    // Coefficient file holding hex kernel values
    parameter KERNEL_MEM_FILE = "fixed_weights/conv.weight.coe",
    // Coefficient file holding hex bias values
    parameter BIAS_MEM_FILE = "fixed_weights/conv.weight.coe",
    // Size of the raw output from the convolutional layer
	localparam RAW_SIZE = (INPUT_SIZE - (KERNEL_SIZE-1)),
    // Size of the final output after pooling
    localparam OUTPUT_SIZE = RAW_SIZE / POOL_KERNEL_SIZE
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_in,
	output wire
		[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_out
);
	reg[7:0] kernels_mem[
		OUTPUT_CHANNELS *
		KERNEL_SIZE * KERNEL_SIZE *
		INPUT_CHANNELS *
		PX_SIZE / 8
		-1:0
	];
	wire[OUTPUT_CHANNELS-1:0]
		[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] kernels;
	reg[7:0] biases_mem[
		OUTPUT_CHANNELS *
		KERNEL_SIZE * KERNEL_SIZE *
		INPUT_CHANNELS *
		PX_SIZE / 8
		-1:0
	];
	wire[OUTPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] biases;
	initial $readmemh(KERNEL_MEM_FILE, kernels_mem);
	initial $readmemh(BIAS_MEM_FILE, biases_mem);
	assign kernels = kernels_mem;
	assign biases = biases_mem;

	genvar i;
	generate
		for (i = 0; i < OUTPUT_CHANNELS; i += 1) begin
			wire[RAW_SIZE-1:0][RAW_SIZE-1:0]
				[INPUT_CHANNELS-1:0]
				[PX_SIZE-1:0] raw_conv_out;
			wire[RAW_SIZE-1:0][RAW_SIZE-1:0]
				[PX_SIZE-1:0] relu_conv_out;
			conv_layer #(
				.INPUT_SIZE(INPUT_SIZE),
				.INPUT_CHANNELS(INPUT_CHANNELS),
				.KERNEL_SIZE(3),
				.PX_SIZE(PX_SIZE)
			) layer (
				.img_in(img_in),
				.kernel(kernels[i]),
				.bias(biases[i]),
				.img_out(raw_conv_out)
			);
			relu_layer #(
				.INPUT_SIZE(RAW_SIZE),
				.PX_SIZE(PX_SIZE)
			) relu (
				.img_in(raw_conv_out),
				.img_out(relu_conv_out)
			);
			pool_layer #(
				.INPUT_SIZE(RAW_SIZE),
				.KERNEL_SIZE(POOL_KERNEL_SIZE),
				.PX_SIZE(PX_SIZE)
			) pool (
				.img_in(relu_conv_out),
				.img_out(img_out[i])
			);
		end
	endgenerate
endmodule
