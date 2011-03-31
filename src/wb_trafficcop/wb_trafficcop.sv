//
// Debug interface for processor
interface debug_interface
#(
   parameter addr_width = 32,
   parameter data_width = 32
);

logic                  stall;   // External Stall Input
logic                  ewt;     // External Watchpoint Trigger Input
logic [3:0]            lss;     // External Load/Store Unit Status
logic [1:0]            is;      // External Insn Fetch Status
logic [10:0]           wp;      // Watchpoints Outputs
logic                  bp;      // Breakpoint Output
logic                  stb;     // External Address/Data Strobe
logic                  we;      // External Write Enable
logic [addr_width-1:0] adr;     // External Address Input
logic [data_width-1:0] dat_s2m; // External Data Input
logic [data_width-1:0] dat_m2s; // External Data Output
logic                  ack;     // External Data Acknowledge (not WB compatible)

modport master
(
   input  stall,
   input  ewt,
   output lss,
   output is,
   output wp,
   output bp,
   input  stb,
   input  we,
   input  adr,
   input  dat_s2m,
   output dat_m2s,
   output ack
);
modport slave
(
   output stall,
   output ewt,
   input  lss,
   input  is,
   input  wp,
   input  bp,
   output stb,
   output we,
   output adr,
   output dat_s2m,
   input  dat_m2s,
   input  ack
);

endinterface

//
// Wishbone bus interface
interface wishbone_b3
#(
   parameter addr_width = 32,
   parameter data_width = 32
);

logic [addr_width-1:0] adr;     //Address
logic        cyc;     //Cycle in progress
logic [data_width-1:0] dat_m2s; //Data [Master to slave]
logic [data_width-1:0] dat_s2m; //Data [Slave to master]
logic [3:0]  sel;     //Bank Select
logic        ack;     //Acknowledge
logic        err;     //Error
logic        rty;     //Retry
logic        we;      //Write Enable
logic        stb;     //Strobe
logic [2:0]  cti;     // ?
logic        bte;     // ?

modport master
(
   output adr,
   output cyc,
   input  dat_s2m,
   output dat_m2s,
   output sel,
   input  ack,
   input  err,
   input  rty,
   output we,
   output stb,
   output cti,
   output bte
);
modport slave
(
   input  adr,
   input  cyc,
   output dat_s2m,
   input  dat_m2s,
   input  sel,
   output ack,
   output err,
   output rty,
   input  we,
   input  stb,
   input  cti,
   input  bte
);

endinterface

typedef struct
{
   int min;
   int max;
} wb_addr_range;

//
// Acts as a traffic cop allowing multiple masters to coexist on the same bus.
//
module wb_trafficcop_b3
#(
   parameter masters = 3
)
(
   wishbone_b3.slave   master [masters],
   wishbone_b3.master  slave
);

