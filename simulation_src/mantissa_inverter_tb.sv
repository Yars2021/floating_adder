`timescale 1ns / 1ps

module mantissa_inverter_tb;

    reg [23:0] inv;
    
    mantissa_inverter inverter(
        .in(24'b0000_0000_0000_0000_1111_0000),
        .out(inv)
    );
    
    initial begin
        #10 $display("inv = %d", inv);
        #10 $stop;
    end
    
endmodule
