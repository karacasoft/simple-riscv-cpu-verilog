`include "cpu.vh"

`include "alu32/alu_ops.vh"
`include "alu32/alu32.v"

`include "registerfile32/registerfile32x32.v"
`include "load_store_unit/load_store_unit.v"

module RiskBesReloadedCPU(
    input clk,
    input rst,
    input [`XLEN-1:0] imem_rd_data,
    output wire [`XLEN-1:0] imem_addr,
    input wire imem_ready,

    output wire [`XLEN-1:0] dmem_addr,
    input wire [`XLEN-1:0] dmem_rd_data,
    output wire [`XLEN-1:0] dmem_wr_data,
    output wire dmem_wr_en,
    input wire dmem_ready
);

localparam S_IDLE        = 0;
localparam S_FETCH_INSTR = 1;
localparam S_EXEC        = 2;
localparam S_MEM_RW      = 3;
localparam S_BRANCH      = 4;
localparam S_JAL         = 5;

reg [4:0] state;
reg [4:0] nextstate;



reg [`XLEN-1:0] pc;
reg [`XLEN-1:0] nextpc;
assign imem_addr = pc >> 2;

wire [(`OPCODE_LEN-1):0] opcode;
wire [(`RD_LEN-1):0] rd;
wire [(`FUNCT3_LEN-1):0] funct3;
wire [(`RS1_LEN-1):0] rs1;
wire [(`RS2_LEN-1):0] rs2;
wire [(`FUNCT7_LEN-1):0] funct7;

