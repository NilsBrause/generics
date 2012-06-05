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
use work.log2.all;

entity pll is
  generic (
    bits            : natural;
    int_bits        : natural;
    nco_bits        : natural;
    freq_bits       : natural;
    signed_arith    : bit := '1';
    use_kogge_stone : bit := '0');
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    input      : in  std_logic_vector(bits-1 downto 0);
    i          : out std_logic_vector(bits+nco_bits-1 downto 0);
    q          : out std_logic_vector(bits+nco_bits-1 downto 0);
    error      : in  std_logic_vector(bits+nco_bits-1 downto 0);
    pregain    : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);
    pgain      : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);
    igain      : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);
    dgain      : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);
    start_freq : in  std_logic_vector(freq_bits-1 downto 0);
    freq_out   : out std_logic_vector(freq_bits-1 downto 0);
    freq_in    : in  std_logic_vector(freq_bits-1 downto 0));
end entity pll;

architecture behav of pll is

  signal pid_out : std_logic_vector(bits+nco_bits-1 downto 0) := (others => '0');
  signal pid_out_round : std_logic_vector(freq_bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  iqdemod_1: entity work.iqdemod
    generic map (
      bits            => bits,
      nco_bits        => nco_bits,
      freq_bits       => freq_bits,
      signed_arith    => signed_arith,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk   => clk,
      reset => reset,
      input => input,
      freq  => freq_in,
      i     => i,
      q     => q);

  pidctrl_1: entity work.pidctrl
    generic map (
      bits            => bits+nco_bits,
      int_bits        => int_bits,
      signed_arith    => signed_arith,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk     => clk,
      reset   => reset,
      input   => error,
      pregain => pregain,
      pgain   => pgain,
      igain   => igain,
      dgain   => dgain,
      output  => pid_out);

  round_1: entity work.round
    generic map (
      inp_bits        => bits+nco_bits,
      outp_bits       => freq_bits,
      signed_arith    => signed_arith,
      use_kogge_stone => use_kogge_stone)
    port map (
      input  => pid_out,
      output => pid_out_round);

  add_1: entity work.add
    generic map (
      bits            => freq_bits,
      use_kogge_stone => use_kogge_stone)
    port map (
      input1    => pid_out_round,
      input2    => start_freq,
      output    => freq_out,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

end architecture behav;
