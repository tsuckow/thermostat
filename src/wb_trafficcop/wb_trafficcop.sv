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
//
module wb_trafficcop_b3
#(
   parameter masters = 1,
   parameter slaves = 2
)
(
   wishbone_b3.slave   master [masters],
   wishbone_b3.master  slave  [slaves],
   input wb_addr_range addrs  [slaves]
);

/*
int i = 0;

task automatic trialtask;
ref wishbone_b3 in;
output logic out;
begin
   out = in.we;
end
endtask

generate
genvar bob;
   for ( bob = 0; bob < slaves; bob = bob + 1 )
   begin : foreachslave
//      assign slave[bob].we = 1;
      logic tmp;
      always@(*)
      begin
         trialtask( slave[bob], tmp );
      end
   end
endgenerate
*/



endmodule
