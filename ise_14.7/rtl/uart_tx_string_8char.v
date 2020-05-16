//-----------------------------------------------------------------------------
// Print to UART sting:
// printf uart string 8 char
//
// v1.0 2020
//-----------------------------------------------------------------------------

module uart_tx_string_8char
(
    input        i_clk,
    input [63:0] i_data,
    input        i_we,
    output       o_uart_tx,
    output reg   o_ready
);

reg [7:0] st = 0;

reg [63:0] data = 0;

reg [7:0]  utx_d = 0;
reg        utx_we = 0;
wire       u_busy;

localparam U_SPEED = 115200;
localparam CLK     = 50_000_000;
localparam U_DIV = CLK / (4 * U_SPEED);


uart_tx UTX1
(
    .i_clk               (i_clk),    // Clk input
	 .i_en_h              (1'b1),     // module enable active-HIGH

	 .i_div               (U_DIV),    // div speed uart-rx. (baud = clk / div)
//	 .i_div               (16'd1),    // for modelsim - fast simulation, div speed uart-rx. (baud = clk / div)

	 .i_tx_data           (utx_d),    // data out
	 .i_we_h              (utx_we),   // we strob Active HIGH, tx_data write to modul

	 .i_parity_en_h       (1'b0),     // bit parity disable(0) / enable (1)
	 .i_parity_type_el_oh (1'b0),     // bit parity type E (Even parity) â€" proverka na chetnost O (Odd parity) â€" proverka na NE chetnost;
	 
	 //.o_int_h             (),       // strob interupt active-HIGH, rx->data out
	 .o_tx                (o_uart_tx),// rs-232 output
	 .o_busy_h            (u_busy)    // (STATUS) busy=1 uart tx byte
);

always @(posedge i_clk)
begin
    case (st)
	 0:
	 begin
	     o_ready <= 1;
		  if (i_we) begin
		      data <= i_data;
            st   <= st + 1'b1;
		  end
    end
		  
	 1:
	 begin
	     o_ready <= 0;
	     if (u_busy == 0) begin
				st <= st + 1'b1;
		  end
	 end


    2:
	 begin
        utx_d <= data[63:56];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 3:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end


    4:
	 begin
        utx_d <= data[55:48];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 5:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end


    6:
	 begin
        utx_d <= data[47:40];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 7:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end


    8:
	 begin
        utx_d <= data[39:32];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 9:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end


    10:
	 begin
        utx_d <= data[31:24];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 11:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end


    12:
	 begin
        utx_d <= data[23:16];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 13:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end


    14:
	 begin
        utx_d <= data[15:8];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 15:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end


    16:
	 begin
        utx_d <= data[7:0];
	     if (u_busy == 0) begin
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
    end

	 17:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end

	 18:
	 begin
	     if (u_busy == 0) begin
	         o_ready <= 1'b1;
	         st      <= 0;
		  end
	 end
	 
    default:
	 begin
    	 st <= 0;
	 end
	 
	 endcase
end

endmodule
