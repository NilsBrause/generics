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

entity array_adder is
  generic (
    bits            : natural;
    width           : natural;
    use_kogge_stone : bit := '0');
  port (
    data  : in  std_logic_vector(width*bits-1 downto 0);
    sum   : out std_logic_vector(width-1+bits-1 downto 0));
end array_adder;

architecture tree_add of array_adder is

  component add is
    generic (
      bits            : natural;
      use_kogge_stone : bit);
    port (
      input1    : in  std_logic_vector(bits-1 downto 0);
      input2    : in  std_logic_vector(bits-1 downto 0);
      output    : out std_logic_vector(bits-1 downto 0);
      carry_in  : in  std_logic;
      carry_out : out std_logic;
      overflow  : out std_logic);
  end component add;

  component reg is
    generic (
      bits : natural);
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      enable   : in  std_logic;
      data_in  : in  std_logic_vector(bits-1 downto 0);
      data_out : out std_logic_vector(bits-1 downto 0));
  end component reg;

  constant stages : natural := log2ceil(width)+1;
  constant swidth : natural := 2**(stages-1);
  constant sum_bits : natural := width+bits-1;
  constant nodes : natural := 2*swidth-1;

  function tree(r, c, w : natural) return natural is
    variable s : natural := 0;
  begin
    if r > 0 then
      for n in 1 to r loop
        s := s + w/(2**(n-1));
      end loop;
    end if;
    return s + c;
  end function;

  signal summand : std_logic_vector(nodes*sum_bits-1 downto 0);
--  signal temp : std_logic_vector((nodes-swidth)*(sum_bits+1)-1 downto 0);
  
begin  -- tree_add

  summands: for i in 0 to width-1 generate
    summand(i*sum_bits + bits-1 downto i*sum_bits)
      <= data(i*bits + bits-1 downto i*bits);
    summand(i*sum_bits + sum_bits-1 downto i*sum_bits + bits)
      <= (others => data(i*bits + bits-1));
  end generate summands;

  zeros: for i in width to swidth-1 generate
    summand(i*sum_bits + sum_bits-1 downto i*sum_bits) <= (others => '0');
  end generate zeros;

  stage: for c in 1 to stages-1 generate
    adds: for i in 0 to 2**(stages-1-c)-1 generate
      add_1: add
        generic map (
          bits            => sum_bits,
          use_kogge_stone => use_kogge_stone)
        port map (
          input1    => summand(tree(c-1, 2*i, swidth)*sum_bits + sum_bits-1
                               downto tree(c-1, 2*i, swidth)*sum_bits),
          input2    => summand(tree(c-1, 2*i+1, swidth)*sum_bits + sum_bits-1
                               downto tree(c-1, 2*i+1, swidth)*sum_bits),
          output    => summand(tree(c, i, swidth)*sum_bits + sum_bits-1
                               downto tree(c, i, swidth)*sum_bits),
--          output    => temp(tree(c-1, i, swidth/2)*(sum_bits+1) + (sum_bits+1)-1
--                            downto tree(c-1, i, swidth/2)*(sum_bits+1)),
          carry_in  => '0',
          carry_out => open,
          overflow  => open);
--      summand(tree(c, i, swidth)*sum_bits + sum_bits-1
--              downto tree(c, i, swidth)*sum_bits)
--        <= temp(tree(c-1, i, swidth/2)*(sum_bits+1) + sum_bits-1
--                downto tree(c-1, i, swidth/2)*(sum_bits+1));
    end generate adds;
  end generate stage;

  sum <= summand(tree(stages-1, 0, swidth)*sum_bits + sum_bits-1
                           downto tree(stages-1, 0, swidth)*sum_bits);

end tree_add;
