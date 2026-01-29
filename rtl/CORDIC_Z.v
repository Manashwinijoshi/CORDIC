
module CORDIC_Z (
    input wire Clk,
    input wire Reset,
    input wire signed [15:0] Z_i,
    input wire signed [15:0] Arctan,
    input wire Enable,
    output wire signed [15:0] Cordic_z
);

    ADD_SUB adder_z (
        .Clk(Clk),
        .Reset(Reset),
        .Input_a(Z_i),
        .Input_b(Arctan),
        .Enable(Enable),
        .Output_res(Cordic_z)
    );

endmodule
