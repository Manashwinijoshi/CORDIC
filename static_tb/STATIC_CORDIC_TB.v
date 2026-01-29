`timescale 1ns/1ps

module CORDIC_TB;

    reg clk;
    reg rst;
    reg [31:0] input_angle;
    wire [31:0] cos_out;
    wire [31:0] sin_out;
    
    real angle_deg, angle_rad;
    real cos_real, sin_real;
    real cos_exp, sin_exp;
    real cos_err, sin_err;
    
    integer passed, failed, total;
    
    parameter LATENCY = 40;
    parameter real ERR_THRESH = 0.01;

    CORDIC_TOP uut (
        .clk(clk),
        .rst(rst),
        .input_angle(input_angle),
        .cos(cos_out),
        .sin(sin_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    function [31:0] deg_to_fp;
        input real deg;
        real rad, abs_val, temp;
        reg sign;
        reg [7:0] exp_val;
        reg [22:0] mant;
        integer exp_int;
        begin
            rad = deg * 3.14159265358979 / 180.0;
            
            if (rad == 0.0) begin
                deg_to_fp = 32'h00000000;
            end
            else begin
                sign = (rad < 0);
                abs_val = sign ? -rad : rad;
                
                exp_int = 127;
                temp = abs_val;
                
                while (temp >= 2.0) begin
                    temp = temp / 2.0;
                    exp_int = exp_int + 1;
                end
                while (temp < 1.0 && temp > 0) begin
                    temp = temp * 2.0;
                    exp_int = exp_int - 1;
                end
                
                mant = $rtoi((temp - 1.0) * 8388608.0);
                exp_val = exp_int;
                
                deg_to_fp = {sign, exp_val, mant};
            end
        end
    endfunction

    function real fp_to_real;
        input [31:0] fp;
        reg sign;
        reg [7:0] exp_val;
        reg [22:0] mant;
        real result;
        integer exp_int;
        begin
            sign = fp[31];
            exp_val = fp[30:23];
            mant = fp[22:0];
            
            if (exp_val == 0) begin
                fp_to_real = 0.0;
            end
            else begin
                exp_int = exp_val - 127;
                result = 1.0 + ($itor(mant) / 8388608.0);
                
                while (exp_int > 0) begin
                    result = result * 2.0;
                    exp_int = exp_int - 1;
                end
                while (exp_int < 0) begin
                    result = result / 2.0;
                    exp_int = exp_int + 1;
                end
                
                fp_to_real = sign ? -result : result;
            end
        end
    endfunction

    function real abs_r;
        input real val;
        begin
            abs_r = (val < 0) ? -val : val;
        end
    endfunction

    task test_angle;
        input real deg;
        begin
            angle_deg = deg;
            angle_rad = deg * 3.14159265358979 / 180.0;
            input_angle = deg_to_fp(deg);
            
            cos_exp = $cos(angle_rad);
            sin_exp = $sin(angle_rad);
            
            repeat(LATENCY) @(posedge clk);
            
            cos_real = fp_to_real(cos_out);
            sin_real = fp_to_real(sin_out);
            
            cos_err = abs_r(cos_real - cos_exp);
            sin_err = abs_r(sin_real - sin_exp);
            
            total = total + 1;
            
            if (cos_err <= ERR_THRESH && sin_err <= ERR_THRESH) begin
                $display("[PASS] %9.3f deg | cos: %9.6f (exp %9.6f) | sin: %9.6f (exp %9.6f)", 
                    deg, cos_real, cos_exp, sin_real, sin_exp);
                passed = passed + 1;
            end
            else begin
                $display("[FAIL] %9.3f deg | cos: %9.6f (exp %9.6f, err %.4f) | sin: %9.6f (exp %9.6f, err %.4f)", 
                    deg, cos_real, cos_exp, cos_err, sin_real, sin_exp, sin_err);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $display("==========================================================");
        $display("              FP32 CORDIC Testbench                       ");
        $display("==========================================================");
        
        passed = 0;
        failed = 0;
        total = 0;
        
        rst = 1;
        input_angle = 32'h00000000;
        
        repeat(10) @(posedge clk);
        rst = 0;
        repeat(10) @(posedge clk);
        
        $display("\n--- Standard Angles (Integer) ---");
        test_angle(0.0);
        test_angle(30.0);
        test_angle(45.0);
        test_angle(60.0);
        test_angle(90.0);
        test_angle(180.0);
        test_angle(270.0);
        test_angle(360.0);
        
        $display("\n--- Decimal Angles (One Decimal Place) ---");
        test_angle(10.5);
        test_angle(20.8);
        test_angle(33.3);
        test_angle(47.7);
        test_angle(55.5);
        test_angle(72.9);
        test_angle(85.1);
        test_angle(99.9);
        test_angle(123.4);
        test_angle(156.7);
        test_angle(189.2);
        test_angle(234.6);
        test_angle(267.8);
        test_angle(298.3);
        test_angle(321.1);
        test_angle(354.9);
        
        $display("\n--- Decimal Angles (Two Decimal Places) ---");
        test_angle(5.25);
        test_angle(12.34);
        test_angle(20.08);
        test_angle(33.33);
        test_angle(45.67);
        test_angle(56.78);
        test_angle(67.89);
        test_angle(78.12);
        test_angle(89.99);
        test_angle(91.01);
        test_angle(111.11);
        test_angle(133.33);
        test_angle(166.66);
        test_angle(199.99);
        test_angle(222.22);
        test_angle(253.87);
        test_angle(277.77);
        test_angle(303.03);
        test_angle(333.33);
        test_angle(359.99);
        
        $display("\n--- Decimal Angles (Three Decimal Places) ---");
        test_angle(0.001);
        test_angle(0.123);
        test_angle(1.234);
        test_angle(12.345);
        test_angle(23.456);
        test_angle(34.567);
        test_angle(45.678);
        test_angle(56.789);
        test_angle(67.891);
        test_angle(78.912);
        test_angle(89.123);
        test_angle(123.456);
        test_angle(178.999);
        test_angle(234.567);
        test_angle(290.123);
        test_angle(345.678);
        
        $display("\n--- Negative Decimal Angles ---");
        test_angle(-10.5);
        test_angle(-20.08);
        test_angle(-33.33);
        test_angle(-45.67);
        test_angle(-67.89);
        test_angle(-89.99);
        test_angle(-111.11);
        test_angle(-156.78);
        test_angle(-199.99);
        test_angle(-234.56);
        test_angle(-278.90);
        test_angle(-321.09);
        test_angle(-359.99);
        
        $display("\n--- Very Small Angles ---");
        test_angle(0.01);
        test_angle(0.05);
        test_angle(0.1);
        test_angle(0.5);
        test_angle(1.0);
        test_angle(-0.01);
        test_angle(-0.05);
        test_angle(-0.1);
        test_angle(-0.5);
        test_angle(-1.0);
        
        $display("\n--- Angles Near Quadrant Boundaries ---");
        test_angle(89.5);
        test_angle(89.9);
        test_angle(90.1);
        test_angle(90.5);
        test_angle(179.5);
        test_angle(179.9);
        test_angle(180.1);
        test_angle(180.5);
        test_angle(269.5);
        test_angle(269.9);
        test_angle(270.1);
        test_angle(270.5);
        test_angle(359.5);
        test_angle(359.9);
        
        $display("\n--- Random-Like Angles ---");
        test_angle(7.832);
        test_angle(14.159);
        test_angle(27.183);
        test_angle(31.416);
        test_angle(41.421);
        test_angle(57.735);
        test_angle(69.282);
        test_angle(83.666);
        test_angle(97.531);
        test_angle(108.246);
        test_angle(127.389);
        test_angle(141.592);
        test_angle(161.803);
        test_angle(173.205);
        test_angle(196.349);
        test_angle(212.132);
        test_angle(236.068);
        test_angle(251.327);
        test_angle(268.507);
        test_angle(284.271);
        test_angle(299.792);
        test_angle(314.159);
        test_angle(331.662);
        test_angle(347.123);
        
        $display("\n==========================================================");
        $display("                    TEST SUMMARY                          ");
        $display("==========================================================");
        $display("  Total:  %0d", total);
        $display("  Passed: %0d", passed);
        $display("  Failed: %0d", failed);
        if (failed == 0)
            $display("\n  *** ALL TESTS PASSED ***");
        else
            $display("\n  *** SOME TESTS FAILED ***");
        $display("  Pass Rate: %.2f%%", (passed * 100.0) / total);
        $display("==========================================================");
        
        #100;
        $finish;
    end

endmodule
