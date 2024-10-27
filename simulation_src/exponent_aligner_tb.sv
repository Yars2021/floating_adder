`timescale 1ns / 1ps

module exponent_aligner_tb;

    reg [0:0] a_or_b;
    reg [7:0] out_dist;
    
    exponent_aligner aligner(
        .in_a(8'b1000_0100),
        .in_b(8'b1000_0011),
        .out_a_or_b(a_or_b),
        .out_dist(out_dist)
    );
    
    initial begin
        #10 $display("a_or_b = %b, out_dist = %d", a_or_b, out_dist);
        #10 $stop;
    end

endmodule
