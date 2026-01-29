module FP_SHIFT_RIGHT (
    input wire [31:0] val_in,
    input wire [3:0] shift_amt,
    output reg [31:0] val_out
);

    wire [7:0] exp_in;
    wire zero_in;
    
    assign exp_in = val_in[30:23];
    assign zero_in = (val_in[30:0] == 31'b0);

    always @(*) begin
        if (zero_in || exp_in <= shift_amt)
            val_out = 32'h00000000;
        else
            val_out = {val_in[31], exp_in - shift_amt, val_in[22:0]};
    end

endmodule
