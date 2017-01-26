-- Copyright (c) 2016, Nils Christopher Brause
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

--! Negative

entity neg is
  generic (
    bits : natural;                     --! number of bits
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk        : in  std_logic;         --! clock input
    reset      : in  std_logic;         --! asynchronous reset (active low)
    input      : in  std_logic_vector(bits-1 downto 0);  --! input
    output     : out std_logic_vector(bits-1 downto 0);  --! negative
    underflow  : out std_logic);        --! signed underflow indicator
end entity neg;

architecture behav of neg is

begin  -- architecture behav

  sub_1: entity work.sub
    generic map (
      bits            => bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => (others => '0'),
      input2     => input,
      output     => output,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => underflow);

end architecture behav;
