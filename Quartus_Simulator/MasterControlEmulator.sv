module MasterControlEmulator
(
   input clk,
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

IntellitecMasterControl controller
(
   .clock( clk ),
   .shed( button ),
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

