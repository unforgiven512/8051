//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 instruction cache                                      ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 instruction cache                                      ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2003/01/13 14:14:41  simont
// replace some modules
//
// Revision 1.2  2002/10/24 13:34:02  simont
// add parameters for instruction cache
//
// Revision 1.1  2002/10/23 16:55:36  simont
// fix bugs in instruction interface
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on


module oc8051_icache (rst, clk, adr_i, dat_o,stb_i, ack_o, cyc_i,
        dat_i, cyc_o, adr_o, ack_i, stb_o);
//
// rst           (in)  reset - pin
// clk           (in)  clock - pini
input rst, clk;

//
// interface to oc8051 cpu
//
// adr_i    (in)  address
// dat_o    (out) data output
// stb_i    (in)  strobe
// ack_o    (out) acknowledge
// cyc_i    (in)  cycle
input stb_i, cyc_i;
input [15:0] adr_i;
output ack_o;
output [31:0] dat_o;
reg [31:0] dat_o;

//
// interface to instruction rom
//
// adr_o    (out) address
// dat_i    (in)  data input
// stb_o    (out) strobe
// ack_i    (in) acknowledge
// cyc_o    (out)  cycle
input ack_i;
input [31:0] dat_i;
output stb_o, cyc_o;
output [15:0] adr_o;
//reg [15:0] adr_o;
reg stb_o, cyc_o;

parameter ADR_WIDTH = 6; // cache address wihth
parameter LINE_WIDTH = 2; // line address width (2 => 4x32)
parameter BL_WIDTH = ADR_WIDTH - LINE_WIDTH; // block address width
parameter BL_NUM = 15; // number of blocks (2^BL_WIDTH-1)
parameter CACHE_RAM = 64; // cache ram x 32 (2^ADR_WIDTH)

//
// internal buffers adn wires
//
// con_buf control buffer, contains upper addresses [15:ADDR_WIDTH1] in cache
reg [13-ADR_WIDTH:0] con_buf [BL_NUM:0];
// valid[x]=1 if block x is valid;
reg [BL_NUM:0] valid;
// con0, con2 contain temporal control information of current address and corrent address+2
// part of con_buf memory
reg [14-ADR_WIDTH:0] con0, con2;
//current upper address,
reg [13-ADR_WIDTH:0] cadr0, cadr2;
reg stb_b;
// byte_select in 32 bit line (adr_i[1:0])
reg [1:0] byte_sel;
// read cycle
reg [LINE_WIDTH-1:0] cyc;
// data input from cache ram
reg [31:0] data1_i;
// temporaly data from ram
reg [15:0] tmp_data1;
reg wr1, wr1_t, stb_it;

wire [31:0] data0, data1_o;
wire cy, cy1;
wire [BL_WIDTH-1:0] adr_i2;
wire hit, hit_l, hit_h;
wire [ADR_WIDTH-1:0] adr_r, addr1;
reg [ADR_WIDTH-1:0] adr_w;
reg [15:0] mis_adr;
wire [15:0] data1;
wire [LINE_WIDTH-1:0] adr_r1;


