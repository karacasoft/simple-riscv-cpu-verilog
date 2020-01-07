`define XLEN 32

`define OPCODE_OFFSET   0
`define OPCODE_LEN      7
`define RD_OFFSET       (`OPCODE_OFFSET+`OPCODE_LEN)
`define RD_LEN          5
`define FUNCT3_OFFSET   (`RD_OFFSET+`RD_LEN)
`define FUNCT3_LEN      3
`define RS1_OFFSET      (`FUNCT3_OFFSET+`FUNCT3_LEN)
`define RS1_LEN         5
`define RS2_OFFSET      (`RS1_OFFSET+`RS1_LEN)
`define RS2_LEN         5
`define FUNCT7_OFFSET   (`RS2_OFFSET+`RS2_LEN)
`define FUNCT7_LEN      7


`define AUIPC 7'b0010111

`define LUI 7'b0110111

`define OP_IMM       7'b0010011
`define FUNCT3_ADDI  3'b000

`define FUNCT3_SLTIX 3'b01x
`define FUNCT3_SLTI  3'b010
`define FUNCT3_SLTIU 3'b011

`define FUNCT3_XORI  3'b100
`define FUNCT3_ORI   3'b110
`define FUNCT3_ANDI  3'b111

`define FUNCT3_SXXI  3'bx01
`define FUNCT3_SLLI  3'b001
`define FUNCT3_SRLI  3'b101
`define FUNCT3_SRAI  3'b101

`define OP                 7'b0110011
`define FUNCT7_FUNCT3_ADD  10'b0000000000
`define FUNCT7_FUNCT3_SUB  10'b0100000000
`define FUNCT7_FUNCT3_SLL  10'b0000000001
`define FUNCT7_FUNCT3_SLT  10'b0000000010
`define FUNCT7_FUNCT3_SLTU 10'b0000000011
`define FUNCT7_FUNCT3_XOR  10'b0000000100
`define FUNCT7_FUNCT3_SRL  10'b0000000101
`define FUNCT7_FUNCT3_SRA  10'b0100000101
`define FUNCT7_FUNCT3_OR   10'b0000000110
`define FUNCT7_FUNCT3_AND  10'b0000000111

`define LOAD               7'b0000011
`define FUNCT3_LB          3'b000
`define FUNCT3_LH          3'b001
`define FUNCT3_LW          3'b010
`define FUNCT3_LBU         3'b100
`define FUNCT3_LHU         3'b101

`define STORE              7'b0100011
`define FUNCT3_SB          3'b000
`define FUNCT3_SH          3'b001
`define FUNCT3_SW          3'b010

`define BRANCH             7'b1100011
`define FUNCT3_BEQ         3'b000
`define FUNCT3_BNE         3'b001
`define FUNCT3_BLT         3'b100
`define FUNCT3_BGT         3'b101
`define FUNCT3_BLTU        3'b110
`define FUNCT3_BGTU        3'b111

`define JAL                7'b1101111
`define JALR               7'b1100111