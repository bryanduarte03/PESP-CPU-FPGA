module pesp_alu(input [31:0] A, input [31:0] B,
 input [3:0] opcode, output reg [31:0] result);
	 always @(*) begin
	 
     case (opcode)
	  
	  4'd0: begin
	     result = A+B;
		end
	  4'd1: begin
	     result = A-B;
		  end
	  4'd2: begin
	     result = A&B;
		  end
	  4'd3: begin
	     result = A | B;
		  end
	  4'd6: begin
	     result = A*B;
	    end
	 default: begin
	    result= 32'd0;
	  end
	  
	endcase
 end
endmodule