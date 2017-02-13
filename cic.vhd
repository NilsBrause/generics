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

--! Cascaded integrator comb filter

--! A CIC-filter can be used to convert a signal from one samplerate s to
--! another samplerate s/2^r without aliasing. The number of samples per
--! filter stage is fixed to one at the moment, but the number of filter
--! stages is configurable.
entity gcic is
  generic (
    bits         : natural;             --! width of the input signal
    out_bits     : natural;             --! width of the output signal
    r            : natural;             --! samplerate divider
    n            : natural);            --! number of filter stages
  port (
    clk     : in  std_logic;            --! input clock (frequency f)
    clk2    : in  std_logic;            --! output clock (must be f/2**r)
    reset   : in  std_logic;            --! asynchronous reset (active low)
    input   : in  std_logic_vector(bits-1 downto 0);  --! input signal
    output  : out std_logic_vector(out_bits-1 downto 0));  --! output signal
end entity gcic;

architecture behav of gcic is

  constant bits2 : natural := n*r + bits;
  signal input2  : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal temp    : std_logic_vector((n+1)*bits2-1 downto 0) := (others => '0');
  signal temp2   : std_logic_vector((n+1)*out_bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  reg_1: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input,
      data_out => input2);

  temp(bits2-1 downto bits) <= (others => input2(bits-1));
  temp(bits-1 downto 0) <= input2;
  
  integrators: for c in 1 to n generate
    accumulator_1: entity work.accumulator
      generic map (
        bits => bits2)
      port map (
        clk    => clk,
        reset  => reset,
        enable => '1',
        input  => temp(c*bits2-1 downto (c-1)*bits2),
        output => temp((c+1)*bits2-1 downto c*bits2));
  end generate integrators;

  -- truncating here instead of at the end saves
  -- a lot of logic and does not intruduce noise.
  -- truncation instead of rounding leads to a 0.5 DC offset
  -- which does not propagate through the differetiators
  reg_2: entity work.reg
    generic map (
      bits => out_bits)
    port map (
      clk      => clk2,
      reset    => reset,
      enable   => '1',
      data_in  => temp((n+1)*bits2-1 downto (n+1)*bits2-out_bits),
      data_out => temp2(out_bits-1 downto 0));

  combs: for c in 1 to n generate
    differentiator_1: entity work.differentiator
      generic map (
        bits => out_bits)
      port map (
        clk    => clk2,
        reset  => reset,
        enable => '1',
        input  => temp2(c*out_bits-1 downto (c-1)*out_bits),
        output => temp2((c+1)*out_bits-1 downto c*out_bits));
  end generate combs;

  output <= temp2((n+1)*out_bits-1 downto n*out_bits);

end architecture behav;
