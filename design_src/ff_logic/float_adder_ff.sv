`timescale 1ns / 1ps


module float_adder_ff(
    input clk_i,
    input rst_i,
    input start_i,
    output busy_o,

    input [31:0] in_a,
    input [31:0] in_b,
    output reg [31:0] out_sum
);


// States
localparam WAIT_FOR_INPUT = 2'b00;
localparam SHIFT_OPERANDS = 2'b01;
localparam CALCULATE_FSUM = 2'b10;
localparam NORMALIZE_FSUM = 2'b11;


// Common vars
logic [24:0] mantissa_a, mantissa_b;
logic [7:0] exponent_a, exponent_b;
logic sign_a, sign_b;

reg result_sign;
reg [7:0] result_exponent, normalized_exponent;
reg [22:0] result_mantissa;


// State tracking
logic [1:0] state;

assign busy_o = (state > 0);


// For SHIFT_OPERANDS
logic [7:0] exponent_ab_diff, exponent_ba_diff;
logic [24:0] shifted_mantissa_a, shifted_mantissa_b;
logic [24:0] shifted_mantissa_a_reg, shifted_mantissa_b_reg;

assign exponent_ab_diff = exponent_a - exponent_b;
assign exponent_ba_diff = exponent_b - exponent_a;

assign shifted_mantissa_a = mantissa_a >> exponent_ba_diff;
assign shifted_mantissa_b = mantissa_b >> exponent_ab_diff;


// For CALCULATE_FSUM
logic [24:0] mantissa_sum;


// For NORMALIZE_FSUM
logic normalized;
logic [7:0] normalization_current, normalization_diff, normalization_current_dec;
logic [7:0] result_exponent_inc, result_exponent_dec;
logic [24:0] left_shifted_mantissa_sum, right_shifted_mantissa_sum;

assign result_exponent_inc = result_exponent + 1;
assign right_shifted_mantissa_sum = mantissa_sum >> 1;
assign normalization_current_dec = normalization_current - 1;
assign normalization_diff = 23 - normalization_current;
assign left_shifted_mantissa_sum = mantissa_sum << normalization_diff;
assign result_exponent_dec = result_exponent - normalization_diff;


always_ff @(posedge clk_i) begin
    if (rst_i) begin
        // Reset registers and set state to WAIT_FOR_INPUT
        state <= WAIT_FOR_INPUT;

        sign_a <= 1'b0;
        sign_b <= 1'b0;

        exponent_a <= 8'b00000000;
        exponent_b <= 8'b00000000;

        mantissa_a <= 23'b00000000000000000000000;
        mantissa_b <= 23'b00000000000000000000000;

        out_sum <= 32'h00000000;

        normalized = 1'b0;
        normalization_current = 8'd22;
    end else begin
        case (state)
            WAIT_FOR_INPUT: // in_a, in_b -> sign_a, sign_b, exponent_a, exponent_b, mantissa_a, mantissa_b
                // Read inputs, if start_i is set
                if (start_i) begin
                    state <= SHIFT_OPERANDS;

                    sign_a <= in_a[31];
                    sign_b <= in_b[31];

                    exponent_a <= in_a[30:23];
                    exponent_b <= in_b[30:23];

                    mantissa_a <= {2'b01, in_a[22:0]};
                    mantissa_b <= {2'b01, in_b[22:0]};
                end
            SHIFT_OPERANDS: // sign_a, sign_b, exponent_a, exponent_b, mantissa_a, mantissa_b -> shifted_mantissa_a_reg, shifted_mantissa_b_reg, result_exponent
                // Shifting mantissas and exponents
                begin
                    state <= CALCULATE_FSUM;

                    if (exponent_a >= exponent_b) begin
                        shifted_mantissa_a_reg <= mantissa_a;
                        shifted_mantissa_b_reg <= shifted_mantissa_b;
                        result_exponent <= exponent_a;
                    end else begin
                        shifted_mantissa_a_reg <= shifted_mantissa_a;
                        shifted_mantissa_b_reg <= mantissa_b;
                        result_exponent <= exponent_b;
                    end
                end
            CALCULATE_FSUM: // shifted_mantissa_a_reg, shifted_mantissa_b_reg, result_exponent -> mantissa_sum, result_sign
                // Sum of shifted operands
                begin
                    state <= NORMALIZE_FSUM;

                    if (sign_a == sign_b) begin
                        mantissa_sum <= shifted_mantissa_a_reg + shifted_mantissa_b_reg;
                        result_sign <= sign_a;
                    end else begin
                        if (shifted_mantissa_a_reg >= shifted_mantissa_b_reg) begin
                            mantissa_sum <= shifted_mantissa_a_reg - shifted_mantissa_b_reg;
                            result_sign <= sign_a;
                        end else begin
                            mantissa_sum <= shifted_mantissa_b_reg - shifted_mantissa_a_reg;
                            result_sign <= sign_b;
                        end
                    end
                end
            NORMALIZE_FSUM: // result_sign, result_exponent, mantissa_sum -> out_sum{result_sign, normalized_exponent, result_mantissa}
                // Normalization and reset to WAIT_FOR_INPUT
                begin
                    if (normalized) begin
                        state <= WAIT_FOR_INPUT;
                        out_sum <= {result_sign, normalized_exponent, result_mantissa};
                    end else begin
                        if (mantissa_sum[24] == 1) begin // Right shift
                            result_mantissa <= right_shifted_mantissa_sum[22:0];
                            normalized_exponent <= result_exponent_inc;
                            normalized <= 1'b1;
                        end else if (mantissa_sum[23] == 1) begin // No shift
                            result_mantissa <= mantissa_sum[22:0];
                            normalized_exponent <= result_exponent;
                            normalized <= 1'b1;
                        end else if (mantissa_sum[normalization_current] == 1) begin // Left shift if found 1
                            result_mantissa <= left_shifted_mantissa_sum[22:0];
                            normalized_exponent <= result_exponent_dec;
                            normalized <= 1'b1;
                        end else if (normalization_current == 0) begin // If 1 was not found and normalization_current is 0, finish normalization
                            result_mantissa <= mantissa_sum[22:0];
                            normalized_exponent <= result_exponent;
                            normalized <= 1'b1;
                        end else begin // If 1 was not found, apply decrement to normalization_current
                            normalization_current <= normalization_current_dec;
                        end
                    end
                end
        endcase
    end
end

endmodule
