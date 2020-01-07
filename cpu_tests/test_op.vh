`include "cpu_tests/test_common.vh"

`define TEST_ADD_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b0, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_ADD(TNUM, VAL1, VAL2) `TEST_ADD_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1+VAL2))

`define TEST_SUB_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0100000, R2, R1, 3'b0, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SUB(TNUM, VAL1, VAL2) `TEST_SUB_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1-VAL2))

`define TEST_SLL_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b001, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SLL(TNUM, VAL1, VAL2) `TEST_SLL_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1 << (VAL2%32)))

`define TEST_SLT_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b010, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SLT(TNUM, VAL1, VAL2) `TEST_SLT_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, ($signed(VAL1) < $signed(VAL2)))

`define TEST_SLTU_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b011, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SLTU(TNUM, VAL1, VAL2) `TEST_SLTU_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1 < VAL2))

`define TEST_XOR_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b100, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_XOR(TNUM, VAL1, VAL2) `TEST_XOR_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1^VAL2))

`define TEST_SRL_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b101, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SRL(TNUM, VAL1, VAL2) `TEST_SRL_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1>>(VAL2%32)))

`define TEST_SRA_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0100000, R2, R1, 3'b101, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SRA(TNUM, VAL1, VAL2) `TEST_SRA_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, $signed($signed(VAL1) >>> (VAL2%32)))

`define TEST_OR_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b110, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_OR(TNUM, VAL1, VAL2) `TEST_OR_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1|VAL2))

`define TEST_AND_REGS(TNUM, R1, R2, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(R2) = VAL2; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, R2, R1, 3'b111, RD, `OP); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_AND(TNUM, VAL1, VAL2) `TEST_AND_REGS(TNUM, 5'd1, 5'd2, 5'd3, VAL1, VAL2, (VAL1&VAL2))

`define OP_ADD_TESTS `TEST_ADD(1, 1, 2); \
    `TEST_ADD(2, 150, 500); \
    `TEST_ADD(3, 'hFFFFFFFF, 1); \
    `TEST_ADD(4, 'h0, 150); \
    
`define OP_SUB_TESTS `TEST_SUB(5, 1, 2); \
    `TEST_SUB(6, 500, 400); \
    `TEST_SUB(7, 0, 500); \
    `TEST_SUB(8, 100, 1); \

`define OP_SLL_TESTS `TEST_SLL(9, 5, 1); \
    `TEST_SLL(10, 10, 1); \
    `TEST_SLL(11, 1, 31); \
    `TEST_SLL(12, 1, 'h85); // shift amount is on lower 5 bits of the register value \

`define OP_SLT_TESTS `TEST_SLT(13, 40, 30); \
    `TEST_SLT(14, 0, 30); \
    `TEST_SLT(15, -500, 0); \
    `TEST_SLT(16, -500, -600); \
    `TEST_SLT(17, -500, -400); \

`define OP_SLTU_TESTS `TEST_SLTU(18, 0, 100); \
    `TEST_SLTU(19, 200, 100); \
    `TEST_SLTU(20, 200, 1000); \
    `TEST_SLTU(21, 200, 'hFFFFFFFF); \

`define OP_XOR_TESTS `TEST_XOR(22, 200, 200); \
    `TEST_XOR(23, 'b01001010, 'b11011010); \

`define OP_SRL_TESTS `TEST_SRL(24, 200, 1); \
    `TEST_SRL(25, 150, 2); \
    `TEST_SRL(26, -1, 1); \
    `TEST_SRL(27, -1, 'h85); \

`define OP_SRA_TESTS `TEST_SRA(28, -1, 1); \
    `TEST_SRA(29, -100, 1); \
    `TEST_SRA(30, -100, 4); \

`define OP_OR_TESTS `TEST_OR(31, 'h55, 'hAA); \
    `TEST_OR(32, 123, 123); \
    `TEST_OR(33, 'hDEADBEEF, 'hBEEFDEAD); \

`define OP_AND_TESTS `TEST_AND(34, 'h55, 'hAA); \
    `TEST_AND(35, 123, 123); \
    `TEST_AND(36, 'hDEADBEEF, 'hBEEFDEAD); \

`define OP_TESTS `OP_ADD_TESTS \
                 `OP_SUB_TESTS \
                 `OP_SLL_TESTS \
                 `OP_SLT_TESTS \
                 `OP_SLTU_TESTS \
                 `OP_XOR_TESTS \
                 `OP_SRL_TESTS \
                 `OP_SRA_TESTS \
                 `OP_OR_TESTS \
                 `OP_AND_TESTS \