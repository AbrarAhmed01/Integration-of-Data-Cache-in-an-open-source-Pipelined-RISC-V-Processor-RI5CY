`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCDC
// Engineer: Abrar Ahmed
//////////////////////////////////////////////////////////////////////////////////


module tb_top
    #(
        parameter INSTR_RDATA_WIDTH = 128,
        parameter ADDR_WIDTH = 22,		// Consistent with PicoRV32
        parameter BOOT_ADDR  = 'h00		// Consistent with Pulpino
    )();
    
    logic clk;
	logic reset;
	logic debug_gnt_o;
	logic debug_rvalid_o;
	logic [31:0] debug_rdata_o;
	logic debug_halted_o;
	logic core_busy_o;
	
    logic lsu_req;                                  //LOAD STORE UNIT Request Signal
    logic [ADDR_WIDTH - 1: 0] lsu_addr;             //Address signals from LOAD STORE UNIT
    logic lsu_we;                                   //Read write enable from LOAD STORE UNIT
    logic [3:0] lsu_be;                             //Byte enable bits from LOAD STORE UNIT
    logic [31:0]lsu_wdata;             //Write data from LOAD STORE UNIT

    
    logic [31:0]lsu_rdata;      //Data read to LOAD STORE UNIT
    logic lsu_rvalid;                        //Valid signal to LOAD STORE UNIT
    logic lsu_gnt;                           //Request granted signal to LOAD STORE UNIT

    logic [31:0]memory_rdata;             //Data read from main memory
    logic memory_rvalid;                               //Valid signal from main memory
    logic memory_gnt;                                  //Request granted signal from main memory

    logic memory_req;                           //Request signal to main memory
    logic [31: 0] memory_addr;      //Address signals to main memory
    logic memory_we;                            //Read write enable to main memory
    logic [3:0] memory_be;                      //Byte enable bits to main memory
    logic [31: 0] memory_wdata;      //Write data to main memory 
    
    int count_issue;
    int count_stalls;
    bit start;
    
    top #(INSTR_RDATA_WIDTH, ADDR_WIDTH, BOOT_ADDR) DUT_CORE ( 
        // Clock and Reset
        .clk_i(clk),
        .rstn_i(reset),
        
        // Interrupt inputs
        .irq_i(),            // level sensitive IR lines
        
        // Debug Interface
        .debug_req_i(0),
        .debug_gnt_o(debug_gnt_o),
        .debug_rvalid_o(debug_rvalid_o),
        .debug_addr_i(0),
        .debug_we_i(0),
        .debug_wdata_i(0),
        .debug_rdata_o(debug_rdata_o),
        .debug_halted_o(debug_halted_o),
        
        // CPU Control Signals
        .fetch_enable_i(1),
        .core_busy_o(core_busy_o),
        
        //signals of LOAD STORE UNIT
        .lsu_req(lsu_req),                                  //LOAD STORE UNIT Request Signal
        .lsu_addr(lsu_addr),             //Address signals from LOAD STORE UNIT
        .lsu_we(lsu_we),                                   //Read write enable from LOAD STORE UNIT
        .lsu_be(lsu_be),                             //Byte enable bits from LOAD STORE UNIT
        .lsu_wdata(lsu_wdata),             //Write data from LOAD STORE UNIT
         
        //signals of LOAD STORE UNIT
        .lsu_rdata(lsu_rdata),      //Data read to LOAD STORE UNIT
        .lsu_rvalid(lsu_rvalid),                        //Valid signal to LOAD STORE UNIT
        .lsu_gnt(lsu_gnt),                           //Request granted signal to LOAD STORE UNIT
        
        //signals of main memory
        .memory_rdata(memory_rdata),             //Data read from main memory
        .memory_rvalid(memory_rvalid),                               //Valid signal from main memory
        .memory_gnt(memory_gnt),                                  //Request granted signal from main memory
        
        //signals of main memory
        .memory_req(memory_req),                           //Request signal to main memory
        .memory_addr(memory_addr),      //Address signals to main memory
        .memory_we(memory_we),                            //Read write enable to main memory
        .memory_be(memory_be),                      //Byte enable bits to main memory
        .memory_wdata(memory_wdata)      //Write data to main memory 

    );
    
    always
    begin 
        clk = ~clk;
        #5;
    end
    
    initial 
    begin
        clk = 1'b0;
        count_issue = 0;
        count_stalls = 0;    
    end
    
    always@(posedge clk)
    begin
        if(lsu_gnt == 1)
        begin
            count_issue++;
            start = 1;
        end
        
        if(start == 1)
        begin
            count_stalls++;
        end
        
        if(lsu_rvalid == 1)
        begin
            start = 0;
        end
        
        $display("Number of issues: %0d", count_issue);
        $display("Number of stalls: %0d", count_stalls);
    end
    
    
    initial
    begin
        reset = 1'b1; #10;
    	reset = 1'b0; #10;
    	reset = 1'b1; #10;
        
        #10000;
        $finish(1);
    end

endmodule
