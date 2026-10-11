module pesp_top(
    input CLOCK_50,
    input [3:0] KEY,
    input [9:0] SW,
    output [9:0] LEDR,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
	 output [6:0] HEX4,
    output [6:0] HEX5
);

    // BOARD UI STATES

    localparam UI_RUNNING  = 2'd0;
    localparam UI_DONE     = 2'd1;
    localparam UI_REGVIEW  = 2'd2;
    localparam UI_MEMVIEW  = 2'd3;
    reg [1:0] ui_state;


    // CPU SIGNALS
    wire cpu_halt;
    wire [9:0] cpu_pc;
    wire [31:0] cpu_ir;
    wire [31:0] cpu_alu_out;
    wire [9:0] cpu_instr_pc;
    wire [31:0] debug_reg_data;
    wire [31:0] debug_mem_data;


    // SLOW CPU CLOCK FOR DEMO
    // CLOCK_50 = 50 MHz
    // bit 23 gives roughly:
    // 50 MHz / 2^24 ≈ 3 Hz

    reg [25:0] clock_divider;

    always @(posedge CLOCK_50) begin

        if (!KEY[0]) begin
            clock_divider <= 26'd0;
        end
        else begin
            clock_divider <= clock_divider + 1'b1;
        end

    end

    wire cpu_clk;

    assign cpu_clk = clock_divider[23];



    // CPU
    pesp_cpu cpu (
        .clk(cpu_clk),
        .reset(!KEY[0]),

        .halt(cpu_halt),
        .pc_out(cpu_pc),
        .ir_out(cpu_ir),
		  .instr_pc_out(cpu_instr_pc),
        .alu_out(cpu_alu_out),

        .debug_reg_addr(SW[4:0]),
        .debug_reg_data(debug_reg_data),

        .debug_mem_addr(SW[9:0]),
        .debug_mem_data(debug_mem_data)
    );

    // BUTTON EDGE DETECTION
    // DE10 buttons are active-low.

    reg key1_old;
    reg key2_old;
    wire key1_pressed;
    wire key2_pressed;

    assign key1_pressed = key1_old & ~KEY[1];
    assign key2_pressed = key2_old & ~KEY[2];


    always @(posedge CLOCK_50) begin

        if (!KEY[0]) begin

            key1_old <= 1'b1;
            key2_old <= 1'b1;

        end
        else begin

            key1_old <= KEY[1];
            key2_old <= KEY[2];

        end

    end



    // BOARD USER-INTERFACE FSM

    always @(posedge CLOCK_50) begin

        if (!KEY[0]) begin

            ui_state <= UI_RUNNING;

        end

        else begin

            case (ui_state)

                UI_RUNNING: begin

                    if (cpu_halt) begin
                        ui_state <= UI_DONE;
                    end

                end


                UI_DONE: begin

                    if (key1_pressed) begin
                        ui_state <= UI_REGVIEW;
                    end

                end


                UI_REGVIEW: begin

                    if (key2_pressed) begin
                        ui_state <= UI_MEMVIEW;
                    end

                end


                UI_MEMVIEW: begin

                    if (key2_pressed) begin
                        ui_state <= UI_REGVIEW;
                    end

                end


                default: begin
                    ui_state <= UI_RUNNING;
                end

            endcase

        end

    end


    // DISPLAY VALUE

    reg [15:0] display_value;
    reg show_done;
	 
	 reg [6:0] mnemonic3;
reg [6:0] mnemonic2;
reg [6:0] mnemonic1;
reg [6:0] mnemonic0;

localparam SEG_BLANK = 7'b1111111;

