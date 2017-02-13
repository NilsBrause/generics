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

--! Subtractor

--! A subtractor subtracts two unsigned or signed numbers and outputs the result.
--! It also includes borrow logic and signed underflow detection.
entity sub is
  generic (
    bits          : natural;            --! number of bits
    use_registers : boolean := false);  --! use additional registers on slow FPGAs
  port (
    clk        : in  std_logic;         --! clock input
    reset      : in  std_logic;         --! asynchronous reset (active low)
    input1     : in  std_logic_vector(bits-1 downto 0);  --! minuend
    input2     : in  std_logic_vector(bits-1 downto 0);  --! subtrahend
    output     : out std_logic_vector(bits-1 downto 0);  --! difference
    borrow_in  : in  std_logic;         --! borrow input
    borrow_out : out std_logic;         --! borrow output or unsigned underflow indicator
    underflow  : out std_logic);        --! signed underflow indicator
end entity sub;

architecture behav of sub is

  signal input2n : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal carry_in : std_logic := '0';
  signal carry_out : std_logic := '0';
  
begin  -- architecture behav

  input2n <= not input2;
  carry_in <= not borrow_in;

  add_1: entity work.add
    generic map (
      bits          => bits,
      use_registers => use_registers)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => input1,
      input2    => input2n,
      output    => output,
      carry_in  => carry_in,
      carry_out => carry_out,
      overflow  => underflow);

  borrow_out <= not carry_out;

end architecture behav;
