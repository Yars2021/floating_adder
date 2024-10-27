`timescale 1ns / 1ps

module mantissa_normalizer_tb;

    reg [22:0] normal;
    reg [7:0] exponent_shift;
    
    mantissa_normalizer normalizer(
        .in(24'b0000_1000_1111_0101_1100_0011),
        .in_carry(0),
        .out(normal),
        .exponent_shift(exponent_shift)
    );

    initial begin
        #10 $display("normal = %d shift = %d", normal, exponent_shift);
        #10 $stop;
    end

endmodule
