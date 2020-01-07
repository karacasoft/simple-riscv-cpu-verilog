`define CACHE_WIDTH 4
`define CACHE_HEIGHT 1024

module DirectCache32(input wire clk,
                     input wire [31:0] addr,
                     input wire rd_en,
                     output reg [31:0] value,
                     output reg ready,

                     input wire [31:0] wr_data,
                     input wire wr_en,
                     
                     output reg [31:0] mem_addr,
                     output reg [31:0] mem_wr_data,
                     output reg mem_wr_en,
                     input wire [31:0] mem_read);

localparam S_IDLE = 4'd0;
localparam S_READ = 4'd1;
localparam S_WRITEBACK = 4'd2;
localparam S_WRITE = 4'd3;

localparam RS_BYTE0 = 3'd0;
localparam RS_BYTE1 = 3'd1;
localparam RS_BYTE2 = 3'd2;
localparam RS_BYTE3 = 3'd3;
localparam RS_COMPLETE = 3'd4;

localparam WB_BYTE0 = 3'd0;
localparam WB_BYTE1 = 3'd1;
localparam WB_BYTE2 = 3'd2;
localparam WB_BYTE3 = 3'd3;
localparam WB_COMPLETE = 3'd4;

reg [3:0] state;
reg [3:0] nextstate;

reg [2:0] read_state;
reg [2:0] nextread_state;

reg [2:0] writeback_state;
reg [2:0] nextwriteback_state;


reg valid [0:`CACHE_HEIGHT];
reg dirty [0:`CACHE_HEIGHT];
reg [19:0] tags [0:`CACHE_HEIGHT];
reg [31:0] cache_mem [0:`CACHE_HEIGHT*`CACHE_WIDTH];

wire [19:0] tag;
wire [9:0] line;
wire [1:0] offset;

assign tag = addr[31:12];
assign line = addr[11:2];
assign offset = addr[1:0];

wire [19:0] mem_tag;
wire [9:0] mem_line;
wire [1:0] mem_offset;

assign mem_tag = mem_addr[31:12];
assign mem_line = mem_addr[11:2];
assign mem_offset = mem_addr[1:0];


initial begin
    state = S_IDLE;
    nextstate = S_IDLE;
    read_state = RS_BYTE0;
    nextread_state = RS_BYTE0;
    writeback_state = WB_BYTE0;
    nextwriteback_state = WB_BYTE0;
end

always @(*) begin
    if(state === S_IDLE || state === S_WRITE) begin
        if(state === S_WRITE) begin
            cache_mem[line * `CACHE_WIDTH + offset] = wr_data;
            dirty[line] = 1;
        end

        value = cache_mem[line * `CACHE_WIDTH + offset];
        if(valid[line] === 1 && tag === tags[line]) begin
            if(wr_en && cache_mem[line * `CACHE_WIDTH + offset] === wr_data) ready = 1;
            else if(!wr_en) ready = 1;
            else ready = 0;
        end
        else ready = 0;
    end
end


always @(*) begin
    if(state === S_WRITEBACK) begin
        ready = 0;
        mem_wr_en = 1;
        case(writeback_state)
        WB_BYTE0: begin
            mem_wr_data = cache_mem[line * `CACHE_WIDTH + 0];
            mem_addr = { addr[31:2], 2'b00 };
        end
        WB_BYTE1: begin
            mem_wr_data = cache_mem[line * `CACHE_WIDTH + 1];
            mem_addr = { addr[31:2], 2'b01 };
        end
        WB_BYTE2: begin
            mem_wr_data = cache_mem[line * `CACHE_WIDTH + 2];
            mem_addr = { addr[31:2], 2'b10 };
        end
        WB_BYTE3: begin
            mem_wr_data = cache_mem[line * `CACHE_WIDTH + 3];
            mem_addr = { addr[31:2], 2'b11 };
        end
        WB_COMPLETE: begin
            dirty[line] = 0;
            mem_wr_en = 0;
        end
        endcase
    end
end

always @(*) begin
    if(state === S_READ) begin
        ready = 0;
        case(read_state)
        RS_BYTE0: begin
            mem_addr = { addr[31:2], 2'b00 };
            cache_mem[mem_line * `CACHE_WIDTH + 0] = mem_read;
        end
        RS_BYTE1: begin
            mem_addr = { addr[31:2], 2'b01 };
            cache_mem[mem_line * `CACHE_WIDTH + 1] = mem_read;
        end
        RS_BYTE2: begin
            mem_addr = { addr[31:2], 2'b10 };
            cache_mem[mem_line * `CACHE_WIDTH + 2] = mem_read;
        end
        RS_BYTE3: begin
            mem_addr = { addr[31:2], 2'b11 };
            cache_mem[mem_line * `CACHE_WIDTH + 3] = mem_read;
        end
        RS_COMPLETE: begin
            tags[mem_line] = mem_tag;
            valid[mem_line] = 1;
            dirty[mem_line] = 0;
        end
        endcase
    end
end

always @(*) begin
    case(state)
    S_IDLE: begin
        if(tags[line] !== tag || valid[line] !== 1) begin
            if(rd_en == 1) nextstate = S_READ;
            else nextstate = S_IDLE;
        end
        else if(tags[line] != tag && valid[line] === 1 && dirty[line] === 1) begin
            if(rd_en == 1) nextstate = S_WRITEBACK;
            else nextstate = S_IDLE;
        end
        else if(tags[line] === tag && valid[line] === 1 && wr_en === 1) begin
            nextstate = S_WRITE;
        end
    end
    S_READ: begin
        case(read_state)
        RS_BYTE0: nextread_state = RS_BYTE1;
        RS_BYTE1: nextread_state = RS_BYTE2;
        RS_BYTE2: nextread_state = RS_BYTE3;
        RS_BYTE3: nextread_state = RS_COMPLETE;
        RS_COMPLETE: nextread_state = RS_BYTE0;
        endcase
        case(read_state)
        RS_BYTE0, RS_BYTE1, RS_BYTE2, RS_BYTE3: nextstate = S_READ;
        RS_COMPLETE: if(wr_en) nextstate = S_WRITE;
                     else nextstate = S_IDLE;
        endcase
    end
    S_WRITEBACK: begin
        case(writeback_state)
        WB_BYTE0: nextwriteback_state = WB_BYTE1;
        WB_BYTE1: nextwriteback_state = WB_BYTE2;
        WB_BYTE2: nextwriteback_state = WB_BYTE3;
        WB_BYTE3: nextwriteback_state = WB_COMPLETE;
        WB_COMPLETE: nextwriteback_state = WB_BYTE0;
        endcase
        case(read_state)
        WB_BYTE0, WB_BYTE1, WB_BYTE2, WB_BYTE3: nextstate = S_WRITEBACK;
        WB_COMPLETE: nextstate = S_IDLE;
        endcase
    end
    S_WRITE: begin
        if(wr_en) nextstate = S_WRITE;
        else nextstate = S_IDLE;
    end

    endcase
end

always @(posedge clk) begin
    state <= nextstate;
    read_state <= nextread_state;
    writeback_state <= nextwriteback_state;
end

endmodule // DirectCache32