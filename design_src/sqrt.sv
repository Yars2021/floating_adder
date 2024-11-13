module sqrt_module (
    input  logic [31:0] in_value, // Входное значение
    output logic [31:0] out_value // Выходное значение (квадратный корень)
);

    logic [31:0] x; // Переменная для хранения текущего приближения
    logic [31:0] x_next; // Следующее приближение
    logic [31:0] temp; // Временная переменная для хранения промежуточных вычислений logic valid; // Флаг для проверки, является ли входное значение валидным

    always_comb begin
        out_value = 0; // Инициализация выходного значения
        
        // Проверка на нулевое значение
        if (in_value == 0) begin
            out_value = 0;
        end else begin x = in_value >> 1;
            for (int i = 0; i < 10; i++) begin
                temp = x;
                x_next = (temp + (in_value / temp)) >> 1;
                if (temp == x_next) begin
                    break;
                end
                x = x_next;
            end
            out_value = x;
        end
    end

endmodule