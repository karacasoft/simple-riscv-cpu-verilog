`define CACHE_WIDTH 4
`define CACHE_HEIGHT 1024

module DirectCache32(input wire clk,
                     input wire [31:0] addr,
                     input wire rd_en,
                     output wire [31:0] value,
                     output wire ready,

                     input wire [31:0] wr_data,
                     input wire wr_en,
                     
                     output reg [31:0] mem_addr,
                     output reg [31:0] mem_wr_data,
                     output reg mem_wr_en,
                     input wire [31:0] mem_read);

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

reg [2:0] mem_req;
reg [2:0] wb_state;

assign ready = (mem_req == 0 && wb_state == 0) ? 1 : 0;

integer ii = 0;
initial begin
    mem_req = 0;
    wb_state = 0;
    mem_wr_en = 0;
    for (ii = 0; ii < `CACHE_HEIGHT; ii++) begin
        valid[ii] = 0;
        dirty[ii] = 0;
    end
end
assign value = cache_mem[line * `CACHE_WIDTH + offset];
always @(*) begin
    if(rd_en == 1) begin
        if (mem_req == 0 && wb_state == 0) begin
            if (valid[line] == 1'b1 && tags[line] == tag) begin
                if(wr_en == 1) begin
                    cache_mem[line * `CACHE_WIDTH + offset] = wr_data;
                    dirty[line] = 1'b1;
                end
            end
            else if(valid[line] == 0 || tags[line] != tag) begin
                if(valid[line] == 1'b1 && dirty[line] == 1'b1) begin
                    wb_state = 'b111;
                    mem_addr = {tags[line], line, 2'b00};
                end
                else begin
                    mem_req = 'b111;
                    mem_addr = {tag, line, 2'b00};
                end
            end
        end
        
        if(mem_req == 3'b011) begin
            mem_req = 0;
            valid[line] = 1;
            dirty[line] = 0;
            tags[line] = tag;
        end

        if(wb_state == 3'b011) begin
            wb_state = 0;
            mem_wr_en = 0;
            mem_addr = {tag, line, 2'b00};
            dirty[line] = 0;
        end
    end
    

end


wire [19:0] mem_tag;
wire [9:0] mem_line;
wire [1:0] mem_offset;

assign mem_tag = mem_addr[31:12];
assign mem_line = mem_addr[11:2];
assign mem_offset = mem_addr[1:0];

always @(posedge clk) begin
    
    if(wb_state > 0) begin
        mem_wr_data <= cache_mem[mem_line * `CACHE_WIDTH + mem_offset];
        mem_wr_en <= 1;
        mem_addr <= mem_addr + 1;
        wb_state <= wb_state - 1;
    end
    if(wb_state == 0) begin
        if(mem_req > 0) begin
            cache_mem[mem_line * `CACHE_WIDTH + mem_offset] <= mem_read;
            mem_addr <= mem_addr + 1;
            mem_req <= mem_req - 1;
        end
    end
end

endmodule // DirectCache32