assign cy = &adr_i[LINE_WIDTH+1:1];
assign {cy1, adr_i2} = {1'b0, adr_i[ADR_WIDTH+1:LINE_WIDTH+2]}+cy;
assign hit_l =(con0=={cadr0,1'b1});
assign hit_h =(con2=={cadr2,1'b1});
assign hit = hit_l && hit_h;

assign adr_r = adr_i[ADR_WIDTH+1:2] + adr_i[1];
assign addr1 = wr1 ? adr_w : adr_r;
assign adr_r1 = adr_r[LINE_WIDTH-1:0] + 2'b01;
//assign ack_o = hit;
assign ack_o = hit && stb_it;

assign data1 = wr1_t ? tmp_data1 : data1_o[31:16];

assign adr_o = {mis_adr[15:LINE_WIDTH+2], cyc, 2'b00};


oc8051_cache_ram oc8051_cache_ram1(.clk(clk), .rst(rst), .addr0(adr_i[ADR_WIDTH+1:2]),
       .addr1(addr1), .data0(data0), .data1_o(data1_o), .data1_i(data1_i),
       .wr1(wr1));

defparam oc8051_cache_ram1.ADR_WIDTH = ADR_WIDTH;
defparam oc8051_cache_ram1.CACHE_RAM = CACHE_RAM;

always @(stb_b or data0 or data1 or byte_sel)
begin
  if (stb_b) begin
    case (byte_sel)
      2'b00  : dat_o = data0;
      2'b01  : dat_o = {data0[23:0], data1[15:8]};
      2'b10  : dat_o = {data0[15:0], data1};
      default: dat_o = {data0[ 7:0], data1, 8'h00};
    endcase
  end else begin
    dat_o = 32'h0;
  end
end

always @(posedge clk or posedge rst)
begin
  if (rst)
    begin
        con0 <= #1 9'h0;
        con2 <= #1 9'h0;
    end
  else
    begin
        con0 <= #1 {con_buf[adr_i[ADR_WIDTH+1:LINE_WIDTH+2]], valid[adr_i[ADR_WIDTH+1:LINE_WIDTH+2]]};
        con2 <= #1 {con_buf[adr_i2], valid[adr_i2]};
    end
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    cadr0 <= #1 8'h00;
    cadr2 <= #1 8'h00;
  end else begin
    cadr0 <= #1 adr_i[15:ADR_WIDTH+2];
    cadr2 <= #1 adr_i[15:ADR_WIDTH+2]+ cy1;
  end
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    stb_b <= #1 1'b0;
    byte_sel <= #1 2'b00;
  end else begin
    stb_b <= #1 stb_i;
    byte_sel <= #1 adr_i[1:0];
  end
end

always @(posedge clk or posedge rst)
begin
  if (rst)
    begin
        cyc    <= #1 2'b00;
        cyc_o  <= #1 1'b0;
        stb_o  <= #1 1'b0;
        data1_i<= #1 32'h0;
        wr1    <= #1 1'b0;
        adr_w  <= #1 6'h0;
        valid  <= #1 16'h0;
    end 
  else if (stb_b && !hit && !stb_o && !wr1)
    begin
        cyc     <= #1 2'b00;
        cyc_o   <= #1 1'b1;
        stb_o   <= #1 1'b1;
        data1_i <= #1 32'h0;
        wr1     <= #1 1'b0;
    end
  else if (stb_o && ack_i)
    begin
        data1_i<= #1 dat_i;
        wr1    <= #1 1'b1;
        adr_w  <= #1 adr_o[ADR_WIDTH+1:2];

        if (&cyc)
          begin
              cyc   <= #1 2'b00;
              cyc_o <= #1 1'b0;
              stb_o <= #1 1'b0;
//              con_buf[mis_adr[ADR_WIDTH+1:LINE_WIDTH+2]] <= #1 mis_adr[15:ADR_WIDTH+2];
              valid[mis_adr[ADR_WIDTH+1:LINE_WIDTH+2]] <= #1 1'b1;
          end
        else
          begin
              cyc   <= #1 cyc + 1'b1;
              cyc_o <= #1 1'b1;
              stb_o <= #1 1'b1;
          end


/*    case (cyc)
      2'b00: begin
        cyc <= #1 2'b01;
        cyc_o <= #1 1'b1;
        stb_o <= #1 1'b1;
      end
      2'b01: begin
        cyc <= #1 2'b10;
        cyc_o <= #1 1'b1;
        stb_o <= #1 1'b1;
      end
      2'b10: begin
        cyc <= #1 2'b11;
        cyc_o <= #1 1'b1;
        stb_o <= #1 1'b1;
      end
      default: begin
        cyc <= #1 2'b00;
        cyc_o <= #1 1'b0;
        stb_o <= #1 1'b0;
        con_buf[mis_adr[7:4]] <= #1 mis_adr[15:8];
        valid[mis_adr[7:4]] <= #1 1'b1;
      end
    endcase*/
    end
  else
    wr1 <= #1 1'b0;
end

//rih
always @(posedge clk)
  if ( ~(stb_b && !hit && !stb_o && !wr1) & (stb_o && ack_i & &cyc) )
    con_buf[mis_adr[ADR_WIDTH+1:LINE_WIDTH+2]] <= #1 mis_adr[15:ADR_WIDTH+2];


always @(posedge clk or posedge rst)
begin
  if (rst)
    mis_adr <= #1 1'b0;
  else if (!hit_l)
    mis_adr <= #1 adr_i;
  else if (!hit_h)
    mis_adr <= #1 adr_i+'d2;
end

always @(posedge clk or posedge rst)
begin
  if (rst)
    tmp_data1 <= #1 1'b0;
  else if (!hit_h && wr1 && (cyc==adr_r1))
    tmp_data1 <= #1 dat_i[31:16];
  else if (!hit_l && hit_h && wr1)
    tmp_data1 <= #1 data1_o[31:16];
end

always @(posedge clk or posedge rst)
begin
  if (rst) begin
    wr1_t <= #1 1'b0;
    stb_it <= #1 1'b0;
  end else begin
    wr1_t <= #1 wr1;
    stb_it <= #1 stb_i;
  end
end

endmodule

