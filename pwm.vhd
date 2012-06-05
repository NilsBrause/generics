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
use ieee.numeric_std.all;
use work.log2.all;

entity pwm is
  generic (
    bits            : natural;
    use_kogge_stone : bit := '0');
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    ratio  : in  std_logic_vector(log2ceil(bits)-1 downto 0);
    output : out std_logic);
end entity pwm;

architecture behav of pwm is

  signal cnt_out : std_logic_vector(log2ceil(bits)-1 downto 0);
  signal cnt_rst : std_logic;
  signal cnt_rst_int : std_logic;

begin  -- architecture behav

  cnt_rst <= cnt_rst_int and reset;
  cnt_rst_int <= '0' when to_integer(unsigned(cnt_out)) = bits else '1';

  counter_1: entity work.counter
    generic map (
      bits            => log2ceil(bits),
      direction       => '1',
      use_kogge_stone => use_kogge_stone)
    port map (
      clk    => clk,
      reset  => cnt_rst,
      enable => enable,
      output => cnt_out);

  output <= '1' when unsigned(cnt_out) < unsigned(ratio) else '0';

end architecture behav;
