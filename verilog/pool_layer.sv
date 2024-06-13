`timescale 1ns / 1ps

// Maxpool layer
module pool_layer #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 6,
	// Kernel size, assumed to be square
	parameter KERNEL_SIZE = 2,
	// Bits per pixel
	parameter PX_SIZE = 8,
	localparam OUTPUT_SIZE = INPUT_SIZE / KERNEL_SIZE
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_in,
	output reg
		[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_out
);
	genvar x, y, k;

	generate
		for (x = 0; x < INPUT_SIZE; x += KERNEL_SIZE) begin
			for (y = 0; y < INPUT_SIZE; y += KERNEL_SIZE) begin
				wire
					[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0]
					[PX_SIZE-1:0] region;
				for (k = 0; k < KERNEL_SIZE; k += 1) begin
					assign region[k] = img_in[x+k][y+KERNEL_SIZE-1:y];
				end

				mtree #(
					.IN_WIDTH(PX_SIZE),
					.LEVELS($rtoi($ceil($clog2(KERNEL_SIZE*KERNEL_SIZE))))
				) maxer (
					.inputs(region),
					.out(img_out[x/KERNEL_SIZE][y/KERNEL_SIZE])
				);
			end
		end
	endgenerate
endmodule
