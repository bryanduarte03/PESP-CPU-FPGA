module pesp_cpu(
    input clk,
    input reset,
    output halt,
    output [9:0] pc_out,
    output [31:0] ir_out,
    output [31:0] alu_out,
	 input [4:0] debug_reg_addr,
    output [31:0] debug_reg_data,

    input [9:0] debug_mem_addr,
    output [31:0] debug_mem_data,
	 output [9:0] instr_pc_out
);

    localparam FETCH1    = 3'd0;
    localparam FETCH2    = 3'd1;
    localparam FETCH3    = 3'd2;
    localparam DECODE    = 3'd3;
    localparam EXECUTE   = 3'd4;
    localparam MEMORY    = 3'd5;
    localparam WRITEBACK = 3'd6;
    localparam HALT      = 3'd7;


    reg [9:0] MAR;
    reg [31:0] MDR;
    reg [31:0] IR;
    reg [9:0] PC;
    reg [9:0] instr_pc;
    reg [2:0] state;

    reg [3:0] opcode;
    reg [4:0] rd;

    reg [31:0] A;
    reg [31:0] B;

    reg [12:0] immediate;

    reg [31:0] result;


    // Register file signals
    wire [31:0] reg_A;
    wire [31:0] reg_B;

    wire [4:0] rs1;
    wire [4:0] rs2;

    reg [4:0] regfile_rs2;

    reg reg_write;
    reg [31:0] write_data;


    // ALU signals
    wire [31:0] alu_result;

    reg [31:0] alu_B;
    reg [3:0] alu_opcode;


    // Instruction memory
    wire [31:0] instruction;


    // Data memory
    wire [31:0] mem_read_data;

    reg mem_write;
    reg [31:0] mem_write_data;
    reg [9:0] mem_address;



    // MODULES


    instruction_mem imem (
        .location(MAR),
        .instruction(instruction)
    );


    pesp_alu alu (
        .A(A),
        .B(alu_B),
        .opcode(alu_opcode),
        .result(alu_result)
    );


    pesp_registerfile regfile (
        .clk(clk),
        .reg_write(reg_write),
        .rs1(rs1),
        .rs2(regfile_rs2),
        .rd(rd),
        .write_data(write_data),
        .A(reg_A),
        .B(reg_B),
		  .debug_reg_addr(debug_reg_addr),
    .debug_reg_data(debug_reg_data)
    );


    data_mem dmem (
        .address(mem_address),
        .write_data(mem_write_data),
        .clk(clk),
        .mem_write(mem_write),
        .read_data(mem_read_data),
		  .debug_mem_addr(debug_mem_addr),
    .debug_mem_data(debug_mem_data)
    );



    // IR FIELDS

    assign rs1 = IR[22:18];
    assign rs2 = IR[17:13];


    // EXTERNAL DEBUG OUTPUTS


    assign halt    = (state == HALT);
    assign pc_out  = PC;
    assign ir_out  = IR;
    assign alu_out = result;
    assign instr_pc_out = instr_pc;

    // REGISTER FILE READ ADDRESS CONTROL
    // Normally port B reads rs2.
    // ST/STI need registers[rd] during MEMORY.


    always @(*) begin

        regfile_rs2 = rs2;

        if (state == MEMORY) begin

            if ((opcode == 4'd9) || (opcode == 4'd10)) begin
                regfile_rs2 = rd;
            end

        end

    end


    // ALU CONTROL


    always @(*) begin

        alu_B = B;
        alu_opcode = opcode;

        case (opcode)

            4'd4: begin               // ADDI
                alu_B = {19'd0, immediate};
                alu_opcode = 4'd0;
            end

            4'd5: begin               // SUBI
                alu_B = {19'd0, immediate};
                alu_opcode = 4'd1;
            end

            4'd7,
            4'd9: begin               // LD / ST address calculation
                alu_B = {19'd0, immediate};
                alu_opcode = 4'd0;
            end

            default: begin
                alu_B = B;
                alu_opcode = opcode;
            end

        endcase

    end


    // REGISTER FILE WRITE CONTROL

    // These signals are already valid BEFORE the rising edge.
    // Therefore the register file writes on the WRITEBACK edge.

    always @(*) begin

        reg_write = 1'b0;
        write_data = 32'd0;

        if (state == WRITEBACK) begin

            case (opcode)

                4'd0,
                4'd1,
                4'd2,
                4'd3,
                4'd4,
                4'd5,
                4'd6,
                4'd8: begin
                    reg_write = 1'b1;
                    write_data = result;
                end

                4'd7: begin
                    reg_write = 1'b1;
                    write_data = MDR;
                end

                default: begin
                    reg_write = 1'b0;
                end

            endcase

        end

    end



    // DATA MEMORY CONTROL


    always @(*) begin

        mem_write = 1'b0;
        mem_write_data = 8'd0;

        // Normal address for LD/ST
        mem_address = result[9:0];

        if (state == MEMORY) begin

            case (opcode)

                4'd7: begin
                    // LD
                    mem_address = result[9:0];
                end


                4'd9: begin
                    // ST:
                    // data_mem[result] = registers[rd]

                    mem_address = result[9:0];
                    mem_write_data = reg_B[7:0];
                    mem_write = 1'b1;
                end


                4'd10: begin
                    // STI:
                    // data_mem[registers[rd]] = immediate

                    mem_address = reg_B[9:0];
                    mem_write_data = result[7:0];
                    mem_write = 1'b1;
                end

            endcase

        end

    end



    // CPU FSM

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            PC <= 10'd0;
            MAR <= 10'd0;
            MDR <= 32'd0;
            IR <= 32'd0;
            instr_pc <= 10'd0;
            opcode <= 4'd0;
            rd <= 5'd0;
            immediate <= 13'd0;

            A <= 32'd0;
            B <= 32'd0;

            result <= 32'd0;

            state <= FETCH1;

        end

        else begin

            case (state)


                // FETCH CYCLE 1
                // MAR = PC
                // PC = PC + 1


                FETCH1: begin

                    MAR <= PC;
                    PC <= PC + 1'b1;

                    state <= FETCH2;

                end



                // FETCH CYCLE 2
                // MDR = instruction memory[MAR]


                FETCH2: begin

                    MDR <= instruction;

                    state <= FETCH3;

                end



                // FETCH CYCLE 3
                // IR = MDR


                FETCH3: begin

                    IR <= MDR;
                    instr_pc <= MAR;
                    state <= DECODE;

                end



                // DECODE


                DECODE: begin

                    opcode <= IR[31:28];
                    rd <= IR[27:23];
                    immediate <= IR[12:0];

                    A <= reg_A;
                    B <= reg_B;

                    state <= EXECUTE;

                end



                // EXECUTE


                EXECUTE: begin

                    case (opcode)

                        // ADD, SUB, AND, OR,
                        // ADDI, SUBI, MPY
                        4'd0,
                        4'd1,
                        4'd2,
                        4'd3,
                        4'd4,
                        4'd5,
                        4'd6: begin

                            result <= alu_result;

                            state <= WRITEBACK;

                        end


                        // LD / ST
                        4'd7,
                        4'd9: begin

                            result <= alu_result;

                            state <= MEMORY;

                        end


                        // LDI
                        4'd8: begin

                            result <= {19'd0, immediate};

                            state <= WRITEBACK;

                        end


                        // STI
                        4'd10: begin

                            result <= {19'd0, immediate};

                            state <= MEMORY;

                        end


                        // BEQ
                        4'd11: begin

                            if (A == B) begin
                                PC <= immediate[9:0];
                            end

                            state <= FETCH1;

                        end


                        // BNE
                        4'd12: begin

                            if (A != B) begin
                                PC <= immediate[9:0];
                            end

                            state <= FETCH1;

                        end


                        // JUMP
                        4'd13: begin

                            PC <= immediate[9:0];

                            state <= FETCH1;

                        end


                        // JCD
                        4'd14: begin

                            if (A == 32'd0) begin
                                PC <= immediate[9:0];
                            end

                            state <= FETCH1;

                        end


                        // HALT
                        4'd15: begin

                            state <= HALT;

                        end


                        default: begin

                            state <= FETCH1;

                        end

                    endcase

                end



                // MEMORY ACCESS


                MEMORY: begin

                    case (opcode)

                        // LD
                        4'd7: begin

                            MDR <= mem_read_data;

                            state <= WRITEBACK;

                        end


                        // ST
                        //
                        // Actual memory write happens on
                        // this rising edge because mem_write
                        // is combinationally high.
                        4'd9: begin

                            state <= FETCH1;

                        end


                        // STI
                        4'd10: begin

                            state <= FETCH1;

                        end


                        default: begin

                            state <= FETCH1;

                        end

                    endcase

                end



                // WRITEBACK
                //
                // Actual register write occurs on this edge.


                WRITEBACK: begin

                    state <= FETCH1;

                end



                // HALT


                HALT: begin

                    state <= HALT;

                end


                default: begin

                    state <= FETCH1;

                end

            endcase

        end

    end

endmodule
