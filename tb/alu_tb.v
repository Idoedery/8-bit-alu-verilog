`timescale 1ns/1ps

module alu_testbench;

    // DUT SIGNALS

    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] opcode;

    wire [7:0] result;
    wire carry;
    wire zero;

    // Verification Counters

    integer tests;
    integer errors;

    // DUT
  
    alu_8bit dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .carry(carry),
        .zero(zero)
    );

    // Reference model

    task calculate_expected;
        input[7:0] test_a;
        input[7:0] test_b;
        input [2:0] test_opcode;

        output [7:0] expected_result;
        output expected_carry;
        output expected_zero;

        reg[8:0] expected_temp;

        begin

            expected_result = 8'h00;
            expected_carry = 1'b0;
            expected_temp = 9'h000;

            case(test_opcode)

                3'b000: begin 
                    expected_temp =
                    {1'b0, test_a} + {1'b0, test_b};

                    expected_result = expected_temp[7:0];
                    expected_carry = expected_temp[8];
                end

                3'b001: begin
                    expected_result = test_a - test_b;
                    expected_carry = (test_a < test_b);
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

        begin

            calculate_expected(
                test_a,
                test_b,
                test_opcode,
                expected_result,
                expected_carry,
                expected_zero
            );

            a = test_a;
            b= test_b;
            opcode = test_opcode;

            #1;

            tests = tests + 1;

            if (result !== expected_result ||
            carry !== expected_carry ||
            zero !== expected_zero
            ) begin

            errors = errors + 1;

            $display(
                "FAIL #%0d: op=%b a=%h b=%h | actual=%h/%b/%b expected=&h/%b/%b",
                tests,
                opcode,
                a,
                b,
                result,
                carry,
                zero,
                expected_result,
                expected_carry,
                expected_zero 
            );

            end
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

        check_case(8'd10, 8'd20, 3'b000);
        check_case(8'hFF, 8'h01, 3'b000);

        check_case(8'd20, 8'd10, 3'b001);
        check_case(8'd3, 8'd5, 3'b001);

        check_case(
            8'b10101010,
            8'b11110000,
            3'b010
        );

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

   


