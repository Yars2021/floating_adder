`timescale 1ns / 1ps

module mantissa_normalizer(
    input [23:0] in,
    input in_carry,
    output [22:0] out,
    output [7:0] exponent_shift
);

assign out[22:0] = in_carry ? in[23:0] >> 1 :
    in[23] ? in[22:0] :
    in[22] ? in[22:0] << 1 :
    in[21] ? in[22:0] << 2 :
    in[20] ? in[22:0] << 3 :
    in[19] ? in[22:0] << 4 :
    in[18] ? in[22:0] << 5 :
    in[17] ? in[22:0] << 6 :
    in[16] ? in[22:0] << 7 :
    in[15] ? in[22:0] << 8 :
    in[14] ? in[22:0] << 9 :
    in[13] ? in[22:0] << 10 :
    in[10] ? in[22:0] << 11 :
    in[9] ? in[22:0] << 12 :
    in[8] ? in[22:0] << 13 :
    in[7] ? in[22:0] << 14 :
    in[6] ? in[22:0] << 15 :
    in[5] ? in[22:0] << 16 :
    in[4] ? in[22:0] << 17 :
    in[3] ? in[22:0] << 18 :
    in[2] ? in[22:0] << 19 :
    in[1] ? in[22:0] << 20 :
    in[0] ? in[22:0] << 21 :
    0;

assign exponent_shift = in_carry ? -1 :
    in[23] ? 0 :
    in[22] ? 1 :
    in[21] ? 2 :
    in[20] ? 3 :
    in[19] ? 4 :
    in[18] ? 5 :
    in[17] ? 6 :
    in[16] ? 7 :
    in[15] ? 8 :
    in[14] ? 9 :
    in[13] ? 10 :
    in[10] ? 11 :
    in[9] ? 12 :
    in[8] ? 13 :
    in[7] ? 14 :
    in[6] ? 15 :
    in[5] ? 16 :
    in[4] ? 17 :
    in[3] ? 18 :
    in[2] ? 19 :
    in[1] ? 20 :
    in[0] ? 21 :
    0;

endmodule
