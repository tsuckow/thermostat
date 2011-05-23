module ThermoProcessor
(
input clock,
input rst,
wishbone_b3.master sdr_bus,
wishbone_b3.slave lcd_bus,
spi.master spi_out,
spi.master spi2_out,
input vsync,
cfi.master flash_out,
wishbone_b3.master thermostat
);

//Wishbone Common
wire wb_clk = clock;
wire wb_rst = rst;

wishbone_b3 masters [3] ();
wishbone_b3 slaves  [6] ();
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
   .wb_data( masters[1].master ),//wb_cpu_data ),
   .interrupts( {19'd0, ~vsync} )
//   .debug( debug )
);


//Slaves
//wishbone_b3 wb_boot_rom ();
//wishbone_b3 wb_ram      ();
//wishbone_b3 wb_touchscreen ();

//Debug
//wishbone_b3 wb_debug ();
/*
assign masters[2].cyc = 1'b0;
assign masters[2].stb = 1'b0;
assign masters[2].adr = 'd0;
assign masters[2].dat_m2s = 'd0;
assign masters[2].sel = 'd0;
assign masters[2].we = 'd0;
assign masters[2].cti = 'd0;
assign masters[2].bte = 'd0;
*/

wishbone_b3 wb_trafficcop ();



//
// Traffic Cop
wb_trafficcop_b3
#(
   .masters(3)
)
cop
(
   .clk( wb_clk ),
   .master( masters ),
   .slave( wb_trafficcop )
);

//
// Bus Expander
wb_expander_b3
#(
   .slaves(6)
)
expander
(
   .master( wb_trafficcop ),
   .slave( slaves ),
   .addrs( '{
      '{32'h00000000,32'h003FFFFF}, //Boot ROM
      '{32'h10004000,32'h10005FFF}, //RAM (Removed)
      '{32'h02000000,32'h027FFFFF}, //Offchip RAM
      '{32'hFFFF0000,32'hFFFF001F}, //SPI (SDCARD)
      '{32'hFFFF0020,32'hFFFF002F}, //Thermostat output
      '{32'hFFFF0040,32'hFFFF005F}  //SPI (A/D)
   } )
);

//
// Boot ROM
/*wb_rom
#(
   .data_width (32),
   .addr_width (16)
)
boot_rom
(
   .clk( wb_clk ),
   .rst( wb_rst ),
   .bus( slaves[0].slave )
);*/
wb_cfi_rom rom
(
   .clk( wb_clk ),
   .rst( wb_rst ),
   .wb( slaves[0] ),
   .cfi( flash_out )
);

//
// RAM
wb_nullslave ns0 ( slaves[1] );
/*wb_ram
#(
   .addr_width (13)
)
ram
(
   .clk( wb_clk ),
   .rst( wb_rst ),
   .bus( slaves[1].slave )
);*/

wb_connector sdr_connector ( .master(sdr_bus), .slave(slaves[2]) );
wb_connector thermo_connector ( .master(thermostat), .slave(slaves[4]) );
wb_connector lcd_connector ( .master(masters[2]), .slave(lcd_bus) );

spi_wrapper spi
(
   .clk( wb_clk ),
   .rst( wb_rst ),
   .slave( slaves[3] ),
   .spi_out( spi_out )
);

spi_wrapper spi2
(
   .clk( wb_clk ),
   .rst( wb_rst ),
   .slave( slaves[5] ),
   .spi_out( spi2_out )
);

endmodule

