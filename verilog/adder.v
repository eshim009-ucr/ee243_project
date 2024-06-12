`timescale 1ns / 1ps

// Wrapper for non-blocking addition of 2 numbers
module adder #(
	// Width in bits of each input
	parameter IN_WIDTH = 32
)(
	// First addend
	input wire[IN_WIDTH-1:0] a,
	// Second adend
	input wire[IN_WIDTH-1:0] b,
	// Sum, including carryout
	output reg[IN_WIDTH:0] sum
);
	always @(a, b) begin
		sum <= a + b;
	end
endmodule
