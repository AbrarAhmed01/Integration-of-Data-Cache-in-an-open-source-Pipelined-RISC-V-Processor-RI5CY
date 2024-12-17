`timescale 1ns / 1ps
module LRU_tb;

    logic clock, rst;
    logic [31:0] addr_i;
    logic [1:0] current_way;
    logic [1:0] LRU_select;     
    logic hit;
    logic miss;
    
    Cache_LRU #(4,32768,16, 32, 32) DUT(
        .clock(clock), 
        .rst(rst),
        .addr_i(addr_i),
        .current_way(current_way),  
        .LRU_select(LRU_select),    
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
        rst = 1; #10 rst = 0;
        addr_i = 32'habc12400; current_way = 0; hit = 1; miss = 0;  #10;
        addr_i = 32'habc12400; current_way = LRU_select; hit = 1; miss = 0;  #10;
        addr_i = 32'habc12400; current_way = LRU_select; hit = 0; miss = 1;  #10;
        addr_i = 32'habc12400; current_way = 0; hit = 1; miss = 1;  #10;
        addr_i = 32'habc12400; current_way = 2; hit = 0; miss = 0;  #10;
        addr_i = 32'habc12400; current_way = 3; hit = 1; miss = 0;  #10;
        addr_i = 32'hafc12400; current_way = 1; hit = 0; miss = 1;  #10;
        addr_i = 32'haaaa0000; current_way = 2; hit = 1; miss = 1;  #10;
        addr_i = 32'haaaa0000; current_way = 3; hit = 1; miss = 0;  #10;
        addr_i = 32'haaaa0000; current_way = 1; hit = 1; miss = 0;  #10;    
        addr_i = 32'haaaa0000; current_way = 0; hit = 1; miss = 1;  #10;  
        addr_i = 32'haaaa0000; current_way = 3; hit = 1; miss = 1;  #10;
        addr_i = 32'haaaa0000; current_way = 1; hit = 1; miss = 0;  #10;
        addr_i = 32'haaaa0000; current_way = 3; hit = 1; miss = 0;  #10;   
        $finish;  
    end 
endmodule