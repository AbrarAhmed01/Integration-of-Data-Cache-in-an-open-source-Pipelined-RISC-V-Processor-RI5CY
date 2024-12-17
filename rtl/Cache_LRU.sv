`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 11:38:53 AM
// Design Name: 
// Module Name: Cache_LRU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//It is parameterized with cache size and addr_width
//It is not parameterized with respect to associativity 
module Cache_LRU #(parameter associativity = 4,
                   parameter cache_size = 32768,
                   parameter block_size = 16,
                   parameter addr_width = 32,
                   parameter data_width = 32)
                  (
                   input [addr_width-1:0] addr_i,
                   input [1:0] current_way,  
                   input clock,
                   input rst,
                   input hit, 
                   input miss,
                   output logic [1:0] LRU_select
                  );
    
    // Calculating the index and the total sets of the cache
    localparam int cache_size_bits = $clog2(cache_size);
    localparam int bytes_offset_bits = $clog2(block_size);          
    localparam int associativity_in_bits = $clog2(associativity);
    localparam int total_sets = cache_size / (block_size * associativity);
    localparam int index_bits = (cache_size_bits - bytes_offset_bits) - associativity_in_bits;
    
    logic [index_bits-1:0] sets_num;
    
    assign sets_num = addr_i[(bytes_offset_bits+index_bits)-1:bytes_offset_bits];
    
    // LRU array: Stores the order of used cache lines per set
    logic [1:0] lru [0:total_sets-1][0:associativity-1]; 
    logic shifting_done; //If the shifting is performed than we can provide output
    // Reset and LRU updating logic
    always_ff @(negedge clock or negedge rst) begin 
        if (!rst) begin
            // Reset all LRU entries for each set
            for (int i = 0; i < total_sets; i++) begin 
                lru[i][0] <= 0;
                lru[i][1] <= 1;
                lru[i][2] <= 2;
                lru[i][3] <= 3;
            end
            shifting_done <= 0;
        end
        else begin
            // If there's a hit or miss, update the LRU
            if (hit || miss) begin 
                // Moving the current way to the most recently used position (last)
                shifting_done = 0;
                for(int i = 0; i < associativity; i++) begin //Loop is use for searching the value in the array
                    if (lru[sets_num][i] == current_way) begin
                        //shifting according to way 0
                        if (!i) begin
                            lru[sets_num][3] <= current_way;
                            lru[sets_num][0] <= lru[sets_num][1];
                            lru[sets_num][1] <= lru[sets_num][2];
                            lru[sets_num][2] <= lru[sets_num][3];
                            shifting_done <= 1;
                        end
                        //shifting according to way 1
                        else if (i == 1) begin 
                            lru[sets_num][3] <= current_way;
                            lru[sets_num][0] <= lru[sets_num][0];
                            lru[sets_num][1] <= lru[sets_num][2];
                            lru[sets_num][2] <= lru[sets_num][3];
                            shifting_done <= 1; 
                        end
                        //shifting according to way 2
                        else if (i == 2) begin 
                            lru[sets_num][3] <= current_way;
                            lru[sets_num][0] <= lru[sets_num][0];
                            lru[sets_num][1] <= lru[sets_num][1];
                            lru[sets_num][2] <= lru[sets_num][3];
                            shifting_done <= 1; 
                        end
                        //shifting according to way 3
                        else begin
                            lru[sets_num][3] <= current_way;
                            lru[sets_num][0] <= lru[sets_num][0];
                            lru[sets_num][1] <= lru[sets_num][1];
                            lru[sets_num][2] <= lru[sets_num][2];
                            shifting_done <= 1;
                        end           
                    end
                end  
            end
            else begin
                 //If no hit or miss, just return the LRU values
                 //Sifiting is not performed so it will be zero
                 shifting_done <= 0;   
                 lru[sets_num][3] <= lru[sets_num][3];
                 lru[sets_num][0] <= lru[sets_num][0];
                 lru[sets_num][1] <= lru[sets_num][1];
                 lru[sets_num][2] <= lru[sets_num][2];
            end
        end
    end 
    
    //Checking if the shifting is performed
    always_ff @(posedge shifting_done, negedge rst) begin
        if (!rst)
            LRU_select = 0;
        else 
            LRU_select = lru[sets_num][0];
    end
                       
endmodule
