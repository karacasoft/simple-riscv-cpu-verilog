module RegisterFile32x32 (
    input clk,
    input [4:0] ra1,
    input [4:0] ra2,
    input write,
    input [4:0] wa,
    input [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2
);

reg [31:0] reg_file [0:30];

assign rdata1 = (ra1 == 0) ? 32'b0 : reg_file[ra1 - 1];
assign rdata2 = (ra1 == 0) ? 32'b0 : reg_file[ra2 - 1];

always @ (posedge clk) begin
    if (write == 1)
    begin
        if(wa != 0) reg_file[wa - 1] <= wdata;
    end
end

endmodule // RegisterFile32x32 