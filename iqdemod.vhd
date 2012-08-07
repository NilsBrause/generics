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

entity iqdemod is
  generic (
    bits            : natural;
    nco_bits        : natural;
    freq_bits       : natural;
    signed_arith    : bit := '1';
    use_registers   : bit := '0';
    use_kogge_stone : bit := '0');
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    input : in  std_logic_vector(bits-1 downto 0);
    freq  : in  std_logic_vector(freq_bits-1 downto 0);
    i     : out std_logic_vector(bits+nco_bits-1 downto 0);
    q     : out std_logic_vector(bits+nco_bits-1 downto 0));
end entity iqdemod;

architecture behav of iqdemod is

  signal sin : std_logic_vector(nco_bits-1 downto 0) := (others => '0');
  signal cos : std_logic_vector(nco_bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  nco_1: entity work.nco
    generic map (
      pir_bits        => freq_bits,
      bits            => nco_bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk   => clk,
      reset => reset,
      pir   => freq,
      sin   => sin,
      cos   => cos);

  mul_1: entity work.mul
    generic map (
      bits1           => bits,
      bits2           => nco_bits,
      signed_arith    => signed_arith,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input,
      input2 => sin,
      output => i);

  mul_2: entity work.mul
    generic map (
      bits1           => bits,
      bits2           => nco_bits,
      signed_arith    => signed_arith,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input,
      input2 => cos,
      output => q);

end architecture behav;
