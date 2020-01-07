`include "direct_cache.v"

module TB_DirectCache32();

reg [31:0] memory_in;

reg         clk;
reg [31:0]  in_addr;
reg [31:0]  in_mem_read;

reg [31:0]  in_wr_data;
reg         in_wr_en;

wire [31:0] out_value;
wire        out_ready;
wire [31:0] out_mem_addr;

wire [31:0] out_mem_wr_data;
wire        out_mem_wr_en;


DirectCache32 cache(.clk(clk),
                     .addr(in_addr),
                     .value(out_value),
                     .ready(out_ready),
                     
                     .wr_data(in_wr_data),
                     .wr_en(in_wr_en),
                     
                     .mem_addr(out_mem_addr),
                     .mem_wr_data(out_mem_wr_data),
                     .mem_wr_en(out_mem_wr_en),
                     .mem_read(in_mem_read));

initial begin
    $dumpfile("cache.vcd");
    $dumpvars(0, TB_DirectCache32);

    clk = 0;
    in_wr_en = 0;
    in_wr_data = 0;

    in_mem_read = 'h00000001;
    in_addr = 'h12345678;
    #20;
    in_wr_en = 1;
    in_wr_data = 'h00000003;
    in_addr = 'h12345679;
    #20;
    in_wr_en = 0;
    in_addr = 'h12345680;
    #20;
    in_addr = 'h12345681;
    #20;
    in_wr_en = 1;
    in_wr_data = 'h00000004;
    in_addr = 'h12345681;


    #20;
    in_wr_en = 0;
    in_mem_read = 'h00000002;
    in_addr = 'hAB345681;
    #20;
    in_addr = 'hAB345682;
    #20;
    in_addr = 'hAB345683;
    #20;
    in_addr = 'hAB345684;
    $finish;

end

always begin
    #1 clk = !clk;
end



endmodule // TB_DirectCache32