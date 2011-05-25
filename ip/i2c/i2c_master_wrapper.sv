interface i2c_external;

wire scl;
wire sda;

modport master( inout scl, inout sda );

endinterface

interface i2c_internal;
   logic scl_s2m;
   logic scl_m2s;
   logic scl_oen_n;
   logic sda_s2m;
   logic sda_m2s;
   logic sda_oen_n;

modport master( input  scl_s2m, output scl_m2s, output scl_oen_n, input  sda_s2m, output sda_m2s, output sda_oen_n );
modport slave ( output scl_s2m, input  scl_m2s, input  scl_oen_n, output sda_s2m, input  sda_m2s, input  sda_oen_n );

endinterface

module i2c_output
(
   i2c_external.master external,
   i2c_internal.slave  internal
);

assign internal.scl_s2m = external.scl;
assign internal.sda_s2m = external.sda;

assign external.scl = internal.scl_oen_n?1'bz:internal.scl_m2s;
assign external.sda = internal.sda_oen_n?1'bz:internal.sda_m2s;

endmodule

module wb_i2c_master
(
   input clk,
   input rst,
   wishbone_b3.slave   bus,
   i2c_internal.master i2c
);

assign bus.rty = 1'b0;

logic [1:0] decodeAddress;
logic [7:0] dataIn,dataOut;

always_comb
   case (bus.sel)
      4'h1:
      begin
         bus.err = 1'b0;
         decodeAddress=2'h3;
         dataIn = bus.dat_m2s[7:0];
         bus.dat_s2m = {8'd0, 8'd0, 8'd0, dataOut};
      end
      4'h2:
      begin
         bus.err = 1'b0;
         decodeAddress=2'h2;
         dataIn = bus.dat_m2s[15:8];
         bus.dat_s2m = {8'd0, 8'd0, dataOut, 8'd0};
      end
      4'h4:
      begin
         bus.err = 1'b0;
         decodeAddress=2'h1;
         dataIn = bus.dat_m2s[23:16];
         bus.dat_s2m = {8'd0, dataOut, 8'd0, 8'd0};
      end
      4'h8:
      begin
         bus.err = 1'b0;
         decodeAddress=2'h0;
         dataIn = bus.dat_m2s[31:24];
         bus.dat_s2m = {dataOut, 8'd0, 8'd0, 8'd0};
      end
      default:
      begin
         bus.err = 1'b1;
         decodeAddress=2'h0;
         dataIn = 8'h0;
         bus.dat_s2m = 32'hDEADBEEF;
      end
   endcase


i2c_master_top master
(
   .wb_clk_i( clk ),
   .wb_rst_i( rst ),
   .arst_i( 1'b1 ),
   .wb_adr_i( {bus.adr[2], decodeAddress} ),
   .wb_dat_i( dataIn ),
   .wb_dat_o( dataOut ),
   .wb_we_i( bus.we ),
   .wb_stb_i( bus.stb ),
   .wb_cyc_i( bus.cyc ),
   .wb_ack_o( bus.ack ),
//   .wb_inta_o,
   .scl_pad_i( i2c.scl_s2m ),
   .scl_pad_o( i2c.scl_m2s ),
   .scl_padoen_o( i2c.scl_oen_n ),
   .sda_pad_i( i2c.sda_s2m ),
   .sda_pad_o( i2c.sda_m2s ),
   .sda_padoen_o( i2c.sda_oen_n )
);


endmodule

