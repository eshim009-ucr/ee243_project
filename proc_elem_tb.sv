`timescale 1ns / 1ps

// Adder tree testbench
module proc_elem_tb #(
	// Width of the kernel, assumed to be square
	parameter KERNEL_SIZE = 3,
	// Number of bits in each pixel
	parameter PX_SIZE = 8,
	localparam NUM_INPUTS = KERNEL_SIZE * KERNEL_SIZE,
	localparam ADDER_IN_SIZE = 2*PX_SIZE,
	localparam ADDER_OUT_SIZE = ADDER_IN_SIZE + $clog2(NUM_INPUTS)
);
	// Test Variables
	integer suite = 0;
	integer test = 0;

	// Geneate log file
	initial begin
		$dumpfile("proc_elem_log.vcd");
		$dumpvars(0);
	end

	reg[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0][PX_SIZE-1:0] img_in;
	reg[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0][PX_SIZE-1:0] kernel_in;
	wire[ADDER_OUT_SIZE-1:0] img_out;
	reg[ADDER_OUT_SIZE-1:0] expected;
	proc_elem #(
		.KERNEL_SIZE(KERNEL_SIZE),
		.PX_SIZE(PX_SIZE)
	) uut (
		.img_in(img_in),
		.img_out(img_out),
		.kernel_in(kernel_in)
	);

	initial begin
		suite++;
		test++;
		$write("=== TEST SUITE %0d: 2 LEVEL TREE ===\n", suite);
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
			8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1
		};
		kernel_in = {
			8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1,
			8'd1, 8'd1, 8'd1
		};
		expected = 8'd9;
		#10;
		if (img_out === expected) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected %0d, Got %0d)\n", expected, img_out);
		end
	end
endmodule
