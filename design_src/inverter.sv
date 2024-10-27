`timescale 1ns / 1ps

module inverter(
    input in[22:0],
    output out[22:0]        
);

wire neg_in[22:0];

not(neg_in, in);

endmodule
