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

entity nco is
  generic (
    freq_bits       : natural;
    bits            : natural;
    use_registers   : bit := '0';
    use_kogge_stone : bit := '0');
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    freq  : in  std_logic_vector(freq_bits-1 downto 0);
    sin   : out std_logic_vector(bits-1 downto 0);
    cos   : out std_logic_vector(bits-1 downto 0));
end entity nco;

architecture behav of nco is

  signal pa : std_logic_vector(freq_bits-1 downto 0) := (others => '0');
  
begin  -- architecture behav

  pareg : entity work.accumulator
    generic map (
      bits            => freq_bits,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => freq,
      output => pa);

  sincos_1: entity work.sincos
    generic map (
      phase_bits => freq_bits,
      bits       => bits)
    port map (
      clk    => clk,
      reset  => reset,
      phase  => pa,
      sinout => sin,
      cosout => cos);

end architecture behav;
