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

entity barrel_shift_int is
  generic (
    bits         : natural;
    value        : natural;
    signed_arith : bit := '1';
    direction    : bit := '0'); -- '0' = right, '1' = left
  port (
    input  : in  std_logic_vector(bits-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity barrel_shift_int;

architecture behav of barrel_shift_int is

begin  -- architecture behav

  right: if direction = '0' generate
    signed_yes: if signed_arith = '1' generate
      output(bits-1 downto bits-value)
        <= (others => input(bits-1));
    end generate signed_yes;
    signed_no: if signed_arith = '0' generate
      output(bits-1 downto bits-value)
        <= (others => '0');
    end generate signed_no;
    output(bits-value-1 downto 0)
      <= input(bits-1 downto value);
  end generate right;

  left: if direction = '1' generate
    output(bits-1 downto value)
      <= input(bits-value-1 downto 0);
    output(value-1 downto 0)
      <= (others => '0');
  end generate left;

end architecture behav;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.log2.all;

entity barrel_shift is
  generic (
    bits         : natural;
    signed_arith : bit := '1');
  port (
    input  : in  std_logic_vector(bits-1 downto 0);
    amount : in  std_logic_vector(log2ceil(bits)-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity barrel_shift;

architecture behav of barrel_shift is

  type output_t is array (natural range <>) of std_logic_vector(bits-1 downto 0);
  signal outputs : output_t(-bits+1 to bits-1);

begin  -- architecture behav

  left: for c in 1 to bits-1 generate
    
    barrel_shift_int_1: entity work.barrel_shift_int
      generic map (
        bits         => bits,
        value        => c,
        signed_arith => signed_arith,
        direction    => '1')
      port map (
        input  => input,
        output => outputs(c));

  end generate left;

  outputs(0) <= input;
  
  right: for c in -1 downto -bits+1 generate
    
    barrel_shift_int_1: entity work.barrel_shift_int
      generic map (
        bits         => bits,
        value        => -c,
        signed_arith => signed_arith,
        direction    => '0')
      port map (
        input  => input,
        output => outputs(c));

  end generate right;

  output <= outputs(to_integer(signed(amount)));
    
end architecture behav;
