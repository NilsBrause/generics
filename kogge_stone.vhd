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
use work.log2.all;

--! Koge-Stone adder

--! The kogge-stone adder is the most efficient way to imolement an adder.
entity kogge_stone is
  generic (
    bits : natural);                    --! width of input
  port (
    A : in  std_logic_vector(bits-1 downto 0);  --! first summand
    B : in  std_logic_vector(bits-1 downto 0);  --! second summand
    S : out std_logic_vector(bits downto 0));  --! sum
end entity kogge_stone;

architecture behav of kogge_stone is

  constant max : natural := log2ceil(bits);

  signal P : std_logic_vector((max+1)*bits-1 downto 0) := (others => '0');
  signal G : std_logic_vector((max+1)*bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  stage0: for i in 0 to bits-1 generate
    P(0*bits + i) <= A(i) xor B(i);
    G(0*bits + i) <= A(i) and B(i);
  end generate stage0;

  stages: for c in 1 to max generate
    stagea: for i in 0 to 2**(c-1)-1 generate
      P(c*bits + i) <= P((c-1)*bits + i);
      G(c*bits + i) <= G((c-1)*bits + i);
    end generate stagea;
    stageb: for i in 2**(c-1) to bits-1 generate
      P(c*bits + i) <= P((c-1)*bits + i) and P((c-1)*bits + i-2**(c-1));
      G(c*bits + i) <= (P((c-1)*bits + i) and G((c-1)*bits + i-2**(c-1)))
                       or G((c-1)*bits + i);
    end generate stageb;
  end generate stages;

  S(0) <= P(0*bits + 0);
  stagen: for i in 1 to bits-1 generate
    S(i) <= P(0*bits + i) xor G(max*bits + i-1);
  end generate stagen;
  S(bits) <= G(max*bits + bits-1);

end architecture behav;
