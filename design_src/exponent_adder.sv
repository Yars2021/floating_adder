`timescale 1ns / 1ps

module exponent_adder(
    input [7:0] in_a,
    input [7:0] in_b,
    output [7:0] out
);

wire [8:0] carry;
assign carry[0] = 0;

generate
    for (genvar i = 0; i < 8; i = i + 1) begin
        full_adder adder(
            .in_a(in_a[i]),
            .in_b(in_b[i]),
            .in_carry(carry[i]),
            .out_sum(out[i]),
            .out_carry(carry[i + 1])
        );
    end
endgenerate

endmodule
