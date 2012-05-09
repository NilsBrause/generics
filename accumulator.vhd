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

entity accumulator is
  generic (
    bits : natural;
    use_kogge_stone : bit);
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    input  : in  std_logic_vector(bits-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity accumulator;

architecture behav of accumulator is

  component add is
    generic (
      bits : natural;
      use_kogge_stone : bit);
    port (
      input1    : in  std_logic_vector(bits-1 downto 0);
      input2    : in  std_logic_vector(bits-1 downto 0);
      output    : out std_logic_vector(bits-1 downto 0);
      carry_in  : in  std_logic;
      carry_out : out std_logic;
      overflow  : out std_logic);
  end component add;

  component reg is
    generic (
      bits : natural);
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      enable   : in  std_logic;
      data_in  : in  std_logic_vector(bits-1 downto 0);
      data_out : out std_logic_vector(bits-1 downto 0));
  end component reg;

  signal add_in : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal add_out : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal reg_out: std_logic_vector(bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  add_1: add
    generic map (
      bits => bits,
      use_kogge_stone => use_kogge_stone)
    port map (
      input1    => add_in,
      input2    => input,
      output    => add_out,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

  reg_1: reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      data_in  => add_out,
      data_out => reg_out);

  output <= reg_out;
  add_in <= reg_out;
  
end architecture behav;
