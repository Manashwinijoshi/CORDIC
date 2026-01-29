module FP_COMPARE_GT (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire gt
);

    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [30:0] mag_a = a[30:0];
    wire [30:0] mag_b = b[30:0];

    assign gt = (sign_a == 0 && sign_b == 1) ? 1'b1 :
                (sign_a == 1 && sign_b == 0) ? 1'b0 :
                (sign_a == 0) ? (mag_a > mag_b) : (mag_a < mag_b);

endmodule
