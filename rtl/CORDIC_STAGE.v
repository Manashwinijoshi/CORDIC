
module CORDIC_STAGE (
    input wire clk,
    input wire rst,
    input wire [31:0] x_in,
    input wire [31:0] y_in,
    input wire [31:0] z_in,
    input wire cos_neg_in,
    input wire sin_neg_in,
    input wire [3:0] stage,
    output reg [31:0] x_out,
    output reg [31:0] y_out,
    output reg [31:0] z_out,
    output reg cos_neg_out,
    output reg sin_neg_out
);

    wire [31:0] atan_val;
    wire [31:0] x_shifted;
    wire [31:0] y_shifted;
    wire dir;
    
    wire [31:0] x_new;
    wire [31:0] y_new;
    wire [31:0] z_new;

    ROM rom (.addr(stage), .data(atan_val));

    FP_SHIFT_RIGHT shift_x (.val_in(x_in), .shift_amt(stage), .val_out(x_shifted));
    FP_SHIFT_RIGHT shift_y (.val_in(y_in), .shift_amt(stage), .val_out(y_shifted));

    assign dir = z_in[31];

    FP_ADD_SUB add_x (
        .clk(clk),
        .rst(rst),
        .In1(x_in),
        .In2(y_shifted),
        .en(dir),
        .out(x_new)
    );

    FP_ADD_SUB add_y (
        .clk(clk),
        .rst(rst),
        .In1(y_in),
        .In2(x_shifted),
        .en(~dir),
        .out(y_new)
    );

    FP_ADD_SUB add_z (
        .clk(clk),
        .rst(rst),
        .In1(z_in),
        .In2(atan_val),
        .en(dir),
        .out(z_new)
    );

    always @(posedge clk) begin
        if (rst) begin
            x_out <= 32'h00000000;
            y_out <= 32'h00000000;
            z_out <= 32'h00000000;
            cos_neg_out <= 1'b0;
            sin_neg_out <= 1'b0;
        end
        else begin
            x_out <= x_new;
            y_out <= y_new;
            z_out <= z_new;
            cos_neg_out <= cos_neg_in;
            sin_neg_out <= sin_neg_in;
        end
    end

endmodule
