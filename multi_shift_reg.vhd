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

entity multi_shift_reg is
  generic (
    bits  : natural;
    bytes : natural);
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    load         : in  std_logic;
    serial_in    : in  std_logic_vector(bits-1 downto 0);
    serial_out   : out std_logic_vector(bits-1 downto 0);
    parallel_in  : in  std_logic_vector(bytes*bits-1 downto 0);
    parallel_out : out std_logic_vector(bytes*bits-1 downto 0);
    enable       : in  std_logic);
end entity multi_shift_reg;

architecture behav of multi_shift_reg is

  signal pout : std_logic_vector(bits*bytes-1 downto 0);
  signal pin : std_logic_vector(bits*bytes-1 downto 0);

begin  -- architecture behav

bits_loop: for c in 0 to bits-1 generate
  shift_reg_1: entity work.shift_reg
    generic map (
      bits => bytes)
    port map (
      clk          => clk,
      reset        => reset,
      load         => load,
      serial_in    => serial_in(c),
      serial_out   => serial_out(c),
      parallel_in  => pin((c+1)*bytes-1 downto c*bytes),
      parallel_out => pout((c+1)*bytes-1 downto c*bytes),
      enable       => enable);
  
  -- translate row/column to column/rows
  bytes_loop: for d in 0 to bytes-1 generate
    parallel_out(d*bits+c) <= pout(c*bytes+d);
    pin(c*bytes+d) <= parallel_in(d*bits+c);
  end generate bytes_loop;
end generate bits_loop;
  
end architecture behav;
