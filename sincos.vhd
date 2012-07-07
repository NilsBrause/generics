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
use work.lut.all;

entity sincos is
  generic (
    phase_bits : natural;
    bits       : natural);
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    phase : in  std_logic_vector(phase_bits-1 downto 0);
    sin   : out std_logic_vector(bits-1 downto 0);
    cos   : out std_logic_vector(bits-1 downto 0));
end entity sincos;

architecture behav of sincos is

  signal phase2    : std_logic_vector(lut_in_bits+1 downto 0) := (others => '0');
  signal quadrant  : std_logic_vector(1 downto 0) := (others => '0');
  signal quadrant2 : std_logic_vector(1 downto 0) := (others => '0');
  signal idx       : std_logic_vector(lut_in_bits-1 downto 0) := (others => '0');
  signal val0      : std_logic_vector(lut_out_bits-1 downto 0) := (others => '0');
  signal val1      : std_logic_vector(lut_out_bits-1 downto 0) := (others => '0');
  signal val2      : std_logic_vector(lut_out_bits-1 downto 0) := (others => '0');
  signal val3      : std_logic_vector(lut_out_bits-1 downto 0) := (others => '0');
  signal cos_tmp   : std_logic_vector(lut_out_bits-1 downto 0) := (others => '0');
  signal sin_tmp   : std_logic_vector(lut_out_bits-1 downto 0) := (others => '0');

begin  -- architecture behav

  more: if phase_bits > lut_in_bits+2 generate
    phase2 <= phase(phase_bits-1 downto phase_bits-lut_in_bits-2);
  end generate more;
  
  less: if phase_bits <= lut_in_bits+2 generate
    phase2(lut_in_bits+1 downto lut_in_bits+2-phase_bits) <= phase;
    phase2(lut_in_bits-phase_bits+1 downto 0) <= (others => '0');
  end generate less;
  
  quadrant2 <= phase2(lut_in_bits+1 downto lut_in_bits);
  idx <= phase2(lut_in_bits-1 downto 0);
  
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
  
  cos_tmp <= val0 when quadrant = "00" else
             not val1 when quadrant = "01" else
             not val0 when quadrant = "10" else
             val1 when quadrant = "11" else
             (others => '0');
  sin_tmp <= val1 when quadrant = "00" else
             val0 when quadrant = "01" else
             not val1 when quadrant = "10" else
             not val0 when quadrant = "11" else
             (others => '0');

  more2: if bits > lut_out_bits generate
    sin(bits-1 downto bits-lut_out_bits) <= sin_tmp;
    sin(bits-lut_out_bits-1 downto 0) <= (others => '0');
    cos(bits-1 downto bits-lut_out_bits) <= cos_tmp;
    cos(bits-lut_out_bits-1 downto 0) <= (others => '0');
  end generate more2;

  less2: if bits <= lut_out_bits generate
    sin <= sin_tmp(lut_out_bits-1 downto lut_out_bits-bits);
    cos <= cos_tmp(lut_out_bits-1 downto lut_out_bits-bits);
  end generate less2;

end architecture behav;