assign opcode = imem_rd_data[(`OPCODE_LEN-1):`OPCODE_OFFSET];
assign rd = imem_rd_data[(`RD_OFFSET+`RD_LEN-1):`RD_OFFSET];
assign funct3 = imem_rd_data[`FUNCT3_OFFSET+`FUNCT3_LEN-1:`FUNCT3_OFFSET];
assign rs1 = imem_rd_data[`RS1_OFFSET+`RS1_LEN-1:`RS1_OFFSET];
assign rs2 = imem_rd_data[`RS2_OFFSET+`RS2_LEN-1:`RS2_OFFSET];
assign funct7 = imem_rd_data[`FUNCT7_OFFSET+`FUNCT7_LEN-1:`FUNCT7_OFFSET];

reg [4:0] alu_op_type;
reg [31:0] alu_op1;
reg [31:0] alu_op2;
wire [31:0] alu_ret;

Alu32 alu(
    .op_type(alu_op_type),
    .op1(alu_op1),
    .op2(alu_op2),
    .ret(alu_ret)
);

wire [31:0] register_file_rdata1;
wire [31:0] register_file_rdata2;

reg [31:0] register_file_wdata;
reg register_file_write;

reg [4:0] register_file_ra1;
reg [4:0] register_file_ra2;
reg [4:0] register_file_wa;

RegisterFile32x32 register_file(
    .clk(clk),
    .ra1(register_file_ra1),
    .ra2(register_file_ra2),
    .write(register_file_write),
    .wa(register_file_wa),
    .wdata(register_file_wdata),
    .rdata1(register_file_rdata1),
    .rdata2(register_file_rdata2)
);

reg [31:0]  lsu_addr;
reg [1:0]   lsu_op_size;
reg         lsu_op_unsigned;

wire [31:0] lsu_rd_data;
wire        lsu_data_ready;

reg [31:0]  lsu_w_data;
reg         lsu_w_en;

reg         lsu_data_req;

LoadStoreUnit lsu(
    .clk(clk),
    .addr(lsu_addr),
    .op_size(lsu_op_size),
    .op_unsigned(lsu_op_unsigned),

    .rd_data(lsu_rd_data),
    .data_ready(lsu_data_ready),
    .w_data(lsu_w_data),
    .w_en(lsu_w_en),

    .data_req(lsu_data_req),

    .mem_addr(dmem_addr),
    .mem_rd_data(dmem_rd_data),
    .mem_data_ready(dmem_ready),
    .mem_w_data(dmem_wr_data),
    .mem_w_en(dmem_wr_en)
);


reg branch_taken;

initial begin
    branch_taken = 0;
    pc = 'h0;
    state = S_IDLE;
end

always @(*) begin
    if(state === S_FETCH_INSTR) begin
        register_file_write = 0;
        case(opcode)
            `OP: begin
                register_file_ra1 = rs1;
                register_file_ra2 = rs2;
                register_file_wa = rd;

                alu_op1 = register_file_rdata1;
                alu_op2 = register_file_rdata2;
                register_file_wdata = alu_ret;
                case ({ funct7, funct3 })
                `FUNCT7_FUNCT3_ADD: alu_op_type = `OP_ADD;
                `FUNCT7_FUNCT3_SUB: alu_op_type = `OP_SUB;
                `FUNCT7_FUNCT3_SLL: alu_op_type = `OP_SLL;
                `FUNCT7_FUNCT3_SLT: alu_op_type = `OP_SLT;
                `FUNCT7_FUNCT3_SLTU: alu_op_type = `OP_SLTU;
                `FUNCT7_FUNCT3_XOR: alu_op_type = `OP_XOR;
                `FUNCT7_FUNCT3_SRL: alu_op_type = `OP_SRL;
                `FUNCT7_FUNCT3_SRA: alu_op_type = `OP_SRA;
                `FUNCT7_FUNCT3_OR: alu_op_type = `OP_OR;
                `FUNCT7_FUNCT3_AND: alu_op_type = `OP_AND;
                default: begin
                    // invalid instruction
                end
                endcase
            end
            `OP_IMM: begin
                register_file_ra1 = rs1;
                register_file_wa = rd;
                alu_op1 = register_file_rdata1;
                alu_op2 = { {20{funct7[`FUNCT7_LEN-1]}} , funct7, rs2 };
                register_file_wdata = alu_ret;
                case (funct3)
                `FUNCT3_SLLI: alu_op_type = `OP_SLL;
                `FUNCT3_SRLI: alu_op_type = `OP_SRL;
                `FUNCT3_SRAI: alu_op_type = `OP_SRA;
                `FUNCT3_ADDI: alu_op_type = `OP_ADD;
                `FUNCT3_SLTI: alu_op_type = `OP_SLT;
                `FUNCT3_SLTIU: alu_op_type = `OP_SLTU;
                `FUNCT3_XORI: alu_op_type = `OP_XOR;
                `FUNCT3_ORI: alu_op_type = `OP_OR;
                `FUNCT3_ANDI: alu_op_type = `OP_AND;
                default: begin
                    // invalid instruction
                end
                endcase
            end
            `LOAD: begin
                lsu_op_unsigned = funct3[2];
                case(funct3)
                `FUNCT3_LB, `FUNCT3_LBU:
                    lsu_op_size = `LSU_OP_SIZE_BYTE;
                `FUNCT3_LH, `FUNCT3_LHU:
                    lsu_op_size = `LSU_OP_SIZE_HALF_WORD;
                `FUNCT3_LW:
                    lsu_op_size = `LSU_OP_SIZE_WORD;
                endcase
                register_file_ra1 = rs1;
                lsu_addr = register_file_rdata1 + { {20{funct7[6]}}, funct7, rs2};
                lsu_data_req = 1;
                register_file_write = 0;
            end
            `STORE: begin
                register_file_write = 0;
                lsu_op_unsigned = 0;
                case(funct3)
                `FUNCT3_SB: lsu_op_size = `LSU_OP_SIZE_BYTE;
                `FUNCT3_SH: lsu_op_size = `LSU_OP_SIZE_HALF_WORD;
                `FUNCT3_SW: lsu_op_size = `LSU_OP_SIZE_WORD;
                endcase
                register_file_ra1 = rs1;
                register_file_ra2 = rs2;
                lsu_addr = register_file_rdata1 + { {20{funct7[6]}}, funct7, rd };
                lsu_w_data = register_file_rdata2;
                lsu_data_req = 1;
            end
            `LUI: begin
                register_file_wa = rd;
                register_file_wdata = {funct7, rs2, rs1, funct3, 12'd0};
            end
            `AUIPC: begin
                register_file_wa = rd;
                register_file_wdata = { funct7, rs2, rs1, funct3, pc[11:0] };
            end
            `BRANCH: begin
                register_file_ra1 = rs1;
                register_file_ra2 = rs2;
                alu_op1 = register_file_rdata1;
                alu_op2 = register_file_rdata2;
                case(funct3)
                `FUNCT3_BEQ: alu_op_type = `OP_SUB;
                `FUNCT3_BNE: alu_op_type = `OP_SUB;
                `FUNCT3_BLT: alu_op_type = `OP_SLT;
                `FUNCT3_BGT: alu_op_type = `OP_SLT;
                `FUNCT3_BLTU: alu_op_type = `OP_SLTU;
                `FUNCT3_BGTU: alu_op_type = `OP_SLTU;
                endcase
            end
            `JAL: begin
                register_file_wa = rd;
                register_file_wdata = pc + 4;
                register_file_write = 1;
            end
            `JALR: begin
                register_file_ra1 = rs1;
                register_file_wa = rd;
                register_file_wdata = pc + 4;
                register_file_write = 1;
            end
            default: register_file_write = 0;
        endcase
    end
end

always @(*) begin
    if(state === S_BRANCH) begin
        case(funct3)
        `FUNCT3_BEQ: if(alu_ret === 0) branch_taken = 1; else branch_taken = 0;
        `FUNCT3_BNE: if(alu_ret !== 0) branch_taken = 1; else branch_taken = 0;
        `FUNCT3_BLT: if(alu_ret === 1) branch_taken = 1; else branch_taken = 0;
        `FUNCT3_BGT: if(alu_ret !== 1) branch_taken = 1; else branch_taken = 0;
        `FUNCT3_BLTU: if(alu_ret === 1) branch_taken = 1; else branch_taken = 0;
        `FUNCT3_BGTU: if(alu_ret !== 1) branch_taken = 1; else branch_taken = 0;
        endcase
    end
end

always @(*) begin
    if(state === S_EXEC) begin
        case(opcode)
        `OP: register_file_write = 1;
        `OP_IMM: register_file_write = 1;
        `LOAD: begin
            register_file_wdata = lsu_rd_data;
            register_file_wa = rd;
            register_file_write = 1;
            lsu_data_req = 0;
        end
        `STORE: begin
            lsu_data_req = 0;
        end
        `AUIPC, `LUI: begin
            register_file_write = 1;
        end
        endcase
    end
end

always @(*) begin
    if(state === S_MEM_RW) begin
        case(opcode)
        `STORE: begin
            lsu_w_en = 1;
        end
        default: lsu_w_en = 0;
        endcase
    end
    else lsu_w_en = 0;
