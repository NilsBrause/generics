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

--! I/Q-demodulator#

--! The IQ demudulator is a Frequency downconverter which converts a QAM
--! modulated high frequency signal into two intermediate frequency signals,
--! which are 90 degree out of phase (I and Q).
entity iqdemod is
  generic (
    bits          : natural;            --! width of input
    nco_bits      : natural;            --! width of internal nco
    freq_bits     : natural;            --! width of frequency input
    lut_bits      : natural;            --! width of LUT input
    signed_arith  : boolean := true;    --! use signed arithmetic
    use_registers : boolean := false);  --! use additional registers on slow FPGAs
  port (
    clk   : in  std_logic;              --! clock input
    reset : in  std_logic;              --! asynchronous reset (active low)
    input : in  std_logic_vector(bits-1 downto 0);  --! input signal
    freq  : in  std_logic_vector(freq_bits-1 downto 0);  --! demodulation frequency
    i     : out std_logic_vector(bits+nco_bits-1 downto 0);  --! in phase signal
    q     : out std_logic_vector(bits+nco_bits-1 downto 0);  --! out of phase signal
    phase : out std_logic_vector(freq_bits-1 downto 0));  -- ! optional phase output 
end entity iqdemod;

architecture behav of iqdemod is

  signal sin : std_logic_vector(nco_bits-1 downto 0) := (others => '0');
  signal cos : std_logic_vector(nco_bits-1 downto 0) := (others => '0');
  signal i_tmp : std_logic_vector(bits+nco_bits-1 downto 0) := (others => '0');
  signal q_tmp : std_logic_vector(bits+nco_bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  nco_1: entity work.nco
    generic map (
      freq_bits     => freq_bits,
      lut_bits      => lut_bits,
      bits          => nco_bits,
      use_registers => use_registers)
    port map (
      clk   => clk,
      reset => reset,
      freq  => freq,
      pm    => (others => '0'),
      sin   => sin,
      cos   => cos,
      saw   => phase);

  mul_1: entity work.mul
    generic map (
      bits1         => bits,
      bits2         => nco_bits,
      signed_arith  => signed_arith,
      use_registers => use_registers)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input,
      input2 => sin,
      output => i_tmp);

  mul_2: entity work.mul
    generic map (
      bits1         => bits,
      bits2         => nco_bits,
      signed_arith  => signed_arith,
      use_registers => use_registers)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input,
      input2 => cos,
      output => q_tmp);

  signed_yes: if signed_arith generate
    i <= i_tmp(bits+nco_bits-2 downto 0) & '0';
    q <= q_tmp(bits+nco_bits-2 downto 0) & '0';
  end generate signed_yes;

  signed_no: if not signed_arith generate
    i <= i_tmp;
    q <= q_tmp;
  end generate signed_no;

end architecture behav;
