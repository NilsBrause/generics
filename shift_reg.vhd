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

entity shift_reg is
  generic (
    bits : natural);
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    serial_in    : in  std_logic;
    serial_out   : out std_logic;
    parallel_out : out std_logic_vector(bits-1 downto 0);
    enable       : in  std_logic);
end entity shift_reg;

architecture behav of shift_reg is

  signal tmp : std_logic_vector(bits downto 0) := (others => '0');
  
begin  -- architecture behav

  tmp(0) <= serial_in;

  regs : for c in 0 to bits-1 generate
    myreg : entity work.reg
      generic map (
        bits => 1)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => enable,
        data_in  => tmp(c downto c),
        data_out => tmp(c+1 downto c+1));
  end generate regs;

  serial_out <= tmp(bits);
  parallel_out <= tmp(bits downto 1);
  
end architecture behav;