end

always @(*) begin
    case(state)
    S_IDLE: nextstate = S_FETCH_INSTR;
    S_FETCH_INSTR: begin
        if(imem_ready)
            case(opcode)
            `LOAD: begin
                nextstate = S_MEM_RW;
            end
            `STORE: begin
                nextstate = S_MEM_RW;
            end
            `BRANCH: begin
                nextstate = S_BRANCH;
            end
            `JAL, `JALR: begin
                nextstate = S_JAL;
            end
            default: begin
                nextstate = S_EXEC;
            end
            endcase
        else nextstate = S_FETCH_INSTR;
        
    end
    S_BRANCH: nextstate = S_FETCH_INSTR;
    S_JAL: nextstate = S_FETCH_INSTR;
    S_MEM_RW: begin
        if(lsu_w_en) begin
            if(lsu_rd_data === lsu_w_data) begin
                nextstate = S_EXEC;
            end else nextstate = S_MEM_RW;
        end
        else if(lsu_data_ready === 1) begin
            nextstate = S_EXEC;
        end else nextstate = S_MEM_RW;
    end
    S_EXEC: nextstate = S_FETCH_INSTR;
    default: nextstate = S_IDLE;
    endcase
end


always @(*) begin
    case(state)
    S_IDLE: nextpc = pc;
    S_EXEC: nextpc = pc + 4;
    S_BRANCH: if(branch_taken) nextpc = pc + {{19{funct7[6]}}, funct7[6], rd[0], funct7[5:0], rd[4:1], 1'b0};
              else nextpc = pc + 4;
    S_JAL: begin
        case(opcode)
        `JAL: begin
            nextpc = pc + {{11{funct7[6]}}, funct7[6], rs1, funct3, rs2[0], funct7[5:0], rs2[4:1], 1'b0};
        end
        `JALR: begin
            nextpc = register_file_rdata1 + {{20{funct7[6]}}, funct7, rs2[4:1], 1'b0};
        end
        endcase
    end
    default: nextpc = pc;
    endcase
end

always @(posedge clk) begin
    
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        pc <= 'h0;
        state <= S_IDLE;
    end
    else begin
        pc <= nextpc;
        state <= nextstate;
    end
end

endmodule