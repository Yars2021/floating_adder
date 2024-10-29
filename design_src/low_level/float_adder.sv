`timescale 1ns / 1ps

module float_adder(
    input [31:0] in_a,
    input [31:0] in_b,
    output [31:0] out
);

wire a_or_b;
wire [7:0] exp_shift_dist, estimated_result_exponent; 
wire [23:0] mantissa_a, mantissa_b, aligned_mantissa_a, aligned_mantissa_b;
wire [23:0] inv_aligned_mantissa_a, inv_aligned_mantissa_b, aligned_mantissa_diff;
wire [23:0] aligned_mantissa_sub_ab, aligned_mantissa_sub_ba;
wire [23:0] aligned_mantissa_sum, aligned_mantissa_sub;
wire aligned_mantissa_sub_carry_ab, aligned_mantissa_sub_carry_ba;
wire aligned_mantissa_sum_carry, aligned_mantissa_sub_carry, invert_result_sign;
wire [7:0] sum_exp_shift, sub_exp_shift, sum_exponent, sub_exponent;
wire [22:0] normalized_sum, normalized_sub;

// 1. a_or_b, dist = exponent_aligner(E1, E2)
exponent_aligner exp_aligner(
    .in_a(in_a[30:23]),
    .in_b(in_b[30:23]),
    .out_a_or_b(a_or_b),
    .out_dist(exp_shift_dist)
);

// 2. prepend 1 to both mantissas
assign mantissa_a[23] = 1, mantissa_b[23] = 1;
assign mantissa_a[22:0] = in_a[22:0];
assign mantissa_b[22:0] = in_b[22:0];

// 3. align mantissas for the exponents to match
assign estimated_result_exponent = a_or_b ? in_a[30:23] : in_b[30:23]; // largest of the two
assign aligned_mantissa_a = a_or_b ? mantissa_a : mantissa_a >> exp_shift_dist; // exp_a >= exp_b, return exp_a : shift exp_a
assign aligned_mantissa_b = a_or_b ? mantissa_b >> exp_shift_dist : mantissa_b; // exp_a >= exp_b, shift exp_b : return exp_b

// 4.1 add mantissas
mantissa_adder aligned_adder(
    .in_a(aligned_mantissa_a),
    .in_b(aligned_mantissa_b),
    .out(aligned_mantissa_sum),
    .out_carry(aligned_mantissa_sum_carry)
);

// 4.2 subtract mantissas and set result sign
mantissa_adder aligned_comparator(
    .in_a(aligned_mantissa_a),
    .in_b(inv_aligned_mantissa_b),
    .out(aligned_mantissa_diff)
);

mantissa_inverter aligned_inverter_a(
    .in(aligned_mantissa_a),
    .out(inv_aligned_mantissa_a)
);

mantissa_inverter aligned_inverter_b(
    .in(aligned_mantissa_b),
    .out(inv_aligned_mantissa_b)
);

mantissa_adder aligned_subtractor_a_b(
    .in_a(aligned_mantissa_a),
    .in_b(inv_aligned_mantissa_b),
    .out(aligned_mantissa_sub_ab),
    .out_carry(aligned_mantissa_sub_carry_ab)
);

mantissa_adder aligned_subtractor_b_a(
    .in_a(aligned_mantissa_b),
    .in_b(inv_aligned_mantissa_a),
    .out(aligned_mantissa_sub_ba),
    .out_carry(aligned_mantissa_sub_carry_ba)
);

assign invert_result_sign = aligned_mantissa_diff[23];
assign aligned_mantissa_sub = aligned_mantissa_diff[23] ? aligned_mantissa_sub_ba : aligned_mantissa_sub_ab;
assign aligned_mantissa_sub_carry = aligned_mantissa_diff[23] ? aligned_mantissa_sub_carry_ba : aligned_mantissa_sub_carry_ab;

// 5. normalize result
mantissa_normalizer sum_normalizer(
    .in(aligned_mantissa_sum),
    .in_carry(aligned_mantissa_sum_carry),
    .out(normalized_sum),
    .exponent_shift(sum_exp_shift) // number of shifts to normalize
);

mantissa_normalizer sub_normalizer(
    .in(aligned_mantissa_sub),
    .in_carry(aligned_mantissa_sub_carry),
    .out(normalized_sub),
    .exponent_shift(sub_exp_shift) // number of shifts to normalize
);

// 6. shift exponent according to the normalization result
assign sum_exponent = (sum_exp_shift == -1) ? estimated_result_exponent + 1 : estimated_result_exponent - sum_exp_shift;
assign sub_exponent = (sub_exp_shift == -1) ? estimated_result_exponent + 1 : estimated_result_exponent - sub_exp_shift;

// 7. select sign mode (S1 = S2 (add) or S1 != S2 (subtract)). check a and b for 0
assign out[30:23] = (in_a == 0) ? in_b[30:23] : (in_b == 0) ? in_a[30:23] : (in_a[31] == in_b[31]) ? sum_exponent : sub_exponent;
assign out[22:0] = (in_a == 0) ? in_b[22:0] : (in_b == 0) ? in_a[22:0] : (in_a[31] == in_b[31]) ? normalized_sum : normalized_sub;
assign out[31] = (in_a[31] == in_b[31]) ? in_a[31] : invert_result_sign ? ~in_a[31] : in_a[31];

endmodule
