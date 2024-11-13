`timescale 1ns / 1ps

module exponent_aligner(
    input [7:0] in_a,
    input [7:0] in_b,
    output out_a_or_b,
    output [7:0] out_dist
);

wire [7:0] inverted_b;
wire [7:0] comparison_result, inverted_comparison_result;

exponent_inverter b_inverter(
    .in(in_b),
    .out(inverted_b)
);

exponent_adder final_adder(
    .in_a(in_a),
    .in_b(inverted_b),
    .out(comparison_result)
);

exponent_inverter final_inverter(
    .in(comparison_result),
    .out(inverted_comparison_result)
);

assign out_a_or_b = (comparison_result[7] == 0) ? 1 : 0; // 1 if a >= b, 0 if a < b
assign out_dist = (comparison_result[7] == 0) ? comparison_result : inverted_comparison_result;

endmodule
