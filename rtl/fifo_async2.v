//--------------------------------------------------------------------
//
// Author      : Omkar Girish Kamath
// Date        : April 6th, 2024
// File        : fifo_combo
// Description : combination rtl of 1 synchronous and 2 asynchronous
//               fifo's (the spec as mentioned in Vijay uncle's papers
//               ). We control which fifo to switch to using a para-
//               -meter.
//--------------------------------------------------------------------

module fifo_async2 (
		    rd_clk_in,
		    wr_clk_in,
		    d_in,
		    wr,
		    rd,
		    d_out,
		    rst,
		    empty,
		    full
		    );
   
   //--------------------------------------------------------------------
   // input
   //--------------------------------------------------------------------
   input wire rd_clk_in;
   input wire wr_clk_in;
   input wire [7:0] d_in;
   input wire 	    wr;
   input wire 	    rd;
   input wire 	    rst;  // active low reset for both read and write pointer
   
   //--------------------------------------------------------------------
   // output
   //--------------------------------------------------------------------
   output reg [7:0] d_out;
   output reg 	    empty;
   output reg 	    full;
   
   //--------------------------------------------------------------------
   // internals
   //--------------------------------------------------------------------
   reg [7:0] 	    mem [255:0];


   
   //ASYNCHRONOUS SECOND DESIGN
   reg [7:0] 	    gr_rd_ptr;
   reg [7:0] 	    gr_wr_ptr;
   wire [7:0] 	    bn_rd_ptr;
   wire [7:0] 	    bn_wr_ptr;
   reg [7:0] 	    bn_rd_ptr_1;
   reg [7:0] 	    bn_wr_ptr_1;
   wire [7:0] 	    gr_rd_ptr_1;
   wire [7:0] 	    gr_wr_ptr_1;
   reg [7:0] 	    gr_rd_ptr_s1;
   reg [7:0] 	    gr_wr_ptr_s1;
   reg [7:0] 	    gr_rd_ptr_s2;
   reg [7:0] 	    gr_wr_ptr_s2;
   wire [7:0] 	    bn_rd_ptr_s2;
   wire [7:0] 	    bn_wr_ptr_s2;
   reg 		    rd_clk;
   reg 		    wr_clk;

   reg [8:0] 	    word_count_wr;
   reg [8:0] 	    word_count_rd;

   reg 		    dir_wr;
   reg 		    dir_rd;
   
   always @(*)
     begin
	rd_clk <= rd_clk_in;
     end

   always @(*)
     begin
	wr_clk <= wr_clk_in;
     end
   
   // g2b converter
   g2b #(8) f1(gr_wr_ptr,bn_wr_ptr);
   
   // 1 added to binary write gray coded pointer
   always @(*)
     begin
	bn_wr_ptr_1 <= bn_wr_ptr + 'b1;
     end
   
   // b2g converter
   b2g #(8) f2(bn_wr_ptr_1,gr_wr_ptr_1);

   // write function
   always @(posedge wr_clk_in)
     begin
	if (wr == 'b1 && full != 'b1)
	  begin
	     mem[bn_wr_ptr] <= d_in;
	  end
     end
   
   // write increment 
   always @(posedge wr_clk_in or negedge rst)
     begin
	if (rst == 'b0)
	  begin
	     gr_wr_ptr <= 'b0;
	  end
	else
	  begin
	     if (full != 'b1 && wr == 'b1)
	       begin
		  gr_wr_ptr <= gr_wr_ptr_1;
	       end
	  end
     end

   // g2b converter
   g2b #(8) f3(gr_rd_ptr,bn_rd_ptr);

   // 1 added to binary rdite gray coded pointer
   always @(*)
     begin
	bn_rd_ptr_1 <= bn_rd_ptr + 'b1;
     end
   
   // b2g converter
   b2g #(8) f4(bn_rd_ptr_1,gr_rd_ptr_1);
   
   // read function
   always @(posedge rd_clk_in)
     begin
	if (rd == 'b1 && empty != 'b1)
	  begin
	     d_out <= mem[bn_rd_ptr];
	  end
     end
   
   // read increment 
   always @(posedge rd_clk_in or negedge rst)
     begin
	if (rst == 'b0)
	  begin
	     gr_rd_ptr <= 'b0;
	  end
	else
	  begin
	     if (empty != 'b1  && rd == 'b1)
	       begin
		  gr_rd_ptr <= gr_rd_ptr_1;
	       end
	  end
     end // always @ (posedge rd_clk_in or negedge rst)
   
   //syncing gray coded rd ptr to write side clk
   always @(posedge wr_clk_in)
     begin
	gr_rd_ptr_s1 <= gr_rd_ptr;
     end
   
   always @(posedge wr_clk_in)
     begin
	gr_rd_ptr_s2 <= gr_rd_ptr_s1;
     end

   //syncing gray coded wr ptr to read side clk
   always @(posedge rd_clk_in)
     begin
	gr_wr_ptr_s1 <= gr_wr_ptr;
     end
   always @(posedge rd_clk_in)
     begin
	gr_wr_ptr_s2 <= gr_wr_ptr_s1;
     end

   g2b #(8) f5(.in(gr_rd_ptr_s2),.out(bn_rd_ptr_s2));
   g2b #(8) f6(.in(gr_wr_ptr_s2),.out(bn_wr_ptr_s2));  // add these 2 bn signals to internals

   always @(*)  // write side
     begin
	if (bn_wr_ptr == bn_rd_ptr_s2 && dir_wr == 1'b1)
	  begin
	     full <= 'b1;
	  end
	else
	  begin
	     full <= 'b0;
	  end
     end // always @ (*)
   

   
   always @(*)  // read side
     begin
	if (bn_wr_ptr_s2 == bn_rd_ptr && dir_rd == 1'b0)
	  begin
	     empty <= 'b1;
	  end
	else
	  begin
	     empty <= 'b0;
	  end
     end // always @ (*)
   

   // word_count write side
   always @(posedge wr_clk_in or negedge rst)
     begin
	if (rst == 'b0)
	  begin
	     word_count_wr <= 'b0;
	  end
	else
	  begin
	     if (bn_wr_ptr > bn_rd_ptr_s2)
	       begin
		  word_count_wr <= bn_wr_ptr - bn_rd_ptr_s2 + 1'b1;
	       end
	     else if (bn_wr_ptr < bn_rd_ptr_s2)
	       begin
		  word_count_wr <= 'd256 - (bn_rd_ptr_s2 - bn_wr_ptr) + 1'b1;
	       end
	  end
     end // always @ (posedge clk or negedge rst)

   
   // word_count read side
   always @(posedge rd_clk_in or negedge rst)
     begin
	if (rst == 'b0)
	  begin
	     word_count_rd <= 'b0;
	  end
	else
	  begin
	     if (bn_wr_ptr_s2 > bn_rd_ptr)
	       begin
		  word_count_rd <= bn_wr_ptr_s2 - bn_rd_ptr + 1;
	       end
	     else if (bn_wr_ptr_s2 < bn_rd_ptr)
	       begin
		  word_count_rd <= 'd256 -(bn_rd_ptr - bn_wr_ptr_s2) + 1;
	       end
	  end
     end // always @ (posedge clk or negedge rst)

   //direction flag write side
   always @(posedge wr_clk_in or negedge rst)
     begin
	if (rst == 'b0)
	  begin
	     dir_wr <= 'b0;
	  end
	else
	  begin
	     if (word_count_wr != 'b0)
	       begin
		  if (word_count_wr > 192)
		    begin
		       dir_wr <= 1'b1;
		    end
		  else
		    begin
		       dir_wr <= 1'b0;
		    end
	       end
	  end // else: !if(rst == 'b0)
     end // always @ (posedge wr_clk_in or negedge rst)
   
   
   //direction flag read side
   always @(posedge rd_clk_in or negedge rst)
     begin
	if (rst == 'b0)
	  begin
	     dir_rd <= 'b0;
	  end
	else
	  begin
	     if (word_count_rd != 'b0)
	       begin
		  if (word_count_rd < 64)
		    begin
		       dir_rd <= 1'b0;
		    end
		  else
		    begin
		       dir_rd <= 1'b1;
		    end
	       end // if (word_count_rd != 'b0)
	  end
     end // always @ (posedge clk or negedge rst)

   
endmodule
