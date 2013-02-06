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

--! phase locked loop

--! A phase locked loop (PLL) is a control loop, which lets you track the phase
--! (and therefore the ferquency) of a sinusoidal signal. For more information
--! see: GARDNER, FLOYD M.: Phaselock Techniques. WILEY INTERSCIENCE, 2005.
entity pll2 is
  generic (
    bits            : natural;          --! width of input
    int_bits        : natural;          --! internal signal width
    nco_bits        : natural;          --! width of nco output
    freq_bits       : natural;          --! width of frequency input/output
    signed_arith    : bit := '1';       --! assume input is signed
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk        : in  std_logic;         --! clock input
    reset      : in  std_logic;         --! asynchronous reset (active low)
    input      : in  std_logic_vector(bits-1 downto 0);  --! input signal
    i          : out std_logic_vector(bits+nco_bits-1 downto 0);  --! intensity output
    q          : out std_logic_vector(bits+nco_bits-1 downto 0);  --! quality output
    error      : in  std_logic_vector(bits+nco_bits-1 downto 0);  --! error input (connect to q)
    pgain      : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);  --! proportional gain
    igain      : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);  --! integral gain
    start_freq : in  std_logic_vector(freq_bits-1 downto 0);  --! start frequency
    freq_out   : out std_logic_vector(freq_bits-1 downto 0);  --! measured frequency
    freq_in    : in  std_logic_vector(freq_bits-1 downto 0);  --! frequency input (connect to freq_in)
    phase      : out std_logic_vector(freq_bits-1 downto 0));  --! optinal phase output
end entity pll2;

architecture behav of pll2 is

  signal pid_out : std_logic_vector(int_bits-1 downto 0) := (others => '0');
  signal pid_out_round : std_logic_vector(freq_bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  iqdemod_1: entity work.iqdemod
    generic map (
      bits            => bits,
      nco_bits        => nco_bits,
      freq_bits       => freq_bits,
      signed_arith    => signed_arith,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk   => clk,
      reset => reset,
      input => input,
      freq  => freq_in,
      i     => i,
      q     => q,
      phase => phase);

  pidctrl_1: entity work.pidctrl
    generic map (
      bits            => bits+nco_bits,
      int_bits        => int_bits,
      signed_arith    => signed_arith,
      gains_first     => '1',
      use_prop        => '1',
      use_int         => '1',
      use_diff        => '0',
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk     => clk,
      reset   => reset,
      input   => error,
      pgain   => pgain,
      igain   => igain,
      dgain   => (others => '0'),
      output  => pid_out);

  round_1: entity work.round
    generic map (
      inp_bits        => int_bits,
      outp_bits       => freq_bits,
      signed_arith    => signed_arith,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk   => clk,
      reset => reset,
      input  => pid_out,
      output => pid_out_round);

  add_1: entity work.add
    generic map (
      bits            => freq_bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => pid_out_round,
      input2    => start_freq,
      output    => freq_out,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

end architecture behav;
