-- Copyright (c) 2013-2017, Nils Christopher Brause
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

--! complex multiplier

--! The multiplier can mutiply complex signed or unsigned numbers.
entity cmplx_mul is
  generic (
    bits1         : natural;                 --! width of first input
    bits2         : natural;                 --! width of second input
    out_bits      : natural;                 --! width of the output
    signed_arith  : boolean := true;         --! use signed arithmetic
    use_registers : boolean := false);       --! use additional registers on slow FPGAs
  port (
    clk         : in  std_logic;             --! clock input
    reset       : in  std_logic;             --! ansynchronous reset (active low)
    input1_real : in  std_logic_vector(bits1-1 downto 0);  --! multiplicator
    input1_imag : in  std_logic_vector(bits1-1 downto 0);  --! multiplicator
    input2_real : in  std_logic_vector(bits2-1 downto 0);  --! multiplicand
    input2_imag : in  std_logic_vector(bits2-1 downto 0);  --! multiplicand
    output_real : out std_logic_vector(out_bits-1 downto 0);  --! product
    output_imag : out std_logic_vector(out_bits-1 downto 0));  --! product
end entity cmplx_mul;

architecture behav of cmplx_mul is

  signal real1_real2 : std_logic_vector(bits1+bits2-1 downto 0);
  signal real1_imag2 : std_logic_vector(bits1+bits2-1 downto 0);
  signal imag1_real2 : std_logic_vector(bits1+bits2-1 downto 0);
  signal imag1_imag2 : std_logic_vector(bits1+bits2-1 downto 0);

  signal real1_real2_tmp : std_logic_vector(out_bits-1 downto 0);
  signal real1_imag2_tmp : std_logic_vector(out_bits-1 downto 0);
  signal imag1_real2_tmp : std_logic_vector(out_bits-1 downto 0);
  signal imag1_imag2_tmp : std_logic_vector(out_bits-1 downto 0);

begin  -- architecture behav

  -- (r1 + i*i1)(r2 + i*i2) = r1*r2 - i1*i2 + i*(i1*r2 + r1*i2)

  mul_real1_real2: entity work.mul
    generic map (
      bits1         => bits1,
      bits2         => bits2,
      signed_arith  => signed_arith,
      use_registers => use_registers)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input1_real,
      input2 => input2_real,
      output => real1_real2);

  mul_real1_imag2: entity work.mul
    generic map (
      bits1         => bits1,
      bits2         => bits2,
      signed_arith  => signed_arith,
      use_registers => use_registers)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input1_real,
      input2 => input2_imag,
      output => real1_imag2);

  mul_imag1_real2: entity work.mul
    generic map (
      bits1         => bits1,
      bits2         => bits2,
      signed_arith  => signed_arith,
      use_registers => use_registers)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input1_imag,
      input2 => input2_real,
      output => imag1_real2);

  mul_imag1_imag2: entity work.mul
    generic map (
      bits1         => bits1,
      bits2         => bits2,
      signed_arith  => signed_arith,
      use_registers => use_registers)
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input1_imag,
      input2 => input2_imag,
      output => imag1_imag2);

  signed_arith_yes: if signed_arith generate
    -- left shift by one dure to sign bit
    real1_real2_tmp <= real1_real2(bits1+bits2-2 downto bits1+bits2-1-out_bits);
    real1_imag2_tmp <= real1_imag2(bits1+bits2-2 downto bits1+bits2-1-out_bits);
    imag1_real2_tmp <= imag1_real2(bits1+bits2-2 downto bits1+bits2-1-out_bits);
    imag1_imag2_tmp <= imag1_imag2(bits1+bits2-2 downto bits1+bits2-1-out_bits);
  end generate signed_arith_yes;

  signed_arith_no: if not signed_arith generate
    real1_real2_tmp <= real1_real2(bits1+bits2-1 downto bits1+bits2-out_bits);
    real1_imag2_tmp <= real1_imag2(bits1+bits2-1 downto bits1+bits2-out_bits);
    imag1_real2_tmp <= imag1_real2(bits1+bits2-1 downto bits1+bits2-out_bits);
    imag1_imag2_tmp <= imag1_imag2(bits1+bits2-1 downto bits1+bits2-out_bits);
  end generate signed_arith_no;

  sub_real: entity work.sub
    generic map (
      bits          => out_bits,
      use_registers => use_registers)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => real1_real2_tmp,
      input2     => imag1_imag2_tmp,
      output     => output_real,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  add_imag: entity work.add
    generic map (
      bits          => out_bits,
      use_registers => use_registers)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => real1_imag2_tmp,
      input2    => imag1_real2_tmp,
      output    => output_imag,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);

end architecture behav;
