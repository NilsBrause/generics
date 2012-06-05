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

entity serializer is
  generic (
    bits            : natural;
    use_kogge_stone : bit := '0');

  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    input  : in  std_logic_vector(bits-1 downto 0);
    clk1   : out std_logic;
    clk2   : out std_logic;
    ser    : out std_logic);
end entity serializer;

architecture behav of serializer is

  signal inp : std_logic_vector(bits downto 0) := (others => '0');
  signal ser_tmp : std_logic := '0';
  signal clk_out : std_logic := '0';

begin  -- architecture behav

  inp(bits downto 1) <= input;
  inp(0) <= '0';

  clkdiv_1: entity work.clkdiv
    generic map (
      div             => bits+1,
      duty_cycle      => '0',
      use_kogge_stone => use_kogge_stone)
    port map (
      clk     => clk,
      reset   => reset,
      enable  => enable,
      clk_out => clk_out);

  shift_reg_1: entity work.shift_reg
    generic map (
      bits => bits+1)
    port map (
      clk          => clk,
      reset        => reset,
      load         => clk_out,
      serial_in    => ser_tmp,
      serial_out   => ser_tmp,
      parallel_in  => inp,
      parallel_out => open,
      enable       => enable);

  ser <= ser_tmp;
  clk1 <= clk and not clk_out;
  clk2 <= clk_out;

end architecture behav;
