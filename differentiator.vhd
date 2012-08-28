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

entity differentiator is
  generic (
    bits : natural;
    use_kogge_stone : bit := '0');
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    input  : in  std_logic_vector(bits-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity differentiator;

architecture behav of differentiator is

  signal reg_out : std_logic_vector(bits-1 downto 0) := (others => '0');

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
      output     => output,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);
  
end architecture behav;
