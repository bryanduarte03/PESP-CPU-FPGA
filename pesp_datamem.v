module data_mem (input [9:0] address,input [31:0] write_data, input clk,
                  input mem_write,output  [31:0] read_data,
                  input [9:0] debug_mem_addr, output [31:0] debug_mem_data);
	
	reg [31:0] memory [0:1023];
	assign read_data= memory[address];
	assign debug_mem_data = memory[debug_mem_addr];
			

	
	always @(posedge clk)begin
	 if (mem_write) begin
			 memory[address]<= write_data;
			 end
	end
	
	endmodule
