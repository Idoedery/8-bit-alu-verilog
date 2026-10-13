`timescale 1ns/1ps

module alu_8bit (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [2:0] opcode,
    output reg [7:0] result,
    output reg carry,
    output reg zero,
    output reg overflow
    );
    reg [8:0] temp;

    // Operation Codes
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_LSHIFT = 3'b110;
    localparam OP_RSHIFT = 3'b111;

    always@(*) begin
        // Default assignments prevent unintended latches
        carry = 1'b0;
        result = 8'b0;
        temp = 9'b0;
        overflow = 1'b0;

        case(opcode)
            OP_ADD: begin 
                temp = {1'b0,a} + {1'b0,b};
                result = temp[7:0];
                carry = temp[8]; 
                overflow = (a[7] ~^ b[7]) & (a[7] ^ result[7]);
            end

            OP_SUB: begin 
                temp = {1'b0,a} - {1'b0,b};
                result = temp[7:0];
                carry = temp[8];
                overflow = (a[7] ^ b[7]) & (a[7] ^ result[7]);
            end
            OP_AND: begin
                result = a & b; 
                
            end

            OP_OR: begin
                result = a | b;
            end
            OP_XOR: begin
                result = a ^ b;  
            end 

            OP_NOT: begin
                result = ~a;   
            end

            OP_LSHIFT: begin 
                result = a << 1;   
            end

            OP_RSHIFT: begin
                result = a >> 1; 
            end

         // case default: handles unexpected opcode values
        default: begin
            result = 8'b0;
            carry = 1'b0;
        end
        endcase
        zero = (result == 8'b0);
        
    end
endmodule

