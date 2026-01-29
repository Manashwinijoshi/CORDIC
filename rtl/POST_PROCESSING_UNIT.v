
module PRE_PROCESSING_UNIT (
    input wire clk,
    input wire rst,
    input wire [31:0] input_angle,
    output reg [31:0] registered_angle,
    output reg cos_neg,
    output reg sin_neg
);

    localparam [31:0] FP_PI_2 = 32'h3FC90FDB;
    localparam [31:0] FP_PI = 32'h40490FDB;
    localparam [31:0] FP_3PI_2 = 32'h4096CBE4;
    localparam [31:0] FP_2PI = 32'h40C90FDB;

    wire [31:0] angle_abs;
    wire input_neg;
    
    wire gt_pi_2, gt_pi, gt_3pi_2, gt_2pi;
    
    wire [31:0] pi_sub_angle;
    wire [31:0] angle_sub_pi;
    wire [31:0] twopi_sub_angle;
    
    reg [31:0] reduced_angle;
    reg cos_neg_calc;
    reg sin_neg_calc;

    assign input_neg = input_angle[31];
    assign angle_abs = {1'b0, input_angle[30:0]};

    FP_COMPARE_GT cmp_pi_2 (.a(angle_abs), .b(FP_PI_2), .gt(gt_pi_2));
    FP_COMPARE_GT cmp_pi (.a(angle_abs), .b(FP_PI), .gt(gt_pi));
    FP_COMPARE_GT cmp_3pi_2 (.a(angle_abs), .b(FP_3PI_2), .gt(gt_3pi_2));
    FP_COMPARE_GT cmp_2pi (.a(angle_abs), .b(FP_2PI), .gt(gt_2pi));

    FP_SUB_COMB sub1 (.a(FP_PI), .b(angle_abs), .result(pi_sub_angle));
    FP_SUB_COMB sub2 (.a(angle_abs), .b(FP_PI), .result(angle_sub_pi));
    FP_SUB_COMB sub3 (.a(FP_2PI), .b(angle_abs), .result(twopi_sub_angle));

    always @(*) begin
        reduced_angle = angle_abs;
        cos_neg_calc = 1'b0;
        sin_neg_calc = 1'b0;
        
        if (gt_2pi) begin
            reduced_angle = 32'h00000000;
            cos_neg_calc = 1'b0;
            sin_neg_calc = 1'b0;
        end
        else if (gt_3pi_2) begin
            reduced_angle = twopi_sub_angle;
            reduced_angle[31] = 1'b1;
            cos_neg_calc = 1'b0;
            sin_neg_calc = 1'b0;
        end
        else if (gt_pi) begin
            reduced_angle = angle_sub_pi;
            cos_neg_calc = 1'b1;
            sin_neg_calc = 1'b1;
        end
        else if (gt_pi_2) begin
            reduced_angle = pi_sub_angle;
            cos_neg_calc = 1'b1;
            sin_neg_calc = 1'b0;
        end
        else begin
            reduced_angle = angle_abs;
            cos_neg_calc = 1'b0;
            sin_neg_calc = 1'b0;
        end

        if (input_neg) begin
            sin_neg_calc = ~sin_neg_calc;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            registered_angle <= 32'h00000000;
            cos_neg <= 1'b0;
            sin_neg <= 1'b0;
        end
        else begin
            registered_angle <= reduced_angle;
            cos_neg <= cos_neg_calc;
            sin_neg <= sin_neg_calc;
        end
    end

endmodule
