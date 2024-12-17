`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCDC
// Engineer: Maaz Ullah
// 
//////////////////////////////////////////////////////////////////////////////////


module cache_tb;

    logic clock;
    logic rst;
    logic [31:0] data_addr_i;
    logic data_w_en;
    logic [3:0] data_be_i;
    logic [31:0] data_wdata_i;     
    logic [31:0] data_rdata_o;
    logic hit;
    logic miss;
    
    Cache_top #(4,32768,16) DUT(.clock(clock),
                                .rst(rst),
                                .data_addr_i(data_addr_i),
                                .data_w_en(data_w_en),
                                .data_wdata_i(data_wdata_i),
                                .data_be_i(data_be_i),
                                .data_rdata_o(data_rdata_o),
                                .hit(hit),
                                .miss(miss) 
                                );
    
    always begin 
        clock = ~clock;
        #5;
    end 
    
    initial 
        clock = 1'b0;
    
    
    initial begin
        rst = 0; #10;
        rst = 1; #10 rst = 0; #10; 
        
        data_addr_i = 32'habc12400; data_w_en = 1; data_be_i = 1; data_wdata_i = 24; #10;
        data_addr_i = 32'hbbc12400; data_w_en = 1; data_be_i = 1; data_wdata_i = 24; #10;
        data_addr_i = 32'hcbc12400; data_w_en = 1; data_be_i = 1; data_wdata_i = 24; #10;       
        data_addr_i = 32'hdbc12400; data_w_en = 1; data_be_i = 1; data_wdata_i = 24; #10;

        
        data_addr_i = 32'habc12400; data_w_en = 1; data_be_i = 1; data_wdata_i = 24; #10;
        data_addr_i = 32'hab226700; data_w_en = 1; data_wdata_i = 24; #10;
        data_addr_i = 32'habc12400; data_w_en = 0; #10;
        data_addr_i = 32'haaaaaaaa; data_w_en = 0; #10;
        data_addr_i = 32'habc12400; data_w_en = 1; data_be_i = 2; data_wdata_i = 44; #10;
        data_addr_i = 32'habc12400; data_w_en = 0; #10;
        data_addr_i = 32'hab222400; data_w_en = 1; data_be_i = 1; data_wdata_i = 56; #10;
        data_addr_i = 32'hafc12400; data_w_en = 1; data_be_i = 1; data_wdata_i = 12; #10;
        data_addr_i = 32'hafc12400; data_w_en = 0; #10;
        //data_addr_i = 32'hafc12400; data_w_en = 0;  #10;
        data_addr_i = 32'hab222400; data_w_en = 0; #10;    
        data_addr_i = 32'habc12400; data_w_en = 0; #10;  
        data_addr_i = 32'haaa12400; data_w_en = 0; #10;
        data_addr_i = 32'habc12400; data_w_en = 1; data_wdata_i = 100; #10;
        data_addr_i = 32'habc12400; data_w_en = 0; #10;     
    end 
endmodule
