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
