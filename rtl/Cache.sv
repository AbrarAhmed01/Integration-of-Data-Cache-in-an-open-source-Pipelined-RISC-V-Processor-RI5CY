`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2024 10:47:47 AM
// Design Name: 
// Module Name: Cache
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


//The parameters are all in bytes
module Cache #(parameter associativity = 4,
               parameter cache_size = 32768,
               parameter block_size = 16,
               parameter addr_width = 32,
               parameter data_width = 32 )
   ( 
    //Input signals 
    input clock,
    input rst,
    input [addr_width-1:0] data_addr_i,
    input data_w_en,
    input [3:0] data_be_i,
    input [data_width-1:0] data_wdata_i,
    input [1:0] LRU_select,     
    output logic [data_width-1:0] data_rdata_o,
    output logic hit,
    output logic miss,
    output logic [1:0] current_way      
    );
    
    /*
    -----------------------------------------------------------------------------------
                            Calculating Tag, index and offset bits
    -----------------------------------------------------------------------------------
    */
    
    //Finding the bits of the tag, index and offset
    localparam int bytes_offset_bits = $clog2(block_size);
    localparam int word_offset_bits = bytes_offset_bits >> 1;
    localparam int cache_size_bits = $clog2(cache_size);
    localparam int associativity_in_bits = $clog2(associativity);
    
    localparam int index_bits = (cache_size_bits - bytes_offset_bits) - associativity_in_bits;
    localparam int tag_bits = addr_width - bytes_offset_bits - index_bits;     
    
    //Finding the total number of sets 
    localparam int total_sets = cache_size / (block_size * associativity);
    
    //Final values of the index, tag and offset
    logic [bytes_offset_bits-1:0] bytes_offset;
    logic [word_offset_bits-1:0] word_offset;
    logic [index_bits-1:0] sets_num;
    logic [tag_bits-1:0] tag_bits_num;
    
    //Assigning the values for the offset, index and tags 
    assign bytes_offset = data_addr_i[bytes_offset_bits-1:0];
    assign sets_num = data_addr_i[(bytes_offset_bits+index_bits)-1:bytes_offset_bits];
    assign tag_bits_num = data_addr_i[addr_width -1:index_bits+bytes_offset_bits];    
    assign word_offset = data_addr_i[bytes_offset_bits-1:word_offset_bits];
    
    //Creating the Cache using mutiple arrays for tag, data and valid bit 
    logic [tag_bits-1:0] cache_tag [0:total_sets-1][0:associativity-1]; //Cache tag bits for each entry 
    logic [127:0] cache_data [0:total_sets-1][0:associativity-1]; //Cache data for each entry
    logic cache_valid [0:total_sets-1][0:associativity-1];  // Valid bit for each cache entry
    
    //The hit found for terminating the loop
    logic hit_found_write;
    logic hit_found_read;
    
    
    /*
    ------------------------------------------------------------------------------------------
                                        Writing To Cache                     
    ------------------------------------------------------------------------------------------
    */   
        
    always_ff @(posedge clock) begin
        hit = 0; // reset hit flag
        miss = 0; // Assume miss until a hit is found 
        hit_found_write = 0;
        hit_found_read = 0;
        // Cache write logic
        if (data_w_en) begin
            //---------------------------Updating the cache if hit ----------------------------
            for(int i = 0; i < associativity; i++) begin 
                if((cache_valid[sets_num][i] && (cache_tag[sets_num][i] == tag_bits_num)) && !hit_found_write) begin
                    hit = 1;
                    miss = 0;
                    hit_found_write = 1;
                    current_way <=  i;
                    //found1 <= found1 + 1;
                    // Storing the value in cache 
                    cache_tag[sets_num][i] <= tag_bits_num; //cache settings the tag in the cache
                    cache_valid[sets_num][i] <= 1; //The data is entered so the value is valid
            
                    case(word_offset)
                    //Writing the Value of cache for the word 0          
                        2'b00: begin
                            if(data_be_i[0]) 
                                cache_data[sets_num][i][7:0] <= data_wdata_i[7:0]; //Writing the data in the cache         
                            if(data_be_i[1])
                                cache_data[sets_num][i][15:8] <= data_wdata_i[15:8]; //Writing the data in the cache
                            if(data_be_i[2])
                                cache_data[sets_num][i][23:16] <= data_wdata_i[23:16]; //Writing the data in the cache
                            if(data_be_i[3])                                    
                                cache_data[sets_num][i][31:24] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end
                    
                        //Writing the Value of cache for the word 1            
                        2'b01: begin  
                            if(data_be_i[0]) 
                                cache_data[sets_num][i][39:32] <= data_wdata_i[7:0]; //Writing the data in the cache
                            if(data_be_i[1])
                                cache_data[sets_num][i][47:40] <= data_wdata_i[15:8]; //Writing the data in the cache
                            if(data_be_i[2])
                                cache_data[sets_num][i][55:48] <= data_wdata_i[23:16]; //Writing the data in the cache
                            if(data_be_i[3])
                                cache_data[sets_num][i][63:56] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end 
                
                        //Writing the value of cache for word 2 
                        2'b10: begin 
                            if(data_be_i[0]) 
                                cache_data[sets_num][i][71:64] <= data_wdata_i[7:0]; //Writing the data in the cache
                            if(data_be_i[1])
                                cache_data[sets_num][i][79:72] <= data_wdata_i[15:8]; //Writing the data in the cache
                            if(data_be_i[2])
                                cache_data[sets_num][i][87:80] <= data_wdata_i[23:16]; //Writing the data in the cache
                            if(data_be_i[3])
                                cache_data[sets_num][i][95:88] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end
                
                        //Writing the value of cache for word 3
                        2'b11: begin
                            if(data_be_i[0]) 
                                cache_data[sets_num][i][103:96] <= data_wdata_i[7:0]; //Writing the data in the cache
                            if(data_be_i[1])
                                cache_data[sets_num][i][111:104] <= data_wdata_i[15:8]; //Writing the data in the cache
                            if(data_be_i[2])
                                cache_data[sets_num][i][119:112] <= data_wdata_i[23:16]; //Writing the data in the cache
                            if(data_be_i[3])
                                cache_data[sets_num][i][127:120] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end
                    endcase
                end
                //Miss is checking in the another condition
                else 
                    miss = 0;
                    
                if (!hit_found_write) 
                    miss = 1;
                else 
                    miss = 0;
            end
                
            //IF the tag is not in the cache 
            //To replace all 4 words from the memory
            if(miss) begin 
                miss = 1;
                hit = 0;
                current_way = LRU_select;
                //hit_found_write <= 0;
                cache_data[sets_num][LRU_select] <= 0;
                cache_tag[sets_num][LRU_select] <= tag_bits_num; //cache settings the tag in the cache
                cache_valid[sets_num][LRU_select] <= 1; //The data is entered so the value is valid
                case(word_offset)
                    //Writing the Value of cache for the word 0          
                    2'b00: begin
                        if(data_be_i[0]) 
                            cache_data[sets_num][LRU_select][7:0] <= data_wdata_i[7:0]; //Writing the data in the cache         
                        if(data_be_i[1])
                            cache_data[sets_num][LRU_select][15:8] <= data_wdata_i[15:8]; //Writing the data in the cache
                        if(data_be_i[2])
                            cache_data[sets_num][LRU_select][23:16] <= data_wdata_i[23:16]; //Writing the data in the cache
                        if(data_be_i[3])                                    
                            cache_data[sets_num][LRU_select][31:24] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end
                    
                        //Writing the Value of cache for the word 1            
                        2'b01: begin  
                            if(data_be_i[0]) 
                                cache_data[sets_num][LRU_select][39:32] <= data_wdata_i[7:0]; //Writing the data in the cache
                            if(data_be_i[1])
                                cache_data[sets_num][LRU_select][47:40] <= data_wdata_i[15:8]; //Writing the data in the cache
                            if(data_be_i[2])
                                cache_data[sets_num][LRU_select][55:48] <= data_wdata_i[23:16]; //Writing the data in the cache
                            if(data_be_i[3])
                                cache_data[sets_num][LRU_select][63:56] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end 
                
                        //Writing the value of cache for word 2 
                        2'b10: begin 
                            if(data_be_i[0]) 
                                cache_data[sets_num][LRU_select][71:64] <= data_wdata_i[7:0]; //Writing the data in the cache
                            if(data_be_i[1])
                                cache_data[sets_num][LRU_select][79:72] <= data_wdata_i[15:8]; //Writing the data in the cache
                            if(data_be_i[2])
                                cache_data[sets_num][LRU_select][87:80] <= data_wdata_i[23:16]; //Writing the data in the cache
                            if(data_be_i[3])
                                cache_data[sets_num][LRU_select][95:88] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end
                
                        //Writing the value of cache for word 3
                        2'b11: begin 
                            if(data_be_i[0]) 
                                cache_data[sets_num][LRU_select][103:96] <= data_wdata_i[7:0]; //Writing the data in the cache
                            if(data_be_i[1])
                                cache_data[sets_num][LRU_select][111:104] <= data_wdata_i[15:8]; //Writing the data in the cache
                            if(data_be_i[2])
                                cache_data[sets_num][LRU_select][119:112] <= data_wdata_i[23:16]; //Writing the data in the cache
                            if(data_be_i[3])
                                cache_data[sets_num][LRU_select][127:120] <= data_wdata_i[31:24]; //Writing the data in the cache
                        end
                endcase                   
            end                        
        end
        
        /*
        ------------------------------------------------------------------------------------------
                                        Reading From Cache                     
        ------------------------------------------------------------------------------------------
        */
        
        
        else begin
            hit = 0;
            miss = 0;        
            // Reading from Cache 
            for (int i = 0; i < associativity; i++) begin //Loop for comparing the values of the tag
                if ((cache_valid[sets_num][i] && (cache_tag[sets_num][i] == tag_bits_num)) && !hit_found_read) begin
                    hit = 1;
                    miss = 0;
                    hit_found_read = 1;
                    current_way <= i;
                    // Selecting the right data based on byte enable (data_be_i)
                    case(word_offset)
                        2'b00: data_rdata_o <= cache_data[sets_num][i][31:0]; // selecting Word 0
                        2'b01: data_rdata_o <= cache_data[sets_num][i][63:32]; // selecting Word 1
                        2'b10: data_rdata_o <= cache_data[sets_num][i][95:64]; // selecting Word 2
                        2'b11: data_rdata_o <= cache_data[sets_num][i][127:96]; // selecting Word 3
                        default: data_rdata_o <= cache_data[sets_num][i][31:0]; // selecting the degfault to first word 
                    endcase
                end
                //If hit is not found
                /*
                else if(!hit_found_read) begin
                    miss = 1;
                    hit = 0;
                    data_rdata_o = 0;
                end
                */
                else 
                    miss <= 0;
            end
            
            if (!hit_found_read)
            begin
                miss = 1;
            end                  
            else 
            begin
                miss = 0;
            end
        end
    end
endmodule