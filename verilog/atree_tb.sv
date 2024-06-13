`timescale 1ns / 1ps

// Adder tree testbench
module atree_tb #(
	parameter IN_WIDTH=8
);
	// Test Variables
	integer suite = 0;
	integer test = 0;

	// Geneate log file
	initial begin
		$dumpfile("atree_tb_log.vcd");
		$dumpvars(0);
	end

	// 2 level tree
	reg[3:0][IN_WIDTH-1:0] inputs2;
	wire[IN_WIDTH+1:0] output2;
	reg[IN_WIDTH+1:0] expected2;
	atree #(
		.IN_WIDTH(IN_WIDTH),
		.LEVELS(2)
	) uut2 (
		.inputs(inputs2),
		.out(output2)
	);

	// 4 level tree
	reg[15:0][IN_WIDTH-1:0] inputs4;
	wire[IN_WIDTH+3:0] output4;
	reg[IN_WIDTH+3:0] expected4;
	atree #(
		.IN_WIDTH(IN_WIDTH),
		.LEVELS(4)
	) uut4 (
		.inputs(inputs4),
		.out(output4)
	);

	initial begin
		suite++;
		test++;
		$write("=== TEST SUITE %0d: 2 LEVEL TREE ===\n", suite);
		$write("\tTest %0d.%0d: All zeros...", suite, test);
		inputs2 = 0;
		expected2 = 0;
		#10;
		if (output2 === expected2) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected %0d, Got %0d)\n", expected2, output2);
		end

		test++;
		$write("\tTest %0d.%0d: All ones...", suite, test);
		inputs2 = -32'sd1;
		expected2 = {10'b11_1111_1100};
		#10;
		if (output2 === expected2) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected 0x%0h, Got 0x%0h)\n", expected2, output2);
		end

		test++;
		$write("\tTest %0d.%0d: Some random unsigned numbers...", suite, test);
		inputs2 = {8'd65, 8'd42, 8'd37, 8'd9};
		expected2 = 10'd65 + 10'd42 + 10'd37 + 10'd9;
		#10;
		if (output2 === expected2) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected 0x%0h, Got 0x%0h)\n", expected2, output2);
		end


		suite++;
		test = 1;
		$write("=== TEST SUITE %0d: 4 LEVEL TREE ===\n", suite);
		$write("\tTest %0d.%0d: All zeros...", suite, test);
		inputs4 = 0;
		expected4 = 0;
		#10;
		if (output4 === expected4) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected %0d, Got %0d)\n", expected4, output4);
		end

		test++;
		$write("\tTest %0d.%0d: All ones...", suite, test);
		inputs4 = -128'sd1;
		expected4 = {24'b1111_1111_0000};
		#10;
		if (output4 === expected4) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected 0x%0h, Got 0x%0h)\n", expected4, output4);
		end

		test++;
		$write("\tTest %0d.%0d: Some random unsigned numbers...", suite, test);
		inputs4 = {
			8'd23, 8'd47, 8'd88, 8'd79,
			8'd98, 8'd52, 8'd93, 8'd89,
			8'd93, 8'd46, 8'd37, 8'd101,
			8'd26, 8'd89, 8'd27, 8'd9
		};
		expected4 = (
			24'd23 + 24'd47 + 24'd88 + 24'd79 +
			24'd98 + 24'd52 + 24'd93 + 24'd89 +
			24'd93 + 24'd46 + 24'd37 + 24'd101 +
			24'd26 + 24'd89 + 24'd27 + 24'd9
		);
		#10;
		if (output4 === expected4) begin
			$write("Passed!\n");
		end else begin
			$write("Failed! (Expected 0x%0h, Got 0x%0h)\n", expected4, output4);
		end
	end
endmodule
