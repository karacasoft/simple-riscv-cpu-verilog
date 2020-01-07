module Mem1024x32(
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire memwrite, memread,
    output reg [31:0] read_data
);

reg [31:0] memory [0:10240];

integer file;
integer temp;

integer ii;
initial begin
    for (ii = 0; ii < 10240; ii++) begin
        memory[ii] = 0;
    end
    file = $fopen("test_programs/branch.bin", "rb");
    temp = $fread(memory, file);
    //$readmemb("../test/imm_add.bin", memory);
end

always @(*) begin
    read_data = memory[addr];
end

always @(posedge clk) begin
    if (memwrite == 1'b1) begin
        memory[addr] <= write_data;
    end
end

endmodule // Mem1024x32