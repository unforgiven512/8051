//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 ram select                                             ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////   Multiplexer wiht whitch we select data send to alu source  ////
////   select.                                                    ////
////                                                              ////
////  To Do:                                                      ////
////   nothing                                                    ////
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
// Revision 1.5  2002/09/30 17:33:59  simont
// prepared header
//
//

// synopsys translate_off
`include "oc8051_timescale.v"
// synopsys translate_on

`include "oc8051_defines.v"

module oc8051_ram_sel (addr, bit_in, in_ram, sfr, sfr_bit, rd_ind, bit_out, out_data);
//
// addr         (in)  address [oc8051_ram_rd_sel.out -r]
// bit_in       (in)  bit input (from ram) [oc8051_ram_top.bit_data_out]
// in_ram       (in)  imput from ram [oc8051_ram_top.rd_data]
// psw          (in)  program status word input [oc8051_psw.data_out]
// acc          (in)  accumulator input [oc8051_acc.data_out]
// dptr_hi      (in)  data pointer high bits input [oc8051_dptr.data_hi]
// ports_in     (in)  ports input [oc8051_ports.data_out]
// sp           (in)  stack pointer [oc8051_sp.data_out]
// b_reg        (in)  b register input [oc8051_b_register.data_out]
// uart         (in)  input from uart [oc8051_uart.data_out]
// int		(in)  input from interrupt module
// tc		(in)  input from timer counter module
// bit_out      (out) bit output [oc8051_alu.bit_in, oc8051_comp.b_in, oc8051_cy_select.data_in]
// out_data     (out) data (byte) output [oc8051_alu_src1_sel.ram, oc8051_alu_src2_sel.ram, oc8051_comp.ram]
//


input bit_in, sfr_bit, rd_ind;
input [7:0] addr, in_ram, sfr;

output bit_out;
output [7:0] out_data;

reg bit_out;
reg [7:0] out_data;

/*
//
//set output in case of address (byte)
always @(addr or in_ram or psw or acc or dptr_hi or ports_in or sp or b_reg or uart or tc or int)
begin
  case (addr)
    `OC8051_SFR_ACC: out_data = acc;
    `OC8051_SFR_PSW: out_data = psw;
    `OC8051_SFR_P0: out_data = ports_in;
    `OC8051_SFR_P1: out_data = ports_in;
    `OC8051_SFR_P2: out_data = ports_in;
    `OC8051_SFR_P3: out_data = ports_in;
    `OC8051_SFR_SP: out_data = sp;
    `OC8051_SFR_B: out_data = b_reg;
    `OC8051_SFR_DPTR_HI: out_data = dptr_hi;
    `OC8051_SFR_SCON:  out_data = uart;
    `OC8051_SFR_SBUF:  out_data = uart;
    `OC8051_SFR_PCON:  out_data = uart;
    `OC8051_SFR_TH0: out_data = tc;
    `OC8051_SFR_TH1: out_data = tc;
    `OC8051_SFR_TL0: out_data = tc;
    `OC8051_SFR_TL1: out_data = tc;
    `OC8051_SFR_TMOD: out_data = tc;
    `OC8051_SFR_IP: out_data = int;
    `OC8051_SFR_IE: out_data = int;
    `OC8051_SFR_TCON: out_data = int;
    default: out_data = in_ram;
  endcase
end


//
//set output in case of address (bit)
always @(addr or bit_in or b_bit or acc_bit or psw_bit or int_bit or port_bit or uart_bit)
begin
  case (addr[7:3])
    `OC8051_SFR_B_ACC: bit_out = acc_bit;
    `OC8051_SFR_B_PSW: bit_out = psw_bit;
    `OC8051_SFR_B_P0: bit_out = port_bit;
    `OC8051_SFR_B_P1: bit_out = port_bit;
    `OC8051_SFR_B_P2: bit_out = port_bit;
    `OC8051_SFR_B_P3: bit_out = port_bit;
    `OC8051_SFR_B_B: bit_out = b_bit;
    `OC8051_SFR_B_IP: bit_out = int_bit;
    `OC8051_SFR_B_IE: bit_out = int_bit;
    `OC8051_SFR_B_TCON: bit_out = int_bit;
    `OC8051_SFR_B_SCON: bit_out = uart_bit;
    default: bit_out = bit_in;
  endcase
end
*/

//
always @(addr or in_ram or sfr or bit_in or sfr_bit)
begin
  if (addr[7] && !rd_ind) begin
    out_data = sfr;
    bit_out = sfr_bit;
  end else begin
    out_data = in_ram;
    bit_out = bit_in;
  end
end

endmodule