localparam SEG_A = 7'b0001000;
localparam SEG_b = 7'b0000011;
localparam SEG_C = 7'b1000110;
localparam SEG_d = 7'b0100001;
localparam SEG_E = 7'b0000110;
localparam SEG_H = 7'b0001001;
localparam SEG_I = 7'b1111001; // resembles I/1
localparam SEG_J = 7'b1100001;
localparam SEG_L = 7'b1000111;
localparam SEG_n = 7'b0101011;
localparam SEG_O = 7'b1000000;
localparam SEG_P = 7'b0001100;
localparam SEG_r = 7'b0101111;
localparam SEG_S = 7'b0010010;
localparam SEG_U = 7'b1000001;
localparam SEG_y = 7'b0010001;


    always @(*) begin

        display_value = 16'd0;
        show_done = 1'b0;

        case (ui_state)

            UI_RUNNING: begin

                // Show PC while CPU executes
                display_value = {6'd0, cpu_pc};

            end


            UI_DONE: begin

                show_done = 1'b1;

            end


            UI_REGVIEW: begin

                display_value = debug_reg_data[15:0];

            end


            UI_MEMVIEW: begin

                display_value = debug_mem_data[15:0];

            end

        endcase

    end
	 always @(*) begin

    mnemonic3 = SEG_BLANK;
    mnemonic2 = SEG_BLANK;
    mnemonic1 = SEG_BLANK;
    mnemonic0 = SEG_BLANK;

    case (cpu_ir[31:28])

        4'h0: begin                 // ADD
            mnemonic2 = SEG_A;
            mnemonic1 = SEG_d;
            mnemonic0 = SEG_d;
        end

        4'h1: begin                 // SUB
            mnemonic2 = SEG_S;
            mnemonic1 = SEG_U;
            mnemonic0 = SEG_b;
        end

        4'h2: begin                 // AND
            mnemonic2 = SEG_A;
            mnemonic1 = SEG_n;
            mnemonic0 = SEG_d;
        end

        4'h3: begin                 // OR
            mnemonic1 = SEG_O;
            mnemonic0 = SEG_r;
        end

        4'h4: begin                 // ADDI
            mnemonic3 = SEG_A;
            mnemonic2 = SEG_d;
            mnemonic1 = SEG_d;
            mnemonic0 = SEG_I;
        end

        4'h5: begin                 // SUBI
            mnemonic3 = SEG_S;
            mnemonic2 = SEG_U;
            mnemonic1 = SEG_b;
            mnemonic0 = SEG_I;
        end

        4'h6: begin                 // MPY
            // Seven-segment M/Y are poor approximations.
            // Display "MPY" approximately as nPY.
            mnemonic2 = SEG_n;
            mnemonic1 = SEG_P;
            mnemonic0 = SEG_y;
        end

        4'h7: begin                 // LD
            mnemonic1 = SEG_L;
            mnemonic0 = SEG_d;
        end

        4'h8: begin                 // LDI
            mnemonic2 = SEG_L;
            mnemonic1 = SEG_d;
            mnemonic0 = SEG_I;
        end

        4'h9: begin                 // ST
            mnemonic1 = SEG_S;
            mnemonic0 = 7'b0000111; // t
        end

        4'hA: begin                 // STI
            mnemonic2 = SEG_S;
            mnemonic1 = 7'b0000111; // t
            mnemonic0 = SEG_I;
        end

        4'hB: begin                 // BEQ
            mnemonic2 = SEG_b;
            mnemonic1 = SEG_E;
            mnemonic0 = SEG_O;      // Q approximated by O
        end

        4'hC: begin                 // BNE
            mnemonic2 = SEG_b;
            mnemonic1 = SEG_n;
            mnemonic0 = SEG_E;
        end

        4'hD: begin                 // JUMP
            mnemonic3 = SEG_J;
            mnemonic2 = SEG_U;
            mnemonic1 = SEG_n;      // M approximation
            mnemonic0 = SEG_P;
        end

        4'hE: begin                 // JCD
            mnemonic2 = SEG_J;
            mnemonic1 = SEG_C;
            mnemonic0 = SEG_d;
        end

        4'hF: begin                 // HALT
            mnemonic3 = SEG_H;
            mnemonic2 = SEG_A;
            mnemonic1 = SEG_L;
            mnemonic0 = 7'b0000111; // t
        end

    endcase
end


    // LEDs

    assign LEDR[9] = (ui_state == UI_MEMVIEW);

    assign LEDR[8] = (ui_state == UI_RUNNING);

    assign LEDR[7] =
        (ui_state == UI_DONE)     ||
        (ui_state == UI_REGVIEW)  ||
        (ui_state == UI_MEMVIEW);

    assign LEDR[6:0] = 7'd0;


    // HEX DIGIT DECODERS

    wire [6:0] hex0_number;
    wire [6:0] hex1_number;
    wire [6:0] hex2_number;
    wire [6:0] hex3_number;


    hex_decoder h0 (
        .value(display_value[3:0]),
        .segments(hex0_number)
    );

    hex_decoder h1 (
        .value(display_value[7:4]),
        .segments(hex1_number)
    );

    hex_decoder h2 (
        .value(display_value[11:8]),
        .segments(hex2_number)
    );

    hex_decoder h3 (
        .value(display_value[15:12]),
        .segments(hex3_number)
    );



    // SHOW dOnE OR NORMAL HEX VALUE


// RUNNING: HEX5:4 = PC, HEX3:0 = mnemonic
// Other modes retain the original 4-digit value display.

wire running_display;
assign running_display = (ui_state == UI_RUNNING);

wire [6:0] pc_low_digit;
wire [6:0] pc_high_digit;

hex_decoder pc0 (
    .value(cpu_instr_pc[3:0]),
    .segments(pc_low_digit)
);

hex_decoder pc1 (
    .value(cpu_instr_pc[7:4]),
    .segments(pc_high_digit)
);

assign HEX0 = running_display ? mnemonic0 :
              show_done ? 7'b0000110 : hex0_number;

assign HEX1 = running_display ? mnemonic1 :
              show_done ? 7'b0101011 : hex1_number;

assign HEX2 = running_display ? mnemonic2 :
              show_done ? 7'b1000000 : hex2_number;

assign HEX3 = running_display ? mnemonic3 :
              show_done ? 7'b0100001 : hex3_number;

assign HEX4 = running_display ? pc_low_digit  : SEG_BLANK;
assign HEX5 = running_display ? pc_high_digit : SEG_BLANK;


endmodule
