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


// Состояния
localparam WAIT_FOR_INPUT = 2'b00;
localparam SHIFT_OPERANDS = 2'b01;
localparam CALCULATE_FSUM = 2'b10;
localparam NORMALIZE_FSUM = 2'b11;


// Общие переменные
logic [24:0] mantissa_a, mantissa_b;
logic [7:0] exponent_a, exponent_b;
logic sign_a, sign_b;

logic result_sign;
logic [7:0] result_exponent;
logic [22:0] result_mantissa;


// Учет состояния
logic [1:0] state;

assign busy_o = (state > 0);


// Для SHIFT_OPERANDS
logic [7:0] exponent_ab_diff, exponent_ba_diff;
logic [24:0] shifted_mantissa_a, shifted_mantissa_b;
logic [24:0] shifted_mantissa_a_reg, shifted_mantissa_b_reg;

assign exponent_ab_diff = exponent_a - exponent_b;
assign exponent_ba_diff = exponent_b - exponent_a;

assign shifted_mantissa_a = mantissa_a >> exponent_ba_diff;
assign shifted_mantissa_b = mantissa_b >> exponent_ab_diff;


// Для CALCULATE_FSUM
logic [24:0] mantissa_sum;


// Для NORMALIZE_FSUM
logic normalized;
logic [4:0] normalization_current, normalization_current_dec;
logic [7:0] result_exponent_inc, result_exponent_dec;
logic [24:0] left_shifted_mantissa_sum;

assign result_exponent_inc = result_exponent + 1;
assign normalization_current_dec = normalization_current - 1;
assign left_shifted_mantissa_sum = mantissa_sum << (23 - normalization_current);
assign result_exponent_dec = result_exponent - (23 - normalization_current);


always_ff @(posedge clk_i) begin
    if (rst_i) begin
        // Сброс всех внутренних регистров и возврат в состояние ожидания
        state <= WAIT_FOR_INPUT;
        
        sign_a <= 1'b0;
        sign_b <= 1'b0;
        
        exponent_a <= 8'b00000000;
        exponent_b <= 8'b00000000;
        
        mantissa_a <= 23'b00000000000000000000000;
        mantissa_b <= 23'b00000000000000000000000;

        out_sum <= 32'h00000000;
        
        normalized = 1'b0;
        normalization_current = 5'd22;
    end else begin
        case (state)
            WAIT_FOR_INPUT: // in_a, in_b -> sign_a, sign_b, exponent_a, exponent_b, mantissa_a, mantissa_b
                // Чтение входных данных, если передан сигнал о начале работы
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
                // Выравнивание мантисс и порядков 
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
                // Сложение сдвинутых операндов
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
                // Нормализация суммы и вывод результата
                begin
                    if (normalized) begin
                        state <= WAIT_FOR_INPUT;
                        out_sum <= {result_sign, result_exponent, result_mantissa};
                    end else begin
                        if (mantissa_sum[24] == 1) begin // Сдвигаем вправо
                            result_mantissa <= mantissa_sum >> 1;
                            result_exponent <= result_exponent_inc;
                            normalized <= 1'b1;
                        end else if (mantissa_sum[23] == 1) begin // Ничего не сдвигаем
                            result_mantissa <= mantissa_sum;
                            normalized <= 1'b1;
                        end else if (mantissa_sum[normalization_current] == 1) begin // Сдвигаем влево, если нашли 1
                            result_mantissa <= left_shifted_mantissa_sum;
                            result_exponent <= result_exponent_dec;
                            normalized <= 1'b1;
                        end else if (normalization_current == 0) begin // Если дошли до 0 и не нашли 1, ничего не делаем и завершаемся
                            normalized <= 1'b1;
                        end else begin // Двигаем расстояние сдвига, если не нашли 1
                            normalization_current <= normalization_current_dec;
                        end
                    end
                end
        endcase
    end 
end

endmodule