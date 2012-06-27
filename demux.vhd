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

entity demultiplex is
  generic (
    bits      : natural;
    code_bits : natural);
  port (
    code   : in  std_logic_vector(code_bits-1 downto 0);
    input  : in  std_logic_vector(2**code_bits*bits-1 downto 0);
    output : out std_logic_vector(bits-1 downto 0));
end entity demultiplex;

architecture behav of demultiplex is

  signal decode : std_logic_vector(2**code_bits-1 downto 0);
  signal input2 : std_logic_vector(2**code_bits*bits-1 downto 0);
  signal input3 : std_logic_vector(2**code_bits*bits-1 downto 0);

begin  -- architecture behav

  decoder_1: entity work.decoder
    generic map (
      bits => code_bits)
    port map (
      input  => code,
      output => decode);

  and_loop: for c in 0 to 2**code_bits-1 generate
    bits_loop: for b in 0 to bits-1 generate
      input2(c*bits+b) <= input(c*bits+b) and decode(c);
    end generate bits_loop;
  end generate and_loop;

  input3(bits-1 downto 0) <= input2(bits-1 downto 0);
  or_loop: for c in 1 to 2**code_bits-1 generate
    input3((c+1)*bits-1 downto c*bits) <= input3(c*bits-1 downto (c-1)*bits) or
                                          input2((c+1)*bits-1 downto c*bits);
  end generate or_loop;
  output <= input3(2**code_bits*bits-1 downto (2**code_bits-1)*bits);

end architecture behav;
