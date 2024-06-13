`timescale 1ns / 1ps

// Convolutional Layer
// More output channels can be accomplished with more instances of this module
module conv_layer #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 32,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
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
		[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] kernel,
	output reg
		[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_out
);
	genvar x, y, k;

	generate
		for (x = 0; x < OUTPUT_SIZE; x += 1) begin
			for (y = 0; y < OUTPUT_SIZE; y += 1) begin
				wire
					[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
					[INPUT_CHANNELS-1:0]
					[PX_SIZE-1:0] region;
				
				for (k = 0; k < KERNEL_SIZE; k += 1) begin
					assign region[k] = img_in[x+k][y+KERNEL_SIZE-1:y];
				end
				
				proc_elem #(
					.KERNEL_SIZE(KERNEL_SIZE),
					.PX_SIZE(PX_SIZE),
					.INPUT_CHANNELS(INPUT_CHANNELS)
				) pe (
					.img_in(region),
					.kernel(kernel),
					.img_out(img_out[x][y])
				);
			end
		end
	endgenerate
endmodule
