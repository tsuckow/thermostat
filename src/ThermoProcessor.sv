module ThermoProcessor
(
   clock,
   rst,
   ooo,
   buf_clk,
   buf1_addr,
   buf1_r,
   buf1_g,
   buf1_b
);

input clock, rst;
output ooo;
input logic  buf_clk;
input [11:2] buf1_addr;
output [7:0] buf1_r;
output [7:0] buf1_g;
output [7:0] buf1_b;

//Wishbone Common
wire wb_clk = clock;
wire wb_rst = rst;

wishbone_b3 masters [3] ();
wishbone_b3 slaves  [5] ();
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
   .slaves(5)
)
expander
(
   .master( wb_trafficcop ),
   .slave( slaves ),
   .addrs( '{
      '{32'h00000000,32'h00003FFF}, //Boot ROM
      '{32'h00004000,32'h00004FFF}, //RAM
      '{32'h01000000,32'h017FFFFF}, //Offchip RAM
      '{32'hFFFF0000,32'hFFFF0FFF}, //Video Buffer 1
      '{32'hFFFF4000,32'hFFFF4FFF}  //Video Buffer 2
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
wb_color_ram
#(
   .addr_width (12)
)
buf1
(
   .clk( wb_clk ),
   .clk2( buf_clk ),
   .rst( wb_rst ),
   .bus( slaves[3].slave ),
   .addr(buf1_addr),
   .r(buf1_r),
   .g(buf1_g),
   .b(buf1_b)
);

//Don't Optimize Away
assign ooo = masters[0].adr[2]; //Inst

endmodule
