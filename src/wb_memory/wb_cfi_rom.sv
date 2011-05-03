interface cfi;

logic [20:0] addr;
wire  [15:0] dq;
logic we_n;
logic reset_n;
logic wp_n;
logic busy_n;
logic ce_n;
logic oe_n;
logic byte_n;

modport master ( output addr, inout dq, output we_n, reset_n, wp_n, input  busy_n, output ce_n, oe_n, byte_n );
modport slave  ( input  addr, inout dq, input  we_n, reset_n, wp_n, output busy_n, input  ce_n, oe_n, byte_n );

endinterface

module cfi_arbitrator
(
   input logic request,
   cfi.master out,
   cfi.slave  normal,
   cfi.slave  requester
);

genvar i;
generate

for (i=0; i < 16; i=i+1)
begin : dqLoop
   tran trans_gate1 (normal.dq[i], out.dq[i]);
   tran trans_gate2 (requester.dq[i], out.dq[i]);
end

endgenerate

//assign out.dq     = request?requester.dq:normal.dq;
assign out.addr   = request?requester.addr:normal.addr;
assign out.we_n   = request?requester.we_n:normal.we_n;
assign out.wp_n   = request?requester.wp_n:normal.wp_n;
assign out.reset_n= request?requester.reset_n:normal.reset_n;
assign out.ce_n   = request?requester.ce_n:normal.ce_n;
assign out.oe_n   = request?requester.oe_n:normal.oe_n;
assign out.byte_n = request?requester.byte_n:normal.byte_n;

assign normal.busy_n    = out.busy_n;
assign requester.busy_n = out.busy_n;
//assign normal.dq    = out.dq;
//assign requester.dq = out.dq;

endmodule



module wb_cfi_rom
(
   input logic clk,
   input logic rst,
   wishbone_b3.slave wb,
   cfi.master cfi
);

logic cs;
assign cs = wb.cyc & wb.stb;

logic [3:0] counter;
logic [15:0] buffer;
logic word;

always@(posedge clk or posedge rst)
begin
   if(rst)
      counter = 'd0;
   else
   begin
      if( cs && counter <= 8 )
         counter = counter + 1;
      else
         counter = 'd0;
   end
end

logic [15:0] endianfix;
assign endianfix = {cfi.dq[7:0],cfi.dq[15:8]};

always_ff@(negedge clk)
   if( counter == 4 )
   begin
      buffer = endianfix;
      word = 1'b1;
   end
   else
   begin
      buffer = buffer;
      if(counter == 1'b0)
         word = 1'b0;
      else
         word = word;
   end

assign cfi.ce_n = !cs;
assign cfi.oe_n = !cs;
assign cfi.addr = { wb.adr[21:2], word };
assign cfi.byte_n = 1'b1;
assign cfi.reset_n = 1'b1;
assign cfi.wp_n = 1'b1;
assign cfi.we_n = 1'b1;

assign wb.ack = counter == 8;
assign wb.dat_s2m = {buffer,endianfix};
assign wb.rty = 1'b0;
assign wb.err = wb.we;

endmodule

