`include "cpu.vh"
`include "cpu_tests/test_common.vh"

`define TEST_LUI_REGS(TNUM, INIT, RD, IMM20, RES) `TEST_NUM(TNUM); \
    `REGISTER(RD) = INIT; \
    `RESET; \
    `SET_U_TYPE(IMM20, RD, `LUI); \
    `DELAY_CYCLES(3); \
    `ASSERT_EQ(`REGISTER(RD), RES); \

`define TEST_LUI(TNUM, INIT, IMM20) `TEST_LUI_REGS(TNUM, INIT, 5'd1, IMM20, ((IMM20 << 12)))

`define LUI_TESTS `TEST_LUI(1, 0, 20'd1); \
                  `TEST_LUI(2, 'hFFFFFF, 20'h15); \
                  `TEST_LUI(3, 'hFFFABC, 20'h150); \