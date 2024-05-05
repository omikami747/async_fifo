//--------------------------------------------------------------------
//
// Author      : Omkar Girish Kamath
// Date        : April 6th, 2024
// File        : tasks_1
// Description : simulation tasks for asynchronous fifo designs
//--------------------------------------------------------------------


`timescale 100ms/1us
module tasks_1;
   `include "../proto/timing_params.v"
   task SINGLE_WRITE;
      //input full;
      integer i;
      begin
	 //i = 0;
	 
	 //$display("performed write %d",i);
	 #(t_wr_clk - t_s - t_h);
	 if (fifo_combo_tb.full == 1'b1)
	   begin
	      fifo_combo_tb.wr = 1'b0;
	   end
	 else
	   begin
	      fifo_combo_tb.wr = 1'b1;
	   end
	 #(t_s + t_h);
	 fifo_combo_tb.wr = 'b0;
	 //#(t_wr_clk - t_s - t_h);
      end
   endtask // SINGLE_WRITE

   task SINGLE_READ;
      //input empty;
      //integer i = 0;
      //$display("performed read %d",i);
      begin
	 #(t_rd_clk - t_s - t_h);
	 if (fifo_combo_tb.empty == 1'b1)
	   begin
	      fifo_combo_tb.rd = 1'b0;
	   end
	 else
	   begin
	      fifo_combo_tb.rd = 1'b1;
	   end
	 #(t_s + t_h);
	 fifo_combo_tb.rd = 'b0;
      end
   endtask // SINGLE_READ

   task CALC;
      input [15:0] lfsr;
      output [7:0] d_out;
      output [15:0]    lfsr_out;
      
      reg [1:16]   interm;
      reg [1:16]   lala;
      
      integer      i;
      begin
	 interm = lfsr;
	 
	 for(i = 0; i < 8; i = i+1)
	   begin
	      d_out[i] = interm[16];
	      interm = {interm[4] ^ interm[13] ^ interm[15] ^ interm[16],interm[1:15]};
	      
	   end
	 lfsr_out = interm;
      end
   endtask
   
endmodule
