`timescale 1ns / 1ps

module pipelined_float_adder(
    input clk_i,
    input rst_i,
    input inp_rdy,

    output logic [4:0] stage_status,
    output logic [4:0] data_status,
    
    input [31:0] in_a,
    input [31:0] in_b,
    output logic [31:0] out_sum
);


// Stage 0 (Taking input)
logic stage_0_sign_a, stage_0_sign_b;
logic [7:0] stage_0_exponent_a, stage_0_exponent_b;
logic [24:0] stage_0_mantissa_a, stage_0_mantissa_b;

// Stage 1 (Aligning)
logic stage_1_sign_a, stage_1_sign_b;
logic [7:0] stage_1_exponent_result;
logic [24:0] stage_1_mantissa_a, stage_1_mantissa_b;

// Stage 2 (Adding)
logic stage_2_sign_result;
logic [7:0] stage_2_exponent_result;
logic [24:0] stage_2_mantissa_sum;

// Stage 3 (Normalizing)
logic stage_3_sign_result;
logic [7:0] stage_3_exponent_result;
logic [24:0] stage_3_mantissa_result;


always_ff @(posedge clk_i) begin
    if (rst_i) begin
        stage_status <= 5'b11111;
        data_status <= 5'b00000;
    end else begin
        // Stage 0 (Reading input)
        if (stage_status[0] == 1 && inp_rdy) begin
            stage_status[0] <= 0;
            data_status[0] <= 0;
        
            stage_0_sign_a <= in_a[31];
            stage_0_sign_b <= in_b[31];
            
            stage_0_exponent_a <= in_a[30:23];
            stage_0_exponent_b <= in_b[30:23];
            
            stage_0_mantissa_a <= {2'b01, in_a[22:0]};
            stage_0_mantissa_b <= {2'b01, in_b[22:0]};
            
            data_status[0] <= 1;
        end
        
        // Stage 1 (Aligning)
        if (stage_status[1] && data_status[0]) begin
            stage_status[1] <= 0;
            data_status[1] <= 0;
        
            stage_1_sign_a <= stage_0_sign_a;
            stage_1_sign_b <= stage_0_sign_b;
        
            if (stage_0_exponent_a >= stage_0_exponent_b) begin
                stage_1_mantissa_a <= stage_0_mantissa_a;
                stage_1_mantissa_b <= stage_0_mantissa_b >> (stage_0_exponent_a - stage_0_exponent_b);
                stage_1_exponent_result <= stage_0_exponent_a;
            end else begin
                stage_1_mantissa_a <= stage_0_mantissa_a >> (stage_0_exponent_b - stage_0_exponent_a);
                stage_1_mantissa_b <= stage_0_mantissa_b;
                stage_1_exponent_result <= stage_0_exponent_b;
            end
            
            data_status[1] <= 1;
            data_status[0] <= 0;
            stage_status[0] <= 1;
        end
        
        // Stage 2 (Adding)
        if (stage_status[2] && data_status[1]) begin
            stage_status[2] <= 0;
            data_status[2] <= 0;
            
            stage_2_exponent_result <= stage_1_exponent_result;
    
            if (stage_1_sign_a == stage_1_sign_b) begin
                stage_2_mantissa_sum <= stage_1_mantissa_a + stage_1_mantissa_b;
                stage_2_sign_result <= stage_1_sign_a;  
            end else begin
                if (stage_1_mantissa_a >= stage_1_mantissa_b) begin
                    stage_2_mantissa_sum <= stage_1_mantissa_a - stage_1_mantissa_b;
                    stage_2_sign_result <= stage_1_sign_a;
                end else begin
                    stage_2_mantissa_sum <= stage_1_mantissa_b - stage_1_mantissa_a;
                    stage_2_sign_result <= stage_1_sign_b;
                end
            end

            data_status[2] <= 1;
            data_status[1] <= 0;
            stage_status[1] <= 1;
        end
        
        // Stage 3 (Normalizing)
        if (stage_status[3] && data_status[2]) begin
            stage_status[3] <= 0;
            data_status[3] <= 0;
            
            stage_3_sign_result <= stage_2_sign_result;
            
            if (stage_2_mantissa_sum[24] == 1) begin
                stage_3_mantissa_result <= stage_2_mantissa_sum >> 1;
                stage_3_exponent_result = stage_2_exponent_result + 1;
            end else if (stage_2_mantissa_sum[23] == 0) begin
                for (int i = 22; i >= 0; i = i - 1) begin
                    if (stage_2_mantissa_sum[i] == 1) begin
                        stage_3_mantissa_result <= stage_2_mantissa_sum << (23 - i);
                        stage_3_exponent_result <= stage_2_exponent_result - (23 - i);
                        break;
                    end
                end
            end

            data_status[3] <= 1;
            data_status[2] <= 0;
            stage_status[2] <= 1;
        end
        
        // Stage 4 (Giving output)
        if (stage_status[4] && data_status[3]) begin
            stage_status[4] <= 0;
            data_status[4] <= 0;
        
            out_sum <= {stage_3_sign_result, stage_3_exponent_result, stage_3_mantissa_result[22:0]};
        
            data_status[4] <= 1;
            data_status[3] <= 0;
            stage_status[3] <= 1;
            stage_status[4] <= 1;
        end
    end
end

endmodule
