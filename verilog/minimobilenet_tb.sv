`timescale 1ns / 1ps

// Full network testbench
module minimobilenet_tb #(
	// Input size, assumed to be square
	parameter INPUT_SIZE = 32,
	// Input image channels/features
	parameter INPUT_CHANNELS = 3,
	// Bits per pixel
	parameter PX_SIZE = 8,
	// Number of classes
	parameter OUTPUT_CHANNELS = 10
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
	wire[OUTPUT_CHANNELS-1:0][PX_SIZE-1:0] img_out;
	reg[OUTPUT_CHANNELS-1:0][PX_SIZE-1:0] expected;
	integer result;
	minimobilenet #(
		.INPUT_SIZE(INPUT_SIZE),
		.INPUT_CHANNELS(INPUT_CHANNELS),
		.PX_SIZE(PX_SIZE)
	) uut (
		.img_in(img_in),
		.img_out(img_out)
	);

	initial begin
		suite++;
		test++;
		$write("=== TEST SUITE %0d: RUN ON TEST DATA ===\n", suite);
		$write("\tTest %0d.%0d: Test Data 0...", suite, test);
		$readmemb("test_data/i0_l6.coe", img_in);
		expected = 6;
		max = expected;
		#10;
		for (int i = 0; i < OUTPUT_CHANNELS; i += 1) begin
			if (img_out[expected] < img_out[i]) begin
				if (img_out[i] > img_out[max]) max = i;
			end
		end
		if (max === expected) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected %0d, Got %0d)\n", expected, max);
		end
	end
endmodule
