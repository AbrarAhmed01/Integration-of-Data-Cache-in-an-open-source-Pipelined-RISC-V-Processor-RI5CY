`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCDC
// Engineer: Abrar Ahmed
//
//////////////////////////////////////////////////////////////////////////////////


module Cache_top #( parameter associativity = 4,
                    parameter cache_size = 32768,
                    parameter block_size = 16,
                    parameter addr_width = 32,
                    parameter data_width = 32 )
                  (
                    //clock and reset signals
                    input clock,
                    input rst, 
                    
                    //signals to cache controller
                    input data_req_i,
                    input [addr_width - 1:0] data_addr_i,
                    input data_we_i,
                    input [3:0] data_be_i,
                    input [data_width - 1:0] data_wdata_i,
                    output logic data_gnt_o,
                    output logic [data_width - 1:0] data_rdata_o,
                    output logic data_rvalid_o,
                    
                    //inputs from main memory
                    input [data_width - 1: 0]mem_rdata,             //Data read from main memory
                    input mem_rvalid,                               //Valid signal from main memory
                    input mem_gnt,                                  //Request granted signal from main memory
                    
                    //outputs from main memory
                    output logic mem_req,                           //Request signal to main memory
                    output logic [addr_width - 1: 0] mem_addr,      //Address signals to main memory
                    output logic mem_we,                            //Read write enable to main memory
                    output logic [3:0] mem_be,                      //Byte enable bits to main memory
                    output logic [data_width - 1: 0] mem_wdata      //Write data to main memory 
                    );
    
    //wires for interconnecting modules
    //signals for cache block
    logic [data_width - 1: 0] cache_rdata;
    logic cache_hit;
    logic cache_miss;
        
    //signals for cache block
    logic [addr_width - 1: 0] cache_addr;
    logic cache_we;
    logic [3:0] cache_be;
    logic [data_width - 1: 0] cache_wdata;
    
    //signals for LRU
    logic [1:0] current_way;
    logic [1:0] LRU_select;
    
    //Cache Controller instantiation
    cache_controller #(addr_width, data_width) controller
    (
        //input clock and reset signals
        .clk(clock),
        .reset(rst),
        
        //inputs from LOAD STORE UNIT
        .lsu_req(data_req_i),
        .lsu_addr(data_addr_i),
        .lsu_we(data_we_i),
        .lsu_be(data_be_i),
        .lsu_wdata(data_wdata_i),
        
        //outputs to LOAD STORE UNIT
        .lsu_rdata(data_rdata_o),
        .lsu_rvalid(data_rvalid_o),
        .lsu_gnt(data_gnt_o),
        
        //inputs from cache block
        .cache_rdata(cache_rdata),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        
        //outputs from cache block
        .cache_addr(cache_addr),
        .cache_we(cache_we),
        .cache_be(cache_be),
        .cache_wdata(cache_wdata),
        
        
        //inputs from main memory
        .mem_rdata(mem_rdata),
        .mem_rvalid(mem_rvalid),
        .mem_gnt(mem_gnt),
        
        //outputs from main memory
        .mem_req(mem_req),
        .mem_addr(mem_addr),
        .mem_we(mem_we),
        .mem_be(mem_be),
        .mem_wdata(mem_wdata)
    );
    
    //Cache Data Array instantiation
    Cache #(4,32768,16,32,32) cache( 
                                .clock(clock),
                                .rst(rst),
                                .data_addr_i(cache_addr),
                                .data_w_en(cache_we),
                                .data_be_i(cache_be),
                                .data_wdata_i(cache_wdata),
                                .LRU_select(LRU_select),     
                                .data_rdata_o(cache_rdata),
                                .hit(cache_hit),
                                .miss(cache_miss),
                                .current_way(current_way)      
                                );

    //Cache LRU module instantiation
    Cache_LRU #(4,32768,16,32,32) lru(
                                     .clock(clock),
                                     .rst(rst),
                                     .addr_i(cache_addr),
                                     .hit(cache_hit),
                                     .miss(cache_miss),
                                     .LRU_select(LRU_select),
                                     .current_way(current_way));
endmodule