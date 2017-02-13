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
use work.log2.all;

--! multiplier

--! The multiplier can mutiply signed or unsigned numbers.
entity mul is
  generic (
    bits1         : natural;            --! width of first input
    bits2         : natural;            --! width of second input
    signed_arith  : boolean := true;    --! use signed arithmetic
    use_registers : boolean := false);  --! use additional registers on slow FPGAs
  port (
    clk    : in  std_logic;             --! clock input
    reset  : in  std_logic;             --! ansynchronous reset (active low)
    input1 : in  std_logic_vector(bits1-1 downto 0);  --! multiplicator
    input2 : in  std_logic_vector(bits2-1 downto 0);  --! multiplicand
    output : out std_logic_vector(bits1+bits2-1 downto 0));  --! product
end entity mul;

architecture behav of mul is

  signal minput1    : std_logic_vector(bits1-1 downto 0) := (others => '0');
  signal minput2    : std_logic_vector(bits2-1 downto 0) := (others => '0');

  signal ninput1    : std_logic_vector(bits1-1 downto 0) := (others => '0');
  signal ninput2    : std_logic_vector(bits2-1 downto 0) := (others => '0');

  constant sum_bits : natural := bits1+bits2;
  signal summands   : std_logic_vector(bits1*sum_bits-1 downto 0) := (others => '0');
  signal tmp        : std_logic_vector(log2ceil(bits1)+sum_bits-1 downto 0) := (others => '0');

begin  -- architecture behavb

  signed_yes: if signed_arith generate
    tmp(bits1+bits2-1 downto 0) <= std_logic_vector(signed(input1) * signed(input2));
  end generate signed_yes;

  signed_no: if not signed_arith generate
    tmp(bits1+bits2-1 downto 0) <= std_logic_vector(unsigned(input1) * unsigned(input2));
  end generate signed_no;

  registers_yes: if use_registers generate
    reg_1: entity work.reg
      generic map (
        bits => bits1+bits2)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => tmp(bits1+bits2-1 downto 0),
        data_out => output);
  end generate registers_yes;

  registers_no: if not use_registers generate
    output <= tmp(bits1+bits2-1 downto 0);
  end generate registers_no;

end architecture behav;
