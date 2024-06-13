`timescale 1ns / 1ps

// Rectifier Layer
module relu_layer #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 5,
	// Bits per pixel
	parameter PX_SIZE = 8
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_in,
	output reg
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_out
);
	genvar x, y;

	generate
		for (x = 0; x < INPUT_SIZE; x += 1) begin
			for (y = 0; y < INPUT_SIZE; y += 1) begin
				always @(img_in[x][y]) begin
					img_out[x][y] <= (img_in[x][y] > 0) ? img_in[x][y] : 0;
				end
			end
		end
	endgenerate
endmodule
