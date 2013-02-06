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

--! Moving average

--! Moving averages can be used as a low-pass filter. In contrast to
--! a CIC filter, the sample rate will not be reduced and the bit-length
--! stays constant. With a sample rate of fS, the frequency cut-off
--! is at fS/(2*avgs).
entity mov_avg is
  generic (
    bits : natural;                     --! width of signals
    avgs : natural);                    --! number of averages
  port (
    clk    : in  std_logic;             --! clock input
    reset  : in  std_logic;             --! asynchronous reset (active low)
    input  : in  std_logic_vector(bits-1 downto 0);  --! signal input
    output : out std_logic_vector(bits-1 downto 0));  --! signal output
end entity mov_avg;

architecture behav of mov_avg is

  signal in_ext : std_logic_vector(bits+avgs-1 downto 0);
  signal in_dly : std_logic_vector(bits+avgs-1 downto 0);
  signal sum : std_logic_vector(bits+avgs-1 downto 0);
  signal sum2 : std_logic_vector(bits+avgs-1 downto 0);
  signal sum3 : std_logic_vector(bits+avgs-1 downto 0);

begin  -- architecture behav

  in_ext(bits+avgs-1 downto bits) <= (others => input(bits-1));
  in_ext(bits-1 downto 0) <= input;

  delay_reg_1: entity work.delay_reg
    generic map (
      bits  => bits+avgs,
      delay => 2**avgs)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => in_ext,
      data_out => in_dly);

  add_1: entity work.add
    generic map (
      bits            => bits+avgs,
      use_registers   => '0',
      use_kogge_stone => '0')
    port map (
      clk       => clk,
      reset     => reset,
      input1    => sum,
      input2    => in_ext,
      output    => sum2,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

  sub_1: entity work.sub
    generic map (
      bits            => bits+avgs,
      use_registers   => '0',
      use_kogge_stone => '0')
    port map (
      clk        => clk,
      reset      => reset,
      input1     => sum2,
      input2     => in_dly,
      output     => sum3,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  reg_2: entity work.reg
    generic map (
      bits => bits+avgs)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => sum3,
      data_out => sum);

  output <= sum(bits+avgs-1 downto avgs);

end architecture behav;
