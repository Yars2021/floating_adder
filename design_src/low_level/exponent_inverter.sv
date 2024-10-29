`timescale 1ns / 1ps

module exponent_inverter(
    input [7:0] in,
    output [7:0] out
);

wire [7:0] neg;

generate
    for (genvar i = 0; i < 8; i = i + 1) begin
        not(neg[i], in[i]);
    end
endgenerate

exponent_adder adder(
    .in_a(neg),
    .in_b(8'b0000_0001),
    .out(out)
);

endmodule
