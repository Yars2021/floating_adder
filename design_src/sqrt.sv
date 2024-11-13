module sqrt_module (
    input  logic [31:0] in_value, // ������� ��������
    output logic [31:0] out_value // �������� �������� (���������� ������)
);

    logic [31:0] x; // ���������� ��� �������� �������� �����������
    logic [31:0] x_next; // ��������� �����������
    logic [31:0] temp; // ��������� ���������� ��� �������� ������������� ���������� logic valid; // ���� ��� ��������, �������� �� ������� �������� ��������

    always_comb begin
        out_value = 0; // ������������� ��������� ��������
        
        // �������� �� ������� ��������
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