`timescale 1ns / 1ps

// Wrapper for non-blocking comparison of 2 numbers
module max #(
	// Width in bits of each input
	parameter IN_WIDTH = 32
)(
	// First number
	input wire[IN_WIDTH-1:0] a,
	// Second number
	input wire[IN_WIDTH-1:0] b,
	// Bigger of a and b
	output reg[IN_WIDTH-1:0] out
);
	always @(a, b) begin
		out <= (a>b) ? a : b;
	end
endmodule
