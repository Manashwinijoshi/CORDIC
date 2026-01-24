module ANGLE_GREATER (
    input wire [31:0] a,
    input wire [31:0] b,
    output reg a_gt_b
);
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [22:0] man_a = a[22:0];
    wire [22:0] man_b = b[22:0];

    always @(*) begin
        a_gt_b = 1'b0;
        if (sign_a != sign_b) begin
            if (sign_a == 1'b0) a_gt_b = 1'b1;
        end
        else begin
            if (exp_a > exp_b) begin
                a_gt_b = ~sign_a;
            end
            else if (exp_a < exp_b) begin
                a_gt_b = sign_a;
            end
            else if (man_a > man_b) begin
                a_gt_b = ~sign_a;
            end
        end
    end
endmodule
