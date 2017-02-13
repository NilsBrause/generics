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

--! Complex Subtractor

--! This subtractor subtracts two signed or unsigned complex numbers
--! and outputs the result. There is no borrow logic.
entity cmplx_sub is
  generic (
    bits          : natural;              --! width of input
    use_registers : boolean := false);          --! use additional registers on slow FPGAs
  port (
    clk         : in  std_logic;          --! input clock
    reset       : in  std_logic;          --! asynchronous reset
    input1_real : in  std_logic_vector(bits-1 downto 0);  --! first summand (r)
    input1_imag : in  std_logic_vector(bits-1 downto 0);  --! first summand (i)
    input2_real : in  std_logic_vector(bits-1 downto 0);  --! second summand (r)
    input2_imag : in  std_logic_vector(bits-1 downto 0);  --! second summand (i)
    output_real : out std_logic_vector(bits-1 downto 0);  --! output sum (r)
    output_imag : out std_logic_vector(bits-1 downto 0);  --! output sum (i)
    underflow   : out std_logic);       --! signed underflow detection
end entity cmplx_sub;

architecture behav of cmplx_sub is

  signal real_underflow : std_logic;
  signal imag_underflow : std_logic;

begin  -- architecture behav

  sub_real: entity work.sub
    generic map (
      bits          => bits,
      use_registers => use_registers)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => input1_real,
      input2     => input2_real,
      output     => output_real,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => real_underflow);

  sub_imag: entity work.sub
    generic map (
      bits          => bits,
      use_registers => use_registers)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => input1_imag,
      input2     => input2_imag,
      output     => output_imag,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => imag_underflow);

  underflow <= real_underflow or imag_underflow;

end architecture behav;
