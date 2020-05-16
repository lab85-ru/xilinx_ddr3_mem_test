`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:51:13 01/28/2020 
// Design Name: 
// Module Name:    uart_tx_dword 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uart_tx_dword(
    input i_clk,
    input [31:0] i_data,
    input i_we,
    output o_uart_tx,
    output reg o_ready
    );

wire o_busy;

reg [31:0] data = 0;

reg [7:0] utx_d = 0;
reg       utx_we = 0;

reg [31:0] cd = 0;
reg [4:0] cd_count = 5'd31;

uart_tx UTX1
(
    .i_clk               (i_clk),  // Clk input
	 .i_en_h              (1'b1),     // module enable active-HIGH
	 .i_div               (16'd108),  // div speed uart-rx. (baud = clk / div)
//	 .i_div               (16'd1),  // div speed uart-rx. (baud = clk / div)
	 .i_tx_data           (utx_d),    // data out
	 .i_we_h              (utx_we),   // we strob Active HIGH, tx_data write to modul

	 .i_parity_en_h       (1'b0),     // bit parity disable(0) / enable (1)
	 .i_parity_type_el_oh (1'b0),     // bit parity type E (Even parity) вЂ" proverka na chetnost O (Odd parity) вЂ" proverka na NE chetnost;
	 
	 //.o_int_h             (),       // strob interupt active-HIGH, rx->data out
	 .o_tx                (o_uart_tx),// rs-232 output
	 .o_busy_h            (o_busy)  // (STATUS) busy=1 uart tx byte
);

reg [7:0] st = 0;


always @(posedge i_clk)
begin
    case (st)
	 0:
	 begin
	     o_ready <= 1;
		  if (i_we) begin
		      data <= i_data;
            st <= st + 1'b1;
		  end
    end
		  
	 1:
	 begin
	     $display("1 o_busy = %d", o_busy);
	     o_ready <= 0;
	     if (o_busy == 0) begin
		      $display("TX DWORD = 0x%x", i_data);
		      utx_d  <= 8'h0a;// Код символа перевод строки
				utx_we <= 1'b1;
				st     <= st + 1'b1;
		  end
	 end
	 
	 2:
	 begin
	     utx_we <= 0;
//		  $display("2 o_busy = %d", o_busy);
		  //if (o_busy == 0) begin
		      st <= st + 1'b1;
		  //end
	 end
	 
	 3:
	 begin
	 /* */
	     //$display("3_ o_busy = %d", o_busy);
	     //$display("i_data[ cd_count = %d ] = %b", cd_count, i_data[ cd_count ]);
	     if (data[ cd_count ] == 1'b1) begin
		      //$display("1");
		      utx_d <= 8'h31; // '1'
		  end else begin
		      //$display("0");
		      utx_d <= 8'h30; // '0'
		  end
		  
//		  utx_we   <= 1'b1;
		  if (o_busy == 0) begin
//		      $display("3 o_busy = %d", o_busy);
				$display("i_data[ cd_count = %d ] = %b", cd_count, i_data[ cd_count ]);
		      cd_count <= cd_count - 1'b1;
            utx_we <= 1;
	         st     <= st + 1'b1;
	     end

//		  cd_count <= cd_count - 1'b1;
//	     st       <= st + 1'b1;

	/*	  */
		  /*
        if (i_data[ 31:28 ] > 9) begin
	         utx_d <= i_data[ 31:28 ] + 8'h37; // bukva
	     end else begin
	         utx_d <= i_data[ 31:28 ] + 8'h30; // cifra	     
	     end
		  if (u_busy == 0) begin
            utx_we <= 1;
	         st   <= st + 1'b1;
	     end
*/
		  
	 end
	 
	 4:
	 begin
	     utx_we <= 0;
        st     <= st + 1'b1;
	 end
	 
	 5:
	 begin
		  if (o_busy == 0) begin
		      st <= st + 1'b1;
		  end
	 end
	 
	 6:
	 begin
	     if (cd_count != 5'd31) begin
		      st <= 3'd3; // Next tx char
		  end else begin
		      st <= st + 1'b1;
		  end
	 end
	 
	 7:
	 begin
        utx_d  <= 8'h0a;// Код символа перевод строки
		  utx_we <= 1'b1;
		  st     <= st + 1'b1;
	 end
	 
	 8:
	 begin
	     utx_we <= 0;
		  st <= st + 1'b1;
	 end
	 
	 9:
	 begin
	     if (o_busy == 0) begin
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
