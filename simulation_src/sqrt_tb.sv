module sqrt_tb;

    // Параметры
    logic [31:0] in_value; // Входное значение
    logic [31:0] out_value; // Выходное значение (квадратный корень)

    // Инстанцирование модуля sqrt2
    sqrt uut (
        .in_value(in_value),
        .out_value(out_value)
    );

    // Процедура для генерации тестов
    initial begin
        // Инициализация входного значения
        in_value = 0;
        #10;

        // Генерация случайных тестовых значений
        for (int i = 0; i < 10; i++) begin
            in_value = $urandom_range(0, 100); // Генерация случайного числа от 0 до 100
            #10; // Ждем некоторое время для обработки
            $display("Input: %0d, Output: %0d", in_value, out_value);
        end

        for (int i = 0; i <= 10; i++) begin
            in_value = i * i; // Генерация случайного числа от 0 до 100
            #10; // Ждем некоторое время для обработки
            $display("Input: %0d, Output: %0d", in_value, out_value);
        end

        // Завершение симуляции
        $finish;
    end

endmodule
