module CORDIC_STAGE_X(
	input  wire clk,
    input  wire rst,
	input wire [31:0] input_angle,
	input wire [31:0] x_i,
	input wire [31:0] y_i,
	output wire [31:0] cordic_x //
	);
	
	wire d,lt;

	ANGLE_LESS LT (
        .a(input_angle),
        .b(32'd0),
        .a_lt_b(lt)
    );
	
	FP_ADD_SUB FAS (
		.clk(clk),
		.rst(rst),
        .In1(x_i), 
        .In2(y_i), 
        .en(d), 
        .out(cordic_x)
		);
		
	assign d = (lt) ? 1'b1 : 1'b0;
endmodule
