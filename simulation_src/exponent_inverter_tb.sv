`timescale 1ns / 1ps

module exponent_inverter_tb;

    reg [7:0] inv;
    
    exponent_inverter inverter(
        .in(8'b1111_0000),
        .out(inv)
    );
    
    initial begin
        #10 $display("inv = %d", inv);
        #10 $stop;
    end

endmodule
