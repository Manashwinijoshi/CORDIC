odule POST_PROCESSING_UNIT (
    input wire clk,
    input wire rst,
    input wire [31:0] cordic_x,
    input wire [31:0] cordic_y,
    input wire cos_neg,
    input wire sin_neg,
    output reg [31:0] cos,
    output reg [31:0] sin
);

    reg [31:0] cos_work;
    reg [31:0] sin_work;

    always @(*) begin
        if (cos_neg)
            cos_work = {~cordic_x[31], cordic_x[30:0]};
        else
            cos_work = cordic_x;
            
        if (sin_neg)
            sin_work = {~cordic_y[31], cordic_y[30:0]};
        else
            sin_work = cordic_y;
    end

    always @(posedge clk) begin
        if (rst) begin
            cos <= 32'h00000000;
            sin <= 32'h00000000;
        end
        else begin
            cos <= cos_work;
            sin <= sin_work;
        end
    end

endmodule
