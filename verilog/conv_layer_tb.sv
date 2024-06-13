`timescale 1ns / 1ps

// Convolutional layer testbench
module conv_layer_tb #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 5,
	// Input image channels/features
	parameter INPUT_CHANNELS = 1,
	// Kernel size, assumed to be square
	parameter KERNEL_SIZE = 3,
	// Bits per pixel
	parameter PX_SIZE = 8,
	localparam OUTPUT_SIZE = (INPUT_SIZE - (KERNEL_SIZE-1))
);
	// Test Variables
	integer suite = 0;
	integer test = 0;

	// Geneate log file
	initial begin
		$dumpfile("conv_layer_log.vcd");
		$dumpvars(0);
	end

	reg[INPUT_SIZE-1:0][INPUT_SIZE-1:0][INPUT_CHANNELS-1:0][PX_SIZE-1:0] img_in;
	reg[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0][INPUT_CHANNELS-1:0][PX_SIZE-1:0] kernel_in;
	wire[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0][PX_SIZE-1:0] img_out;
	reg[OUTPUT_SIZE-1:0][OUTPUT_SIZE-1:0][PX_SIZE-1:0] expected;
	conv_layer #(
		.INPUT_SIZE(INPUT_SIZE),
		.INPUT_CHANNELS(INPUT_CHANNELS),
		.KERNEL_SIZE(KERNEL_SIZE),
		.PX_SIZE(PX_SIZE)
	) uut (
		.img_in(img_in),
		.img_out(img_out),
		.kernel(kernel_in)
	);

	initial begin
		suite++;
		test++;
		$write("=== TEST SUITE %0d: 1 CHANNEL CONV LAYER ===\n", suite);
		$write("\tTest %0d.%0d: All zeros...", suite, test);
		img_in = 0;
		kernel_in = 0;
		expected = 0;
		#10;
		if (img_out === expected) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected %0d, Got %0d)\n", expected, img_out);
		end

		test++;
		$write("\tTest %0d.%0d: All ones...", suite, test);
		img_in = {
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1
		};
		kernel_in = {
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1, 8'd1, 8'd1
		};
		expected = {
			8'd9>>3, 8'd9>>3, 8'd9>>3,
			8'd9>>3, 8'd9>>3, 8'd9>>3,
			8'd9>>3, 8'd9>>3, 8'd9>>3
		};
		#10;
		if (img_out === expected) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected %0d, Got %0d)\n", expected, img_out);
		end
	end
endmodule
