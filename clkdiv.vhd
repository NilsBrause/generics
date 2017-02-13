-- Copyright (c) 2012-2017, Nils Christopher Brause
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

--! clock divider

--! This clock divider can be used to generate a slower clock from a fast clock by
--! dividing its frequency by N, where N doesn't have to be a power of two.
entity clkdiv is
  generic (
    div : natural);                     --! clock divider
  port (
    clk     : in  std_logic;            --! clock input
    reset   : in  std_logic;            --! asynchronous reset (active low)
    enable  : in  std_logic;            --! enable pin
    clk_out : out std_logic);           --! divided clock output
end entity clkdiv;

architecture behav of clkdiv is

  signal ratio : std_logic_vector(log2ceil(div)-1 downto 0) := (others => '0');
  signal gated : std_logic;

begin  -- architecture behav

  ratio <= std_logic_vector(to_unsigned(div/2, log2ceil(div)));
  
  div_01: if div = 0 or div = 1 generate
    clk_out <= clk;
  end generate div_01;

  div_much: if div > 1 generate
  pwm_1: entity work.pwm
    generic map (
      bits => div)
    port map (
      clk    => clk,
      reset  => reset,
      enable => enable,
      ratio  => ratio,
      output => gated);

  -- convert gated clock to derived clock
  reg1_1: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      data_in  => gated,
      data_out => clk_out);
  end generate div_much;

end architecture behav;
