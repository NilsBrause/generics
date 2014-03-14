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

--! A differatiator

--! This is a standard differentiator. Every clock cycle, it outputs the
--! the difference of the last two inputs.
entity differentiator is
  generic (
    bits : natural;                     --! width of input signal
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk    : in  std_logic;             --! clock input
    reset  : in  std_logic;             --! asynchronous reset (active low)
    enable : in  std_logic;             --! enable pin
    input  : in  std_logic_vector(bits-1 downto 0);  --! signal input
    output : out std_logic_vector(bits-1 downto 0));  --! differentiator output
end entity differentiator;

architecture behav of differentiator is

  signal reg_out : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal sub_out : std_logic_vector(bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  reg_1: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      data_in  => input,
      data_out => reg_out);

  sub_1: entity work.sub
    generic map (
      bits            => bits,
      use_registers   => '0',
      use_kogge_stone => use_kogge_stone)
    port map (
      clk       => clk,
      reset     => reset,
      input1     => input,
      input2     => reg_out,
      output     => sub_out,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  reg_2: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      data_in  => sub_out,
      data_out => output);
  
end architecture behav;
