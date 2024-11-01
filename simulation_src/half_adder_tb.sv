`timescale 1ns / 1ps

module half_adder_tb;

    reg in_a, in_b, in_carry;
    wire sum, carry;
    
    half_adder adder_l(
        .in_a(in_a),
        .in_b(in_b),
        .out_sum(sum),
        .out_carry(carry)
    );
    
    integer i;
    reg [2:0] test_val;
    
    initial begin
    
        for (i = 0; i < 4; i = i + 1) begin
            test_val = i;
            in_a = test_val[1];
            in_b = test_val[2];
            
            #10 $display("in_a = %b, in_b = %b, out_carry = %b, out_sum = %b", in_a, in_b, carry, sum);
        end
        
        #10 $stop;
        
    end

endmodule
