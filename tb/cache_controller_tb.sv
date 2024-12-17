`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCDC
// Engineer: Abrar Ahmed
//////////////////////////////////////////////////////////////////////////////////


module cache_controller_tb
    #(
        parameter ADDR_WIDTH = 22,
        parameter DATA_WIDTH = 32)();
    
    logic clk;
	logic reset;
    
    //inputs from LOAD STORE UNIT
    logic lsu_req;
    logic [ADDR_WIDTH - 1: 0] lsu_addr;
    logic lsu_we;
    logic [3:0] lsu_be;
    logic [DATA_WIDTH - 1: 0]lsu_wdata;
        
    //outputs to LOAD STORE UNIT
    logic [DATA_WIDTH - 1: 0]lsu_rdata;
    logic lsu_rvalid;
    logic lsu_gnt;
        
    //inputs from cache block
    logic [DATA_WIDTH - 1: 0] cache_rdata;
    logic cache_hit;
    logic cache_miss;
        
    //outputs from cache block
    logic [ADDR_WIDTH - 1: 0] cache_addr;
    logic cache_we;
    logic [3:0] cache_be;
    logic [DATA_WIDTH - 1: 0] cache_wdata;
        
        
    //inputs from main memory
    logic [DATA_WIDTH - 1: 0] mem_rdata;
    logic mem_rvalid;
    logic mem_gnt;
        
    //outputs from main memory
    logic mem_req;
    logic [ADDR_WIDTH - 1: 0] mem_addr;
    logic mem_we;
    logic [3:0] mem_be;
    logic [DATA_WIDTH - 1: 0] mem_wdata;
    
    //main memory output
    logic [DATA_WIDTH - 1: 0] instr_rdata_o;
    logic instr_rvalid_o;
    logic instr_gnt_o;
    
    cache_controller #(ADDR_WIDTH, DATA_WIDTH) DUT
    (
        //input clock and reset signals
        .clk(clk),
        .reset(reset),
        
        //inputs from LOAD STORE UNIT
        .lsu_req(lsu_req),
        .lsu_addr(lsu_addr),
        .lsu_we(lsu_we),
        .lsu_be(lsu_be),
        .lsu_wdata(lsu_wdata),
        
        //outputs to LOAD STORE UNIT
        .lsu_rdata(lsu_rdata),
        .lsu_rvalid(lsu_rvalid),
        .lsu_gnt(lsu_gnt),
        
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
    
    ram #(ADDR_WIDTH) memory(
    // Clock
    .clk(clk),

    .instr_req_i(1'b0),
    .instr_addr_i(0),
    .instr_rdata_o(instr_rdata_o),
    .instr_rvalid_o(instr_rvalid_o),
    .instr_gnt_o(instr_gnt_o),

    .data_req_i(mem_req),
    .data_addr_i(mem_addr),
    .data_we_i(mem_we),
    .data_be_i(mem_be),
    .data_wdata_i(mem_wdata),
    .data_rdata_o(mem_rdata),
    .data_rvalid_o(mem_rvalid),
    .data_gnt_o(mem_gnt)
  );
  
    Cache_top #(4, 32768, 16, 32, 32) cache (
        .clock(clk),
        .rst(reset), 
        .data_addr_i({10'd0,cache_addr}),
        .data_w_en(cache_we),
        .data_be_i(cache_be),
        .data_wdata_i(cache_wdata),
        .data_rdata_o(cache_rdata),
        .hit(cache_hit),
        .miss(cache_miss)
    );
    
    always
    begin 
        clk = ~clk;
        #5;
    end 
    
    initial 
    begin
        clk = 1'b0;    
    end
    
    initial
    begin
        reset = 1'b1; #10;
    	reset = 1'b0; #10;
    	reset = 1'b1; #15;

        @(posedge clk);
    	lsu_req = 1;
    	lsu_addr = 32'h80;
    	lsu_we = 1;
    	lsu_be = 4'b1111;
    	lsu_wdata = 32'hffffffff;
    	
    	#100;
    	$finish();
    end
    
endmodule
