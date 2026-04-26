# I2C Master-Slave Communication System (Verilog)

This project provides a complete, synthesizable implementation of the **I2C (Inter-Integrated Circuit) Protocol** using Verilog HDL. It includes a fully functional Master controller and an EEPROM-like Slave device, designed for robust communication in FPGA/ASIC environments.

## 🚀 Overview
The system implements the standard I2C protocol, handling the complex `inout` SDA line management and synchronization issues commonly found in hardware communication.

### Key Features:
* **Complete Master-Slave Link:** Full implementation of Start, Stop, and Data Transfer conditions.
* **Clock Divider:** Integrated frequency scaling to match I2C standard speeds (100kHz/400kHz) from high-speed system clocks.
* **Open-Drain Logic:** Correct handling of the bidirectional `SDA` line using `High-Impedance (Z)` states.
* **3-Stage Synchronization:** The Slave includes a synchronizer for `SCL` and `SDA` to prevent metastability.
* **Pull-up Simulation:** Optimized for simulation environments (like ModelSim) using `pullup` primitives.

## 📂 Project Structure
* `master.v`: The I2C Master controller handling the state machine and clock generation.
* `slave.v`: An EEPROM-style Slave that responds to addresses and stores/retrieves data.
* `top.v`: Top-level module connecting the Master and Slave.
* `tb_i2c.v`: Comprehensive Testbench for verifying the whole system.

## 🛠 Technical Details
### State Machines:
The Master uses a multi-state FSM:
1.  **IDLE**: Waiting for the start signal.
2.  **START**: Generating the start condition.
3.  **ADDRESS**: Sending the 7-bit Slave address + R/W bit.
4.  **ACK**: Waiting for Slave acknowledgment.
5.  **DATA**: Transferring 8-bit data packets.
6.  **STOP**: Generating the stop condition.

### Handling the Inout SDA:
To avoid "Bus Contention" (Red X in simulation), the project uses:
```verilog
assign sda = sda_en ? sda_out : 1'bz;
