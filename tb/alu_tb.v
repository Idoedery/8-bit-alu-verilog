`timescale 1ns/1ps

module alu_testbench;
    reg [7:0] a;
    reg [7:0] b;
    reg [2:0] opcode;

    wire [7:0] result;
    wire carry;
    wire zero;
  
    alu_8bit dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .carry(carry),
        .zero(zero)
    );

    initial begin

        a = 8'd0;
        b = 8'd0;
        opcode = 3'b000;

        #1;

        a = 8'd10;
        b = 8'd20;
        opcode = 3'b000;

        #1;

        if (result === 8'd30 &&
            carry === 1'b0 &&
            zero === 1'b0 
        ) begin
            $display(
            "PASS: a=%d, b=%d, result=%d carry =%b zero=%b", 
            a, b, result, carry, zero
            );
        end

        else begin
            $display(
                "FAIL: a=%d, b=%d, result=%d, carry=%b, zero=%b expected = 30",
                a, b, result, carry, zero
            );
        end

        $finish;

    end

endmodule

   


