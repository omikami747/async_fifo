module random_num_gen (wr,
		       full,
		       d_out,
		       rst
		       );

   input full;
   input rst;
   input wr;
   
   output reg [7:0] d_out;

   reg [15:0] lfsr;
   reg [15:0] lfsr_out;
   integer    fd;
   
`define EXPECTED_OUT_FILE "./num_gen_out.log"

   initial
     begin
	fd = $fopen(`EXPECTED_OUT_FILE,"w");
     end
   
   always @(posedge wr or negedge rst or posedge full)
     begin
	if (rst == 'b0) // seed value initialization
	  begin
	     lfsr <= 'b00001_01010_10000_1;
	  end
	else
	  begin
	     if (~full)
	       begin
		  tasks_1.CALC(lfsr,d_out,lfsr_out);
		  $fdisplay(fd,"%d",d_out);
		  lfsr = lfsr_out;
	       end
	  end
     end
endmodule
