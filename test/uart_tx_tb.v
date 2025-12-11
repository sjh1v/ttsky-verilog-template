`timescale 1ns / 1ps

module uart_tx_tb;

    // 1. 입력 신호 (내 마음대로 조종할 것들)
    reg clk;
    reg rst_n;
    reg tx_start;
    reg [7:0] data_in;

    // 2. 출력 신호 (관찰할 것들)
    wire tx_out;
    wire tx_busy;

    // 3. 설계한 UART 모듈 연결 (DUT: Design Under Test)
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

    // 4. 클럭 생성 (50MHz = 20ns 주기 -> 10ns마다 뒤집기)
    always #10 clk = ~clk;

    // 5. 테스트 시나리오 시작
    initial begin
        // 시뮬레이션 결과 저장 파일 설정 (이게 있어야 파형을 봅니다)
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        // 초기화
        clk = 0;
        rst_n = 0;      // 리셋 누름
        tx_start = 0;
        data_in = 8'h00;

        // 리셋 해제
        #100;
        rst_n = 1;      // 리셋 뗌
        #100;

        // [테스트 1] 문자 'A' (Hex 0x41, Binary 01000001) 전송
        $display("Test 1: Sending 'A' (0x41)...");
        data_in = 8'h41; 
        tx_start = 1;   // 전송 시작 신호 줌
        #20;            // 한 클럭 정도 유지
        tx_start = 0;   // 신호 끔

        // 전송이 끝날 때까지 기다림 (tx_busy가 1이 되었다가 0이 될 때까지)
        wait(tx_busy == 1);
        wait(tx_busy == 0);
        $display("Test 1 Complete!");
        
        #1000; // 잠시 대기

        // [테스트 2] 문자 'B' (Hex 0x42) 전송
        $display("Test 2: Sending 'B' (0x42)...");
        data_in = 8'h42;
        tx_start = 1;
        #20;
        tx_start = 0;

        wait(tx_busy == 1);
        wait(tx_busy == 0);
        $display("Test 2 Complete!");

        #1000;
        $finish; // 시뮬레이션 종료
    end

endmodule
