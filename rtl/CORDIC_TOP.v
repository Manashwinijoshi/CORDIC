
module CORDIC_TOP (
    input wire clk,
    input wire rst,
    input wire [31:0] input_angle,
    output wire [31:0] cos,
    output wire [31:0] sin
);

    wire [31:0] angle_pre;
    wire cos_neg_pre;
    wire sin_neg_pre;
    wire [31:0] x_pipe;
    wire [31:0] y_pipe;
    wire cos_neg_pipe;
    wire sin_neg_pipe;

    PRE_PROCESSING_UNIT PRE (
        .clk(clk),
        .rst(rst),
        .input_angle(input_angle),
        .registered_angle(angle_pre),
        .cos_neg(cos_neg_pre),
        .sin_neg(sin_neg_pre)
    );

    CORDIC_PIPELINE PIPE (
        .clk(clk),
        .rst(rst),
        .angle_in(angle_pre),
        .cos_neg_in(cos_neg_pre),
        .sin_neg_in(sin_neg_pre),
        .x_out(x_pipe),
        .y_out(y_pipe),
        .cos_neg_out(cos_neg_pipe),
        .sin_neg_out(sin_neg_pipe)
    );

    POST_PROCESSING_UNIT POST (
        .clk(clk),
        .rst(rst),
        .cordic_x(x_pipe),
        .cordic_y(y_pipe),
        .cos_neg(cos_neg_pipe),
        .sin_neg(sin_neg_pipe),
        .cos(cos),
        .sin(sin)
    );

endmodule
