interface IntellitecSignal;
  logic tm4, tm2;
  logic mt12, mt2;
  modport master(output mt12, output mt2, input tm4, input tm2);
  modport slave(input mt12, input mt2, output tm4, output tm2);
endinterface
/*
module IntellitecClock
(
	IntellitecSignal.Master it
);

endmodule
*/
//
//
//
module IntellitecMasterControl
(
	input clock,
	input [1:0] shed,
	IntellitecSignal.master it,
	output ac1,
	output ac2,
	output f1O,
	output f1H,
	output f2O,
	output f2H,
	output ht1,
	output ht2
);

	wire [0:9] data;
	reg  [0:9] values2;
	reg  [0:9] values4;
	wire [2:0] count;
	wire [3:0] item;
	
	assign data = {1'b0,1'b0,shed[1],1'b0,1'b0,1'b0,shed[0],1'b0,1'b0,1'b0};
	
	typedef enum reg[1:0] {Sync, Intermediate, Data} States;
	States state;
	
	always_ff@(posedge clock)
	begin
		case(state)
			//Generate Sync Pulse
			Sync:
			begin
				//Count to 3, //pull string
				if(count=='d2)
				begin
					state = Data;
					count = 'd0;
				end
				else
				begin
					state = Sync;
					count = count+3'd1;
				end
				item = 'd0;
			end
			//Bit Sync Pulse
			Intermediate:
			begin
				state = (item=='d9)?Sync:Data;
				count = 'd0;
				item = item + 3'd1;
			end
			Data:
			begin
				state = (count=='d7)?Intermediate:Data;
				count = count+3'd1;
				
				if( count == 'd3 ) values2[ item ] = it.tm2;
				if( count == 'd3 ) values4[ item ] = it.tm4;
			end
			default:
			begin
				state = Sync;
				count = 'd0;
			end
		endcase
	end
	
always_comb
	begin
		case(state)
			Data:
				begin
					it.mt12 = 0;
					it.mt2 = data[item];
				end
			default:
				begin
					//Pull the line to +12V
					it.mt12 = 1;
					it.mt2 = 0;
				end
		endcase
			
		ac1 = ~(values2[1] & !shed[0]);
		ac2 = ~(values2[5] & !shed[1]);
		f1O = ~(values4[0] & !shed[0]);
		f1H = ~(values2[0] & !shed[0]);
		f2O = ~(values4[4] & !shed[1]);
		f2H = ~(values2[4] & !shed[1]);
		ht1 = ~(values2[3] & !shed[0]);
		ht2 = ~(values2[7] & !shed[1]);
	end
	
endmodule

//
//
//
module IntellitecThermostatControl
(
	input clock,
	input ac1,
	input ac2,
	input f1O,
	input f1H,
	input f2O,
	input f2H,
	input ht1,
	input ht2,
	IntellitecSignal.slave it,
	output reg sync12,
	output reg [1:0] shed
);

wire [0:9] data4;
wire [0:9] data2;
wire [3:0] item;
reg  [1:0] count;


assign data4 = {f1O & ~f1H, 1'd0, 1'd0, 1'd0, f2O & ~f2H, 1'd0, 1'd0, 1'd0, 1'd0, 1'd0};
assign data2 = {f1O &  f1H,  ac1, 1'd0,  ht1, f2O &  f2H,  ac2, 1'd0,  ht2, 1'd0, 1'd0};

typedef enum reg[0:0] {Syncing, Data} States;
States state;

//reg sync12;
reg sync12_last;
always_ff@(posedge clock or posedge it.mt12)
begin
	if(it.mt12)
		sync12 = 1'b1;
	else
		sync12 = 1'b0;
end

always_ff@(posedge clock)
	sync12_last = sync12;

reg tm4;
reg tm2;
	
always_ff@(posedge clock)
	begin
		case(state)
			Syncing:
				begin
					state = (~it.mt12 && item>1)?Data:Syncing;
					item = (it.mt12)?(item + 1'd1):4'd0;
				end
			Data:
				begin
					state = (sync12 & ~sync12_last & item>='d9)?Syncing:Data;
					item = (sync12 & ~sync12_last)?((item>='d9)?4'd0:(item + 1'd1)):item;
					if(item == 'd2 && count == 'd2) shed[0] = it.mt2;
					if(item == 'd6 && count == 'd2) shed[1] = it.mt2;
				end
			default:
				begin
					state = Syncing;
				end
		endcase
		count = (sync12 & ~sync12_last)?2'd0:(count==3?2'd3:count+2'd1);
	end
	
always_comb
	begin
		case(state)
			Data:
				begin
					tm4 = data4[item];
					tm2 = data2[item];
				end
			default:
				begin
					tm4 = 0;
					tm2 = 0;
				end
			endcase
	end

	//
	//When sync12 is high, output disabled
	assign it.tm4 = tm4 & ~sync12;
	assign it.tm2 = tm2 & ~sync12;

endmodule
