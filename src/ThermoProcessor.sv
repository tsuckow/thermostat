
module interruptEdge
(
input in,
input clk,
input clr,
input rst,
output logic out
);

logic int_last;
always_ff@(negedge clk or posedge rst)
begin
   if(rst)
   begin
      int_last <= 1'b0;
      out      <= 1'b0;
   end
   else
   begin
      int_last <= in;
      out <= (out | (in & ~int_last)) & ~clr;
   end
end

endmodule

module interruptChange
(
input in,
input clk,
input clr,
input rst,
output logic out
);

logic int_last;
always_ff@(negedge clk or posedge rst)
begin
   if(rst)
   begin
      int_last <= 1'b0;
      out      <= 1'b0;
   end
   else
   begin
      int_last <= in;
      out <= (out | (in ^ int_last)) & ~clr;
   end
end

endmodule

module ThermoProcessor
(
input clock,
input rst,
wishbone_b3.master sdr_bus,
wishbone_b3.slave lcd_bus,
spi.master spi_out,
spi.master spi2_out,
input lcd::touchevent touch,
cfi.master flash_out,
wishbone_b3.master thermostat,
wishbone_b3.master rtc_bus,
//i2c_internal.master rtc
input a2d_busy_n
);

//Wishbone Common
wire wb_clk = clock;
wire wb_rst = rst;

wishbone_b3 masters [3] ();
wishbone_b3 slaves  [8] ();

logic int1,int3;
interruptChange touchInt (.in(touch.touching),.clk(clock),.rst(rst),.clr(touch_clr_int),.out(int1));
//interruptEdge   a2dInt (.in(a2d_busy_n),.clk(clock),.rst(rst),.clr(slaves[5].stb),.out(int2));

always@(negedge clock)
	int3 = a2d_busy_n;

//
// Proc
proc_wrapper myProc
(
   .clk( clock ),
   .rst( rst ),
   .wb_inst( masters[0].master ),//wb_cpu_inst ),
   .wb_data( masters[1].master ),//wb_cpu_data ),
   .interrupts( {17'd0,int3,1'b0,int1} )
//   .debug( debug )
);

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
   .slaves(8)
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
      '{32'hFFFF0040,32'hFFFF005F}, //SPI (A/D)
      '{32'hFFFFFFF0,32'hFFFFFFF4}, //RTC
      '{32'hFFFFFFE0,32'hFFFFFFE3}  //Touch reg
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
wb_connector rtc_connector ( .master(rtc_bus), .slave(slaves[6]) );
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

wb_reg_ro touchreg
(
   .bus( slaves[7] ),
   .in({touch.touching,3'b0,touch.x_coord,4'b0,touch.y_coord}),
   .read( touch_clr_int )
);

endmodule

