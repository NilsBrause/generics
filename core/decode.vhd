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

--! Decoder

--! A decoder transforms an arbitrary b bit number n into a 2^b bit vector
--! with the nth bit is set to '1' and all other bits are '0'.
entity decoder is
  generic (
    bits : natural);                    --! width of input signal
  port (
    input  : in  std_logic_vector(bits-1 downto 0);  --! input signal
    output : out std_logic_vector(2**bits-1 downto 0));  --! decoded output
end entity decoder;

architecture behav of decoder is

begin  -- architecture behav

  my_little_loopy: for c in 0 to 2**bits-1 generate
    output(c) <= '1' when input = std_logic_vector(to_unsigned(c, bits)) else
                 '0';
  end generate my_little_loopy;

end architecture behav;
