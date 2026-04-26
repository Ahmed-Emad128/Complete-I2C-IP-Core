module i2c_top(
input clk,
input reset_n,
input start,
input  [6:0] m_target_addr,
input  [7:0] m_word_addr,  
input  [7:0] m_data_in,    
input  [6:0] s_own_addr, 
inout sda,
output busy
);

 wire scl;


 i2c_master  master(
 .clk(clk),
 .reset_n(reset_n),
 .start(start),
 .addr(m_target_addr),   
 .word_addr(m_word_addr),
 .data(m_data_in),       
 .scl(scl),          
 .sda(sda),          
 .busy(busy)
 );

 i2c_eeprom_slave eeprom_slave (
  .clk(clk),
 .reset_n(reset_n),
 .scl(scl),      
 .sda(sda),      
 .my_addr(s_own_addr)
 );
assign (pull1, pull0) sda = 1'b1;
 endmodule