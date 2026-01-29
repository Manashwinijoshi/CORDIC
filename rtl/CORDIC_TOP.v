
module CORDIC_TOP (
    input wire Clk,
    input wire Reset,
    input wire signed [17:0] Input_angle,
    output wire signed [15:0] Cos_out,
    output wire signed [15:0] Sin_out
);

    parameter STAGES = 16; 
    
    wire signed [15:0] Reduced_angle;
    wire cos_negate_pre;
    
    wire signed [15:0] cordic_x_out;
    wire signed [15:0] cordic_y_out;
    wire cos_negate_out;
    
    reg signed [15:0] initial_x_reg;
    reg signed [15:0] initial_y_reg;
    reg signed [15:0] initial_z_reg;
    reg initial_cos_negate_reg;
    
    // CORDIC gain K = 0.607252935 in Q1.15 format
    // K × 2^15 = 0.607252935 × 32768 = 19897 = 0x4DB9
    localparam signed [15:0] CORDIC_GAIN = 16'sh4DB9; // 19897 = 0.6073 in Q1.15

    PRE_PROCESSING_UNIT PIPU (
        .Input_angle(Input_angle),
        .Reduced_angle(Reduced_angle),
        .Cos_negate(cos_negate_pre)
    );

    always @(posedge Clk) begin
        if (Reset) begin
            initial_x_reg <= 16'b0;
            initial_y_reg <= 16'b0;
            initial_z_reg <= 16'b0;
            initial_cos_negate_reg <= 1'b0;
        end
        else begin
            initial_x_reg <= CORDIC_GAIN; // X starts at K for gain compensation
            initial_y_reg <= 16'b0; // Y starts at 0
            initial_z_reg <= Reduced_angle; // Z starts at target angle
            initial_cos_negate_reg <= cos_negate_pre;
        end
    end

    CORDIC_PIPELINE #(
        .STAGES(STAGES)
    ) CP (
        .Clk(Clk),
        .Reset(Reset),
        .Initial_x(initial_x_reg),
        .Initial_y(initial_y_reg),
        .Initial_z(initial_z_reg),
        .Initial_cos_negate(initial_cos_negate_reg),
        .Final_cordic_x(cordic_x_out),
        .Final_cordic_y(cordic_y_out),
        .Final_cos_negate(cos_negate_out)
    );

    POST_PROCESSING_UNIT POPU (
        .Cordic_x_in(cordic_x_out),
        .Cordic_y_in(cordic_y_out),
        .Cos_negate_in(cos_negate_out),
        .Cos(Cos_out),
        .Sin(Sin_out)
    );

endmodule
