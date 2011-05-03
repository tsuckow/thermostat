interface spi #( parameter SLAVES = 1 );

logic mosi;
logic miso;
logic sclk;
logic [SLAVES-1:0] ss;

modport master
(
   output ss,
   output sclk,
   output mosi,
   input  miso
);

endinterface

module spi_wrapper
(
   input clk,
   input rst,
   wishbone_b3.slave slave,
   spi.master spi_out
);

spi_top spi
(
  // Wishbone signals
  .wb_clk_i(clk),
  .wb_rst_i(rst),
  .wb_adr_i(slave.adr),
  .wb_dat_i(slave.dat_m2s),
  .wb_dat_o(slave.dat_s2m),
  .wb_sel_i(slave.sel),
  .wb_we_i(slave.we),
  .wb_stb_i(slave.stb),
  .wb_cyc_i(slave.cyc),
  .wb_ack_o(slave.ack),
  .wb_err_o(slave.err),
//  .wb_int_o,

  // SPI signals
  .ss_pad_o(spi_out.ss),
  .sclk_pad_o(spi_out.sclk),
  .mosi_pad_o(spi_out.mosi),
  .miso_pad_i(spi_out.miso)
);

assign slave.rty = 1'b0;

endmodule

