`timescale 1ns / 1ps

module uart_tx_tb;


    reg clk;
    reg rst_n;
    reg tx_start;
    reg [7:0] data_in;


    wire tx_out;
    wire tx_busy;

 
    uart_tx #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(115200)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx_out(tx_out),
        .tx_busy(tx_busy)
    );


    always #10 clk = ~clk;


    initial begin
 
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

     
        clk = 0;
        rst_n = 0;     
        tx_start = 0;
        data_in = 8'h00;


        #100;
        rst_n = 1;     
        #100;

       
        $display("Test 1: Sending 'A' (0x41)...");
        data_in = 8'h41; 
        tx_start = 1;   
        #20;            
        tx_start = 0;   

       
        wait(tx_busy == 1);
        wait(tx_busy == 0);
        $display("Test 1 Complete!");
        
        #1000;

       
        $display("Test 2: Sending 'B' (0x42)...");
        data_in = 8'h42;
        tx_start = 1;
        #20;
        tx_start = 0;

        wait(tx_busy == 1);
        wait(tx_busy == 0);
        $display("Test 2 Complete!");

        #1000;
      
    end

endmodule
