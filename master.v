module i2c_master(
    input clk,
    input reset_n,
    input start,
    input [6:0] addr,      // Slave Address
    input [7:0] word_addr,  //Register Address
    input [7:0] data,       
    output reg scl,
    inout sda,
    output reg busy
);
     
 parameter CLK_DIV = 16;
 reg [3:0] clk_cnt;
 reg       tick; 

always @(posedge clk or negedge reset_n) begin
 if (!reset_n) begin
     clk_cnt <= 0;
     tick    <= 0;
 end else begin
     if (clk_cnt == CLK_DIV - 1) begin
      clk_cnt <= 0;
      tick    <= 1;
  end else begin
   clk_cnt <= clk_cnt + 1;
 tick    <= 0;
        end
    end
end
 reg sda_en;
 reg sda_out;
 reg [3:0] state;
 reg [3:0] bit_count;
 reg [7:0] tx_reg;
 
 reg [1:0] phase;
assign sda = (sda_en && (sda_out == 1'b0)) ? 1'b0 : 1'bz;

 localparam IDLE = 0,
 START     = 1,
 ADDR      = 2,                     
 ACK1      = 3,
 WORD_ADDR = 4,   
 ACK_WORD  = 5,   
 DATA      = 6,
 ACK2      = 7,
 STOP      = 8;
always @(posedge clk or negedge reset_n) begin 
 if (!reset_n) begin
     state     <= IDLE;
     scl       <= 1'b1;
     sda_out   <= 1'b1;
     sda_en    <= 1'b0; 
     busy      <= 1'b0;
     bit_count <= 0;
     phase     <= 0;
     tx_reg    <= 0;
    end    
    else if (tick) begin 
  case(state)
   IDLE: begin
       busy    <= 1'b0;
       scl     <= 1'b1;
       sda_en  <= 1'b1;
       sda_out <= 1'b1;
       if (start) begin
           state <= START;
           busy  <= 1'b1;
       end
      end
  START: begin
      sda_out <= 1'b0;
      state   <= ADDR;
      bit_count <= 7;
      tx_reg  <= {addr, 1'b0}; 
  end

  ADDR: begin
      if (phase == 0) begin
          scl <= 1'b0; 
          sda_out <= tx_reg[bit_count];
          phase <= 1;
      end else if (phase == 1) begin
          scl <= 1'b1; 
          phase <= 0;
          if (bit_count == 0) state <= ACK1;
          else bit_count <= bit_count - 1;
      end
  end

  ACK1: begin
      if (phase == 0) begin
          scl    <= 1'b0;
          sda_en <= 1'b0; 
          phase  <= 1;
      end else begin
          scl    <= 1'b1;
          phase  <= 0;
          state  <= WORD_ADDR;
          bit_count <= 7;
          tx_reg <= word_addr;
      end
  end

  WORD_ADDR: begin
      if (phase == 0) begin
          scl <= 1'b0; sda_en <= 1'b1;
          sda_out <= tx_reg[bit_count];
          phase <= 1;
      end else begin
          scl <= 1'b1;
          phase <= 0;
          if (bit_count == 0) state <= ACK_WORD;
          else bit_count <= bit_count - 1;
      end
  end

  ACK_WORD: begin
      if (phase == 0) begin
          scl <= 1'b0; sda_en <= 1'b0;
          phase <= 1;
      end else begin
          scl <= 1'b1;
          phase <= 0;
          state <= DATA;
          bit_count <= 7;
          tx_reg <= data;
      end
  end

  DATA: begin
      if (phase == 0) begin
          scl <= 1'b0; sda_en <= 1'b1;
          sda_out <= tx_reg[bit_count];
          phase <= 1;
      end else begin
          scl <= 1'b1;
          phase <= 0;
          if (bit_count == 0) state <= ACK2;
          else bit_count <= bit_count - 1;
      end
  end
  ACK2: begin
      if (phase == 0) begin
          scl <= 1'b0; sda_en <= 1'b0;
          phase <= 1;
      end else begin
          scl <= 1'b1;
          phase <= 0;
          state <= STOP;
      end
  end
  STOP: begin
      if (phase == 0) begin
          scl <= 1'b0;
          sda_en <= 1'b1;
          sda_out <= 1'b0; 
          phase <= 1;
      end else if (phase == 1) begin
          scl <= 1'b1; 
          phase <= 2;
      end else begin
          sda_out <= 1'b1; 
          state <= IDLE;
          phase <= 0;
      end
            end
        endcase
        end
    end
endmodule