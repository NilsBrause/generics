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

entity barrel_shift_int is
  generic (
    bits           : natural;
    value          : natural;
    signed_arith   : boolean := true;
    direction_left : boolean := false); --! false = right, true = left
  port (
    input  : in  std_logic_vector(bits-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity barrel_shift_int;

architecture behav of barrel_shift_int is

begin  -- architecture behav

  right: if not direction_left generate
    signed_yes: if signed_arith generate
      output(bits-1 downto bits-value)
        <= (others => input(bits-1));
    end generate signed_yes;
    signed_no: if not signed_arith generate
      output(bits-1 downto bits-value)
        <= (others => '0');
    end generate signed_no;
    foo: if bits > value generate
      output(bits-value-1 downto 0)
        <= input(bits-1 downto value);
    end generate foo;
  end generate right;

  left: if direction_left generate
    bar: if bits > value generate
      output(bits-1 downto value)
        <= input(bits-value-1 downto 0);
    end generate bar;
    output(value-1 downto 0)
      <= (others => '0');
  end generate left;

end architecture behav;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.log2.all;

entity barrel_shift2 is
  generic (
    bits           : natural;             --! width of input
    signed_arith   : boolean := true;
    direction_left : boolean := false); --! false = right, true = left
  port (
    input  : in  std_logic_vector(bits-1 downto 0);
    amount : in  std_logic_vector(log2ceil(bits)-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity barrel_shift2;

architecture behav of barrel_shift2 is

  type output_t is array (integer range <>) of std_logic_vector(bits-1 downto 0);
  signal outputs : output_t(0 to bits);
  signal iamount : natural;

begin  -- architecture behav

  outputs(0) <= input;
  
  shifts: for c in 1 to bits generate
    barrel_shift_int_1: entity work.barrel_shift_int
      generic map (
        bits           => bits,
        value          => c,
        signed_arith   => signed_arith,
        direction_left => direction_left)
      port map (
        input  => input,
        output => outputs(c));
  end generate shifts;

  iamount <= to_integer(unsigned(amount));
  output <= outputs(iamount) when iamount <= bits else
            (others => '0');
  
end architecture behav;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.log2.all;

--! Barrel shifter

--! A barel shift can be used to efficiently multipliy or divide by powers of
--! two. Whwn shifting to the right, the top most bit will either be filled
--! with zeros (unsigned) od the the former most significant bit (sigend).
entity barrel_shift is
  generic (
    bits         : natural;             --! number of bits to shift
    signed_arith : boolean := true);    --! use signed arithmetic
  port (
    input  : in  std_logic_vector(bits-1 downto 0);  --! input value
    --! amount of bits to shift (positive = left, negative = rigt)
    amount : in  std_logic_vector(log2ceil(bits)-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));  --! shifted output
end entity barrel_shift;

architecture behav of barrel_shift is

  type output_t is array (integer range <>) of std_logic_vector(bits-1 downto 0);
  signal outputs : output_t(-bits to bits);

begin  -- architecture behav

  left: for c in 1 to bits generate
    barrel_shift_int_1: entity work.barrel_shift_int
      generic map (
        bits           => bits,
        value          => c,
        signed_arith   => signed_arith,
        direction_left => true)
      port map (
        input  => input,
        output => outputs(c));
  end generate left;

  outputs(0) <= input;
  
  right: for c in -1 downto -bits generate
    barrel_shift_int_1: entity work.barrel_shift_int
      generic map (
        bits           => bits,
        value          => -c,
        signed_arith   => signed_arith,
        direction_left => false)
      port map (
        input  => input,
        output => outputs(c));
  end generate right;

  output <= outputs(to_integer(signed(amount)));
    
end architecture behav;
