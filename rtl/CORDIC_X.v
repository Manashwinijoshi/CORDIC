module CORDIC_X (
    input wire Clk,
    input wire Reset,
    input wire signed [15:0] X_i,
    input wire signed [15:0] Shifted_y,
    input wire Enable,
    output wire signed [15:0] Cordic_x
);

    ADD_SUB adder_x (
        .Clk(Clk),
        .Reset(Reset),
        .Input_a(X_i),
        .Input_b(Shifted_y),
        .Enable(Enable),
        .Output_res(Cordic_x)
    );

endmodule
