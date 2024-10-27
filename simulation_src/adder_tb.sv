`timescale 1ns / 1ps

module adder_tb;

    reg in_a, in_b, in_carry;
    wire sum, carry;
    
    full_adder adder_l(
        .in_a(in_a),
        .in_b(in_b),
        .in_carry(in_carry),
        .out_sum(sum),
        .out_carry(carry)
    );
    
    integer i;
    reg [2:0] test_val;
    reg exp_vout;
    
    initial begin
    
        for (i = 0; i < 8; i = i + 1) begin
            test_val = i;
            in_carry = test_val[0];
            in_a = test_val[1];
            in_b = test_val[2];
            
            #10 $display("in_a = %b, in_b = %b, in_carry = %b, out_sum = %b, out_carry = %b", in_a, in_b, in_carry, sum, carry);
        end
        
        #10 $stop;
        
    end
    
endmodule
