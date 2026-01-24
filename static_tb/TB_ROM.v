
`timescale 1ns / 1ps
module TB_ROM;

    reg [3:0] addr;
    reg clk;
    wire [31:0] data;

    ROM DUT (
        .clk(clk),
        .addr(addr),
        .data(data)
    );

    task driver(input [3:0] address);
        begin
            addr = address;
        end
    endtask

    task monitor();
        begin
            #1;
            $display("Addr: %h | Data: %h", addr, data);
        end
    endtask
	task checker(input [3:0] address, input [31:0] expected_data);
		begin
			@(posedge clk);
			if (data !== expected_data) begin
				$display("Mismatch at Addr %h: Expected %h, Got %h", address, expected_data, data);
			end else begin
				$display("Match at Addr %h: Data %h", address, data);
			end
		end
	endtask
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
	integer i;
	
    // Stimulus
    initial begin
        
        for (i = 0; i < 16; i = i + 1) begin
            driver(i);
            @(posedge clk);
            monitor();
			checker(i, data);
        end
        $finish;
    end

endmodule
