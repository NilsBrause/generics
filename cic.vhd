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

entity cic is
  generic (
    bits            : natural;
    r               : natural;
    n               : natural;
    signed_arith    : bit := '1';
    use_kogge_stone : bit := '0');
  port (
    clk     : in  std_logic;
    clk2    : in  std_logic;
    reset   : in  std_logic;
    input   : in  std_logic_vector(bits-1 downto 0);
    output  : out std_logic_vector(bits-1 downto 0);
    output2  : out std_logic_vector(n*r+bits-1 downto 0));
end entity cic;

architecture behav of cic is

  constant bits2 : natural := n*r + bits;
  signal input2  : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal temp    : std_logic_vector((2*n+2)*bits2-1 downto 0) := (others => '0');

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
        bits            => bits2,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => '1',
        input  => temp(c*bits2-1 downto (c-1)*bits2),
        output => temp((c+1)*bits2-1 downto c*bits2));
  end generate integrators;

  reg_2: entity work.reg
    generic map (
      bits => bits2)
    port map (
      clk      => clk2,
      reset    => reset,
      enable   => '1',
      data_in  => temp((n+1)*bits2-1 downto n*bits2),
      data_out => temp((n+2)*bits2-1 downto (n+1)*bits2));

  combs: for c in 1 to n generate
    differentiator_1: entity work.differentiator
      generic map (
        bits            => bits2,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk2,
        reset  => reset,
        enable => '1',
        input  => temp((n+1+c)*bits2-1 downto (n+1+c-1)*bits2),
        output => temp((n+1+c+1)*bits2-1 downto (n+1+c)*bits2));
  end generate combs;

  output2 <= temp((2*n+2)*bits2-1 downto (2*n+1)*bits2);

  round_1: entity work.round
    generic map (
      inp_bits        => bits2,
      outp_bits       => bits,
      signed_arith    => signed_arith,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk   => clk,
      reset => reset,
      input  => temp((2*n+2)*bits2-1 downto (2*n+1)*bits2),
      output => output);

end architecture behav;
