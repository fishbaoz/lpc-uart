/*
 * A simple LPC UART device.
 * Glues a transmitter part, a receiver part and a LPC bus interface.
 *
 * Copyright (C) 2017 Lubomir Rintel <lkundrak@v3.sk>
 * Distributed under the terms of GPLv2 or (at your option) any later version.
 */

module device (
	LPC_CLK,
	LPC_RST,
	LPC_D0,
	LPC_D1,
	LPC_D2,
	LPC_D3,
	LPC_FRAME,

	UART_TX,
	UART_RX

//	LED_0, LED_1, LED_2, LED_3,
);
	input LPC_CLK;
	input LPC_RST;
	inout LPC_D0;
	inout LPC_D1;
	inout LPC_D2;
	inout LPC_D3;
	input LPC_FRAME;

	output UART_TX;
	input UART_RX;

//	output LED_0, LED_1, LED_2, LED_3;

	wire [7:0] tx_data;
	wire tx_data_valid;
	wire [7:0] rx_data;
	wire rx_data_valid;
	wire tx_busy;

//	wire [3:0] led_value;// = 4'b1001;

	lpc lpc0 (LPC_CLK, LPC_RST, { LPC_D3, LPC_D2, LPC_D1, LPC_D0 }, LPC_FRAME, tx_data, tx_data_valid, rx_data, rx_data_valid, tx_busy);
	uart_tx uart_tx0 (LPC_CLK, tx_data, tx_data_valid, UART_TX, tx_busy /*, led_value */);
	uart_rx uart_rx0 (LPC_CLK, rx_data, rx_data_valid, UART_RX);

//	assign {LED_3, LED_2, LED_1, LED_0} = led_value;

//	always @(posedge LPC_CLK)
//	begin
//		led_value <= 4'b1010;
//	end

endmodule
