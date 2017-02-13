-- Copyright (c) 2014-2017, Nils Christopher Brause
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

entity highpass is
  generic (
    bits : natural);                    --! width of input signal
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    input  : in  std_logic_vector(bits-1 downto 0);
    b      : in  std_logic_vector(bits-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity highpass;

architecture behav of highpass is

  signal input_diff          : std_logic_vector(bits-1 downto 0);
  signal output_tmp          : std_logic_vector(bits-1 downto 0);
  signal last_output         : std_logic_vector(bits-1 downto 0);
  signal last_output_mul     : std_logic_vector(bits-1 downto 0);
  signal last_output_mul_tmp : std_logic_vector(2*bits-1 downto 0);

begin  -- architecture behav

  differentiator_1: entity work.differentiator
    generic map (
      bits => bits)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => input,
      output => input_diff);

  accumulator_1: entity work.add
    generic map (
      bits          => bits,
      use_registers => false)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => input_diff,
      input2    => last_output_mul,
      output    => output_tmp,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

  output_reg: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => output_tmp,
      data_out => last_output);

  output <= last_output;
  
  output_mul: entity work.mul
    generic map (
      bits1         => bits,
      bits2         => bits,
      signed_arith  => true,
      use_registers => false)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => last_output,
      input2 => b,
      output => last_output_mul_tmp);

  last_output_mul <= last_output_mul_tmp(2*bits-2 downto bits-1);
  
end architecture behav;
