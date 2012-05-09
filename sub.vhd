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

entity sub is
  generic (
    bits : natural);
  port (
    input1     : in  std_logic_vector(bits-1 downto 0);
    input2     : in  std_logic_vector(bits-1 downto 0);
    output     : out std_logic_vector(bits-1 downto 0);
    borrow_in  : in  std_logic;
    borrow_out : out std_logic;
    underflow  : out std_logic);
end entity sub;

architecture behav of sub is

  component add is
    generic (
      bits : natural);
    port (
      input1    : in  std_logic_vector(bits-1 downto 0);
      input2    : in  std_logic_vector(bits-1 downto 0);
      output    : out std_logic_vector(bits-1 downto 0);
      carry_in  : in  std_logic;
      carry_out : out std_logic;
      overflow  : out std_logic);
  end component add;

  signal input2n : std_logic_vector(bits-1 downto 0);
  signal carry_in : std_logic;
  signal carry_out : std_logic;
  
begin  -- architecture behav

  input2n <= not input2;
  carry_in <= not borrow_in;

  add_1: add
    generic map (
      bits => bits)
    port map (
      input1    => input1,
      input2    => input2n,
      output    => output,
      carry_in  => carry_in,
      carry_out => carry_out,
      overflow  => underflow);

  borrow_out <= not carry_out;

end architecture behav;
