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

entity comparator is
  generic (
    bits : natural;
    use_kogge_stone : bit := '0');
  port (
    input1 : in  std_logic_vector(bits-1 downto 0);
    input2 : in  std_logic_vector(bits-1 downto 0);
    equal  : out std_logic;
    uless  : out std_logic;
    sless  : out std_logic);
end entity comparator;

architecture behav of comparator is

  signal cmp_out : std_logic_vector(bits-1 downto 0);
  signal sub_out : std_logic_vector(bits-1 downto 0);
  signal equal_tmp : std_logic_vector(bits-1 downto 0);
  signal carry : std_logic;
  signal overflow : std_logic;

begin  -- architecture behav

  -- test for equalness
  cmp_loop: for c in 0 to bits-1 generate
    cmp_out(c) <= input1(c) xnor input2(c);
  end generate cmp_loop;
  equal_tmp(bits-1) <= cmp_out(bits-1);
  equal2_loop: for c in bits-2 downto 0 generate
    equal_tmp(c) <= equal_tmp(c+1) and cmp_out(c);
  end generate equal2_loop;
  equal <= equal_tmp(0);

  sub_1: entity work.sub
    generic map (
      bits            => bits,
      use_kogge_stone => use_kogge_stone)
    port map (
      input1     => input1,
      input2     => input2,
      output     => sub_out,
      borrow_in  => '0',
      borrow_out => carry,
      underflow  => overflow);
  
  -- test for signed less
  sless <= (sub_out(bits-1) and not overflow)
           or (not sub_out(bits-1) and overflow);

  -- test for unsigned less
  uless <= carry;
  
end architecture behav;
