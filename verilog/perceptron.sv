`timescale 1ns / 1ps

// Perceptron
// More output channels can be accomplished with more instances of this module
module perceptron #(
	// Number of inputs
	parameter INPUT_SIZE = 5,
	// Bits per pixel
	parameter PX_SIZE = 8,
	localparam ADDER_OUT_SIZE = PX_SIZE + $clog2(INPUT_SIZE)
) (
	input wire
		[INPUT_SIZE-1:0]
		[PX_SIZE-1:0] img_in,
	input wire
		[INPUT_SIZE-1:0]
		[PX_SIZE-1:0] weights,
	input wire
		[PX_SIZE-1:0] bias,
	output reg
		[PX_SIZE-1:0] img_out
);
	wire
		[INPUT_SIZE-1:0]
		[PX_SIZE-1:0] adder_inputs;
	wire[ADDER_OUT_SIZE-1:0] adder_output;
	atree #(
		.IN_WIDTH(PX_SIZE),
		.LEVELS($rtoi($ceil($clog2(INPUT_SIZE+1))))
	) adder (
		.inputs(adder_inputs),
		.out(adder_output)
	);
	assign img_out = adder_output[ADDER_OUT_SIZE-1:ADDER_OUT_SIZE-PX_SIZE-1];
	assign adder_inputs[0] = bias;

	genvar i;
	generate
		// Start offset to make room for bias term
		for (i = 1; i <= INPUT_SIZE; i += 1) begin
			assign adder_inputs[i] = img_in[i] * weights[i];
		end
	endgenerate
endmodule
