`timescale 1ns / 1ps


module pipelined_float_adder_tb;

logic clk, rst, inp_rdy;
logic [4:0] stage_status, data_status;
logic [31:0] float_a, float_b, float_sum;

pipelined_float_adder float_adder(
    .clk_i(clk),
    .rst_i(rst),
    .inp_rdy(inp_rdy),
    
    .stage_status(stage_status),
    .data_status(data_status),
    
    .in_a(float_a),
    .in_b(float_b),
    .out_sum(float_sum)
);

initial begin
    while (1) begin
        #1 clk <= 1;
        #1 clk <= 0;
    end
end

initial begin
    rst <= 1;
    #5
    rst <= 0;
    
    float_a <= 32'b1_01111101_10011001100110011001101;
    float_b <= 32'b0_01111101_00110011001100110011010;

    inp_rdy <= 1;
    #5
    inp_rdy <= 0;

    #50
    $display("Output = %b\n", float_sum);
    
    $stop;
end

endmodule
