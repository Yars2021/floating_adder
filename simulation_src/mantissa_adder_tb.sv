`timescale 1ns / 1ps

module mantissa_adder_tb;

    reg [23:0] sum;
    reg carry;
    
    mantissa_adder adder(
        .in_a(24'b0001_0000_0000_0000_0100_1000),
        .in_b(24'b0111_0000_0000_0000_0011_0001),
        .out(sum),
        .out_carry(carry)
    );
    
    initial begin
        #10 $display("sum = %d", sum);
        #10 $stop;
    end
    
endmodule
