module lpc_dev (lpc_clk, lpc_rst, lpc_data, lpc_frame, data, in, busy);
	reg rd = 0;
	reg lpc_data_out = 0;
	reg [3:0] out_data;

	input lpc_clk;
	input lpc_rst;

	inout [3:0] lpc_data;
	input lpc_frame;

	output [7:0] data;
	output in;
	input busy;

	wire lpc_clk;
	wire lpc_rst;
	wire busy;
	assign lpc_data = lpc_data_out ? out_data : 4'bZ;
	wire lpc_frame;

	reg [7:0] data;
	reg in = 0;

	parameter START = 0;
	parameter CTDIR = 1;
	parameter ADDR0 = 2;
	parameter ADDR1 = 3;
	parameter ADDR2 = 4;
	parameter ADDR3 = 5;
	parameter WDATA0 = 6;
	parameter WDATA1 = 7;
	parameter TAR0 = 8;
	parameter SYNC = 9;
	parameter RDATA0 = 10;
	parameter RDATA1 = 11;
	parameter TAR1 = 12;
	reg [3:0] state = START;

	always @(posedge lpc_clk)
	begin
		//$display("LPCCLK: [%d] [%x] [%x]", state, lpc_frame, lpc_data);
		if (lpc_frame == 0)
		begin
			if (lpc_data == 0)
				state <= CTDIR;
			else
				state <= START;
		end
		else
		begin
			case (state)
			START:
				in <= 0;
			CTDIR:
				if (lpc_data == 0)
				begin
					rd <= 1;
					state <= ADDR0;
				end
				else if (lpc_data == 2)
				begin
					rd <= 0;
					state <= ADDR0;
				end
				else
					state <= START;
			ADDR0:
				if (lpc_data == 0)
					state <= ADDR1;
				else
					state <= START;
			ADDR1:
				if (lpc_data == 'h3)
					state <= ADDR2;
				else
					state <= START;
			ADDR2:
				if (lpc_data == 'hf)
					state <= ADDR3;
				else
					state <= START;
			ADDR3:
				if (lpc_data == 'hd && rd == 1)
					state <= TAR0;
				else if (lpc_data == 'h8 && rd == 0)
					state <= WDATA0;
				else
					state <= START;
			WDATA0:
			begin
				data[3:0] = lpc_data;
				state <= WDATA1;
			end
			WDATA1:
			begin
				data[7:4] = lpc_data;
				state <= TAR0;
			end
			TAR0:
			begin
				lpc_data_out = 1;
				state <= SYNC;
			end
			SYNC:
			begin
				out_data <= 0;
				if (rd)
					state <= RDATA0;
				else
				begin
					in <= 1;
					state <= TAR1;
				end
			end
			RDATA0:
			begin
				out_data <= 0;
				state <= RDATA1;
			end
			RDATA1:
			begin
				out_data <= (busy ? 0 : 2);
				state <= TAR1;
			end
			TAR1:
			begin
				lpc_data_out = 0;
				state <= START;
			end
			endcase
		end
	end
endmodule
