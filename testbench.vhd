-- Copyright (c) 2012, Nils Christopher Brause
-- All rights reserved.
-- 
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the Max Planck Institute for
-- Gravitational Physics (Albert Einstein Institute).

library ieee;
use ieee.std_logic_1164.all;
use work.log2.all;

entity testbench is
  
end entity testbench;

architecture behav of testbench is

  signal clk     : std_logic := '0';
  signal clk2    : std_logic := '0';
  signal rst     : std_logic := '0';
  signal reset   : std_logic := '0';
  signal serial  : std_logic := '0';
  signal cnt_out : std_logic_vector(7 downto 0) := (others => '0');
  signal sin     : std_logic_vector(9 downto 0) := (others => '0');
  signal i       : std_logic_vector(19 downto 0) := (others => '0');
  signal i2      : std_logic_vector(19 downto 0) := (others => '0');

begin  -- architecture behav

  -- generate clock
  clk_proc: process is
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process clk_proc;

  -- generate reset
  rst_proc: process is
  begin
    rst <= '0';
    wait for 100 ns;
    rst <= '1';
    wait;
  end process rst_proc;

-------------------------------------------------------------------------------

  -- synchronize reset
  reset_reg1: entity work.reg1(behav)
    port map (
      clk      => clk,
      reset    => '1',
      enable   => '1',
      data_in  => rst,
      data_out => reset);

  shift_reg_1: entity work.shift_reg
    generic map (
      bits => 8)
    port map (
      clk          => clk,
      reset        => reset,
      load         => '0',
      parallel_in  => (others => '0'),
      serial_in    => serial,
      serial_out   => open,
      parallel_out => open,
      enable       => '1');
  
  shift_reg_2: entity work.shift_reg
    generic map (
      bits => 8)
    port map (
      clk          => clk,
      reset        => reset,
      load         => clk2,
      parallel_in  => "10110111",
      serial_in    => '0',
      serial_out   => serial,
      parallel_out => open,
      enable       => '1');

  delay_reg_1: entity work.delay_reg
    generic map (
      bits  => 8,
      delay => 2)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => "10101010",
      data_out => open);

  add_1: entity work.add
    generic map (
      bits => 8)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => "01110011",
      input2    => "01010111",
      output    => open,
      carry_in  => '1',
      carry_out => open,
      overflow  => open);

  sub_1: entity work.sub
    generic map (
      bits => 8)
    port map (
      clk       => clk,
      reset     => reset,
      input1     => "11000111",
      input2     => "00011111",
      output     => open,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  accumulator_1: entity work.accumulator
    generic map (
      bits => 8)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => "00001011",
      output => open);

  counter_1: entity work.counter
    generic map (
      bits      => 8,
      direction => '1')
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      output => cnt_out);

  nco_1: entity work.nco
    generic map (
      freq_bits => 10,
      bits      => 10)
    port map (
      clk   => clk,
      reset => reset,
      freq  => "0001000000",
      sin   => sin,
      cos   => open);

  array_adder_1: entity work.array_adder
    generic map (
      bits  => 8,
      width => 6)
    port map (
      clk   => clk,
      reset => reset,
      data  => "111111111111111111111111111111111111111111111111",
      sum   => open);

  mul_1: entity work.mul
    generic map (
      bits1           => 8,
      bits2           => 8,
      signed_arith    => '0',
      use_kogge_stone => '1')
    port map (
      clk    => clk,
      reset  => reset,
      input1 => "11010101",
      input2 => "10101010",
      output => open);

  round_1: entity work.round
    generic map (
      inp_bits  => 8,
      outp_bits => 4)
    port map (
      clk   => clk,
      reset => reset,
      input  => cnt_out,
      output => open);

  iqdemod_1: entity work.iqdemod
    generic map (
      bits      => 10,
      nco_bits  => 10,
      freq_bits => 10)
    port map (
      clk   => clk,
      reset => reset,
      input => sin,
      freq  => "0001000001",
      i     => i,
      q     => open);

  decoder_1: entity work.decoder
    generic map (
      bits => 4)
    port map (
      input  => "1010",
      output => open);

  barrel_shift_1: entity work.barrel_shift
    generic map (
      bits => 8)
    port map (
      input  => "10101010",
      amount => "110",
      output => open);

  differentiator_1: entity work.differentiator
    generic map (
      bits => 20)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => i,
      output => open);

  cic_1: entity work.cic
    generic map (
      bits => 20,
      r    => 3,
      n    => 1)
    port map (
      clk     => clk,
      clk2    => clk2,
      reset   => reset,
      input   => i,
      output  => i2,
      output2 => open);

  lfsr_1: entity work.lfsr
    generic map (
      bits => 12)
    port map (
      clk    => clk,
      reset  => reset,
      seed   => "011000111011",
      output => open);

  pidctrl_1: entity work.pidctrl
    generic map (
      bits     => 20,
      int_bits => 40)
    port map (
      clk     => clk,
      reset   => reset,
      input   => i2,
      pgain   => "000011",
      igain   => "000110",
      dgain   => "100000",
      output  => open);

  clkdiv_1: entity work.clkdiv
    generic map (
      div => 2**3)
    port map (
      clk     => clk,
      reset   => reset,
      enable  => '1',
      clk_out => clk2);

  pwm_1: entity work.pwm
    generic map (
      bits => 8)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      ratio  => "101",
      output => open);

  serializer_1: entity work.serializer
    generic map (
      bits => 8)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => "10101001",
      clk1   => open,
      clk2   => open,
      ser    => open);

  comparator_1: entity work.comparator
    generic map (
      bits            => 3,
      use_kogge_stone => '1')
    port map (
      clk    => clk,
      reset  => reset,
      input1 => "100",
      input2 => "011",
      equal  => open,
      uless  => open,
      sless  => open);

  demultiplex_1: entity work.demultiplex
    generic map (
      bits      => 2,
      code_bits => 2)
    port map (
      code   => "10",
      input  => "00011011",
      output => open);

  multi_shift_reg_1: entity work.multi_shift_reg
    generic map (
      bits  => 4,
      bytes => 4)
    port map (
      clk          => clk,
      reset        => reset,
      load         => '0',
      serial_in    => "0011",
      serial_out   => open,
      parallel_in  => (others => '0'),
      parallel_out => open,
      enable       => '1');

  butterfly_1: entity work.butterfly
    generic map (
      bits       => 16,
      phase_bits => 16)
    port map (
      clk          => clk,
      reset        => reset,
      phase        => "1000000000000000",  -- unsigned 0.5
      input1_real  => "0100000000000000",  -- signed 0.5
      input1_imag  => "0100000000000000",  -- signed 0.5
      input2_real  => "0100000000000000",  -- signed 0.5
      input2_imag  => "0100000000000000",  -- signed 0.5
      output1_real => open,             -- signed 0
      output1_imag => open,             -- signed 0
      output2_real => open,             -- signed 1
      output2_imag => open);            -- signed 1

  multiplex_1: entity work.multiplex
    generic map (
      bits      => 2,
      code_bits => 2)
    port map (
      basein => "11100100",
      input  => "11",
      code   => "01",
      output => open);

end architecture behav;
