module pesp_registerfile(input clk, input reg_write, input [4:0] rs1,
                 input [4:0] rs2, input [4:0] rd,input [31:0] write_data, 
					  output reg [31:0] A, output reg [31:0] B,
					  input [4:0] debug_reg_addr, output [31:0] debug_reg_data);
	
	reg[31:0] registers [0:31];
	always @(*) begin
	   A = registers[rs1];
		B = registers[rs2];
			
	end
	 assign debug_reg_data = registers[debug_reg_addr];

	always @(posedge clk)begin
	 if (reg_write) begin
			 registers[rd]<= write_data;
			 end
	end

	endmodule
