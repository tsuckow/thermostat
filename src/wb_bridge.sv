
module wb_bridge_fastmasterout
(
input clk_slave,
input clk_master,
input rst,
wishbone_b3.slave slave,
wishbone_b3.master master
);

logic slaveacked;
logic [31:0] s2m;
logic ackreg;

always_ff@(negedge clk_slave or posedge rst)
begin
   if(rst)
      slaveacked = 0;
   else
      slaveacked = ackreg;
end

always_ff@(posedge clk_master or posedge rst)
begin
   if(rst)
   begin
      s2m = 'd0;
      ackreg = 0;
   end
   else
   begin
      if(master.ack)
      begin
         s2m = master.dat_s2m;
         ackreg = 1;
      end
      else
      begin
         s2m = s2m;
         ackreg = ackreg & !slaveacked;
      end
   end
end

assign master.adr = slave.adr;
assign master.cyc = slave.cyc;
assign slave.dat_s2m = s2m;
assign master.dat_m2s = slave.dat_m2s;
assign master.sel = slave.sel;
assign slave.ack = slaveacked;
assign slave.err = master.err;
assign slave.rty = master.rty;
assign master.we = slave.we;
assign master.stb = slave.stb & !(slaveacked || ackreg);
assign master.cti = slave.cti;
assign master.bte = slave.bte;

endmodule
