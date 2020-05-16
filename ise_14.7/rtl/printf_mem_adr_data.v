//-----------------------------------------------------------------------------
// Print to UART sting:
// 0xXXXXXXXX 0xXXXXXXXX 0xXXXXXXXX
//  mem adr   write data  read data
//
//
// v1.0 2020
//-----------------------------------------------------------------------------
module printf_mem_adr_data
(
    input i_clk,
    input [31:0] i_mem_adr,
    input [31:0] i_mem_dataw,
    input [31:0] i_mem_datar,
    input i_we,
    output o_uart_tx,
    output reg o_ready
);

wire u_busy, u_ready, u_ready32;

reg [7:0] st = 0;

reg [31:0] adr   = 0;
reg [31:0] dataw = 0;
reg [31:0] datar = 0;

reg [7:0]  utx_d  = 0;
reg        utx_we = 0;

reg [31:0] utx_d32  = 0;
reg        utx_we32 = 0;

reg [31:0] cd = 0;
reg [4:0]  cd_count = 5'd31;

localparam U_SPEED = 115200;
localparam CLK     = 50_000_000;
localparam U_DIV   = CLK / (4 * U_SPEED);

wire uart_tx, uart_tx32;
reg  mux_utx_byte_word = 0; // = 0 tx char, =1 tx hex word

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
	 .o_tx                (uart_tx),  // rs-232 output
	 .o_busy_h            (u_busy)    // (STATUS) busy=1 uart tx byte
);

uart_tx_dword_hex UTX_HEX32
(
    .i_clk               (i_clk),      // Clk input
	 .i_data              (utx_d32),    // data out
	 .i_we                (utx_we32),   // we strob Active HIGH, tx_data write to modul

	 .o_uart_tx           (uart_tx32),  // rs-232 output
	 .o_ready             (u_ready32)    // (STATUS) busy=1 uart tx byte
);



always @(posedge i_clk)
begin
    case (st)
	 0:
	 begin
	     o_ready <= 1;
		  mux_utx_byte_word <= 0; // SET mode tx byte (default)
		  if (i_we) begin
		      adr   <= i_mem_adr;
		      dataw <= i_mem_dataw;
		      datar <= i_mem_datar;
            st    <= st + 1'b1;
		  end
    end
		  
	 1:
	 begin
	     o_ready <= 0;
	     if (u_busy == 0 && u_ready32 == 1) begin
				st <= st + 1'b1;
		  end
	 end

    2:
    begin
	     mux_utx_byte_word <= 1; // SET mode tx dword
        utx_d32 <= adr;
	     if (u_busy == 0 && u_ready32 == 1) begin
            utx_we32 <= 1;
	         st       <= st + 1'b1;
	     end
	 end
	 
	 3:
	 begin
	     utx_we32 <= 0;
	     if (u_ready32 == 0) st <= st + 1'b1;
	 end

    4:	 
    begin
        utx_d <= 8'h20; // ' '
	     if (u_busy == 0 && u_ready32 == 1) begin
				mux_utx_byte_word <= 0; // SET mode tx char
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
	 end
	 
    5:	 
	 begin
	     utx_we <= 0;
	     if (u_busy == 0) st <= st + 1'b1;
	 end
	 
	 // data write ---------------------------------
	 6:
    begin
        utx_d32 <= dataw;
	     if (u_busy == 0 && u_ready32 == 1) begin
				mux_utx_byte_word <= 1; // SET mode tx dword
            utx_we32 <= 1;
	         st       <= st + 1'b1;
	     end
	 end
	 
	 7:
	 begin
	     utx_we32 <= 0;
	     if (u_ready32 == 0) st <= st + 1'b1;
	 end

    //space --------------------------------
    8:	 
    begin
        utx_d <= 8'h20; // ' '
	     if (u_busy == 0 && u_ready32 == 1) begin
	         mux_utx_byte_word <= 0; // SET mode tx char
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
	 end
	 
    9:	 
	 begin
	     utx_we <= 0;
	     if (u_ready == 0) st <= st + 1'b1;
	 end
	 
	 // data read---------------------------------
	 10:
    begin
        utx_d32 <= datar;
	     if (u_busy == 0 && u_ready32 == 1) begin
    	      mux_utx_byte_word <= 1; // SET mode tx dword
            utx_we32 <= 1;
	         st       <= st + 1'b1;
	     end
	 end
	 
	 11:
	 begin
	     utx_we32 <= 0;
	     if (u_ready32 == 0) st <= st + 1'b1;
	 end
	 
    // '\n' --------------------------------
    12:	 
    begin
        utx_d <= 8'h0a; // '\n'
	     if (u_busy == 0 && u_ready32 == 1) begin
	         mux_utx_byte_word <= 0; // SET mode tx char
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end
	 end
	 
    13:	 
	 begin
	     utx_we <= 0;
	     if (u_ready == 0) st <= st + 1'b1;
	 end
	 
    14:	 
 	 begin
	     if (u_busy == 0 && u_ready32 == 1) begin
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

assign o_uart_tx = mux_utx_byte_word ? uart_tx32 : uart_tx;
assign u_ready = ! u_busy;

endmodule
