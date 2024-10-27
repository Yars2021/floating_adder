`timescale 1ns / 1ps

module exponent_adder_tb;

    reg [7:0] sum;
    
    exponent_adder adder(
        .in_a(8'b1001_0000),
        .in_b(8'b0110_0001),
        .out(sum)
    );
    
    initial begin
        #10 $display("sum = %d", sum);
        #10 $stop;
    end

endmodule
