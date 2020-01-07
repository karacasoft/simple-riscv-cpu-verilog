`define CLK_DELAY #5
`define DELAY_CYCLES(COUNT) #(COUNT*10)

`define TEST_NUM(num) test_num = num

`define SET_FIELDS_R(FUNCT7, RS2, RS1, FUNCT3, RD, OPCODE) __rs1 = RS1; \
                                                           __rs2 = RS2; \
                                                           __rd = RD; \
                                                           __funct3 = FUNCT3; \
                                                           __funct7 = FUNCT7; \
                                                           __opcode = OPCODE; \

`define SET_FIELDS_I(IMM12, RS1, FUNCT3, RD, OPCODE) __rs1 = RS1; \
                                                    __rd = RD; \
                                                    __funct3 = FUNCT3; \
                                                    __imm12 = IMM12; \
                                                    __opcode = OPCODE; \

`define SET_FIELDS_U(IMM20, RD, OPCODE) __rd = RD; \
                                        __imm20 = IMM20; \
                                        __opcode = OPCODE; \

`define SET_FIELDS_S(IMM12, RS2, RS1, FUNCT3, OPCODE) __rs1 = RS1; \
                                                    __rs2 = RS2; \
                                                    __funct3 = FUNCT3; \
                                                    __imm12 = IMM12; \
                                                    __opcode = OPCODE; \

`define SET_FIELDS_B(IMM12, RS2, RS1, FUNCT3, OPCODE) __imm12 = IMM12; \
                                                      __rs2 = RS2; \
                                                      __rs1 = RS1; \
                                                      __funct3 = FUNCT3; \
                                                      __opcode = OPCODE; \


`define SET_R_TYPE(FUNCT7, RS2, RS1, FUNCT3, RD, OPCODE) `SET_FIELDS_R(FUNCT7, RS2, RS1, FUNCT3, RD, OPCODE); cpu_imem_rd_data = { __funct7, __rs2, __rs1, __funct3, __rd, __opcode }
`define SET_I_TYPE(IMM12, RS1, FUNCT3, RD, OPCODE) `SET_FIELDS_I(IMM12, RS1, FUNCT3, RD, OPCODE); cpu_imem_rd_data = { __imm12, __rs1, __funct3, __rd, __opcode }
`define SET_U_TYPE(IMM20, RD, OPCODE) `SET_FIELDS_U(IMM20, RD, OPCODE); cpu_imem_rd_data = { __imm20, __rd, __opcode }
`define SET_S_TYPE(IMM12, RS2, RS1, FUNCT3, OPCODE) `SET_FIELDS_S(IMM12, RS2, RS1, FUNCT3, OPCODE); cpu_imem_rd_data = { __imm12[11:5], __rs2, __rs1, __funct3, __imm12[4:0], __opcode }
`define SET_B_TYPE(IMM12, RS2, RS1, FUNCT3, OPCODE) `SET_FIELDS_B(IMM12, RS2, RS1, FUNCT3, OPCODE); cpu_imem_rd_data = { __imm12[11], __imm12[9:4], __rs2, __rs1, __funct3, __imm12[3:0], __imm12[10], __opcode }

`define REGISTER(REG_X) cpu.register_file.reg_file[REG_X-1]

`define PC cpu.pc
`define IMEM_READY cpu_imem_ready
`define DMEM_RD_DATA cpu_dmem_rd_data
`define DMEM_READY cpu_dmem_ready

`define RESET cpu_rst = 1; `DELAY_CYCLES(1); cpu_rst = 0

`define ASSERT_EQ(ACTUAL, EXP) if ((EXP) !== (ACTUAL)) begin $display("TEST_NUM=%d, Assertion failed expected %x != actual %x", test_num, (EXP), (ACTUAL)); error=1; `DELAY_CYCLES(5); $finish_and_return(1); end
`define ASSERT_MEM_REQ(ADDR) if((ADDR) !== (cpu_dmem_addr)) begin $display("TEST_NUM=%d, Expected memory request to address=%x, found address=%x instead", test_num, (ADDR), (cpu_dmem_addr)); error=1; `DELAY_CYCLES(5); $finish_and_return(2); end
`define ASSERT_MEM_WRITE(ADDR, VALUE) `ASSERT_MEM_REQ(ADDR); \
            if(cpu.dmem_wr_data !== (VALUE)) begin $display("TEST_NUM=%d, Expected dmem_wr_data==%x actual = %x", test_num, (VALUE), cpu.dmem_wr_data); error=1; `DELAY_CYCLES(5); $finish_and_return(3); end \
            if(cpu.dmem_wr_en !== 1) begin $display("TEST_NUM=%d, Expected dmem_wr_en == 1, actual was %x", test_num, cpu.dmem_wr_en); error=1; `DELAY_CYCLES(5); $finish_and_return(4); end \
