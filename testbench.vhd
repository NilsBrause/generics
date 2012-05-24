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

entity testbench is
  
end entity testbench;

architecture behav of testbench is

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal reset : std_logic := '0';
  signal serial : std_logic := '0';

  signal cnt_out : std_logic_vector(7 downto 0) := (others => '0');
  signal sin : std_logic_vector(9 downto 0) := (others => '0');

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

-------------------------------------------------------------------------------

  -- synchronize reset
  reset_reg1: entity work.reg1
    port map (
      clk      => clk,
      reset    => '1',
      enable   => '1',
      data_in  => rst,
      data_out => reset);

  serial_gen: process (clk, reset) is
  begin
    if reset = '0' then
      serial <= '0';
    elsif rising_edge(clk) then
      serial <= not serial;
    end if;
  end process serial_gen;

  shift_reg_1: entity work.shift_reg
    generic map (
      bits => 8)
    port map (
      clk          => clk,
      reset        => reset,
      serial_in    => serial,
      serial_out   => open,
      parallel_out => open,
      enable       => '1');

  delay_reg_1: entity work.delay_reg
    generic map (
      bits  => 8,
      delay => 2)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => "10101010",
      data_out => open);

  add_1: entity work.add
    generic map (
      bits => 8)
    port map (
      input1    => "01110011",
      input2    => "01010111",
      output    => open,
      carry_in  => '1',
      carry_out => open,
      overflow  => open);

  sub_1: entity work.sub
    generic map (
      bits => 8)
    port map (
      input1     => "11000111",
      input2     => "00011111",
      output     => open,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  accumulator_1: entity work.accumulator
    generic map (
      bits => 8)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => "00001011",
      output => open);

  counter_1: entity work.counter
    generic map (
      bits      => 8,
      direction => '1')
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      output => cnt_out);

  nco_1: entity work.nco
    generic map (
      pir_bits => 10,
      bits     => 10)
    port map (
      clk   => clk,
      reset => reset,
      pir   => "0001000000",
      sin   => sin,
      cos   => open);

  array_adder_1: entity work.array_adder
    generic map (
      bits  => 8,
      width => 6)
    port map (
      clk   => clk,
      reset => reset,
      data  => "111111111111111111111111111111111111111111111111",
      sum   => open);

  mul_1: entity work.mul
    generic map (
      bits1           => 8,
      bits2           => 8,
      signed_arith    => '0',
      use_kogge_stone => '1')
    port map (
      clk    => clk,
      reset  => reset,
      input1 => "11010101",
      input2 => "10101010",
      output => open);

  round_1: entity work.round
    generic map (
      inp_bits        => 8,
      outp_bits       => 4)
    port map (
      input  => cnt_out,
      output => open);

  iqdemod_1: entity work.iqdemod
    generic map (
      bits            => 10,
      nco_bits        => 10,
      freq_bits       => 10)
    port map (
      clk   => clk,
      reset => reset,
      input => sin,
      freq  => "0001000001",
      i     => open,
      q     => open);

  demultiplexer_1: entity work.demultiplexer
    generic map (
      bits => 4)
    port map (
      input  => "1010",
      output => open);

end architecture behav;
