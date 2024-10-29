`timescale 1ns / 1ps

module mantissa_adder(
    input [23:0] in_a,
    input [23:0] in_b,
    output [23:0] out,
    output out_carry
);

wire [24:0] carry;
assign carry[0] = 0;

generate
    for (genvar i = 0; i < 24; i = i + 1) begin
        full_adder adder(
            .in_a(in_a[i]),
            .in_b(in_b[i]),
            .in_carry(carry[i]),
            .out_sum(out[i]),
            .out_carry(carry[i + 1])
        );
    end
endgenerate

assign out_carry = carry[24];

endmodule
