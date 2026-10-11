module instruction_mem(input [9:0] location, output [31:0] instruction);
   reg [31:0] memory [0:1023];
	
	initial begin
        $readmemh("program.hex", memory);
    end


  assign instruction = memory[location];
  
  endmodule
