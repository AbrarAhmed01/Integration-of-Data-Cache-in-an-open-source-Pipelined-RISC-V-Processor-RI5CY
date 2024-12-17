// Top level wrapper for RI5CY

// Copyright (C) 2017 Embecosm Limited <www.embecosm.com>

// Contributor: Jeremy Bennett <jeremy.bennett@embecosm.com>

// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.

// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
// more details.

// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.


// This instantiates memory and (eventually) a debug interface for the core.

module top
#(
  parameter INSTR_RDATA_WIDTH = 128,
  parameter ADDR_WIDTH = 22,		// Consistent with PicoRV32
  parameter BOOT_ADDR  = 'h80		// Consistent with Pulpino
  )
(
  // Clock and Reset
 input  logic        clk_i,
 input  logic        rstn_i,

 // Interrupt inputs
 input  logic [31:0] irq_i,            // level sensitive IR lines

 // Debug Interface
 input  logic        debug_req_i,
 output logic        debug_gnt_o,
 output logic        debug_rvalid_o,
 input  logic [14:0] debug_addr_i,
 input  logic        debug_we_i,
 input  logic [31:0] debug_wdata_i,
 output logic [31:0] debug_rdata_o,
 output logic        debug_halted_o,

 // CPU Control Signals
 input  logic        fetch_enable_i,
 output logic        core_busy_o,
 
 //signals of LOAD STORE UNIT
 output logic lsu_req,                                  //LOAD STORE UNIT Request Signal
 output logic [ADDR_WIDTH - 1: 0] lsu_addr,             //Address signals from LOAD STORE UNIT
 output logic lsu_we,                                   //Read write enable from LOAD STORE UNIT
 output logic [3:0] lsu_be,                             //Byte enable bits from LOAD STORE UNIT
 output logic [31:0]lsu_wdata,             //Write data from LOAD STORE UNIT
 
 //signals of LOAD STORE UNIT
 output logic [31:0]lsu_rdata,      //Data read to LOAD STORE UNIT
 output logic lsu_rvalid,                        //Valid signal to LOAD STORE UNIT
 output logic lsu_gnt,                           //Request granted signal to LOAD STORE UNIT
 
 //signals of main memory
 output logic [31:0]memory_rdata,             //Data read from main memory
 output logic memory_rvalid,                               //Valid signal from main memory
 output logic memory_gnt,                                  //Request granted signal from main memory
 
 //signals of main memory
 output logic memory_req,                           //Request signal to main memory
 output logic [31: 0] memory_addr,      //Address signals to main memory
 output logic memory_we,                            //Read write enable to main memory
 output logic [3:0] memory_be,                      //Byte enable bits to main memory
 output logic [31: 0] memory_wdata      //Write data to main memory 
 );

   // signals connecting core to memory

   logic 	          instr_req;
   logic 	          instr_gnt;
   logic 	          instr_rvalid;
   logic [ADDR_WIDTH-1:0] instr_addr;
   logic [127:0] 	  instr_rdata;

   logic 		  data_req;
   logic 		  data_gnt;
   logic 		  data_rvalid;
   logic [ADDR_WIDTH-1:0] data_addr;
   logic 		  data_we;
   logic [3:0] 		  data_be;
   logic [31:0] 	  data_rdata;
   logic [31:0] 	  data_wdata;

    //inputs from main memory
    logic [31: 0] mem_rdata;
    logic mem_rvalid;
    logic mem_gnt;
        
    //outputs from main memory
    logic mem_req;
    logic [31: 0] mem_addr;
    logic mem_we;
    logic [3:0] mem_be;
    logic [31: 0] mem_wdata;
    
   // Instantiate the core
    
   riscv_core
     #(
       .INSTR_RDATA_WIDTH (INSTR_RDATA_WIDTH)
       )
   riscv_core_i
     (
      .clk_i               ( clk_i          ),
      .rst_ni              ( rstn_i         ),

      .clock_en_i          ( '1             ),
      .test_en_i           ( '1             ),

      .boot_addr_i         ( BOOT_ADDR      ),
      .core_id_i           ( 4'h0           ),
      .cluster_id_i        ( 6'h0           ),

      .instr_addr_o        ( instr_addr     ),
      .instr_req_o         ( instr_req      ),
      .instr_rdata_i       ( instr_rdata    ),
      .instr_gnt_i         ( instr_gnt      ),
      .instr_rvalid_i      ( instr_rvalid   ),

      .data_addr_o         ( data_addr      ),
      .data_wdata_o        ( data_wdata     ),
      .data_we_o           ( data_we        ),
      .data_req_o          ( data_req       ),
      .data_be_o           ( data_be        ),
      .data_rdata_i        ( data_rdata     ),
      .data_gnt_i          ( data_gnt       ),
      .data_rvalid_i       ( data_rvalid    ),
      .data_err_i          ( 1'b0           ),

      .irq_i               ( irq_i          ),

      .debug_req_i         ( debug_req_i    ),
      .debug_gnt_o         ( debug_gnt_o    ),
      .debug_rvalid_o      ( debug_rvalid_o ),
      .debug_addr_i        ( debug_addr_i   ),
      .debug_we_i          ( debug_we_i     ),
      .debug_wdata_i       ( debug_wdata_i  ),
      .debug_rdata_o       ( debug_rdata_o  ),
      .debug_halted_o      ( debug_halted_o ),
      .debug_halt_i        ( 1'b0           ),	// Not used in single core
      .debug_resume_i      ( 1'b0           ),	// Not used in single core

      .fetch_enable_i      ( fetch_enable_i ),
      .core_busy_o         ( core_busy_o    ),

      .ext_perf_counters_i (                )
      );

   // Instantiate the memory

   ram
     #(
       .ADDR_WIDTH (ADDR_WIDTH - 2)
       )
   ram_i
     (
      .clk            ( clk_i        ),

      .instr_req_i    ( instr_req    ),
      .instr_addr_i   ( instr_addr   ),
      .instr_rdata_o  ( instr_rdata  ),
      .instr_rvalid_o ( instr_rvalid ),
      .instr_gnt_o    ( instr_gnt    ),

      .data_req_i     ( mem_req     ),
      .data_addr_i    ( mem_addr[21:0]),
      .data_we_i      ( mem_we      ),
      .data_be_i      ( mem_be      ),
      .data_wdata_i   ( mem_wdata   ),
      .data_rdata_o   ( mem_rdata   ),
      .data_rvalid_o  ( mem_rvalid  ),
      .data_gnt_o     ( mem_gnt     )
      );
    
    Cache_top #(4, 32768, 16, 32, 32)
    
    cache
        (
            //clock and reset signals
            .clock(clk_i),
            .rst(rstn_i), 
            
            //signals to cache controller
            .data_req_i     ( data_req          ),
            .data_addr_i    ( {10'd0,data_addr} ),
            .data_we_i      ( data_we           ),
            .data_be_i      ( data_be           ),
            .data_wdata_i   ( data_wdata        ),
            .data_gnt_o     ( data_gnt          ),
            .data_rdata_o   ( data_rdata        ),
            .data_rvalid_o  ( data_rvalid       ),
            
            //inputs from main memory
            .mem_rdata      ( mem_rdata         ),
            .mem_rvalid     ( mem_rvalid        ),
            .mem_gnt        ( mem_gnt           ),
            
            //outputs from main memory
            .mem_req        ( mem_req           ),
            .mem_addr       ( mem_addr          ),
            .mem_we         ( mem_we            ),
            .mem_be         ( mem_be            ),
            .mem_wdata      ( mem_wdata         )
        );
    
     //for test purposes
     assign lsu_req = data_req;                                
     assign lsu_addr = data_addr;            
     assign lsu_we = data_we;                                  
     assign lsu_be = data_be;                            
     assign lsu_wdata = data_wdata;           

     assign lsu_rdata = data_rdata;      
     assign lsu_rvalid = data_rvalid;                        
     assign lsu_gnt = data_gnt;                         

     
     assign memory_rdata = mem_rdata;         
     assign memory_rvalid = mem_rvalid;                               
     assign memory_gnt = mem_gnt;                                  

     
     assign memory_req = mem_req;                           
     assign memory_addr = mem_addr;      
     assign memory_we = mem_we;                          
     assign memory_be = mem_be;                      
     assign memory_wdata = mem_wdata;      
    
endmodule	// top
