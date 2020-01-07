`include "mem32/mem1024x32.v"
`include "direct_cache/direct_cache.v"

`include "cpu.v"

`timescale 100ns / 1ns

module TBComputer;

reg         clk;
wire [31:0] memory_addr;
wire [31:0] memory_write_data;
wire        memory_memwrite;
reg         memory_read;
wire [31:0] memory_read_data;

assign memory_addr = (icache_rd_en === 1) ? icache_mem_addr : dcache_mem_addr;


assign dcache_rd_en = icache_ready;
assign icache_rd_en = !dcache_rd_en;


Mem1024x32 memory(
    .clk(clk), // in
    .addr(memory_addr), // in
    .write_data(dcache_mem_wr_data), // in
    .memwrite(dcache_mem_wr_en), // in
    .memread(1'b1), // in
    .read_data(memory_read_data) // out
);

wire           dcache_rd_en;
reg [31:0]     dcache_addr;
wire [31:0]    dcache_value;
wire           dcache_ready;

wire [31:0]    dcache_mem_addr;
wire [31:0]    dcache_mem_wr_data;
wire           dcache_mem_wr_en;

DirectCache32 dcache(.clk(clk), // in
                     .rd_en(dcache_rd_en),
                     .addr(cpu_dmem_addr), // in
                     .value(dcache_value), // out
                     .ready(dcache_ready), // out

                     .wr_data(cpu_dmem_wr_data), // in
                     .wr_en(cpu_dmem_wr_en), // in
                     
                     .mem_addr(dcache_mem_addr), // out
                     .mem_wr_data(dcache_mem_wr_data), // out
                     .mem_wr_en(dcache_mem_wr_en), // out
                     .mem_read(memory_read_data)); // in

wire           icache_rd_en;
wire [31:0]    icache_value;
wire           icache_ready;

wire [31:0]   icache_mem_wr_data;
wire          icache_mem_wr_en;
wire [31:0]   icache_mem_addr;

wire [31:0]    cpu_imem_addr;

wire [31:0]    cpu_dmem_addr;
wire [31:0]    cpu_dmem_wr_data;
wire           cpu_dmem_wr_en;

DirectCache32 icache(.clk(clk), // in
                     .rd_en(icache_rd_en),
                     .addr(cpu_imem_addr), // in
                     .value(icache_value), // out
                     .ready(icache_ready), // out

                     .wr_data(32'b0), // in
                     .wr_en(1'b0), // in
                     
                     .mem_addr(icache_mem_addr), // out
                     .mem_wr_data(icache_mem_wr_data), // out
                     .mem_wr_en(icache_mem_wr_en), // out
                     .mem_read(memory_read_data)); // in




RiskBesReloadedCPU cpu(
    .clk(clk), // in
    .rst(1'b0), // in
    .imem_rd_data(icache_value), // in
    .imem_addr(cpu_imem_addr), // out
    .imem_ready(icache_ready), // in

    .dmem_addr(cpu_dmem_addr), // out
    .dmem_rd_data(dcache_value), // in
    .dmem_wr_data(cpu_dmem_wr_data), // out
    .dmem_wr_en(cpu_dmem_wr_en), // out
    .dmem_ready(dcache_ready) // in
);

initial begin
    $dumpfile("computer.vcd");
    $dumpvars(0, TBComputer);
    clk = 1;
    #2000;
    $finish();
end

always begin
    #5; clk = !clk;
end

endmodule