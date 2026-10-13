`timescale 1ns/1ps

module alu_testbench;

    // DUT SIGNALS

    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] opcode;

    wire [7:0] result;
    wire carry;
    wire zero;
    wire overflow;

    // Verification Counters

    integer tests;
    integer errors;

    // used for exhaustive verfication of all cases (2^8 * 2^8 * 2*3)
    integer op_idx;
    integer a_idx;
    integer b_idx;

    // DUT
  
    alu_8bit dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .carry(carry),
        .zero(zero),
        .overflow(overflow)
    );

    // Reference model

    task calculate_expected;
        input[7:0] test_a;
        input[7:0] test_b;
        input [2:0] test_opcode;

        output [7:0] expected_result;
        output expected_carry;
        output expected_zero;
        output expected_overflow;

        reg[8:0] expected_temp;
        reg signed [8:0] signed_result;
        

        begin
            
            expected_result = 8'h00;
            expected_carry = 1'b0;
            expected_temp = 9'h000;

            // additional declaration to store a signed result
            expected_overflow = 1'b0;
            signed_result = 9'sd0;

            case(test_opcode)

                3'b000: begin // Calculates Expected Behavior for ADDITION
                    expected_temp =
                    {1'b0, test_a} + {1'b0, test_b};

                    signed_result = $signed(test_a) + $signed(test_b);

                    expected_result = expected_temp[7:0];
                    expected_carry = expected_temp[8];

                    // Behavioral verification of overflow for signed arithmetic
                    // Overflow discernment differs from DUT for extra check

                    if (signed_result > 127 || signed_result < -128)
                        expected_overflow = 1'b1; 
                    else 
                        expected_overflow = 1'b0;
                end

                3'b001: begin // Calculates Expected Behavior for SUBTRACTION
                    expected_result = test_a - test_b;
                    expected_carry = (test_a < test_b);
                    
                    signed_result = $signed(test_a) - $signed(test_b);
                    
                    if (signed_result > 127 || signed_result < -128)
                        expected_overflow = 1'b1;
                    else 
                        expected_overflow = 1'b0;
                end

                3'b010:
                    expected_result = test_a & test_b;
                3'b011:
                    expected_result = test_a | test_b;

                3'b100:
                    expected_result = test_a ^ test_b;

                3'b101:
                    expected_result = ~test_a;

                3'b110:
                    expected_result = test_a << 1;

                3'b111:
                    expected_result = test_a >> 1;
                
            endcase

            expected_zero = (expected_result == 8'h00);
        end
    endtask



    // Checker



    task check_case;
        input [7:0] test_a;
        input [7:0] test_b;
        input [2:0] test_opcode;

        reg [7:0] expected_result;
        reg expected_carry;
        reg expected_zero;
        reg expected_overflow;

        

        begin

            calculate_expected(
                test_a,
                test_b,
                test_opcode,
                expected_result,
                expected_carry,
                expected_zero,
                expected_overflow
            );

            a = test_a;
            b= test_b;
            opcode = test_opcode;

            #1;

            tests = tests + 1;

            if (result !== expected_result ||
            carry !== expected_carry ||
            zero !== expected_zero ||
            overflow !== expected_overflow
            ) begin

            errors = errors + 1;

            $display(
                "FAIL #%0d: op=%b a=%h b=%h | actual: result=%h carry=%b zero=%b overflow=%b | expected: result=%h carry=%b zero=%b overflow=%b",
                tests,
                opcode,
                a,
                b,
                result,
                carry,
                zero,
                expected_result,
                expected_carry,
                expected_zero,
                expected_overflow 

            );

            end
            // else begin
            //     $display(
            //         "PASS #%0d: op=%b a=%h b=%h", 
            //         tests, opcode, a, b
            //     );
            // end
        end
    endtask

    // Test sequence

    initial begin

        a = 8'b0;
        b= 8'b0;
        opcode = 3'b000;

        tests = 0;
        errors = 0;

        #1;
        // check cases of basic functionality for addition that can easily be verified
        check_case(8'd10, 8'd20, 3'b000);
        check_case(8'd255, 8'd1, 3'b000);
        // check cases of basic functionality for subtraction that can easily be verified
        check_case(8'd20, 8'd10, 3'b001);
        check_case(8'd3, 8'd5, 3'b001);

        // Basic check for ANDer functionality
        check_case(
            8'b10101010,
            8'b11110000,
            3'b010
        );

        // check overflow and carry flag logic

        // Addition: signed overflow without carry
        check_case(8'd127, 8'd1, 3'b000);

        // Addition: carry without signed overflow
        check_case(8'd255, 8'd1, 3'b000);

        // Addition: signed overflow with carry
        check_case(8'd128, 8'd128, 3'b000);

        // Subtraction: negative signed overflow
        check_case(8'd128, 8'd1, 3'b001);

        // Subtraction: borrow without signed overflow
        check_case(8'd3, 8'd5, 3'b001);

        #1

        // exhaustive means of testing all combinations

        for (op_idx = 0; op_idx < 8; op_idx = op_idx + 1) begin
            for (a_idx = 0; a_idx < 256; a_idx = a_idx + 1) begin
                for (b_idx = 0; b_idx < 256; b_idx = b_idx + 1) begin
                    check_case(a_idx, b_idx, op_idx);
                end
            end
        end
                

        $display("");
        $display("-----------------------------");
        $display("ALU VERIFICATION SUMMARY");
        $display("-----------------------------");
        $display("Tests run : %0d", tests);
        $display("Failures  : %0d", errors);

        if (errors == 0)
            $display("RESULT    : ALL TESTS PASSED");
        else
            $display("RESULT    : VERIFICATION FAILED");

        $display("-----------------------------");


        $finish;

    end

endmodule

   


