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

--! Multi direction counter

--! This is a counter, that can either count up- or downwards at every clock
--! cycle. If it reaches its maximal value it restarts at zero.
entity counter is
  generic (
    bits            : natural;          --! width of counter output
    direction       : bit;              --! '1' = up, '0' = down
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk    : in  std_logic;             --! clock input
    reset  : in  std_logic;             --! asynchronous reset
    enable : in  std_logic;             --! enable pin
    output : out std_logic_vector(bits-1 downto 0));
end entity counter;

architecture behav of counter is
  
  signal one : std_logic_vector(bits-1 downto 0) := (others => '0');
  constant mone : std_logic_vector(bits-1 downto 0) := (others => '1');

begin  -- architecture behav

  one(0) <= '1';
  one(bits-1 downto 1) <= (others => '0');

  up: if direction = '1' generate
    accumulator_1: entity work.accumulator
      generic map (
        bits            => bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => enable,
        input  => one,
        output => output);
  end generate up;

  down: if direction = '0' generate
    accumulator_1: entity work.accumulator
      generic map (
        bits            => bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => enable,
        input  => mone,
        output => output);
  end generate down;

end architecture behav;
