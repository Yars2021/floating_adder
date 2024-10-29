`timescale 1ns / 1ps

module mantissa_inverter(
    input [23:0] in,
    output [23:0] out
);

wire [23:0] neg;

generate
    for (genvar i = 0; i < 24; i = i + 1) begin
        not(neg[i], in[i]);
    end
endgenerate

mantissa_adder adder(
    .in_a(neg),
    .in_b(24'b0000_0000_0000_0000_0000_0001),
    .out(out)
);

endmodule
