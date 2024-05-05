`timescale 100ms/1us

`ifdef ASYNC1
 `define fifo_model fifo_async1
`else
 `define fifo_model fifo_async2
`endif

module fifo_combo_tb;
   reg	   rd_clk_in;
   reg 	   wr_clk_in;
   reg [7:0] d_in;
   reg 	     wr;
   reg 	     rd;
   wire [7:0] d_out;
   wire       ov_flw;
   wire       ud_flw;
   reg 	      rst;
   wire       empty;
   wire       full;
   reg 	      rd_high;
   reg 	      wr_high;
   wire [7:0] lfsr_in;
   reg 	      rd_st;
   integer    fd;
   parameter wr_clk_half = t_wr_clk * d_c;
   parameter rd_clk_half = t_rd_clk * d_c;
   reg 	      wr_done;
   
`define OUT_FILE "./rtl_out.log"
`include "../proto/timing_params.v"
   always
     begin
	rd_clk_in = 'b0;
	#(rd_clk_half);
	rd_clk_in = 'b1;
	#(rd_clk_half);
     end

   always
     begin
	wr_clk_in = 'b0;
	#(wr_clk_half);
	wr_clk_in = 'b1;
	#(wr_clk_half);
     end

   `fifo_model dut(
		   .rd_clk_in(rd_clk_in),
		   .wr_clk_in(wr_clk_in),
		   .d_in(d_in),
		   .wr(wr),
		   .rd(rd),
		   .d_out(d_out),
		   .full(full),
		   .empty(empty),
		   .rst(rst)
		   );

   random_num_gen rand_gen(.wr(wr),
			   .full(full),
			   .d_out(lfsr_in),
			   .rst(rst)
			   );
   
   
   always @(*)
     if (wr == 1'b1)
       begin
	  d_in = lfsr_in;
       end
     else
       begin
	  d_in = 8'bX;
       end

   always @(negedge rd)
     begin
	if (rd_st && rst != 1'b0)
	  begin
	     $fdisplay(fd,"%d",d_out);
	  end
	else
	  begin
	     rd_st = 'b1;
	  end
     end
   
   initial
     begin: write_fifo

	integer count_1;
	integer i;
	i = 0;
	
	$dumpvars;

	wr_done = 1'b0;
	wr = 'b0;
	rd = 'b0;
	rst = 'b0;
        rd_st = 'b0;
	fd = $fopen(`OUT_FILE,"w");
	
	repeat(10)
	  @(posedge wr_clk_in);
	rst = 'b1;
	#t_h;
	
	for (count_1 = 0; count_1 < 10000 ;count_1 = count_1 + 1)
	  begin
	     tasks_1.SINGLE_WRITE;
	     //$display("performed write %d",i);
	     i = i + 1;
	  end
	wr_done = 1;
	$display("finished writing");
        
     end // initial begin
   
   initial
     begin: read_fifo

	integer i;
	i = 0;
	
	@(posedge rd_clk_in);
	#t_h;
	while (1)
	  begin
	     tasks_1.SINGLE_READ;
	     //$display("performed read %d",i);
	     i = i + 1;
	  end
     end

   always @(posedge rd_clk_in)
     begin: terminate
	integer i;
        
	if (wr_done == 1 && empty == 1'b1)
	  begin
	     i = i + 1;
	     if (i == 20)
	       begin
		  $finish;
	       end
	  end
	else
	  begin
	     i = 0;
	  end // else: !if(wr_done == 1 && empty == 1'b1)
	
     end
   
endmodule
