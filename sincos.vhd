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
use ieee.math_real.all;

entity sincos is
  generic (
    phase_bits : natural;
    bits       : natural);
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    phase  : in  std_logic_vector(phase_bits-1 downto 0);
    sinout : out std_logic_vector(bits-1 downto 0);
    cosout : out std_logic_vector(bits-1 downto 0));
end entity sincos;

architecture behav of sincos is

  constant lut_in_bits : natural := phase_bits-2;

  type rom_t is array (0 to 2**lut_in_bits-1) of std_logic_vector(bits-1 downto 0);

  function makelut return rom_t is
    variable tmp : rom_t;
    variable x : real;
  begin
    for c in 0 to 2**lut_in_bits-1 loop
      x := cos(real(c)/real(2**lut_in_bits-1)*MATH_PI/real(2))*real(2**(bits-1)-1);
      tmp(c) := std_logic_vector(to_signed(integer(x), bits));
    end loop;  -- c
    return tmp;
  end makelut;

  constant rom : rom_t := makelut;

  signal quadrant  : std_logic_vector(1 downto 0) := (others => '0');
  signal quadrant2 : std_logic_vector(1 downto 0) := (others => '0');
  signal idx       : std_logic_vector(lut_in_bits-1 downto 0) := (others => '0');
  signal val0      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val1      : std_logic_vector(bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  quadrant2 <= phase(phase_bits-1 downto phase_bits-2);
  idx <= phase(lut_in_bits-1 downto 0);
  
  -- make synthesizable RAM
  lutram: process (clk, reset) is
  begin
    if rising_edge(clk) then
      val0 <= rom(to_integer(unsigned(idx)));
      val1 <= rom(to_integer(unsigned(not idx)));
    end if;
  end process lutram;
  
  reg_3: entity work.reg
    generic map (
      bits => 2)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => quadrant2,
      data_out => quadrant);
  
  cosout <= val0 when quadrant = "00" else
            not val1 when quadrant = "01" else
            not val0 when quadrant = "10" else
            val1 when quadrant = "11" else
            (others => '0');
  sinout <= val1 when quadrant = "00" else
            val0 when quadrant = "01" else
            not val1 when quadrant = "10" else
            not val0 when quadrant = "11" else
            (others => '0');

end architecture behav;
