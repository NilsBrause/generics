-- Copyright (c) 2013, Nils Christopher Brause
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

entity pulse_sync is
  port (
    clk    : in  std_logic;
    clk2   : in  std_logic;
    reset  : in  std_logic;
    input  : in  std_logic;
    output : out std_logic);
end entity pulse_sync;

architecture behav of pulse_sync is

  signal input2 : std_logic;
  signal reg_in : std_logic;
  signal reg_out : std_logic;
  signal clock : std_logic;
  signal rising : std_logic;
  signal falling : std_logic;

begin  -- architecture behav

  -- sync input to clk
  sync_reg_1: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input,
      data_out => input2);

  -- create 50% clock
  not_reg: entity work.reg1
    port map (
      clk      => input2,
      reset    => reset,
      enable   => '1',
      data_in  => reg_in,
      data_out => reg_out);

  reg_in <= not reg_out;

  -- sync new clk to clk2
  sync_reg_2: entity work.reg1
    port map (
      clk      => clk2,
      reset    => reset,
      enable   => '1',
      data_in  => reg_out,
      data_out => clock);

  -- detect rising edge
  rising_edge_detector: entity work.edge_detector
    generic map (
      edge => '1')
    port map (
      clk    => clk2,
      reset  => reset,
      input  => clock,
      output => rising);

  -- detect falling edge
  falling_edge_detector: entity work.edge_detector
    generic map (
      edge => '0')
    port map (
      clk    => clk2,
      reset  => reset,
      input  => clock,
      output => falling);

  output <= rising or falling;

end architecture behav;
