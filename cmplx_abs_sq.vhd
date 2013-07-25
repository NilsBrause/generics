-- Copyright (c) 2013, Nils Christopher Brause
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

--! Complex Absolue squared

--! This calculates the square of the absolute value of an complex number.
--! The subtractor for the imaginary part may generate an underflow.
entity cmplx_abs_sq is
  generic (
    bits : natural;                     --! width of input
    out_bits : natural;                 --! width of output
    signed_arith    : bit := '1';       --! use signed arithmetic
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk         : in  std_logic;          --! input clock
    reset       : in  std_logic;          --! asynchronous reset
    input_real  : in  std_logic_vector(bits-1 downto 0);  --! real inpur
    input_imag  : in  std_logic_vector(bits-1 downto 0);  --! imaginary input
    output_real : out std_logic_vector(out_bits-1 downto 0);  --! real output
    output_imag : out std_logic_vector(out_bits-1 downto 0);  --! imaginary output
    underflow   : out std_logic);       --! signed underflow detection
end entity cmplx_abs_sq;

architecture behav of cmplx_abs_sq is

  signal input_real2 : std_logic_vector(bits-1 downto 0);
  signal input_imag2 : std_logic_vector(bits-1 downto 0);

  signal input_cc_real : std_logic_vector(bits-1 downto 0);
  signal input_cc_imag : std_logic_vector(bits-1 downto 0);

begin  -- architecture behav

  use_registers_yes: if use_registers = '1' generate
    reg_input_real: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input_real,
        data_out => input_real2);

    reg_input_imag: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input_imag,
        data_out => input_imag2);
  end generate use_registers_yes;
  
  use_registers_no: if use_registers = '0' generate
    input_real2 <= input_real;
    input_imag2 <= input_imag;
  end generate use_registers_no;

  cmplx_conj_1: entity work.cmplx_conj
    generic map (
      bits            => bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk         => clk,
      reset       => reset,
      input_real  => input_real,
      input_imag  => input_imag,
      output_real => input_cc_real,
      output_imag => input_cc_imag,
      underflow   => underflow);

  cmplx_mul_1: entity work.cmplx_mul
    generic map (
      bits1           => bits,
      bits2           => bits,
      out_bits        => out_bits,
      signed_arith    => signed_arith,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk         => clk,
      reset       => reset,
      input1_real => input_real2,
      input1_imag => input_imag2,
      input2_real => input_cc_real,
      input2_imag => input_cc_imag,
      output_real => output_real,
      output_imag => output_imag);

end architecture behav;
 
