`timescale 1ns / 1ps

module CORDIC_TB;

    parameter STAGES = 16;
    parameter CLK_PERIOD = 10;
    
    reg Clk;
    reg Reset;
    reg [16:0] Input_angle;
    wire [15:0] Cos_out;
    wire [15:0] Sin_out;
    
    real ANGLE_DEGREES;
    real ANGLE_RADIANS;
    real EXPECTED_COS;
    real EXPECTED_SIN;
    real ACTUAL_COS;
    real ACTUAL_SIN;
    real COS_ERROR;
    real SIN_ERROR;
    
    real MAX_COS_ERROR;
    real MAX_SIN_ERROR;
    integer TOTAL_TESTS;
    integer PASSED_TESTS;
    
    CORDIC_TOP #(
        .STAGES(STAGES)
    ) DUT (
        .Clk(Clk),
        .Reset(Reset),
        .Input_angle(Input_angle),
        .Cos_out(Cos_out),
        .Sin_out(Sin_out)
    );
    
    initial begin
        Clk = 1'b0;
        forever #(CLK_PERIOD/2) Clk = ~Clk;
    end
    
    function [16:0] DEGREES_TO_ANGLE_FORMAT;
        input real ANGLE_DEG;
        real SCALED_VALUE;
        begin
            SCALED_VALUE = (ANGLE_DEG / 360.0) * 102944.0;
            DEGREES_TO_ANGLE_FORMAT = SCALED_VALUE;
        end
    endfunction
    
    function real FIXED_TO_FLOAT;
        input [15:0] FIXED_VALUE;
        real FLOAT_RESULT;
        begin
            if (FIXED_VALUE[15] == 1'b1) begin
                FLOAT_RESULT = ($signed(FIXED_VALUE) / 32768.0);
            end
            else begin
                FLOAT_RESULT = (FIXED_VALUE / 32768.0);
            end
            FIXED_TO_FLOAT = FLOAT_RESULT;
        end
    endfunction
    
    task TEST_SINGLE_CASE;
        input real TEST_ANGLE_DEG;
        begin
            
            ANGLE_DEGREES = TEST_ANGLE_DEG;
            ANGLE_RADIANS = (TEST_ANGLE_DEG * 3.14159265359) / 180.0;
            Input_angle = DEGREES_TO_ANGLE_FORMAT(TEST_ANGLE_DEG);
            
            repeat(STAGES + 5) @(posedge Clk);
            
            EXPECTED_COS = $cos(ANGLE_RADIANS);
            EXPECTED_SIN = $sin(ANGLE_RADIANS);
            
            ACTUAL_COS = FIXED_TO_FLOAT(Cos_out);
            ACTUAL_SIN = FIXED_TO_FLOAT(Sin_out);
            
            COS_ERROR = $abs(EXPECTED_COS - ACTUAL_COS);
            SIN_ERROR = $abs(EXPECTED_SIN - ACTUAL_SIN);
            
            if (COS_ERROR > MAX_COS_ERROR) begin
                MAX_COS_ERROR = COS_ERROR;
            end
            
            if (SIN_ERROR > MAX_SIN_ERROR) begin
                MAX_SIN_ERROR = SIN_ERROR;
            end
            
            TOTAL_TESTS = TOTAL_TESTS + 1;
            
            if (COS_ERROR < 0.001 && SIN_ERROR < 0.001) begin
                PASSED_TESTS = PASSED_TESTS + 1;
                $display("PASS: %0.2f degrees", TEST_ANGLE_DEG);
            end
            else begin
                $display("FAIL: %0.2f degrees, cos_error=%0.6f, sin_error=%0.6f", 
                         TEST_ANGLE_DEG, COS_ERROR, SIN_ERROR);
            end
            
            $display("  Expected: cos=%0.6f, sin=%0.6f", EXPECTED_COS, EXPECTED_SIN);
            $display("  Actual:   cos=%0.6f, sin=%0.6f", ACTUAL_COS, ACTUAL_SIN);
            $display("  Raw: cos_out=%h, sin_out=%h", Cos_out, Sin_out);
            $display("");
            
        end
    endtask
    
    initial begin
        
        Reset = 1'b1;
        Input_angle = 17'b0;
        MAX_COS_ERROR = 0.0;
        MAX_SIN_ERROR = 0.0;
        TOTAL_TESTS = 0;
        PASSED_TESTS = 0;
        
        $display("========================================");
        $display("CORDIC TESTBENCH");
        $display("========================================");
        $display("");
        
        repeat(5) @(posedge Clk);
        Reset = 1'b0;
        repeat(3) @(posedge Clk);
        
        $display("TESTING KEY ANGLES:");
        $display("");
        
        TEST_SINGLE_CASE(0.0);
        TEST_SINGLE_CASE(30.0);
        TEST_SINGLE_CASE(45.0);
        TEST_SINGLE_CASE(60.0);
        TEST_SINGLE_CASE(90.0);
        TEST_SINGLE_CASE(120.0);
        TEST_SINGLE_CASE(135.0);
        TEST_SINGLE_CASE(150.0);
        TEST_SINGLE_CASE(180.0);
        TEST_SINGLE_CASE(210.0);
        TEST_SINGLE_CASE(225.0);
        TEST_SINGLE_CASE(240.0);
        TEST_SINGLE_CASE(270.0);
        TEST_SINGLE_CASE(300.0);
        TEST_SINGLE_CASE(315.0);
        TEST_SINGLE_CASE(330.0);
        TEST_SINGLE_CASE(360.0);
        
        $display("");
        $display("TESTING EDGE CASES:");
        $display("");
        
        TEST_SINGLE_CASE(0.5);
        TEST_SINGLE_CASE(89.5);
        TEST_SINGLE_CASE(90.5);
        TEST_SINGLE_CASE(179.5);
        TEST_SINGLE_CASE(180.5);
        TEST_SINGLE_CASE(269.5);
        TEST_SINGLE_CASE(270.5);
        TEST_SINGLE_CASE(359.5);
        
        $display("");
        $display("TESTING RANDOM ANGLES:");
        $display("");
        
        TEST_SINGLE_CASE(17.3);
        TEST_SINGLE_CASE(73.8);
        TEST_SINGLE_CASE(123.4);
        TEST_SINGLE_CASE(198.7);
        TEST_SINGLE_CASE(247.5);
        TEST_SINGLE_CASE(312.6);
        
        $display("");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("========================================");
        $display("TOTAL TESTS: %0d", TOTAL_TESTS);
        $display("PASSED:      %0d", PASSED_TESTS);
        $display("FAILED:      %0d", TOTAL_TESTS - PASSED_TESTS);
        $display("PASS RATE:   %0.2f%%", (PASSED_TESTS * 100.0) / TOTAL_TESTS);
        $display("MAX COS ERROR: %0.6f", MAX_COS_ERROR);
        $display("MAX SIN ERROR: %0.6f", MAX_SIN_ERROR);
        $display("========================================");
        
        if (PASSED_TESTS == TOTAL_TESTS) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("SOME TESTS FAILED");
        end
        
        #100;
        $finish;
        
    end
    
    initial begin
        #1000000;
        $display("ERROR: SIMULATION TIMEOUT!");
        $finish;
    end
    
    initial begin
        $dumpfile("cordic_tb.vcd");
        $dumpvars(0, CORDIC_TB);
    end

endmodule