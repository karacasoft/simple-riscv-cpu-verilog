`include "load_store_unit/load_store_unit.vh"

module LoadStoreUnit(
    input wire clk,
    input wire [31:0] addr,
    input wire [1:0] op_size,
    input wire op_unsigned,

    output wire [31:0] rd_data,
    output wire data_ready,
    input wire [31:0] w_data,
    input wire w_en,

    input wire data_req,

    output reg [31:0] mem_addr,
    input wire [31:0] mem_rd_data,
    input wire mem_data_ready,
    output reg [31:0] mem_w_data,
    output reg mem_w_en
);

localparam STATE_IDLE            = 4'd0;
localparam STATE_READ            = 4'd1;
localparam STATE_R_BEFORE_W      = 4'd2;
localparam STATE_WRITE           = 4'd3;
localparam STATE_WRITE_STALL     = 4'd4;

wire [31:0] word_addr;
assign word_addr = addr >> 2;

wire [1:0] misalignment;
assign misalignment = addr[1:0];

reg [31:0] out_rd_data;
assign rd_data = out_rd_data;

reg out_data_ready;
assign data_ready = out_data_ready;

reg [3:0] state;
reg [3:0] next_state;

reg [1:0] read_state;

reg [31:0] rd_word_0;
reg [31:0] rd_word_1;

initial begin
    state = STATE_IDLE;
    next_state = STATE_IDLE;
    mem_w_en = 0;
    read_state = 0;
end

always @(posedge clk) begin
    state <= next_state;
end

always @(*) begin
    case(state)
    STATE_IDLE: begin
        if(data_req === 1)
            if(w_en) next_state = STATE_R_BEFORE_W;
            else next_state = STATE_READ;
    end
    STATE_READ: begin
        if(mem_data_ready === 1)
            if(read_state === 0) next_state = STATE_IDLE;
            else if(w_en === 1) next_state = STATE_WRITE_STALL;
        else
            next_state = STATE_READ;
    end
    STATE_R_BEFORE_W: begin
        if(mem_data_ready === 1)
            if(w_en) next_state = STATE_WRITE_STALL;
            else begin
                if(read_state === 0) next_state = STATE_IDLE;
            end
        else
            next_state = STATE_R_BEFORE_W;
    end
    STATE_WRITE_STALL: begin
        next_state = STATE_WRITE;
    end
    STATE_WRITE: begin
        if(mem_data_ready === 1) next_state = STATE_IDLE;
        else next_state = STATE_WRITE;
    end
    endcase
end

always @(*) begin
    if(state === STATE_IDLE) begin
        out_data_ready = 0;
        mem_w_en = 0;
    end
end

always @(*) begin
    if(state === STATE_WRITE_STALL) begin
        out_data_ready = 0;
    end
end

// STORE
always @(*) begin
    if(state === STATE_WRITE) begin
        mem_w_en = 1;
        case (op_size)
        `LSU_OP_SIZE_BYTE: begin
            if(misalignment === 'b00) mem_w_data = { mem_rd_data[31:8], w_data[7:0] };
            else if(misalignment === 'b01) mem_w_data = { mem_rd_data[31:16], w_data[7:0], mem_rd_data[7:0] };
            else if(misalignment === 'b10) mem_w_data = { mem_rd_data[31:24], w_data[7:0], mem_rd_data[15:0] };
            else if(misalignment === 'b11) mem_w_data = { w_data[7:0], mem_rd_data[23:0] };

            out_data_ready = mem_data_ready;
        end
        `LSU_OP_SIZE_HALF_WORD: begin
            if(misalignment === 'b00) begin
                mem_w_data = { mem_rd_data[31:16], w_data[15:0] };

                out_data_ready = mem_data_ready;
            end
            else if(misalignment === 'b01) begin
                mem_w_data = { mem_rd_data[31:24], w_data[15:0], mem_rd_data[7:0] };

                out_data_ready = mem_data_ready;
            end
            else if(misalignment === 'b10) begin
                mem_w_data = { w_data[15:0], mem_rd_data[15:0] };

                out_data_ready = mem_data_ready;
            end
            else if(misalignment === 'b11) begin
                if(read_state === 2) begin
                    mem_w_data = { w_data[7:0], rd_word_0[31:8] };
                    if(mem_w_data === mem_rd_data) begin
                        read_state = 1;
                        mem_addr = word_addr + 1;
                    end
                end 
                else if(read_state === 1) begin
                    mem_w_data = { rd_word_1[23:0], w_data[15:8] };
                    if(mem_w_data === mem_rd_data) begin
                        read_state = 0;
                        out_data_ready = 1;
                    end
                end
            end
        end
        `LSU_OP_SIZE_WORD: begin
            if(misalignment === 'b00) begin
                mem_w_data = w_data;

                out_data_ready = mem_data_ready;
            end
            else if(misalignment === 'b01) begin
                
            end
            else if(misalignment === 'b10) begin
                
            end
            else if(misalignment === 'b11) begin
                
            end
            
        end
        endcase
    end
    
end


// LOAD
always @(*) begin
    if(state === STATE_READ || state === STATE_R_BEFORE_W) begin
        case (op_size)
        `LSU_OP_SIZE_BYTE: begin
            mem_addr = word_addr;
            if(misalignment === 2'b00)
                if(op_unsigned) out_rd_data = { 24'b0, mem_rd_data[7:0] };
                else out_rd_data = { {24{mem_rd_data[7]}}, mem_rd_data[7:0] };
            else if(misalignment === 2'b01)
                if(op_unsigned) out_rd_data = { 24'b0, mem_rd_data[15:8] };
                else out_rd_data = { {24{mem_rd_data[15]}}, mem_rd_data[15:8] };
            else if(misalignment === 2'b10)
                if(op_unsigned) out_rd_data = { 24'b0, mem_rd_data[23:16] };
                else out_rd_data = { {24{mem_rd_data[23]}}, mem_rd_data[23:16] };
            else if(misalignment === 2'b11)
                if(op_unsigned) out_rd_data = { 24'b0, mem_rd_data[31:24] };
                else out_rd_data = { {24{mem_rd_data[31]}}, mem_rd_data[31:24] };

            out_data_ready = (state === STATE_R_BEFORE_W) ? 0 : mem_data_ready;

        end
        `LSU_OP_SIZE_HALF_WORD: begin
            if(misalignment === 'b11) begin
                if(read_state === 0) begin
                    mem_addr = word_addr;
                    read_state = 2;
                    out_data_ready = 0;
                end
                else if(read_state === 2) begin
                    if(mem_data_ready) begin
                        rd_word_0 = mem_rd_data;
                        if(state === STATE_READ) begin
                            mem_addr = word_addr + 1;
                            read_state = 1;
                        end
                    end
                end
                else if(read_state === 1) begin
                    if(mem_data_ready) begin
                        rd_word_1 = mem_rd_data;
                        if(state === STATE_READ) begin
                            if(op_unsigned) out_rd_data = { 16'b0, rd_word_1[7:0], rd_word_0[31:24] };
                            else out_rd_data = { {16{rd_word_1[7]}}, rd_word_1[7:0], rd_word_0[31:24] };
                            out_data_ready = 1;
                            read_state = 0;
                        end
                    end
                end
            end
            else if(misalignment === 'b00 || misalignment === 'b01 || misalignment === 'b10) begin
                mem_addr = word_addr;
                rd_word_0 = mem_rd_data;
                if(misalignment == 'b00)
                    if(op_unsigned) out_rd_data = { 16'b0, rd_word_0[15:0] };
                    else out_rd_data = { {16{rd_word_0[15]}}, rd_word_0[15:0] };
                else if(misalignment == 'b01) 
                    if(op_unsigned) out_rd_data = { 16'b0, rd_word_0[23:8] };
                    else out_rd_data = { {16{rd_word_0[23]}}, rd_word_0[23:8] };
                else if(misalignment == 'b10)
                    if(op_unsigned) out_rd_data = { 16'b0, rd_word_0[31:16] };
                    else out_rd_data = { {16{rd_word_0[31]}}, rd_word_0[31:16] };
                out_data_ready = (state === STATE_R_BEFORE_W) ? 0 : mem_data_ready;
            end
        end
        `LSU_OP_SIZE_WORD: begin
            if(misalignment === 'b00) begin
                mem_addr = word_addr;
                rd_word_0 = mem_rd_data;
                out_rd_data = rd_word_0;
                out_data_ready = (state === STATE_R_BEFORE_W) ? 0 : mem_data_ready;
            end
            else if(misalignment === 'b01 || misalignment === 'b10 || misalignment === 'b11) begin
                if(read_state === 0 && state === STATE_READ) begin
                    mem_addr = word_addr;
                    read_state = 2;
                    out_data_ready = 0;
                end
                else if(read_state === 2) begin
                    if(mem_data_ready) begin
                        rd_word_0 = mem_rd_data;
                        if(state === STATE_READ) begin
                            mem_addr = word_addr + 1;
                            read_state = 1;
                        end
                    end
                end
                else if(read_state === 1) begin
                    rd_word_1 = mem_rd_data;
                    if(mem_data_ready && state === STATE_READ) begin
                        read_state = 0;
                        if(misalignment === 'b01) begin
                            out_rd_data = { rd_word_1[7:0], rd_word_0[31:8] };
                        end
                        else if(misalignment === 'b10) begin
                            out_rd_data = { rd_word_1[15:0], rd_word_0[31:16] };
                        end
                        else if(misalignment === 'b11) begin
                            out_rd_data = { rd_word_1[23:0], rd_word_0[31:24] };
                        end
                        out_data_ready = 1;
                    end
                end
            end
        end
        endcase
    end
end

endmodule // LoadStoreUnit