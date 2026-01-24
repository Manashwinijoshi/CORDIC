`timescale 1ns/1ps

module tb_angle_greater();

    // Inputs
    reg [31:0] a;
    reg [31:0] b;
    // Outputs
    wire a_gt_b;

    // Instantiate the Unit Under Test (UUT)
    angle_greater uut (
        .a(a), 
        .b(b), 
      .a_gt_b(a_gt_b)
    );

    // --- Verification Components ---

    // Task: Driver - Drives input values to the UUT
    task driver(input [31:0] val_a, input [31:0] val_b);
        begin
            a = val_a;
            b = val_b;
            #10; // Wait for combinational logic to settle
        end
    endtask

    // Task: Monitor - Observes and prints current state
    task monitor;
        begin
          $display("Time: %0t | a: %h | b: %h | Result a_gt_b: %b", $time, a, b, a_gt_b);
        end
    endtask

    // Task: Scoreboard - Validates the logic
    // Note: We use a simple bit-level comparison or real-casting for the gold model
    task scoreboard(input expected_result);
        begin
          if (a_gt_b !== expected_result) begin
            $display("ERROR: Expected %b, Got %b", expected_result, a_gt_b);
            end else begin
                $display("PASS");
            end
        end
    endtask

    // --- Test Procedure ---
    initial begin
        $display("Starting Testbench...");
        $display("---------------------------------------");

        // Corner Case: 0 vs 0 (Positive Zero)
        // Hex: 00000000
        $display("Test 1: Zero vs Zero");
        driver(32'h00000000, 32'h00000000); 
        monitor();
        scoreboard(1'b0);
      
        // both numbers are same
        //A=32'h3d700000,B=32'h3d700000
      $display("Test 2:both numbers are same");
        driver(32'h3d700000, 32'h3d700000); 
        monitor();
        scoreboard(1'b0);

      
        // Corner Case: Positive Zero vs Negative Zero
        // IEEE 754: 0.0 == -0.0, but your module treats + as > -
      $display("Test 3: Positive Zero vs Negative Zero");
        driver(32'h00000000, 32'h80000000); 
        monitor();
       scoreboard(1'b1);

        // Corner Case: Small Negative vs Large Negative
        // A = -1.0 (BF800000), B = -2.0 (C0000000) -> A > B is true
      $display("Test 4: -1.0 vs -2.0");
      driver(32'hBF800000, 32'hc0000000); 
        monitor();
        scoreboard(1'b1);

      
       // Corner Case: different exponent, same mantissa
      $display("Test 5: different exponent, same mantissa (Positive)");
      driver(32'h43340001, 32'h43440001); 
       monitor();
      scoreboard(1'b0);

        // Corner Case: Infinity
      // +Inf (7F800000) vs a large number 461C4000
      $display("Test 6: Infinity vs Large Number");
        driver(32'h7F800000, 32'h461C4000); 
        monitor();
      scoreboard(1'b1);
      
        // Close Angles (Same Exp, Different Mantissa)
        // A = 180.000015 (43340001), B = 180.0 (43340000)
        // This specifically tests your mantissa comparison logic.
      $display("Test 7: close angles same exp,different mantisa");
        driver(32'h43340001, 32'h43340000); 
        monitor();
      scoreboard(1'b1);

        // Boundary Angles
      // B = 359.9 (43B3F333), A = 0.1 (3DCCCCCD)
      $display("Test 8:boundry angles rounding off to 0");
        driver(32'h3DCCCCCD,32'h43B3F333); 
        monitor();
      scoreboard(1'b0);

        //Signed Directional Angles (Negative Angles)
        // A = -10.5 (C1280000), B = -20.5 (C1A40000)
        // Magnitude of B is larger, but since it's negative, A > B.
      $display("Test 9:floating point negative numbers");
        driver(32'hC1280000, 32'hC1A40000); 
        monitor();
      scoreboard(1'b1);

        // Cross-Quadrant Zero check
        // A = 0.1 (Positive), B = -0.1 (Negative)
      $display("Test 10:check for same floating point number different sign");
        driver(32'h3DCCCCCD, 32'hBDCCCCCD); 
        monitor();
      scoreboard(1'b1);

        $display("---------------------------------------");
        $display("Tests Completed.");
        $finish;
    end

endmodule
