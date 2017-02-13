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

--! Complex Conjugate

--! The compex conjugate of a complex number a+i*b ist a-i*b.
--! The subtractor for the imaginary part may generate an underflow.
entity cmplx_conj is
  generic (
    bits          : natural;              --! width of input
    use_registers : boolean := false);    --! use additional registers on slow FPGAs
  port (
    clk         : in  std_logic;          --! input clock
    reset       : in  std_logic;          --! asynchronous reset
    input_real  : in  std_logic_vector(bits-1 downto 0);  --! real inpur
    input_imag  : in  std_logic_vector(bits-1 downto 0);  --! imaginary input
    output_real : out std_logic_vector(bits-1 downto 0);  --! real output
    output_imag : out std_logic_vector(bits-1 downto 0);  --! imaginary output
    underflow   : out std_logic);       --! signed underflow detection
end entity cmplx_conj;

architecture behav of cmplx_conj is

begin  -- architecture behav

  use_registers_yes: if use_registers generate
    reg_1: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input_real,
        data_out => output_real);
  end generate use_registers_yes;
  
  use_registers_no: if not use_registers generate
    output_real <= input_real;
  end generate use_registers_no;

  neg_1: entity work.neg
    generic map (
      bits          => bits,
      use_registers => use_registers)
    port map (
      clk       => clk,
      reset     => reset,
      input     => input_imag,
      output    => output_imag,
      underflow => underflow);

end architecture behav;
