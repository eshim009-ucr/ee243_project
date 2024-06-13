`timescale 1ns / 1ps

// Rectifier Layer
module relu_layer #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 5,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
	// Bits per pixel
	parameter PX_SIZE = 8
) (
	input wire
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_in,
	output reg
		[INPUT_SIZE-1:0][INPUT_SIZE-1:0]
		[INPUT_CHANNELS-1:0]
		[PX_SIZE-1:0] img_out
);
	genvar x, y;

	generate
		for (x = 0; x < INPUT_SIZE; x += 1) begin
			for (y = 0; y < INPUT_SIZE; y += 1) begin
				for (c = 0; c < INPUT_CHANNELS; c += 1) begin
					always @(img_in[x][y][c]) begin
						if (img_in[x][y][c] > 0) begin
							img_out[x][y][c] = img_in[x][y][c];
						end else begin
							img_out[x][y][c] = 0;
						end
					end
				end
			end
		end
	endgenerate
endmodule