`include "oitConstant.sv"

logic [masters-1:0] req;
assign req = //Would be awsome in for loop if Quartus didn't crash.
   {
      master[2].cyc,
      master[1].cyc,
      master[0].cyc
   };

logic [oitBits(masters)-1:0] req_num;
priority_encoder #($bits(req),$bits(req_num)) enc ( req, req_num );

logic [32+3-1:0] m0_out, m1_out, m2_out, slave_out;
assign {master[0].dat_s2m, master[0].ack, master[0].err, master[0].rty} = m0_out;
assign {master[1].dat_s2m, master[1].ack, master[1].err, master[1].rty} = m1_out;
assign {master[2].dat_s2m, master[2].ack, master[2].err, master[2].rty} = m2_out;
assign slave_out = {slave.dat_s2m, slave.ack, slave.err, slave.rty};

always_comb
begin
   case( req_num )
      'd0:
         begin
            slave.adr = master[0].adr;
            slave.cyc = master[0].cyc;
            slave.dat_m2s = master[0].dat_m2s;
            slave.sel = master[0].sel;
            slave.we  = master[0].we;
            slave.stb = master[0].stb;
            slave.cti = master[0].cti;
            slave.bte = master[0].bte;
            m0_out = slave_out;
            m1_out = 'd0;
            m2_out = 'd0;
         end
      'd1:
         begin
            slave.adr = master[1].adr;
            slave.cyc = master[1].cyc;
            slave.dat_m2s = master[1].dat_m2s;
            slave.sel = master[1].sel;
            slave.we  = master[1].we;
            slave.stb = master[1].stb;
            slave.cti = master[1].cti;
            slave.bte = master[1].bte;
            m0_out = 'd0;
            m1_out = slave_out;
            m2_out = 'd0;
         end
      'd2:
         begin
            slave.adr = master[2].adr;
            slave.cyc = master[2].cyc;
            slave.dat_m2s = master[2].dat_m2s;
            slave.sel = master[2].sel;
            slave.we  = master[2].we;
            slave.stb = master[2].stb;
            slave.cti = master[2].cti;
            slave.bte = master[2].bte;
            m0_out = 'd0;
            m1_out = 'd0;
            m2_out = slave_out;
         end
      default:
         begin
            slave.adr = 'd0;
            slave.cyc = 1'b0;
            slave.dat_m2s = 'd0;
            slave.sel = 'd0;
            slave.we  = 1'b0;
            slave.stb = 1'b0;
            slave.cti = 'd0;
            slave.bte = 1'b0;
            m0_out = 'd0;
            m1_out = 'd0;
            m2_out = 'd0;
         end
   endcase
end

endmodule

//
// Expands a wishbone bus to handle multiple slaves.
//
module wb_expander_b3
#(
   parameter slaves = 3
)
(
   wishbone_b3.slave   master,
   wishbone_b3.master  slave  [slaves],
   input wb_addr_range addrs  [slaves]
);

   function logic between;
      input integer x;
      input wb_addr_range rng;

      between = x >= rng.min && x <= rng.max;

   endfunction

logic [32+3-1:0] s2m0, s2m1, s2m2, master_out;
assign s2m0 = {slave[0].dat_s2m, slave[0].ack, slave[0].err, slave[0].rty};
assign s2m1 = {slave[1].dat_s2m, slave[1].ack, slave[1].err, slave[1].rty};
assign s2m2 = {slave[2].dat_s2m, slave[2].ack, slave[2].err, slave[2].rty};
assign {master.dat_s2m, master.ack, master.err, master.rty} = master_out;

   always_comb
   begin
      slave[0].adr = master.adr;
      slave[1].adr = master.adr;
      slave[2].adr = master.adr;

      slave[0].cyc = master.cyc;
      slave[1].cyc = master.cyc;
      slave[2].cyc = master.cyc;

      slave[0].cyc = master.cyc;
      slave[1].cyc = master.cyc;
      slave[2].cyc = master.cyc;

      slave[0].dat_m2s = master.dat_m2s;
      slave[1].dat_m2s = master.dat_m2s;
      slave[2].dat_m2s = master.dat_m2s;

      slave[0].sel = master.sel;
      slave[1].sel = master.sel;
      slave[2].sel = master.sel;

      slave[0].we  = master.we;
      slave[1].we  = master.we;
      slave[2].we  = master.we;

      slave[0].stb = between( master.adr, addrs[0] )?master.stb:1'b0;
      slave[1].stb = between( master.adr, addrs[1] )?master.stb:1'b0;
      slave[2].stb = between( master.adr, addrs[2] )?master.stb:1'b0;

      slave[0].cti = master.cti;
      slave[1].cti = master.cti;
      slave[2].cti = master.cti;

      slave[0].bte = master.bte;
      slave[1].bte = master.bte;
      slave[2].bte = master.bte;

      if( between( master.adr, addrs[0] ) )
         master_out = s2m0;
      else if( between( master.adr, addrs[1] ) )
         master_out = s2m1;
      else if( between( master.adr, addrs[2] ) )
         master_out = s2m2;
      else
         master_out = 'd2; //Error

   end

endmodule

