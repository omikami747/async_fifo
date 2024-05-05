//--------------------------------------------------------------------
//
// Author      : Omkar Girish Kamath
// Date        : April 6th, 2024
// File        : b2g
// Description : binary to gray converter file
//--------------------------------------------------------------------

module b2g (
	    in,
	    out
	    );
   
   //`include "parameter.v"
   // parameter N = $clog2(D);
   parameter N = 9;
   
   //--------------------------------------------------------------------
   // inputs
   //--------------------------------------------------------------------
   input wire [N-1:0] in;
   
   //--------------------------------------------------------------------
   // outputs
   //--------------------------------------------------------------------
   output reg [N-1:0] out;
   
   //--------------------------------------------------------------------
   // internals
   //--------------------------------------------------------------------
   integer 	    i;
   
   //--------------------------------------------------------------------
   // module
   //--------------------------------------------------------------------
   always @(*)
     begin
	out[N-1] = in[N-1];                    // b_(n) = g_(n)
	for (i = N-2; i >= 0; i = i - 1)   
	  out[i] = in[i + 1] ^ in[i];     // b_(i) = b_(i+1) ^ g_(i)
     end
   
endmodule