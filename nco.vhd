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

--! numerically controlled oszillator

--! A numerically controlled oszillator can generate a sinosoidal signal
--! of arbitrary frequency. It can be used in a direct digital synthesizer.
entity nco is
  generic (
    freq_bits       : natural;          --! width of freqeuncy input
    lut_bits        : natural;          --! width of LUT input
    bits            : natural;          --! width of output signals
    use_registers   : bit := '0';       --! use additional rtegisters on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk   : in  std_logic;              --! clock input
    reset : in  std_logic;              --! asynchronous reset (active low)
    freq  : in  std_logic_vector(freq_bits-1 downto 0);  --! frequency input
    pm    : in  std_logic_vector(freq_bits-1 downto 0);  --! phase modulation
    sin   : out std_logic_vector(bits-1 downto 0);  --! sine output
    cos   : out std_logic_vector(bits-1 downto 0);  --! cosine output
    saw   : out std_logic_vector(freq_bits-1 downto 0));  --! sawtooth output
end entity nco;

architecture behav of nco is

  signal pa : std_logic_vector(freq_bits-1 downto 0) := (others => '0');
  signal pam : std_logic_vector(freq_bits-1 downto 0) := (others => '0');
  
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

  add_1: entity work.add
    generic map (
      bits            => freq_bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => pa,
      input2    => pm,
      output    => pam,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

  sincos_1: entity work.sincos
    generic map (
      phase_bits    => lut_bits,
      use_registers => use_registers,
      bits          => bits)
    port map (
      clk    => clk,
      reset  => reset,
      phase  => pam(freq_bits-1 downto freq_bits-lut_bits),
      sinout => sin,
      cosout => cos);

  saw <= pam;

end architecture behav;
