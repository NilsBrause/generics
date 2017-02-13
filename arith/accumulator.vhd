-- Copyright (c) 2012-2017, Nils Christopher Brause
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

--! An accumulator

--! This is a standard accumulator. It accumulates the input value at every
--! clock cycle. The resulting accumulated value is put out. If it reaches the
--! maximal value it overflows.
entity accumulator is
  generic (
    bits : natural);                    --! width of input signal
  port (
    clk    : in  std_logic;             --! clock input
    reset  : in  std_logic;             --! asynchronous reset
    enable : in  std_logic;             --! enable pin
    input  : in  std_logic_vector(bits-1 downto 0);  --! input signal
    output : out std_logic_vector(bits-1 downto 0));  --! accumulated output
end entity accumulator;

architecture behav of accumulator is

  signal add_in  : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal add_out : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal reg_out : std_logic_vector(bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  add_1: entity work.add
    generic map (
      bits          => bits,
      use_registers => false)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => add_in,
      input2    => input,
      output    => add_out,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

  reg_1: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      data_in  => add_out,
      data_out => reg_out);

  output <= reg_out;
  add_in <= reg_out;
  
end architecture behav;
