-- Copyright (c) 2014, Nils Christopher Brause
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
use ieee.math_real.all;

entity butterfly is
  generic (
    bits            : natural;
    k               : natural := 0;
    N               : natural := 1;
    use_kn          : bit := '0';       --! use k & N or provides sin/cos
    signed_arith    : bit := '1';       --! use signed arithmetic
    use_registers   : bit := '1';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    cos_in       : in  std_logic_vector(bits-1 downto 0);
    msin_in      : in  std_logic_vector(bits-1 downto 0);
    input1_real  : in  std_logic_vector(bits-1 downto 0);
    input1_imag  : in  std_logic_vector(bits-1 downto 0);
    input2_real  : in  std_logic_vector(bits-1 downto 0);
    input2_imag  : in  std_logic_vector(bits-1 downto 0);
    output1_real : out std_logic_vector(bits-1 downto 0);
    output1_imag : out std_logic_vector(bits-1 downto 0);
    output2_real : out std_logic_vector(bits-1 downto 0);
    output2_imag : out std_logic_vector(bits-1 downto 0));
end entity butterfly;

architecture behav of butterfly is

  -- sin(2*pi*k/N)
  function isin(k : integer; N : integer) return std_logic_vector is
    variable tmp : real;
  begin
    tmp := sin(real(k)/real(N)*MATH_PI*real(2))*real(2**(bits-1)-1);
    return std_logic_vector(to_signed(integer(tmp), bits));
  end isin;
  
  -- cos(2*pi*k/N)
  function icos(k : integer; N : integer) return std_logic_vector is
    variable tmp : real;
  begin
    tmp := cos(real(k)/real(N)*MATH_PI*real(2))*real(2**(bits-1)-1);
    return std_logic_vector(to_signed(integer(tmp), bits));
  end icos;

  signal cos2         : std_logic_vector(bits-1 downto 0);
  signal msin2        : std_logic_vector(bits-1 downto 0);
  signal input1_real2 : std_logic_vector(bits-1 downto 0);
  signal input1_imag2 : std_logic_vector(bits-1 downto 0);
  signal input1_real3 : std_logic_vector(bits-1 downto 0);
  signal input1_imag3 : std_logic_vector(bits-1 downto 0);
  signal input1_real4 : std_logic_vector(bits-1 downto 0);
  signal input1_imag4 : std_logic_vector(bits-1 downto 0);
  signal input2_real2 : std_logic_vector(bits-1 downto 0);
  signal input2_imag2 : std_logic_vector(bits-1 downto 0);
  signal input2_real3 : std_logic_vector(bits-1 downto 0);
  signal input2_imag3 : std_logic_vector(bits-1 downto 0);
  signal input2_real4 : std_logic_vector(bits-1 downto 0);
  signal input2_imag4 : std_logic_vector(bits-1 downto 0);

begin  -- architecture behav
  -- wk = exp(-2*pi*i*k) = cos(2*pi*k) - i*sin(2*pi*k)
  -- t = x1 * wk
  -- y0 = x0 + t
  -- y1 = x0 - t

  -- calculate wk = exp(-2*pi*i*k) = cos(2*pi*k) - i*sin(2*pi*k)
  cos2 <= icos(k, N) when use_kn = '1' else cos_in;
  msin2 <= std_logic_vector(-signed(isin(k, N))) when use_kn = '1' else msin_in;
  
  -- calculate t = x1 * wk
  cmplx_mul_1: entity work.cmplx_mul
    generic map (
      bits1           => bits,
      bits2           => bits,
      out_bits        => bits,
      signed_arith    => signed_arith,
      use_registers   => '0',
      use_kogge_stone => use_kogge_stone)
    port map (
      clk         => clk,
      reset       => reset,
      input1_real => input2_real,
      input1_imag => input2_imag,
      input2_real => cos2,
      input2_imag => msin2,
      output_real => input2_real2,
      output_imag => input2_imag2);

  input1_real2 <= input1_real;
  input1_imag2 <= input1_imag;

  use_registers_yes: if use_registers = '1' generate
    reg_input1_real: entity work.reg
      generic map (
        bits  => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input1_real2,
        data_out => input1_real3);
        
    reg_input1_imag: entity work.reg
      generic map (
        bits  => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input1_imag2,
        data_out => input1_imag3);
  
    reg_input2_real: entity work.reg
      generic map (
        bits  => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_real2,
        data_out => input2_real3);
        
    reg_input2_imag: entity work.reg
      generic map (
        bits  => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_imag2,
        data_out => input2_imag3);
  end generate use_registers_yes;
  
  use_registers_no: if use_registers = '0' generate
    input1_real3 <= input1_real2;
    input1_imag3 <= input1_imag2;
    input2_real3 <= input1_real2;
    input2_imag3 <= input1_imag2;
  end generate use_registers_no;
  
  -- attenuation to prevent overflow
  input1_real4 <= input1_real3(bits-1) & input1_real3(bits-1 downto 1);
  input1_imag4 <= input1_imag3(bits-1) & input1_imag3(bits-1 downto 1);
  input2_real4 <= input2_real3(bits-1) & input2_real3(bits-1 downto 1);
  input2_imag4 <= input2_imag3(bits-1) & input2_imag3(bits-1 downto 1);
  
  -- calculate y0 = x0 + t
  cmplx_add_1: entity work.cmplx_add
    generic map (
      bits            => bits,
      use_registers   => '0',
      use_kogge_stone => use_kogge_stone)
    port map (
      clk         => clk,
      reset       => reset,
      input1_real => input1_real4,
      input1_imag => input1_imag4,
      input2_real => input2_real4,
      input2_imag => input2_imag4,
      output_real => output1_real,
      output_imag => output1_imag,
      overflow    => open);

  -- calculate y1 = x0 - t
  cmplx_sub_1: entity work.cmplx_sub
    generic map (
      bits            => bits,
      use_registers   => '0',
      use_kogge_stone => use_kogge_stone)
    port map (
      clk         => clk,
      reset       => reset,
      input1_real => input1_real4,
      input1_imag => input1_imag4,
      input2_real => input2_real4,
      input2_imag => input2_imag4,
      output_real => output2_real,
      output_imag => output2_imag,
      underflow   => open);
end architecture behav;
