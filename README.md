# I2S-Verilog-Driver

This driver is used for the Digilent I2S2 Pmod for audio sampling and playback. The I2S2 Pmod must be set to Slave mode, where the host FPGA board will supply three clock signals:
- Master clock (MCLK) is set at 22.579 MHz (from 100 MHz clock + MMCM) 
- Serial clock (SCLK) fully toggles once per 8 MCLK periods
- Left/Right Word Select signal (LRCK) toggles once per 64 SCLK periods. 

These signals allow for a 44.1 KHz audio passthrough. The audio is sampled at a resolution of 24 bits per channel.

Using a next state/current state FSM, here are the states used in the I2S2 module:

- `HALT` : 
- `WAIT_ONE` :
- `READ` : 
