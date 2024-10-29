`timescale 1ns / 1ps

module half_adder(
    input in_a,
    input in_b,
    output out_sum,
    output out_carry
);

xor(out_sum, in_a, in_b);
and(out_carry, in_a, in_b); 

endmodule
