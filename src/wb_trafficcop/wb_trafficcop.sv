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


module wb_connector
(
   wishbone_b3.slave slave,
   wishbone_b3.master master
);

assign master.adr = slave.adr;
assign master.cyc = slave.cyc;
assign slave.dat_s2m = master.dat_s2m;
assign master.dat_m2s = slave.dat_m2s;
assign master.sel = slave.sel;
assign slave.ack = master.ack;
assign slave.err = master.err;
assign slave.rty = master.rty;
assign master.we = slave.we;
assign master.stb = slave.stb;
assign master.cti = slave.cti;
assign master.bte = slave.bte;

endmodule

module wb_nullslave
(
   wishbone_b3.slave slave
);

assign slave.dat_s2m = 'd0;
assign slave.ack = 1'b0;
assign slave.err = 1'b1;
assign slave.rty = 1'b0;

endmodule

//
// Acts as a traffic cop allowing multiple masters to coexist on the same bus.
//
module wb_trafficcop_b3
#(
   parameter masters = 3
)
(
   input               clk,
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

logic [oitBits(masters)-1:0] req_nextnum, req_num;
priority_encoder #($bits(req),$bits(req_num)) enc ( req, req_nextnum );

always_ff@(posedge clk)
begin
   if( req[req_num] )
      req_num = req_num;
   else
      req_num = req_nextnum;
end

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
   parameter slaves = 5
)
(
   wishbone_b3.slave   master,
   wishbone_b3.master  slave  [slaves],
   input wb_addr_range addrs  [slaves]
);
`include "oitConstant.sv"

   function logic between;
      input integer x;
      input wb_addr_range rng;

      between = x >= rng.min && x <= rng.max;

   endfunction

logic [32+3-1:0] master_out;
logic [32+3-1:0] s2m [slaves];
generate
   genvar i;
   for(i = 0; i < slaves; i = i + 1)
   begin  : s2mloop
      assign s2m[i] = {slave[i].dat_s2m, slave[i].ack, slave[i].err, slave[i].rty};
   end
endgenerate

assign {master.dat_s2m, master.ack, master.err, master.rty} = master_out;

generate
   for(i = 0; i < slaves; i = i + 1)
   begin  : m2sloop
      assign slave[i].adr = master.adr;
      assign slave[i].cyc = master.cyc;
      assign slave[i].dat_m2s = master.dat_m2s;
      assign slave[i].sel = master.sel;
      assign slave[i].we  = master.we;
      assign slave[i].stb = between( master.adr, addrs[i] )?master.stb:1'b0;
      assign slave[i].cti = master.cti;
      assign slave[i].bte = master.bte;
   end
endgenerate

logic [slaves-1:0] whichslave;
generate
   for(i = 0; i < slaves; i = i + 1)
   begin  : selloop
      assign whichslave[i] = between( master.adr, addrs[i] );
   end
endgenerate

logic [oitBits(slaves)-1:0] whichslavenum;
priority_encoder #($bits(whichslave),$bits(whichslavenum)) enc ( whichslave, whichslavenum );

always_comb
begin
   if( whichslave == 0 )
      master_out = 'd2; //Error
   else
      master_out = s2m[whichslavenum];
end

endmodule

