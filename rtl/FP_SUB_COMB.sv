
module FP_SUB_COMB (
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] result
);

    reg sign_a, sign_b, sign_res;
    reg [7:0] exp_a, exp_b, exp_res;
    reg [23:0] mant_a, mant_b;
    reg [31:0] mant_a_ext, mant_b_ext;
    reg [32:0] mant_res;
    reg eff_sub;
    reg sign_b_eff;
    
    integer i;
    reg [5:0] shft;
    reg found;

    wire zero_a = (a[30:0] == 31'b0);
    wire zero_b = (b[30:0] == 31'b0);

    always @(*) begin
        
        sign_res = 0;
        exp_res = 0;
        mant_res = 0;
        result = 32'h00000000;
        eff_sub = 0;
        shft = 0;
        found = 0;

        sign_a = a[31];
        sign_b = ~b[31];
        exp_a = a[30:23];
        exp_b = b[30:23];

        sign_b_eff = sign_b;

        if (sign_a != sign_b_eff)
            eff_sub = 1;
        else
            eff_sub = 0;

        mant_a = {1'b1, a[22:0]};
        mant_b = {1'b1, b[22:0]};

        mant_a_ext = {mant_a, 8'b0};
        mant_b_ext = {mant_b, 8'b0};

        if (zero_a && zero_b) begin
            result = 32'h00000000;
        end
        else if (zero_a) begin
            result = {~b[31], b[30:0]};
        end
        else if (zero_b) begin
            result = a;
        end
        else begin
            
            if (exp_a > exp_b) begin
                shft = exp_a - exp_b;
                if (shft > 31) shft = 31;
                mant_b_ext = mant_b_ext >> shft;
                exp_res = exp_a;
            end
            else if (exp_b > exp_a) begin
                shft = exp_b - exp_a;
                if (shft > 31) shft = 31;
                mant_a_ext = mant_a_ext >> shft;
                exp_res = exp_b;
            end
            else begin
                exp_res = exp_a;
            end

            if (eff_sub == 0) begin
                mant_res = mant_a_ext + mant_b_ext;
                sign_res = sign_a;
            end
            else begin
                if (mant_a_ext >= mant_b_ext) begin
                    mant_res = mant_a_ext - mant_b_ext;
                    sign_res = sign_a;
                end
                else begin
                    mant_res = mant_b_ext - mant_a_ext;
                    sign_res = sign_b_eff;
                end
            end

            if (mant_res == 0) begin
                result = 32'h00000000;
            end
            else begin
                if (mant_res[32]) begin
                    mant_res = mant_res >> 1;
                    exp_res = exp_res + 1;
                end
                else begin
                    shft = 0;
                    found = 0;
                    for (i = 31; i >= 0; i = i - 1) begin
                        if (mant_res[i] && !found) begin
                            shft = 31 - i;
                            found = 1;
                        end
                    end
                    if (shft > 0) begin
                        mant_res = mant_res << shft;
                        if (exp_res > shft)
                            exp_res = exp_res - shft;
                        else begin
                            result = 32'h00000000;
                            exp_res = 0;
                        end
                    end
                end

                if (exp_res != 0) begin
                    if (exp_res >= 8'hFF)
                        result = {sign_res, 8'hFF, 23'b0};
                    else
                        result = {sign_res, exp_res, mant_res[30:8]};
                end
            end
        end
    end

endmodule
