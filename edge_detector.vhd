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

--! Converts rising/falling endge into a pulse
entity edge_detector is
  generic (
    edge : std_logic := '1');           --! '1' = rising, '0' = falling
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    input  : in  std_logic;
    output : out std_logic);
end entity edge_detector;

architecture behav of edge_detector is

  signal tmp : std_logic_vector(0 to 1);

begin  -- architecture behav

  -- synchonize input
  reg1_1: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input,
      data_out => tmp(0));

  -- delay input by one clock cycle
  reg1_2: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => tmp(0),
      data_out => tmp(1));

  output <= '1' when tmp(1) = (not edge) and tmp(0) = edge else '0';

end architecture behav;
