module CORDIC_Y (
    input wire Clk,
    input wire Reset,
    input wire signed [15:0] Y_i,
    input wire signed [15:0] Shifted_x,
    input wire Enable,
    output wire signed [15:0] Cordic_y
);

    wire enable_inverted;
    
    assign enable_inverted = ~Enable;
    
    ADD_SUB adder_y (
        .Clk(Clk),
        .Reset(Reset),
        .Input_a(Y_i),
        .Input_b(Shifted_x),
        .Enable(enable_inverted),
        .Output_res(Cordic_y)
    );

endmodule
