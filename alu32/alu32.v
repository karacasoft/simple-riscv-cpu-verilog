`include "alu32/alu_ops.vh"

module Alu32(
    input [4:0] op_type,
    input [31:0] op1,
    input [31:0] op2,
    output reg [31:0] ret
);

wire [4:0] shamt;

assign shamt = op2[4:0];

always @(*) begin
    case(op_type)
    `OP_ADD: ret = op1 + op2;
    `OP_SUB: ret = op1 - op2;

    `OP_SLL: ret = op1 << shamt;
    `OP_SRL: ret = op1 >> shamt;
    `OP_SLA: ret = $signed(op1) <<< shamt;
    `OP_SRA: ret = $signed(op1) >>> shamt;

    `OP_SLT: ret = { 31'b0, $signed(op1) < $signed(op2) };
    `OP_SLTU: ret = { 31'b0, op1 < op2 };

    `OP_XOR: ret = op1 ^ op2;
    `OP_OR: ret = op1 | op2;
    `OP_AND: ret = op1 & op2;
    endcase
end

endmodule // Alu32