`timescale 1ns / 1ps

module high_level_float_adder_tb;

    reg [31:0] sum;
    
    high_level_float_adder adder(
        .in_a(32'b0_10000011_10110010111000010100100), // 27.18
        .in_b(32'b1_10000000_10010010000111001010110), // -3.1415
        .out(sum)
    );
    
    initial begin
        #10 $display("sum = %b", sum);
        #10 $stop;
    end

endmodule
