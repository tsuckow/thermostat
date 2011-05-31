package lcd;

   typedef struct
   {
      logic [7:0] r;
      logic [7:0] g;
      logic [7:0] b;
   } color;

   typedef struct
   {
      logic [11:0] x_coord;
      logic [11:0] y_coord;
      logic touching;
   } touchevent;

endpackage

