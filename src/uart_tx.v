module uart_tx #(
    parameter CLK_FREQ = 50000000,  
    parameter BAUD_RATE = 115200   
)(
    input wire clk,
    input wire rst_n,
    input wire tx_start,      
    input wire [7:0] data_in, 
    output reg tx_out,        
    output reg tx_busy        
);

    // 상태 머신 정의 (FSM)
    localparam IDLE   = 3'b000;
    localparam START  = 3'b001;
    localparam DATA   = 3'b010;
    localparam PARITY = 3'b011;
    localparam STOP   = 3'b100;

    reg [2:0] state;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    reg [15:0] clk_cnt;
    reg [2:0] bit_idx;
    reg [7:0] data_reg;
    reg parity_bit;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_out <= 1'b1;
            tx_busy <= 1'b0;
            clk_cnt <= 0;
            bit_idx <= 0;
            data_reg <= 0;
            parity_bit <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;
                    tx_busy <= 1'b0;
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (tx_start) begin
                        state <= START;
                        tx_busy <= 1'b1;
                        data_reg <= data_in;
                        parity_bit <= ^data_in; 
                    end
                end

                START: begin
                    tx_out <= 1'b0;
                    if (clk_cnt < CLKS_PER_BIT - 1) clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= 0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx_out <= data_reg[bit_idx];
                    if (clk_cnt < CLKS_PER_BIT - 1) clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= 0;
                        if (bit_idx < 7) bit_idx <= bit_idx + 1;
                        else begin
                            bit_idx <= 0;
                            state <= PARITY;
                        end
                    end
                end

                PARITY: begin 
                    tx_out <= parity_bit;
                    if (clk_cnt < CLKS_PER_BIT - 1) clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= 0;
                        state <= STOP;
                    end
                end

                STOP: begin
                    tx_out <= 1'b1;
                    if (clk_cnt < CLKS_PER_BIT - 1) clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= 0;
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
