`timescale 1ns / 1ps

module high_level_float_adder(
    input logic[31:0] in_a,
    input logic[31:0] in_b,
    output logic[31:0] out
);

logic [24:0] mantissa_a, mantissa_b, mantissa_sum;
logic [7:0] exponent_a, exponent_b;

logic result_sign;
logic [7:0] result_exponent;
logic [22:0] result_mantissa;

assign out = {result_sign, result_exponent, result_mantissa};

always_comb begin
    exponent_a = in_a[30:23];
    exponent_b = in_b[30:23];
    
    mantissa_a = {2'b01, in_a[22:0]};
    mantissa_b = {2'b01, in_b[22:0]};

    if (exponent_a >= exponent_b) begin
        mantissa_b = mantissa_b >> (exponent_a - exponent_b);
        result_exponent = exponent_a;
    end else begin
        mantissa_a = mantissa_a >> (exponent_b - exponent_a);
        result_exponent = exponent_b;
    end

    if (in_a[31] == in_b[31]) begin
        mantissa_sum = mantissa_a + mantissa_b;
        result_sign = in_a[31];  
    end else begin
        if (mantissa_a >= mantissa_b) begin
            mantissa_sum = mantissa_a - mantissa_b;
            result_sign = in_a[31];
        end else begin
            mantissa_sum = mantissa_b - mantissa_a;
            result_sign = in_b[31];
        end
    end
    
    if (mantissa_sum[24] == 1) begin
        mantissa_sum = mantissa_sum >> 1;
        result_exponent = result_exponent + 1;
    end else if (mantissa_sum[23] == 0) begin
        for (int i = 22; i >= 0; i = i - 1) begin
            if (mantissa_sum[i] == 1) begin
                mantissa_sum = mantissa_sum << (22 - i);
                result_exponent = result_exponent - (22 - i);
            end
        end
    end
    
    result_mantissa = mantissa_sum[22:0];
end

endmodule
