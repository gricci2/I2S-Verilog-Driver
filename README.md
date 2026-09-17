# I2S-Verilog-Driver

This driver is used for the Digilent I2S2 Pmod for audio sampling and playback. The I2S2 Pmod must be set to Slave mode, where the host FPGA board will supply three clock signals:
- Master clock (MCLK) is set at 22.579 MHz (from 100 MHz clock + MMCM) 
- Serial clock (SCLK) fully toggles once per 8 MCLK periods
- Left/Right Word Select signal (LRCK) toggles once per 64 SCLK periods. 

These signals allow for a 44.1 KHz audio passthrough. The audio is sampled at a resolution of 24 bits per channel.

Using a next state/current state FSM, here are the states used in the I2S2 module:

- `HALT` : will enter this state at startup or whenever `i2s_reset` is high or `mmcm_lock` (MMCM clock lock) is low. This state sets `next_state` to `WAIT_ONE` as long as the MMCM clock is locked and reset is not high
- `WAIT_ONE` : this state is entered whenever there is a `lrck_change` or after a `HALT` and waits one full period (according to the I2S protocol) before transitioning to `READ`
- `READ` : starts reading data at the first SCLK falling edge after a `WAIT_ONE` transition. Will shift bits until `shift_count` is 24 (resolution size) and sets `msample_valid` high upon completion. `msample_channel` is also set to the `i2s_lrck` value to determine which audio channel is being sampled (left/right)

This module also uses AXI signals `msample_valid` and `sready` to handshake with a receiving module. `msample_valid` is set to high once the 24 bit shift register is done sampling. It remains high until the input signal `sready` goes high, indicating that the receiving module has read the data. A high `msample_valid` signal cannot be reset on the capture edge of the 24th bit to ensure that the valid signal will always be high while a complete audio sample is ready to be read.

Note: testing was done on a Digilent Arty S7-25. An ILA module is also included along with the clock wizard where the 100 MHz clock was used to create the 22.579 MHz MCLK
