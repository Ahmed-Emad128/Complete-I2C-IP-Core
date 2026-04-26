`timescale 1ns / 1ps  
module tb_i2c;

 reg  clk;
 reg  reset_n;
 reg  start;
 reg  [6:0] m_target_addr;
 reg  [7:0] m_word_addr;
 reg  [7:0] m_data_in;
 reg  [6:0] s_own_addr; 
 wire  busy;

wire sda;


 i2c_top dut (
 .clk(clk),
 .reset_n(reset_n),
 .start(start),
 .m_target_addr(m_target_addr),
 .m_word_addr(m_word_addr),
 .m_data_in(m_data_in),
 .s_own_addr(s_own_addr),
 .busy(busy),
 .sda(sda)
    );

 always #10 clk = ~clk;

 initial begin
  clk     = 0;
  reset_n = 0;
  start   = 0;

 s_own_addr = 7'h5A; 

 m_target_addr = 7'h5A; 
  
  m_word_addr = 8'h05;
  m_data_in   = 8'hAA; 

  #40; 
  reset_n = 1;  
  #3200;

  $display("Time: %0t | Starting I2C Write Transaction...", $time);
  start = 1;
  wait (busy == 1);    
  start = 0;   
//  wait(busy == 1); 
//  wait(busy == 0); 
// 
//#100
#30000 
  $display("Time: %0t | Transaction Completed Successfully!", $time);
  
  $stop; 
    end

endmodule