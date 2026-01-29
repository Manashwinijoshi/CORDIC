module POST_PROCESSING_UNIT (
    input wire signed [15:0] Cordic_x_in,
    input wire signed [15:0] Cordic_y_in,
    input wire Cos_negate_in,
    output wire signed [15:0] Cos,
    output wire signed [15:0] Sin
);

    wire signed [15:0] temp_cos;

    assign temp_cos = (Cos_negate_in) ? -Cordic_x_in : Cordic_x_in;
    
    assign Cos = temp_cos;
    assign Sin = Cordic_y_in;

endmodule
