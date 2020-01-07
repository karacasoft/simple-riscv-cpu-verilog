`timescale 1ns / 100ps

`include "cpu_tests/test_common.vh"
`include "cpu_tests/test_op.vh"
`include "cpu_tests/test_op_imm.vh"
`include "cpu_tests/test_lui.vh"
`include "cpu_tests/test_load_store.vh"
`include "cpu_tests/test_auipc.vh"
`include "cpu_tests/test_branch.vh"


`include "cpu.vh"
`include "cpu.v"

module TB_RiskBesReloadedCPU();

reg cpu_clk;
reg cpu_rst;
reg [`XLEN-1:0] cpu_imem_rd_data;
wire [`XLEN-1:0]  cpu_imem_addr;
reg cpu_imem_ready;

wire [`XLEN-1:0] cpu_dmem_addr;
reg [`XLEN-1:0] cpu_dmem_rd_data;
wire [`XLEN-1:0] cpu_dmem_wr_data;
wire cpu_dmem_wr_en;
reg cpu_dmem_ready;



RiskBesReloadedCPU cpu(
    .clk(cpu_clk),
    .rst(cpu_rst),
    .imem_rd_data(cpu_imem_rd_data),
    .imem_addr(cpu_imem_addr),
    .imem_ready(cpu_imem_ready),

    .dmem_addr(cpu_dmem_addr),
    .dmem_rd_data(cpu_dmem_rd_data),
    .dmem_wr_data(cpu_dmem_wr_data),
    .dmem_wr_en(cpu_dmem_wr_en),
    .dmem_ready(cpu_dmem_ready)
);

/* Required for testing */
integer test_num;
reg [4:0] __rs1;
reg [4:0] __rs2;
reg [4:0] __rd;
reg [2:0] __funct3;
reg [6:0] __funct7;
reg [6:0] __opcode;
reg [11:0] __imm12;
reg [19:0] __imm20;
/************************/

reg error;

initial begin
    error = 0;
    $dumpfile("cpu.vcd");
    $dumpvars(0, TB_RiskBesReloadedCPU);
    cpu_rst = 0;
    cpu_clk = 1;
    cpu_imem_ready = 1;
    cpu_dmem_ready = 1;


    $display("Running OP tests");
    `OP_TESTS;

    $display("Running OP_IMM tests");
    `OP_IMM_TESTS;

    $display("Running delayed instruction tests");
    `TEST_NUM(100);
    `RESET;
    `REGISTER(1) = 1;
    `REGISTER(2) = 2;
    `SET_R_TYPE(0, 2, 1, 0, 3, `OP);
    `PC = 'h400;
    `IMEM_READY = 0;
    `DELAY_CYCLES(3);
    `IMEM_READY = 1;
    `DELAY_CYCLES(2);
    `ASSERT_EQ(`PC, 'h404);
    `ASSERT_EQ(`REGISTER(3), 3);

    /*
    $display("Running Load-Store tests");
    `TEST_LW_ALIGNED(1, 1, 2, 0, 0, 500);
    `TEST_LW_MISALIGNED(2, 1, 2, 0, 1, 'h12345678, 'h1234ABCD, 'hCD123456);
    `TEST_LW_MISALIGNED(3, 1, 2, 0, 2, 'h12345678, 'h1234ABCD, 'hABCD1234);
    `TEST_LW_MISALIGNED(4, 1, 2, 0, 3, 'h12345678, 'h1234ABCD, 'h34ABCD12);

    `TEST_LW_SAME_REG_ALIGNED(111, 1, 0, 0, 500);
    `TEST_LW_SAME_REG_MISALIGNED(112, 1, 0, 1, 'h12345678, 'h1234ABCD, 'hCD123456);
    `TEST_LW_SAME_REG_MISALIGNED(113, 1, 0, 2, 'h12345678, 'h1234ABCD, 'hABCD1234);
    `TEST_LW_SAME_REG_MISALIGNED(114, 1, 0, 3, 'h12345678, 'h1234ABCD, 'h34ABCD12);

    `TEST_LHU_ALIGNED(5, 1, 2, 0, 0, 'h12345678, 'h5678);
    `TEST_LHU_ALIGNED(6, 1, 2, 0, 1, 'h12345678, 'h3456);
    `TEST_LHU_ALIGNED(7, 1, 2, 0, 2, 'h12345678, 'h1234);
    `TEST_LHU_ALIGNED(8, 1, 2, 0, 2, 'h87654321, 'h8765);

    `TEST_LH_ALIGNED(9, 1, 2, 0, 0, 'h87654321, 'h4321);
    `TEST_LH_ALIGNED(10, 1, 2, 0, 1, 'h87654321, 'h6543);
    `TEST_LH_ALIGNED(11, 1, 2, 0, 2, 'h87654321, 'hFFFF8765);

    `TEST_LH_MISALIGNED(12, 1, 2, 0, 3, 'h12345678, 'h1234ABCD, 'hFFFFCD12);
    `TEST_LH_MISALIGNED(13, 1, 2, 0, 3, 'h12345678, 'h1234AB00, 'h12);
    `TEST_LHU_MISALIGNED(14, 1, 2, 0, 3, 'h12345678, 'h1234ABCD, 'hCD12);
    `TEST_LHU_MISALIGNED(15, 1, 2, 0, 3, 'h12345678, 'h1234AB00, 'h12);

    `TEST_LB(16, 1, 2, 0, 0, 'h12345687, 'hFFFFFF87);
    `TEST_LB(17, 1, 2, 0, 1, 'h12345687, 'h56);
    `TEST_LB(18, 1, 2, 0, 2, 'h12345687, 'h34);
    `TEST_LB(19, 1, 2, 0, 3, 'h12345687, 'h12);

    `TEST_LBU(161, 1, 2, 0, 0, 'h12345687, 'h87);
    `TEST_LBU(171, 1, 2, 0, 1, 'h12345687, 'h56);
    `TEST_LBU(181, 1, 2, 0, 2, 'h12345687, 'h34);
    `TEST_LBU(191, 1, 2, 0, 3, 'h12345687, 'h12);

    `TEST_SB(20, 2, 1, 0, 0, 'hAA, 'h12345678, 'h123456AA);
    `TEST_SB(21, 2, 1, 0, 1, 'hAA, 'h12345678, 'h1234AA78);
    `TEST_SB(22, 2, 1, 0, 2, 'hAA, 'h12345678, 'h12AA5678);
    `TEST_SB(23, 2, 1, 0, 3, 'hAA, 'h12345678, 'hAA345678);

    `TEST_SH_ALIGNED(24, 2, 1, 0, 0, 'hAABB, 'h12345678, 'h1234AABB);
    `TEST_SH_ALIGNED(25, 2, 1, 0, 1, 'hAABB, 'h12345678, 'h12AABB78);
    `TEST_SH_ALIGNED(26, 2, 1, 0, 2, 'hAABB, 'h12345678, 'hAABB5678);
    `TEST_SH_MISALIGNED(27, 2, 1, 0, 3, 'hAABB, 'h11111111, 'h22222222, 'hBB111111, 'h222222AA);

    `TEST_SW_ALIGNED(28, 2, 1, 0, 0, 'h12345678, 'h11111111);
    // TODO misaligned store word instructions are missing
    // Also, not implemented on code, so, do it at some point, lol
    */
    
    $display("Running LUI tests");
    `LUI_TESTS;

    $display("Running AUIPC tests");
    `TEST_AUIPC(1, 1, 'h1234, 'h400, 'h1234400);
    `TEST_AUIPC(2, 1, 'h123AB, 'h123400, 'h123AB400);
    `TEST_AUIPC(3, 1, 'h123AB, 'h0, 'h123AB000);

    //#1;
    $display("Running branch tests");
    `TEST_BEQ(1, 2, 1, 0, 0, 8, 'h400, 'h410);
    `TEST_BEQ(2, 2, 1, 0, 0, -8, 'h400, 'h3f0);
    `TEST_BEQ(3, 2, 1, 1, 0, 8, 'h400, 'h404);
    `TEST_BEQ(4, 2, 1, 0, 1, -8, 'h400, 'h404);

    `TEST_BNE(5, 2, 1, 1, 0, 8, 'h400, 'h410);
    `TEST_BNE(6, 2, 1, 0, 1, -8, 'h400, 'h3f0);
    `TEST_BNE(7, 2, 1, 0, 0, 8, 'h400, 'h404);
    `TEST_BNE(8, 2, 1, 0, 0, -8, 'h400, 'h404);

    `TEST_BLT(9, 2, 1, 1, 0, 8, 'h400, 'h410);
    `TEST_BLT(10, 2, 1, 0, -1, -8, 'h400, 'h3f0);
    `TEST_BLT(11, 2, 1, 0, 1, 8, 'h400, 'h404);
    `TEST_BLT(12, 2, 1, -1, 0, -8, 'h400, 'h404);

    `TEST_BGT(13, 2, 1, 0, 1, 8, 'h400, 'h410);
    `TEST_BGT(14, 2, 1, -1, 0, -8, 'h400, 'h3f0);
    `TEST_BGT(15, 2, 1, 1, 0, 8, 'h400, 'h404);
    `TEST_BGT(16, 2, 1, 0, -1, -8, 'h400, 'h404);
    
    `TEST_BLTU(17, 2, 1, 1, 0, 8, 'h400, 'h410);
    `TEST_BLTU(18, 2, 1, -1, 0, -8, 'h400, 'h3f0);
    `TEST_BLTU(19, 2, 1, 0, 1, 8, 'h400, 'h404);
    `TEST_BLTU(20, 2, 1, 0, -1, -8, 'h400, 'h404);

    `TEST_BGTU(21, 2, 1, 0, 1, 8, 'h400, 'h410);
    `TEST_BGTU(22, 2, 1, 0, -1, -8, 'h400, 'h3f0);
    `TEST_BGTU(23, 2, 1, 1, 0, 8, 'h400, 'h404);
    `TEST_BGTU(24, 2, 1, -1, 0, -8, 'h400, 'h404);

    $display("All tests passed successfully");
    $finish();
end

always begin
    `CLK_DELAY; cpu_clk = !cpu_clk;
end

endmodule // TB_RiskBesReloadedCPU