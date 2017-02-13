-- Copyright (c) 2013-2017, Nils Christopher Brause
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
use ieee.numeric_std.all;
use work.log2.all;

--! First In First Out
entity fifo is
  generic (
    bits : natural;
    size : natural);
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    input  : in  std_logic_vector(bits-1 downto 0);
    wr_en  : in  std_logic;
    full   : out std_logic;
    output : out std_logic_vector(bits-1 downto 0);
    rd_en  : in  std_logic;
    empty  : out std_logic);
end entity fifo;

architecture behav of fifo is

  signal addr1 : std_logic_vector(log2ceil(size)-1 downto 0);
  signal addr2 : std_logic_vector(log2ceil(size)-1 downto 0);
  signal fuel : std_logic_vector(log2ceil(size)-1 downto 0);

begin  -- architecture behav

  counter_1: entity work.counter
    generic map (
      bits         => log2ceil(size),
      direction_up => true)
    port map (
      clk    => clk,
      reset  => reset,
      enable => wr_en,
      output => addr1);

  counter_2: entity work.counter
    generic map (
      bits         => log2ceil(size),
      direction_up => true)
    port map (
      clk    => clk,
      reset  => reset,
      enable => rd_en,
      output => addr2);

  ram_1: entity work.ram
    generic map (
      bits  => bits,
      bytes => size)
    port map (
      clk1      => clk,
      clk2      => clk,
      we1       => wr_en,
      we2       => '0',
      addr1     => addr1,
      addr2     => addr2,
      data1_in  => input,
      data2_in  => (others => '0'),
      data1_out => open,
      data2_out => output);

  sub_1: entity work.sub
    generic map (
      bits          => log2ceil(size),
      use_registers => false)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => addr1,
      input2     => addr2,
      output     => fuel,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  full <= '1' when fuel = (fuel'range => '1') else '0';
  empty <= '1' when fuel = (fuel'range => '0') else '0';

end architecture behav;
