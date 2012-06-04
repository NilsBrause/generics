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

entity clkdiv is
  generic (
    div : natural;
    use_kogge_stone : bit := '0');
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    enable  : in  std_logic;
    clk_out : out std_logic);
end entity clkdiv;

architecture behav of clkdiv is

  signal tmp : std_logic_vector(div-1 downto 0);
  signal last : std_logic;

begin  -- architecture behav

  counter_1: entity work.counter
    generic map (
      bits            => div,
      direction       => '1',
      use_kogge_stone => use_kogge_stone)
    port map (
      clk    => clk,
      reset  => reset,
      enable => enable,
      output => tmp);

  div_no: if div = 0 generate
    clk_out <= clk;
  end generate div_no;

  div_yes: if div > 0 generate
    process (clk, reset) is
    begin
      if reset = '0' then
        clk_out <= '0';
      elsif rising_edge(clk) then
        if tmp(div-1) = '1' and last = '0' then
          clk_out <= '1';
        else
          clk_out <= '0';
        end if;
        last <= tmp(div-1);
      end if;
    end process;
  end generate div_yes;

end architecture behav;
