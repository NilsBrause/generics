-- Copyright (c) 2013, Nils Christopher Brause
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

--! Absolute Value

--! This component can be used to compute the absolute value of an signed signal
entity absolute is
  generic (
    bits            : natural;          --! width of input
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk    : in  std_logic;             --! input clock
    reset  : in  std_logic;             --! asynchronous reset (active low)
    input  : in  std_logic_vector(bits-1 downto 0);  --! input signal
    output : out std_logic_vector(bits-1 downto 0));  --! absolute value
end entity absolute;

architecture behav of absolute is

  signal tmp : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal tmp2 : std_logic_vector(bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  sub_1: entity work.sub
    generic map (
      bits            => bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => (others => '0'),
      input2     => input,
      output     => tmp,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  use_registers_yes: if use_registers = '1' generate
    reg_1: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input,
        data_out => tmp2);
  end generate use_registers_yes;

  use_registers_no: if use_registers = '0' generate
    tmp2 <= input;
  end generate use_registers_no;

  output <= tmp when tmp(bits-1) = '0' else tmp2;

end architecture behav;
