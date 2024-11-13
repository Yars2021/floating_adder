module sqrt_tb;

    // ���������
    logic [31:0] in_value; // ������� ��������
    logic [31:0] out_value; // �������� �������� (���������� ������)

    // ��������������� ������ sqrt2
    sqrt uut (
        .in_value(in_value),
        .out_value(out_value)
    );

    // ��������� ��� ��������� ������
    initial begin
        // ������������� �������� ��������
        in_value = 0;
        #10;

        // ��������� ��������� �������� ��������
        for (int i = 0; i < 10; i++) begin
            in_value = $urandom_range(0, 100); // ��������� ���������� ����� �� 0 �� 100
            #10; // ���� ��������� ����� ��� ���������
            $display("Input: %0d, Output: %0d", in_value, out_value);
        end

        for (int i = 0; i <= 10; i++) begin
            in_value = i * i; // ��������� ���������� ����� �� 0 �� 100
            #10; // ���� ��������� ����� ��� ���������
            $display("Input: %0d, Output: %0d", in_value, out_value);
        end

        // ���������� ���������
        $finish;
    end

endmodule
