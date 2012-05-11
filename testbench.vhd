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

entity testbench is
  
end entity testbench;

architecture behav of testbench is

  component reg1 is
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      enable   : in  std_logic;
      data_in  : in  std_logic;
      data_out : out std_logic);
  end component reg1;

  component shift_reg is
    generic (
      bits : natural);
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      serial_in    : in  std_logic;
      serial_out   : out std_logic;
      parallel_out : out std_logic_vector(bits-1 downto 0);
      enable       : in  std_logic);
  end component shift_reg;

  component delay_reg is
    generic (
      bits  : natural;
      delay : natural);
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      enable   : in  std_logic;
      data_in  : in  std_logic_vector(bits-1 downto 0);
      data_out : out std_logic_vector(bits-1 downto 0));
  end component delay_reg;

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

  component sub is
    generic (
      bits : natural;
      use_kogge_stone : bit);
    port (
      input1     : in  std_logic_vector(bits-1 downto 0);
      input2     : in  std_logic_vector(bits-1 downto 0);
      output     : out std_logic_vector(bits-1 downto 0);
      borrow_in  : in  std_logic;
      borrow_out : out std_logic;
      underflow  : out std_logic);
  end component sub;

  component accumulator is
    generic (
      bits            : natural;
      use_kogge_stone : bit);
    port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      enable : in  std_logic;
      input  : in  std_logic_vector(bits-1 downto 0);
      output : out std_logic_vector(bits-1 downto 0));
  end component accumulator;

  component counter is
    generic (
      bits            : natural;
      direction       : bit;
      use_kogge_stone : bit);
    port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      enable : in  std_logic;
      output : out std_logic_vector(bits-1 downto 0));
  end component counter;

  component sincos is
    generic (
      phase_bits : natural;
      bits       : natural);
    port (
      phase : in  std_logic_vector(phase_bits-1 downto 0);
      sin   : out std_logic_vector(bits-1 downto 0);
      cos   : out std_logic_vector(bits-1 downto 0));
  end component sincos;
  
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal reset : std_logic := '0';
  signal serial : std_logic := '0';

  signal tmp : std_logic_vector(7 downto 0) := (others => '0');
  
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
  reset_reg1: reg1
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

  shift_reg_1: shift_reg
    generic map (
      bits => 8)
    port map (
      clk          => clk,
      reset        => reset,
      serial_in    => serial,
      serial_out   => open,
      parallel_out => open,
      enable       => '1');

  delay_reg_1: delay_reg
    generic map (
      bits  => 8,
      delay => 2)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => "10101010",
      data_out => open);

  add_1: add
    generic map (
      bits => 8,
      use_kogge_stone => '1')
    port map (
      input1    => "01110011",
      input2    => "01010111",
      output    => open,
      carry_in  => '1',
      carry_out => open,
      overflow  => open);

  sub_1: sub
    generic map (
      bits => 8,
      use_kogge_stone => '0')
    port map (
      input1     => "11000111",
      input2     => "00011111",
      output     => open,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  accumulator_1: accumulator
    generic map (
      bits            => 8,
      use_kogge_stone => '0')
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => "00001011",
      output => open);

  counter_1: counter
    generic map (
      bits            => 8,
      direction       => '1',
      use_kogge_stone => '0')
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      output => tmp);

  sincos_1: sincos
    generic map (
      phase_bits => 8,
      bits       => 8)
    port map (
      phase => tmp,
      sin   => open,
      cos   => open);

end architecture behav;
