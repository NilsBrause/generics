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

--! sine/cosine

--! This is a sine/cosine look up table implementation, that can be used to
--! implement e.g. a numerically controlled oszillator.
entity sincos is
  generic (
    phase_bits    : natural;            --! width of the phase input
    bits          : natural;            --! width of the output
    use_registers : bit := '0';         --! use additional registers on slow FPGAs
    lut_type      : natural := 2);      --! length of the look up table = 2*pi/n
  port (
    clk    : in  std_logic;             --! clock input
    reset  : in  std_logic;             --! asynchronous reset (active low)
    phase  : in  std_logic_vector(phase_bits-1 downto 0);  --! phase input
    sinout : out std_logic_vector(bits-1 downto 0);  --! sine output
    cosout : out std_logic_vector(bits-1 downto 0)); --! cosine output
end entity sincos;

architecture behav of sincos is

  type dyn_rom1_t is array (0 to 2**phase_bits/1-1)
    of std_logic_vector(bits-1 downto 0);
  type dyn_rom2_t is array (0 to 2**phase_bits/2-1)
    of std_logic_vector(bits-1 downto 0);
  type dyn_rom4_t is array (0 to 2**phase_bits/4-1)
    of std_logic_vector(bits-1 downto 0);

  function makelut1 return dyn_rom1_t is
    variable tmp : dyn_rom1_t;
    variable x : real;
  begin
    for c in 0 to 2**phase_bits-1 loop
      x := cos(real(c)/real(2**phase_bits)*MATH_PI*real(2))*real(2**(bits-1)-1);
      tmp(c) := std_logic_vector(to_signed(integer(x), bits));
    end loop;  -- c
    return tmp;
  end makelut1;

  function makelut2 return dyn_rom2_t is
    variable tmp : dyn_rom2_t;
    variable x : real;
  begin
    for c in 0 to 2**phase_bits/2-1 loop
      x := cos(real(c)/real(2**phase_bits)*MATH_PI*real(2))*real(2**(bits-1)-1);
      tmp(c) := std_logic_vector(to_signed(integer(x), bits));
    end loop;  -- c
    return tmp;
  end makelut2;

  function makelut4 return dyn_rom4_t is
    variable tmp : dyn_rom4_t;
    variable x : real;
  begin
    for c in 0 to 2**phase_bits/4-1 loop
      x := cos(real(c)/real(2**phase_bits)*MATH_PI*real(2))*real(2**(bits-1)-1);
      tmp(c) := std_logic_vector(to_signed(integer(x), bits));
    end loop;  -- c
    return tmp;
  end makelut4;

  constant dyn_rom1 : dyn_rom1_t := makelut1;
  constant dyn_rom2 : dyn_rom2_t := makelut2;
  constant dyn_rom4 : dyn_rom4_t := makelut4;

  signal quadrant  : std_logic_vector(1 downto 0) := (others => '0');
  signal val0      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val1      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val2      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val3      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val4      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val5      : std_logic_vector(bits-1 downto 0) := (others => '0');

  signal sin_tmp : std_logic_vector(bits-1 downto 0);
  signal cos_tmp : std_logic_vector(bits-1 downto 0);

begin  -- architecture behav
  
  -- make synthesizable RAM
  lutram: process (clk, reset) is
  begin
    if rising_edge(clk) then
      val0 <= dyn_rom4(to_integer(unsigned(phase(phase_bits-3 downto 0))));
      val1 <= dyn_rom4(to_integer(unsigned(not phase(phase_bits-3 downto 0))));
      
      val2 <= dyn_rom2(to_integer(unsigned(phase(phase_bits-2 downto 0))));
      val3 <= dyn_rom2(to_integer(unsigned(not phase(phase_bits-2)
                                           & phase(phase_bits-3 downto 0))));
      
      val4 <= dyn_rom1(to_integer(unsigned(phase(phase_bits-1 downto 0))));
      val5 <= dyn_rom1(to_integer(unsigned(phase(phase_bits-1 downto 0))
                                  -2**phase_bits/4));
    end if;
  end process lutram;
  
  reg_3: entity work.reg
    generic map (
      bits => 2)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => phase(phase_bits-1 downto phase_bits-2),
      data_out => quadrant);
  
  cos_tmp <= val4 when lut_type = 1 else
             val2 when quadrant = "00" and lut_type = 2 else
             val2 when quadrant = "01" and lut_type = 2 else
             not val2 when quadrant = "10" and lut_type = 2 else
             not val2 when quadrant = "11" and lut_type = 2 else
             val0 when quadrant = "00" and lut_type = 4 else
             not val1 when quadrant = "01" and lut_type = 4 else
             not val0 when quadrant = "10" and lut_type = 4 else
             val1 when quadrant = "11" and lut_type = 4 else
             (others => '0');
  
  sin_tmp <= val5 when lut_type = 1 else
             val3 when quadrant = "10" and lut_type = 2 else
             val3 when quadrant = "01" and lut_type = 2 else
             not val3 when quadrant = "00" and lut_type = 2 else
             not val3 when quadrant = "11" and lut_type = 2 else
             val1 when quadrant = "00" and lut_type = 4 else
             val0 when quadrant = "01" and lut_type = 4 else
             not val1 when quadrant = "10" and lut_type = 4 else
             not val0 when quadrant = "11" and lut_type = 4 else
             (others => '0');

  use_registers_yes: if use_registers = '1' generate
    sin_reg: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => sin_tmp,
        data_out => sinout);
    
    cos_reg: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => cos_tmp,
        data_out => cosout);
  end generate use_registers_yes;

  use_registers_no: if use_registers = '0' generate
    sinout <= sin_tmp;
    cosout <= cos_tmp;
  end generate use_registers_no;

end architecture behav;
