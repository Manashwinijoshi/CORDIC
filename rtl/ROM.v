
module ROM (
    input wire [3:0] Address,
    output reg [15:0] Data
);

    always @(*) begin
        case (Address)
            4'd0 : Data = 16'd12867; // arctan(2^0) = 45.0000° = 0.7854 rad
            4'd1 : Data = 16'd7596; // arctan(2^-1) = 26.5651° = 0.4636 rad
            4'd2 : Data = 16'd4013; // arctan(2^-2) = 14.0362° = 0.2450 rad
            4'd3 : Data = 16'd2037; // arctan(2^-3) = 7.1250° = 0.1244 rad
            4'd4 : Data = 16'd1022; // arctan(2^-4) = 3.5763° = 0.0624 rad
            4'd5 : Data = 16'd511; // arctan(2^-5) = 1.7899° = 0.0312 rad
            4'd6 : Data = 16'd256; // arctan(2^-6) = 0.8952° = 0.0156 rad
            4'd7 : Data = 16'd128; // arctan(2^-7) = 0.4476° = 0.0078 rad
            4'd8 : Data = 16'd64; // arctan(2^-8) = 0.2238° = 0.0039 rad
            4'd9 : Data = 16'd32; // arctan(2^-9) = 0.1119° = 0.0020 rad
            4'd10 : Data = 16'd16; // arctan(2^-10) = 0.0560° = 0.0010 rad
            4'd11 : Data = 16'd8; // arctan(2^-11) = 0.0280° = 0.0005 rad
            4'd12 : Data = 16'd4; // arctan(2^-12) = 0.0140° = 0.0002 rad
            4'd13 : Data = 16'd2; // arctan(2^-13) = 0.0070° = 0.0001 rad
            4'd14 : Data = 16'd1; // arctan(2^-14) = 0.0035° = 0.0001 rad
            4'd15 : Data = 16'd1; // arctan(2^-15) = 0.0018° = 0.0000 rad
            default : Data = 16'd0;
        endcase
    end

endmodule
