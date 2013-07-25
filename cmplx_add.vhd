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

--! Complex Adder

--! This adder adds two signed or unsigned complex numbers
--! and outputs the result. There is no carry logic.
entity cmplx_add is
  generic (
    bits : natural;                     --! width of input
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk         : in  std_logic;          --! input clock
    reset       : in  std_logic;          --! asynchronous reset
    input1_real : in  std_logic_vector(bits-1 downto 0);  --! first summand (r)
    input1_imag : in  std_logic_vector(bits-1 downto 0);  --! first summand (i)
    input2_real : in  std_logic_vector(bits-1 downto 0);  --! second summand (r)
    input2_imag : in  std_logic_vector(bits-1 downto 0);  --! second summand (i)
    output_real : out std_logic_vector(bits-1 downto 0);  --! output sum (r)
    output_imag : out std_logic_vector(bits-1 downto 0);  --! output sum (i)
    overflow    : out std_logic);       --! signed overflow detection
end entity cmplx_add;

architecture behav of cmplx_add is

  signal real_overflow : std_logic;
  signal imag_overflow : std_logic;

begin  -- architecture behav

  add_real: entity work.add
    generic map (
      bits            => bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => input1_real,
      input2    => input2_real,
      output    => output_real,
      carry_in  => '0',
      carry_out => open,
      overflow  => real_overflow);

  add_imag: entity work.add
    generic map (
      bits            => bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk       => clk,
      reset     => reset,
      input1    => input1_imag,
      input2    => input2_imag,
      output    => output_imag,
      carry_in  => '0',
      carry_out => open,
      overflow  => imag_overflow);

  overflow <= real_overflow or imag_overflow;

end architecture behav;
