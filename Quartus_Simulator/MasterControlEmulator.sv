module MasterControlEmulator
(
//   input clk,
   input [1:0] button,
   IntellitecSignal.Master it,
   output ac1,
   output ac2,
   output f1O,
   output f1H,
   output f2O,
   output f2H,
   output ht1,
   output ht2
);

logic clock_loop, clock_ff, clk;
assign clock_loop = ~clock_loop;//FIXME

always_ff@( posedge clock_loop )
begin
   if( clock_loop )
   begin
      clock_ff = ~clock_ff;
   end
end

oitClockDivider #( 73_551_044, 33_000 ) div (.in(clock_ff), .out(clk));

IntellitecMasterControl controller
(
   .clock( clk ),
   .shed( ~button ),
   .it,
   .ac1,
   .ac2,
   .f1O,
   .f1H,
   .f2O,
   .f2H,
   .ht1,
   .ht2
);

endmodule

