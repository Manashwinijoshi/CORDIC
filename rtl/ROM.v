module ROM (
    input wire [3:0] addr,
    output reg [31:0] data
);

    always @(*) begin
        case (addr)
            4'd0  : data = 32'h3F490FDB;
            4'd1  : data = 32'h3EED6338;
            4'd2  : data = 32'h3E7ADBB0;
            4'd3  : data = 32'h3DFEADD5;
            4'd4  : data = 32'h3D7FAADE;
            4'd5  : data = 32'h3CFFEAAE;
            4'd6  : data = 32'h3C7FFAAB;
            4'd7  : data = 32'h3BFFFEAB;
            4'd8  : data = 32'h3B7FFFAB;
            4'd9  : data = 32'h3AFFFFEB;
            4'd10 : data = 32'h3A7FFFFB;
            4'd11 : data = 32'h39FFFFFF;
            4'd12 : data = 32'h397FFFFF;
            4'd13 : data = 32'h38FFFFFF;
            4'd14 : data = 32'h387FFFFF;
            4'd15 : data = 32'h37FFFFFF;
            default : data = 32'h00000000;
        endcase
    end

endmodule
