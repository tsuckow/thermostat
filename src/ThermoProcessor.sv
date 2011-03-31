module ThermoProcessor
(
   clock,
   rst,
   ooo
);

input clock, rst;
output ooo;

//Wishbone Common
wire wb_clk = clock;
wire wb_rst = rst;

wishbone_b3 masters [3] ();
wishbone_b3 slaves  [3] ();
//Masters
//wishbone_b3 wb_cpu_data ();
//wishbone_b3 wb_cpu_inst ();
//debug_interface debug ();

//
// Proc
proc_wrapper myProc
(
   .clk( clock ),
   .rst( rst ),
   .wb_inst( masters[0].master ),//wb_cpu_inst ),
   .wb_data( masters[1].master )//wb_cpu_data ),
//   .debug( debug )
);


//Slaves
//wishbone_b3 wb_boot_rom ();
//wishbone_b3 wb_ram      ();
//wishbone_b3 wb_touchscreen ();

//Debug
//wishbone_b3 wb_debug ();
assign masters[2].cyc = 1'b0;
assign masters[2].stb = 1'b0;
assign masters[2].adr = 'd0;
assign masters[2].dat_m2s = 'd0;
assign masters[2].sel = 'd0;
assign masters[2].we = 'd0;
assign masters[2].cti = 'd0;
assign masters[2].bte = 'd0;


wishbone_b3 wb_trafficcop ();



//
// Traffic Cop
wb_trafficcop_b3
#(
   .masters(3)
)
cop
(
   .master( masters ),
   .slave( wb_trafficcop )
);

//
// Bus Expander
wb_expander_b3
#(
   .slaves(3)
)
expander
(
   .master( wb_trafficcop ),
   .slave( slaves ),
   .addrs( '{
      '{32'h00000000,32'h00003FFF},
      '{32'h00004000,32'h00004FFF},
      '{32'h20000000,32'h2FFFFFFF}
   } )
);

//
// Boot ROM
wb_rom
#(
   .data_width (32),
   .addr_width (14)
)
boot_rom
(
   .clk( wb_clk ),
   .rst( wb_rst ),
   .bus( slaves[0].slave )//wb_boot_rom )
);

//
// RAM
wb_ram
#(
   .data_width (32),
   .addr_width (12)
)
ram
(
   .clk( wb_clk ),
   .rst( wb_rst ),
   .bus( slaves[1].slave )//wb_boot_rom )
);

//
// Touchscreen
assign slaves[2].ack = 1'b0;
assign slaves[2].rty = 1'b0;
assign slaves[2].err = 1'b1;
assign slaves[2].dat_s2m = 'd0;

//Don't Optimize Away
assign ooo = masters[0].adr[2]; //Inst

endmodule
