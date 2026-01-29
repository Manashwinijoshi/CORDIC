module PRE_PROCESSING_UNIT (
    input wire signed [17:0] Input_angle,
    output reg signed [15:0] Reduced_angle,
    output reg Cos_negate
);

    localparam signed [17:0] ANGLE_ZERO = 18'sh00000; // 0
    localparam signed [17:0] ANGLE_PI_2 = 18'sh06488; // 90° = 25736
    localparam signed [17:0] ANGLE_PI = 18'sh0C910; // 180° = 51472
    localparam signed [17:0] ANGLE_PI_3_2 = 18'sh12D98; // 270° = 77208
    localparam signed [17:0] ANGLE_TWO_PI = 18'sh19220; // 360° = 102944

    reg signed [17:0] normalized_angle;

    always @(*) begin
        
        normalized_angle = Input_angle;
        
        // angles >= 360
        if (normalized_angle >= ANGLE_TWO_PI) begin
            normalized_angle = normalized_angle - ANGLE_TWO_PI;
        end
        
        // angles < 0
        if (normalized_angle < ANGLE_ZERO) begin
            normalized_angle = normalized_angle + ANGLE_TWO_PI;
        end

        // Quadrant I: (0° to 90°)
        if (normalized_angle <= ANGLE_PI_2) begin
            Reduced_angle = normalized_angle[15:0];
            Cos_negate = 1'b0;
        end
        // Quadrant II: (90° to 180°)
        else if (normalized_angle <= ANGLE_PI) begin
            Reduced_angle = ANGLE_PI - normalized_angle;
            Cos_negate = 1'b1;
        end
        // Quadrant III: (180° to 270°)
        else if (normalized_angle <= ANGLE_PI_3_2) begin
            Reduced_angle = normalized_angle - ANGLE_PI;
            Reduced_angle = -Reduced_angle;
            Cos_negate = 1'b1;
        end
        // Quadrant IV: (270° to 360°)
        else begin
            Reduced_angle = normalized_angle - ANGLE_TWO_PI;
            Cos_negate = 1'b0;
        end

    end

endmodule
