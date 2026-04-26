module i2c_eeprom_slave(
input clk,
input reset_n,
input scl,
inout sda,
input [6:0] my_addr
);

reg [7:0] memory [0:255];
reg [7:0] word_addr;
reg [7:0] shift_reg;
reg       rw_bit;
reg sda_out;
reg sda_en;
reg [3:0] bit_count;
reg [3:0] state;

assign sda = (sda_en && (sda_out == 1'b0)) ? 1'b0 : 1'bz;
 localparam IDLE = 0,
  RX_DEV_ADDR   = 1,
  ACK_DEV_ADDR  = 2,
  RX_WORD_ADDR  = 3,
  ACK_WORD_ADDR = 4,
  RX_DATA       = 5,
  ACK_RX_DATA   = 6,
  TX_DATA       = 7,
  GET_ACK       = 8;

 // 3-stage synchronizer
 reg scl_r1, scl_r2, scl_r3;
 reg sda_r1, sda_r2, sda_r3;

 always @(posedge clk or negedge reset_n) begin
 if (!reset_n) begin
 scl_r1<=1;
 scl_r2<=1; 
 scl_r3<=1;
 sda_r1<=1;
 sda_r2<=1;
 sda_r3<=1;
  end else begin
 scl_r1 <= scl;
 scl_r2 <= scl_r1;
 scl_r3 <= scl_r2;
 sda_r1 <= sda;
 sda_r2 <= sda_r1;
 sda_r3 <= sda_r2;
  end
 end
 wire scl_rising  =  scl_r1 & ~scl_r2;
 wire scl_falling = ~scl_r1 &  scl_r2;
 wire start_det = ~sda_r1 &  sda_r2 &  scl_r1;
 wire stop_det  =  sda_r1 & ~sda_r2 &  scl_r1;

 always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
      state     <= IDLE;
      sda_out   <= 1'b1;
      sda_en    <= 1'b0;
      bit_count <= 0;
      word_addr <= 0;
      shift_reg <= 0;
      rw_bit    <= 0;
  end else begin
      if (stop_det) begin
          state  <= IDLE;
          sda_en <= 1'b0;
      end else if (start_det) begin
          state     <= RX_DEV_ADDR;
          bit_count <= 7;
          sda_en    <= 1'b0;
      end else begin
          case(state)
IDLE: begin
   sda_en <= 1'b0;
end
RX_DEV_ADDR: begin
   if (scl_rising) begin
       shift_reg[bit_count] <= sda_r1;
       if (bit_count == 0)
              state <= ACK_DEV_ADDR;
          else
              bit_count <= bit_count - 1;
      end
  end

  ACK_DEV_ADDR: begin
  if (scl_falling ) begin
      if (shift_reg[7:1] == my_addr) begin
          sda_out <= 1'b0;
          sda_en  <= 1'b1;
          rw_bit  <= shift_reg[0];
      end else begin
          state <= IDLE;
      end
  end else if (scl_rising) begin
      if (shift_reg[7:1] == my_addr) begin
          if (rw_bit == 1'b0) begin
              state     <= RX_WORD_ADDR;
              bit_count <= 7;
          end else begin
              state     <= TX_DATA;
              bit_count <= 7;
              shift_reg <= memory[word_addr];
          end
      end
      end
  end

  RX_WORD_ADDR: begin
      if (scl_falling)
          sda_en <= 1'b0; 
      else if (scl_rising) begin
          shift_reg[bit_count] <= sda_r1;
          if (bit_count == 0)
              state <= ACK_WORD_ADDR;
          else
              bit_count <= bit_count - 1;
      end
  end

  ACK_WORD_ADDR: begin
      if (scl_falling ) begin
          sda_out   <= 1'b0;
          sda_en    <= 1'b1;
          word_addr <= shift_reg;
      end else if (scl_rising) begin
          state     <= RX_DATA;
          bit_count <= 7;
      end
  end

  RX_DATA: begin
      if (scl_falling)
          sda_en <= 1'b0; 
      else if (scl_rising) begin
          shift_reg[bit_count] <= sda_r1;
          if (bit_count == 0)
              state <= ACK_RX_DATA;
          else
              bit_count <= bit_count - 1;
      end
  end

  ACK_RX_DATA: begin
      if (scl_falling) begin 
          sda_out           <= 1'b0;
          sda_en            <= 1'b1;
          memory[word_addr] <= shift_reg;
          word_addr         <= word_addr + 1;
      end else if (scl_rising) begin
          state     <= RX_DATA;
          bit_count <= 7;
      end
  end

  TX_DATA: begin
      if (scl_falling) begin
          sda_out <= shift_reg[bit_count];
          sda_en  <= 1'b1;
      end else if (scl_rising) begin
          if (bit_count == 0)
              state <= GET_ACK;
          else
              bit_count <= bit_count - 1;
      end
  end

  GET_ACK: begin
 if (scl_falling) begin
     sda_en <= 1'b0;
 end else if (scl_rising) begin
     if (sda_r1 == 1'b0) begin
         word_addr <= word_addr + 1;
         shift_reg <= memory[word_addr + 1];
         state     <= TX_DATA;
         bit_count <= 7;
     end else begin
         state <= IDLE;
     end
      end
  end

  default: state <= IDLE;
       endcase
         end
     end
    end
endmodule