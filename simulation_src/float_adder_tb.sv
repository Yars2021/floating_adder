`timescale 1ns / 1ps

module float_adder_tb;

    reg [31:0] sum;
    
    float_adder adder(
        .in_a(32'b1_01111101_10011001100110011001101), // -0.4
        .in_b(32'b0_01111101_00110011001100110011010), // 0.3
        .out(sum)
    );
    
    initial begin
        #10 $display("sum = %b", sum);
        #10 $stop;
    end

endmodule
