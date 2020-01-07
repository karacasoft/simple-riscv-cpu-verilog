`include "cpu_tests/test_common.vh"

`define TEST_ADDI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_I_TYPE(VAL2, R1, 3'b0, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_ADDI(TNUM, VAL1, VAL2) `TEST_ADDI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, (VAL1+VAL2))

`define TEST_SLTI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_I_TYPE(VAL2, R1, 3'b010, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SLTI(TNUM, VAL1, VAL2) `TEST_SLTI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, ($signed(VAL1) < $signed(VAL2)))

`define TEST_SLTIU_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_I_TYPE(VAL2, R1, 3'b011, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SLTIU(TNUM, VAL1, VAL2) `TEST_SLTIU_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, (VAL1 < VAL2))

`define TEST_XORI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_I_TYPE(VAL2, R1, 3'b100, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_XORI(TNUM, VAL1, VAL2) `TEST_XORI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, (VAL1^VAL2))

`define TEST_ORI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_I_TYPE(VAL2, R1, 3'b110, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_ORI(TNUM, VAL1, VAL2) `TEST_ORI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, (VAL1|VAL2))

`define TEST_ANDI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_I_TYPE(VAL2, R1, 3'b111, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_ANDI(TNUM, VAL1, VAL2) `TEST_ANDI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, (VAL1&VAL2))

`define TEST_SLLI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, VAL2, R1, 3'b001, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SLLI(TNUM, VAL1, VAL2) `TEST_SLLI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, (VAL1 << (VAL2%32)))

`define TEST_SRLI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0, VAL2, R1, 3'b101, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SRLI(TNUM, VAL1, VAL2) `TEST_SRLI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, (VAL1 >> (VAL2%32)))

`define TEST_SRAI_REGS(TNUM, R1, RD, VAL1, VAL2, RES)    `TEST_NUM(TNUM); \
    `RESET; \
    `REGISTER(R1) = VAL1; \
    `REGISTER(RD) = 'hX; \
    `SET_R_TYPE(7'b0100000, VAL2, R1, 3'b101, RD, `OP_IMM); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES) \

`define TEST_SRAI(TNUM, VAL1, VAL2) `TEST_SRAI_REGS(TNUM, 5'd1, 5'd2, VAL1, VAL2, $signed($signed(VAL1) >>> (VAL2%32)))


`define OP_IMM_ADDI_TESTS `TEST_ADDI(1, 5, 12'd10); \
    `TEST_ADDI(2, 5, -12'd10); \
    `TEST_ADDI(3, 'hFFFFFFFF, 12'd1); \

`define OP_IMM_SLTI_TESTS `TEST_SLTI(4, 5, 12'd10); \
    `TEST_SLTI(5, 15, 12'd10); \
    `TEST_SLTI(6, -5, 12'd10); \
    `TEST_SLTI(7, 5, -12'd10); \

`define OP_IMM_SLTIU_TESTS `TEST_SLTIU(8, 5, 12'd10); \
    `TEST_SLTIU(9, 15, 12'd10); \
    `TEST_SLTIU(10, -5, 12'd10); \
    `TEST_SLTIU(11, 5, -12'd10); \

`define OP_IMM_XORI_TESTS `TEST_XORI(12, 200, 12'd200); \
    `TEST_XORI(13, 'b01001010, 12'b11011010); \

`define OP_IMM_ORI_TESTS `TEST_ORI(14, 'h55, 12'hAA); \
    `TEST_ORI(15, 123, 12'd123); \
    `TEST_ORI(16, 'hDEADBEEF, 12'h123); \

`define OP_IMM_ANDI_TESTS `TEST_ANDI(17, 'h55, 12'hAA); \
    `TEST_ANDI(18, 123, 12'd123); \
    `TEST_ANDI(19, 'hDEADBEEF, 12'h123); \

`define OP_IMM_SLLI_TESTS `TEST_SLLI(20, 5, 5'd1); \
    `TEST_SLLI(21, 10, 5'd1); \
    `TEST_SLLI(22, 1, 5'd31); \
    `TEST_SLLI(23, 1, 5'h5); \

`define OP_IMM_SRLI_TESTS `TEST_SRL(24, 200, 5'd1); \
    `TEST_SRL(25, 150, 5'd2); \
    `TEST_SRL(26, -1, 5'd1); \

`define OP_IMM_SRAI_TESTS `TEST_SRA(27, -1, 5'd1); \
    `TEST_SRA(28, -100, 5'd1); \
    `TEST_SRA(29, -100, 5'd4); \

`define OP_IMM_TESTS `OP_IMM_ADDI_TESTS \
                 `OP_IMM_SLTI_TESTS \
                 `OP_IMM_SLTIU_TESTS \
                 `OP_IMM_XORI_TESTS \
                 `OP_IMM_ORI_TESTS \
                 `OP_IMM_ANDI_TESTS \
                 `OP_IMM_SLLI_TESTS \
                 `OP_IMM_SRLI_TESTS \
                 `OP_IMM_SRAI_TESTS \