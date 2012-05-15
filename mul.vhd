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
use ieee.numeric_std.all;
use work.log2.all;

entity mul is
  generic (
    bits1           : natural;
    bits2           : natural;
    signed_arith    : bit := '1';
    use_kogge_stone : bit := '1');
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    input1 : in  std_logic_vector(bits1-1 downto 0);
    input2 : in  std_logic_vector(bits2-1 downto 0);
    output : out std_logic_vector(bits1+bits2-1 downto 0));
end entity mul;

architecture behav of mul is

  signal minput1    : std_logic_vector(bits1-1 downto 0);
  signal minput2    : std_logic_vector(bits2-1 downto 0);

  signal ninput1    : std_logic_vector(bits1-1 downto 0);
  signal ninput2    : std_logic_vector(bits2-1 downto 0);

  constant sum_bits : natural := bits1+bits2;
  signal summands   : std_logic_vector(bits1*sum_bits-1 downto 0);
  signal tmp        : std_logic_vector(log2ceil(bits1)+sum_bits-1 downto 0);

begin  -- architecture behavb

  kogge_stone_no: if use_kogge_stone = '0' generate

    signed_yes: if signed_arith = '1' generate
      output <= std_logic_vector(signed(input1) * signed(input2));
    end generate signed_yes;

    signed_no: if signed_arith = '0' generate
      output <= std_logic_vector(unsigned(input1) * unsigned(input2));
    end generate signed_no;

  end generate kogge_stone_no;

  kogge_stone_yes: if use_kogge_stone = '1' generate

    signed_yes: if signed_arith = '1' generate
      minput1 <= std_logic_vector(-signed(input1));
      minput2 <= std_logic_vector(-signed(input2));
      ninput1 <= input1 when input1(bits1-1) = '0' else minput1;
      ninput2 <= input2 when input1(bits1-1) = '0' else minput2;
    end generate signed_yes;

    signed_no: if signed_arith = '0' generate
      ninput1 <= input1;
      ninput2 <= input2;
    end generate signed_no;

    shifts: for i in 0 to bits1-1 generate
      
      signed_yes: if signed_arith = '1' generate
        summands(i*sum_bits + sum_bits-1 downto i*sum_bits + bits2+i)
          <= (others => ninput2(bits2-1)) when ninput1(i) = '1' else (others => '0');
      end generate signed_yes;
      
      signed_no: if signed_arith = '0' generate
        summands(i*sum_bits + sum_bits-1 downto i*sum_bits + bits2+i)
          <= (others => '0');
      end generate signed_no;
      
      summands(i*sum_bits + bits2+i-1 downto i*sum_bits + i)
        <= ninput2 when ninput1(i) = '1' else (others => '0');
      summands(i*sum_bits + i-1 downto i*sum_bits + 0)
        <= (others => '0');
      
    end generate shifts;

    array_adder_1: entity work.array_adder
      generic map (
        bits            => sum_bits,
        width           => bits1,
        signed_arith    => signed_arith,
        use_registers   => '1',
        use_kogge_stone => '1')
      port map (
        clk   => clk,
        reset => reset,
        data  => summands,
        sum   => tmp);

    output <= tmp((bits1+bits2)-1 downto 0);

  end generate kogge_stone_yes;

end architecture behav;
