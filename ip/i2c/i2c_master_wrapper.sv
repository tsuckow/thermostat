interface i2c_external;

wire scl;
wire sda;

modport master( inout scl, inout sda );

endinterface

interface i2c_internal;
   logic scl_s2m;
   logic scl_m2s;
   logic scl_oen;
   logic sda_s2m;
   logic sda_m2s;
   logic sda_oen;

modport master( input  scl_s2m, output scl_m2s, output scl_oen, input  sda_s2m, output sda_m2s, output sda_oen );
modport slave ( output scl_s2m, input  scl_m2s, input  scl_oen, output sda_s2m, input  sda_m2s, input  sda_oen );

endinterface

module i2c_output
(
   i2c_external.master external,
   i2c_internal.slave  internal
);

assign external.scl = internal.scl_oen?internal.scl_m2s:1'bz;
assign external.sda = internal.sda_oen?internal.sda_m2s:1'bz;

assign internal.scl_s2m = external.scl;
assign internal.sda_s2m = external.sda;

endmodule

module wb_i2c_master
(
   input clk,
   input rst,
   wishbone_b3.slave   bus,
   i2c_internal.master i2c
);

i2c_master_top master
(
   .wb_clk_i( clk ),
   .wb_rst_i( rst ),
   .arst_i( 1'b0 ),
   .wb_adr_i( bus.adr ),
   .wb_dat_i( bus.dat_m2s ),
   .wb_dat_o( bus.dat_s2m ),
   .wb_we_i( bus.we ),
   .wb_stb_i( bus.stb ),
   .wb_cyc_i( bus.cyc ),
   .wb_ack_o( bus.ack ),
//   .wb_inta_o,
   .scl_pad_i( i2c.scl_s2m ),
   .scl_pad_o( i2c.scl_m2s ),
   .scl_padoen_o( i2c.scl_oen ),
   .sda_pad_i( i2c.sda_s2m ),
   .sda_pad_o( i2c.sda_m2s ),
   .sda_padoen_o( i2c.sda_oen )
);


endmodule

