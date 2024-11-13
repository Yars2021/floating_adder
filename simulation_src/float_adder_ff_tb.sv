`timescale 1ns / 1ps


module float_adder_ff_tb;

logic clk;
logic rst;
logic [31:0] in_a;
logic [31:0] in_b;
logic start_i;
logic busy_o;
logic [31:0] out_sum;

float_adder_ff float_adder(
    .clk_i(clk),
    .rst_i(rst),
    .in_a(in_a),
    .in_b(in_b),
    .start_i(start_i),
    .busy_o(busy_o),
    .out_sum(out_sum)
);

int ctr = 0;

initial begin
    rst <= 1;
    
    clk <= 0; 
    #1
    clk <= 1;
    #1
    clk <= 0;
    
    rst <= 0;
 
    #1
    in_a <= 32'b1_01111101_10011001100110011001101;
    in_b <= 32'b0_01111101_00110011001100110011010;
    clk <= 1;
    start_i <= 1;
    #1
    clk <= 0;
    #1
    ctr = 0;
    
    while (busy_o) begin
        clk <= 1;
        #1
        clk <= 0;
        #1

        ctr++;
    end
    
    #10
    
    $display("Float sum = %b", out_sum);
    $display("Ticks: %d", ctr);
    $stop;
end

endmodule
