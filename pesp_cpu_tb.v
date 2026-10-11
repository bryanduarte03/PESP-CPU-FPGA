`timescale 1ns/1ps

module pesp_cpu_tb;

    reg clk;
    reg reset;

    wire halt;
    wire [9:0] pc_out;
    wire [31:0] ir_out;
    wire [31:0] alu_out;

    integer cycles;


    pesp_cpu uut (
        .clk(clk),
        .reset(reset),
        .halt(halt),
        .pc_out(pc_out),
        .ir_out(ir_out),
        .alu_out(alu_out)
    );


    // 10 ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    initial begin

        reset = 1;
        cycles = 0;

        #20;
        reset = 0;

        // Wait for CPU to halt, with timeout
        while ((halt !== 1'b1) && (cycles < 500)) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        #10;

        if (halt !== 1'b1) begin

            $display("");
            $display("================================");
            $display("TEST FAILED: CPU TIMEOUT");
            $display("================================");

            $stop;

        end


        $display("");
        $display("================================");
        $display("FINAL CPU STATE");
        $display("================================");

        $display("PC      = %d", pc_out);
        $display("IR      = %h", ir_out);
        $display("ALU OUT = %d", alu_out);


        $display("");
        $display("REGISTER FILE");
        $display("================================");

        $display("R1  = %d", uut.regfile.registers[1]);
        $display("R2  = %d", uut.regfile.registers[2]);
        $display("R3  = %d", uut.regfile.registers[3]);
        $display("R4  = %d", uut.regfile.registers[4]);
        $display("R5  = %d", uut.regfile.registers[5]);
        $display("R6  = %d", uut.regfile.registers[6]);
        $display("R7  = %d", uut.regfile.registers[7]);
        $display("R8  = %d", uut.regfile.registers[8]);
        $display("R9  = %d", uut.regfile.registers[9]);
        $display("R10 = %d", uut.regfile.registers[10]);
        $display("R11 = %d", uut.regfile.registers[11]);
        $display("R12 = %d", uut.regfile.registers[12]);
        $display("R13 = %d", uut.regfile.registers[13]);
        $display("R14 = %d", uut.regfile.registers[14]);
        $display("R15 = %d", uut.regfile.registers[15]);
        $display("R21 = %d", uut.regfile.registers[21]);


        $display("");
        $display("DATA MEMORY");
        $display("================================");

        $display("MEM[105] = %d", uut.dmem.memory[105]);
        $display("MEM[120] = %d", uut.dmem.memory[120]);


        // Check complete CPU result
        if (
            uut.regfile.registers[1]  == 32'd5   &&
            uut.regfile.registers[2]  == 32'd10  &&
            uut.regfile.registers[3]  == 32'd15  &&
            uut.regfile.registers[4]  == 32'd5   &&
            uut.regfile.registers[5]  == 32'd0   &&
            uut.regfile.registers[6]  == 32'd15  &&
            uut.regfile.registers[7]  == 32'd8   &&
            uut.regfile.registers[8]  == 32'd6   &&
            uut.regfile.registers[9]  == 32'd50  &&

            uut.regfile.registers[10] == 32'd100 &&
            uut.regfile.registers[11] == 32'd15  &&
            uut.dmem.memory[105]       == 32'd15  &&

            uut.regfile.registers[12] == 32'd120 &&
            uut.regfile.registers[13] == 32'd77  &&
            uut.dmem.memory[120]       == 32'd77  &&

            uut.regfile.registers[14] == 32'd1   &&
            uut.regfile.registers[15] == 32'd2   &&

            uut.regfile.registers[21] == 32'd42  &&

            pc_out == 10'd29
        ) begin

            $display("");
            $display("================================");
            $display("FULL CPU REGRESSION TEST PASSED");
            $display("================================");

        end
        else begin

            $display("");
            $display("================================");
            $display("FULL CPU REGRESSION TEST FAILED");
            $display("================================");

        end

        $stop;

    end


    // CPU trace
    always @(posedge clk) begin

        $display(
            "time=%0t state=%d PC=%d IR=%h opcode=%d rd=%d A=%d B=%d result=%d mem_write=%b mem_addr=%d",
            $time,
            uut.state,
            pc_out,
            ir_out,
            uut.opcode,
            uut.rd,
            uut.A,
            uut.B,
            uut.result,
            uut.mem_write,
            uut.mem_address
        );

    end

endmodule