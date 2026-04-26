
vlib work

vlog -work work "D:/Projects/I2C/master.v"
vlog -work work "D:/Projects/I2C/slave.v"
vlog -work work "D:/Projects/I2C/top.v"
vlog -work work "D:/Projects/I2C/tb.v"

vsim -voptargs=+acc work.tb_i2c
add wave *
run -all
#quit -sim