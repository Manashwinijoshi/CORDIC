module CORDIC_PIPELINE (
    input wire clk,
    input wire rst,
    input wire [31:0] angle_in,
    input wire cos_neg_in,
    input wire sin_neg_in,
    output wire [31:0] x_out,
    output wire [31:0] y_out,
    output wire cos_neg_out,
    output wire sin_neg_out
);

    localparam [31:0] K = 32'h3F1B74EE;

    wire [31:0] x_stage [0:16];
    wire [31:0] y_stage [0:16];
    wire [31:0] z_stage [0:16];
    wire cos_neg_stage [0:16];
    wire sin_neg_stage [0:16];

    reg [31:0] x_init_reg;
    reg [31:0] y_init_reg;
    reg [31:0] z_init_reg;
    reg cos_neg_init_reg;
    reg sin_neg_init_reg;

    always @(posedge clk) begin
        if (rst) begin
            x_init_reg <= 32'h00000000;
            y_init_reg <= 32'h00000000;
            z_init_reg <= 32'h00000000;
            cos_neg_init_reg <= 1'b0;
            sin_neg_init_reg <= 1'b0;
        end
        else begin
            x_init_reg <= K;
            y_init_reg <= 32'h00000000;
            z_init_reg <= angle_in;
            cos_neg_init_reg <= cos_neg_in;
            sin_neg_init_reg <= sin_neg_in;
        end
    end

    assign x_stage[0] = x_init_reg;
    assign y_stage[0] = y_init_reg;
    assign z_stage[0] = z_init_reg;
    assign cos_neg_stage[0] = cos_neg_init_reg;
    assign sin_neg_stage[0] = sin_neg_init_reg;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_STAGE

            CORDIC_STAGE stage_i (
                .clk(clk),
                .rst(rst),
                .x_in(x_stage[i]),
                .y_in(y_stage[i]),
                .z_in(z_stage[i]),
                .cos_neg_in(cos_neg_stage[i]),
                .sin_neg_in(sin_neg_stage[i]),
                .stage(i[3:0]),
                .x_out(x_stage[i+1]),
                .y_out(y_stage[i+1]),
                .z_out(z_stage[i+1]),
                .cos_neg_out(cos_neg_stage[i+1]),
                .sin_neg_out(sin_neg_stage[i+1])
            );

        end
    endgenerate

    assign x_out = x_stage[16];
    assign y_out = y_stage[16];
    assign cos_neg_out = cos_neg_stage[16];
    assign sin_neg_out = sin_neg_stage[16];

endmodule
