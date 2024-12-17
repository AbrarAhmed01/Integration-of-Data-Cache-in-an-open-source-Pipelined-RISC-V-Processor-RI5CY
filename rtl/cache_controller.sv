`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NCDC
// Engineer: Abrar Ahmed
// 
//////////////////////////////////////////////////////////////////////////////////


module cache_controller
    #(
        parameter ADDR_WIDTH = 32,                      //Address width parameter
        parameter DATA_WIDTH = 32)                      //Data width parameter
    (
        //input clock and reset signals
        input clk,
        input reset,
        
        //inputs from LOAD STORE UNIT
        input lsu_req,                                  //LOAD STORE UNIT Request Signal
        input [ADDR_WIDTH - 1: 0] lsu_addr,             //Address signals from LOAD STORE UNIT
        input lsu_we,                                   //Read write enable from LOAD STORE UNIT
        input [3:0] lsu_be,                             //Byte enable bits from LOAD STORE UNIT
        input [DATA_WIDTH - 1: 0]lsu_wdata,             //Write data from LOAD STORE UNIT
        
        //outputs to LOAD STORE UNIT
        output logic [DATA_WIDTH - 1: 0]lsu_rdata,      //Data read to LOAD STORE UNIT
        output logic lsu_rvalid,                        //Valid signal to LOAD STORE UNIT
        output logic lsu_gnt,                           //Request granted signal to LOAD STORE UNIT
        
        //inputs from cache block
        input [DATA_WIDTH - 1: 0] cache_rdata,          //Data read from cache
        input cache_hit,                                //Cache hit signal
        input cache_miss,                               //Cache miss signal
        
        //outputs from cache block
        output logic [ADDR_WIDTH - 1: 0] cache_addr,    //Address signals to cache
        output logic cache_we,                          //Read write enable to cache
        output logic [3:0] cache_be,                    //Byte enable bits to cache
        output logic [DATA_WIDTH - 1: 0] cache_wdata,   //Write data to cache
        
        
        //inputs from main memory
        input [DATA_WIDTH - 1: 0]mem_rdata,             //Data read from main memory
        input mem_rvalid,                               //Valid signal from main memory
        input mem_gnt,                                  //Request granted signal from main memory
        
        //outputs from main memory
        output logic mem_req,                           //Request signal to main memory
        output logic [ADDR_WIDTH - 1: 0] mem_addr,      //Address signals to main memory
        output logic mem_we,                            //Read write enable to main memory
        output logic [3:0] mem_be,                      //Byte enable bits to main memory
        output logic [DATA_WIDTH - 1: 0] mem_wdata      //Write data to main memory
    );
    
    //enum data type for FSM
    enum logic [2:0] {IDLE, HIT_CHECK, MISS, FETCH_1, FETCH_2, FETCH_3, FETCH_4} cs_control, ns_control;
	
	logic [ADDR_WIDTH - 1: 0] addr;
	logic [DATA_WIDTH - 1: 0] data;
	logic rw_en;
	logic [3:0] byte_en;
	
	//store the inputs from the LOAD STORE UNIT
	always@(posedge clk)
	begin
	   if(!reset)
	   begin
	       addr <= 0;
	       data <= 0;
	       rw_en <= 0;
	       byte_en <= 0;
	   end
	   
	   else if(lsu_req == 1'b1 && (cs_control == IDLE || cs_control == HIT_CHECK))
	   begin
	       addr <= lsu_addr;
	       data <= lsu_wdata;
	       rw_en <= lsu_we;
	       byte_en <= lsu_be;
	   end
	end
	
	/////////////
	/////FSM/////
	/////////////
	
	//Sequential Part of FSM
	always_ff @(posedge clk or negedge reset)
	begin
		if(!reset)
		begin
			cs_control <= IDLE;
		end
		
		else
		begin
			cs_control <= ns_control;
		end
	
	end
    
    
	//Combinational Part od FSM
	
	always_comb
	begin
		ns_control = cs_control;
		
		case(cs_control)
		  IDLE:
		  begin
		      lsu_rvalid = 1'b0;
		      mem_req = 1'b0;
		      if(lsu_req)
		      begin
		          lsu_gnt = 1'b1;
		          cache_addr = addr;
		          cache_wdata = data;
		          cache_we = rw_en;
		          cache_be = byte_en;
		          ns_control = HIT_CHECK;
		      end
		      
		      else
		      begin
		          lsu_gnt = 1'b0;
		          cache_addr = addr;
		          cache_wdata = data;
		          cache_we = 1'b0;
		          cache_be = 4'b0000;
		          ns_control = IDLE;
		      end
		  end
		  
		  HIT_CHECK:
		  begin
		      mem_addr = addr;
		      mem_wdata = data;
		      mem_we = rw_en;
		      mem_be = byte_en;
		      
		      cache_addr = addr;
              cache_wdata = data;
              cache_we = rw_en;
              cache_be = byte_en;
		      
		      //read cases
		      if(rw_en == 1'b0 && cache_hit == 1'b1 && cache_miss == 1'b0)
		      begin
		          lsu_rvalid = 1'b1;
		          lsu_rdata = cache_rdata;
		          mem_req = 1'b0;
		          
		          if(lsu_req)
		          begin
		              lsu_gnt = 1'b1;
		              cache_addr = addr;
		              cache_wdata = data;
		              cache_we = rw_en;
		              cache_be = byte_en;
                      ns_control = HIT_CHECK;
		          end
		          
		          else
		          begin
		              lsu_gnt = 1'b0;
                      cache_addr = addr;
                      cache_wdata = data;
                      cache_we = 1'b0;
                      cache_be = 4'b0000;
		              ns_control = IDLE;
		              
                  end
		      end
		      //in case of miss
		      else if(rw_en == 1'b0 && cache_hit == 1'b0 && cache_miss == 1'b1)
		      begin
		          lsu_rvalid = 1'b0;
		          lsu_rdata = 0;
		          
		          mem_req = 1'b1;
		          lsu_gnt = 1'b0;
                  cache_addr = addr;
                  cache_wdata = data;
                  cache_we = rw_en;
                  cache_be = byte_en;
		          
		          if(mem_gnt == 1'b1)
		          begin
		              ns_control = MISS;
                  end
                  
                  else
                  begin
                      ns_control = HIT_CHECK;
                  end
		      end
		      
		      //write cases
		      else if(rw_en == 1'b1 && cache_hit == 1'b1 && cache_miss == 1'b0)
		      begin
		          lsu_rvalid = 1'b1;
		          lsu_rdata = cache_rdata;
		          mem_req = 1'b1;
		          
		          if(lsu_req)
		          begin
		              lsu_gnt = 1'b1;
		              cache_addr = addr;
		              cache_wdata = data;
		              cache_we = rw_en;
		              cache_be = byte_en;
                      ns_control = HIT_CHECK;
		          end
		          
		          else
		          begin
		              lsu_gnt = 1'b0;
                      cache_addr = addr;
                      cache_wdata = data;
                      cache_we = 1'b0;
                      cache_be = 4'b0000;
		              ns_control = IDLE;
		              
                  end
		          
		      end
		      
		      //in case of write miss
		      else if(rw_en == 1'b1 && cache_hit == 1'b0 && cache_miss == 1'b1)
		      begin
		          lsu_rvalid = 1'b0;
		          lsu_rdata = 0;
		          lsu_gnt = 1'b0;
                  cache_addr = addr;
                  cache_wdata = data;
                  cache_we = rw_en;
                  cache_be = byte_en;
		          
		          mem_req = 1'b1;
		          
		          if(mem_gnt == 1'b1)
		          begin
		              ns_control = MISS;
                  end
                  
                  else
                  begin
                      ns_control = HIT_CHECK;
                  end
                  
		      end
		      
		      else
		      begin
		          lsu_gnt = 1'b0;
                  cache_addr = addr;
                  cache_wdata = data;
                  cache_we = 1'b0;
                  cache_be = 4'b0000;
                  
		          lsu_rvalid = 1'b0;
		          mem_req = 1'b0;
		          lsu_rdata = 0;
		          ns_control = HIT_CHECK;
		      end
		  end
		  
		  //1st word read or write
		  MISS:
		  begin
		      lsu_gnt = 1'b0;
		      if(mem_rvalid == 1'b1)
		      begin
		          if(rw_en == 1)
		          begin
		              lsu_rvalid = 1'b1;
		              lsu_rdata = mem_rdata;
		              
		              //do nothing to cache
                      cache_addr = addr;
                      cache_wdata = data;
                      cache_we = 1'b0;
                      cache_be = 4'b0000;
                     
                      //fetch 1st word from memory
                      mem_req = 1'b1;
                      mem_addr = addr;
                      mem_wdata = data;
                      mem_we = 1'b0;
                      mem_be = 4'b1111;
		              
		              if(mem_gnt == 1'b1)
		              begin
		                  ns_control = FETCH_1;
		              end
		              
		              else
		              begin
		                  ns_control = MISS;
		              end
		              
		          end
		          
		          else
		          begin
		              lsu_rvalid = 1'b1;
		              lsu_rdata = mem_rdata;
		              
		              //writting fetch data to cache
		              cache_addr = addr;
		              cache_we = 1'b1;
		              cache_wdata = mem_rdata;
		              cache_be = 4'b1111;
		              
		              //fetch 2nd word from memory
		              mem_req = 1'b1;
		              mem_addr = addr + 4;
                      mem_wdata = data;
                      mem_we = 1'b0;
                      mem_be = 4'b1111;
                      
		              if(mem_gnt == 1'b1)
		              begin
		                  ns_control = FETCH_2;
		              end
		              
		              else
		              begin
		                  ns_control = MISS;
		              end
		              
		          end
		      end
		      
		      else
		      begin
                //do nothing to cache
                cache_addr = addr;
                cache_wdata = data;
                cache_we = 1'b0;
                cache_be = 4'b0000;
                
                mem_req = 1'b0;
                mem_addr = addr;
                mem_wdata = data;
                mem_we = 1'b0;
                mem_be = 4'b0000;
                
                lsu_rvalid = 1'b0;
                lsu_rdata = 0;
                ns_control = MISS;
		      end
		  end
		  
		  FETCH_1:
		  begin
             lsu_rvalid = 1'b0;
             lsu_rdata = 0;
		     
		     if(mem_rvalid == 1'b1)
		     begin
                
                //writting fetch data to cache
                  cache_addr = addr;
                  cache_we = 1'b1;
                  cache_wdata = mem_rdata;
                  cache_be = 4'b1111;
                  
                  //fetch 2nd word from memory
                  mem_req = 1'b1;
                  mem_addr = addr + 4;
                  mem_wdata = data;
                  mem_we = 1'b0;
                  mem_be = 4'b1111;
                  
                  if(mem_gnt == 1'b1)
                  begin
                      ns_control = FETCH_2;
                  end
                  
                  else
                  begin
                      ns_control = FETCH_1;
                  end
                
		     end
		     else
		     begin
                //do nothing to cache
                cache_addr = addr;
                cache_wdata = data;
                cache_we = 1'b0;
                cache_be = 4'b0000;
                
                mem_req = 1'b0;
                mem_addr = addr + 4;
                mem_wdata = data;
                mem_we = 1'b0;
                mem_be = 4'b0000;
		        ns_control = FETCH_1;
		     end
		  end
		  
		  //second fetch start
		  FETCH_2:
		  begin
             lsu_rvalid = 1'b0;
             lsu_rdata = 0;
		     
		     if(mem_rvalid == 1'b1)
		     begin
                
                //writting fetch data to cache
                  cache_addr = addr + 4;
                  cache_we = 1'b1;
                  cache_wdata = mem_rdata;
                  cache_be = 4'b1111;
                  
                  //fetch 3rd word from memory
                  mem_req = 1'b1;
                  mem_addr = addr + 8;
                  mem_wdata = data;
                  mem_we = 1'b0;
                  mem_be = 4'b1111;
                  
                  if(mem_gnt == 1'b1)
                  begin
                      ns_control = FETCH_3;
                  end
                  
                  else
                  begin
                      ns_control = FETCH_2;
                  end
                
		     end
		     else
		     begin
                //do nothing to cache
                cache_addr = addr + 4;
                cache_wdata = data;
                cache_we = 1'b0;
                cache_be = 4'b0000;
                
                mem_req = 1'b0;
                mem_addr = addr + 8;
                mem_wdata = data;
                mem_we = 1'b0;
                mem_be = 4'b0000;
		        ns_control = FETCH_2;
		     end
		  end
             
		  
		  //third word fetch start
		  FETCH_3:
		  begin
		  
		     if(mem_rvalid == 1'b1)
		      begin
                
                //writting fetch data to cache
                  cache_addr = addr + 8;
                  cache_we = 1'b1;
                  cache_wdata = mem_rdata;
                  cache_be = 4'b1111;
                  
                  //fetch 3rd word from memory
                  mem_req = 1'b1;
                  mem_addr = addr + 12;
                  mem_wdata = data;
                  mem_we = 1'b0;
                  mem_be = 4'b1111;
                  
                  if(mem_gnt == 1'b1)
                  begin
                      ns_control = FETCH_4;
                  end
                  
                  else
                  begin
                      ns_control = FETCH_3;
                  end
                
		     end
		     else
		     begin
                //do nothing to cache
                cache_addr = addr + 8;
                cache_wdata = data;
                cache_we = 1'b0;
                cache_be = 4'b0000;
                
                mem_req = 1'b0;
                mem_addr = addr + 12;
                mem_wdata = data;
                mem_we = 1'b0;
                mem_be = 4'b0000;
                
		        ns_control = FETCH_3;
		     end
		  end
		  
		  //fourth word fetch start
		  FETCH_4:
		  begin
             mem_req = 1'b0;
             mem_addr = addr + 12;
             mem_wdata = data;
             mem_we = 1'b0;
             mem_be = 4'b0000;
		     
		     if(mem_rvalid == 1'b1)
		     begin
                
                //writting fetch data to cache
                  cache_addr = addr + 12;
                  cache_we = 1'b1;
                  cache_wdata = mem_rdata;
                  cache_be = 4'b1111;
                  
                  ns_control = IDLE;
		     end
		     
		     else
		     begin
                //do nothing to cache
                cache_addr = addr + 12;
                cache_wdata = data;
                cache_we = 1'b0;
                cache_be = 4'b0000;
                
		        ns_control = FETCH_4;
		     end
		  end
		
		endcase
	end
    
endmodule
