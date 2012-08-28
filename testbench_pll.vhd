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

entity testbench_pll is
  
end entity testbench_pll;

architecture behav of testbench_pll is

  constant freq_bits : natural := 12;
  constant nco_bits : natural := 12;
  constant cic_div : natural := 5;

  signal clk        : std_logic := '0';
  signal clk2       : std_logic := '0';
  signal rst        : std_logic := '0';
  signal reset      : std_logic := '0';
  signal sin        : std_logic_vector(nco_bits-1 downto 0) := (others => '0');
  signal q          : std_logic_vector(2*nco_bits-1 downto 0) := (others => '0');
  signal freq       : std_logic_vector(freq_bits-1 downto 0) := (others => '0');
  signal start_freq : std_logic_vector(freq_bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  -- generate clock
  clk_proc: process is
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process clk_proc;

  -- generate reset
  rst_proc: process is
  begin
    rst <= '0';
    wait for 100 ns;
    rst <= '1';
    wait;
  end process rst_proc;

  -- generate frequencies
  freq_gen: process is
  begin
    start_freq <= "000100000000";
    wait for 50 us;
    start_freq <= "000110000000";
    wait for 50 us;
    start_freq <= "001000000000";
    wait for 50 us;
    start_freq <= "001010000000";
    wait for 50 us;
    start_freq <= "001100000000";
    wait for 50 us;
    start_freq <= "001110000000";
    wait;
  end process freq_gen;

-------------------------------------------------------------------------------

  -- synchronize reset
  reset_reg1: entity work.reg1
    port map (
      clk      => clk,
      reset    => '1',
      enable   => '1',
      data_in  => rst,
      data_out => reset);

 -- generate test signal
  nco_1: entity work.nco
    generic map (
      freq_bits => freq_bits,
      bits      => nco_bits)
    port map (
      clk   => clk,
      reset => reset,
      freq  => start_freq,
      sin   => sin,
      cos   => open);

  -- the PLL
  pll_1: entity work.pll2
    generic map (
      bits      => nco_bits,
      int_bits  => 40,
      nco_bits  => nco_bits,
      freq_bits => freq_bits,
      use_registers   => '1',
      use_kogge_stone => '1')
    port map (
      clk        => clk,
      reset      => reset,
      input      => sin,
      i          => open,
      q          => q,
      error      => q,
      pgain      => "001000",
      igain      => "000100",
      dgain      => "100000",
      start_freq => "000100000000",
      freq_out   => freq,
      freq_in    => freq);

  clkdiv_1: entity work.clkdiv
    generic map (
      div => cic_div)
    port map (
      clk     => clk,
      reset   => reset,
      enable  => '1',
      clk_out => clk2);

  cic_1: entity work.cic
    generic map (
      bits => nco_bits,
      r    => cic_div,
      n    => 1)
    port map (
      clk     => clk,
      clk2    => clk2,
      reset   => reset,
      input   => freq,
      output  => open,
      output2 => open);

  cic_2: entity work.cic
    generic map (
      bits => 2*nco_bits,
      r    => cic_div,
      n    => 1)
    port map (
      clk     => clk,
      clk2    => clk2,
      reset   => reset,
      input   => q,
      output  => open,
      output2 => open);

end architecture behav;
