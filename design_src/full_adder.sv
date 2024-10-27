`timescale 1ns / 1ps

module full_adder(
    input in_a,
    input in_b,
    input in_carry,
    output out_sum,
    output out_carry
);

wire op_sum_result, carry_0, carry_1;

half_adder op_sum(
    .in_a(in_a),
    .in_b(in_b),
    .out_sum(op_sum_result),
    .out_carry(carry_0)
);

half_adder carry_sum(
    .in_a(op_sum_result),
    .in_b(in_carry),
    .out_sum(out_sum),
    .out_carry(carry_1)
);

or(out_carry, carry_0, carry_1);

endmodule
