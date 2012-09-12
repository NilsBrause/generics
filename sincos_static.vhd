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
use work.lut.all;

--! sine/cosine (static)

--! This is a sine/cosine look up table implementation, that can be used to
--! implement e.g. a numerically controlled oszillator.
--! The static version requires an external lut, which can be generated with
--! the help of makelut.cpp
entity sincos_static is
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
end entity sincos_static;

architecture behav of sincos_static is

  signal quadrant  : std_logic_vector(1 downto 0) := (others => '0');
  signal val0      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val1      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val2      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val3      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val4      : std_logic_vector(bits-1 downto 0) := (others => '0');
  signal val5      : std_logic_vector(bits-1 downto 0) := (others => '0');

  signal phase2 : std_logic_vector(lut_bits-1 downto 0);
  signal val02  : std_logic_vector(lut_bits-1 downto 0) := (others => '0');
  signal val12  : std_logic_vector(lut_bits-1 downto 0) := (others => '0');
  signal val22  : std_logic_vector(lut_bits-1 downto 0) := (others => '0');
  signal val32  : std_logic_vector(lut_bits-1 downto 0) := (others => '0');
  signal val42  : std_logic_vector(lut_bits-1 downto 0) := (others => '0');
  signal val52  : std_logic_vector(lut_bits-1 downto 0) := (others => '0');

  signal sin_tmp : std_logic_vector(bits-1 downto 0);
  signal cos_tmp : std_logic_vector(bits-1 downto 0);

begin  -- architecture behav

  round_1: entity work.round
    generic map (
      inp_bits        => phase_bits,
      outp_bits       => lut_bits,
      signed_arith    => '0')
    port map (
      clk    => clk,
      reset  => reset,
      input  => phase,
      output => phase2);
  
  -- make synthesizable RAM
  lutram: process (clk, reset) is
  begin
    if rising_edge(clk) then
      val02 <= rom4(to_integer(unsigned(phase2(lut_bits-3 downto 0))));
      val12 <= rom4(to_integer(unsigned(not phase(lut_bits-3 downto 0))));
      
      val22 <= rom2(to_integer(unsigned(phase2(lut_bits-2 downto 0))));
      val32 <= rom2(to_integer(unsigned(not phase(lut_bits-2)
                                        & phase(lut_bits-3 downto 0))));
      
      val42 <= rom1(to_integer(unsigned(phase2(lut_bits-1 downto 0))));
      val52 <= rom1(to_integer(unsigned(phase2(lut_bits-1 downto 0))
                               -2**lut_bits/4));
    end if;
  end process lutram;
  
  round_2: entity work.round
    generic map (
      inp_bits        => lut_bits,
      outp_bits       => bits,
      signed_arith    => '0')
    port map (
      clk    => clk,
      reset  => reset,
      input  => val02,
      output => val0);
  
  round_3: entity work.round
    generic map (
      inp_bits        => lut_bits,
      outp_bits       => bits,
      signed_arith    => '0')
    port map (
      clk    => clk,
      reset  => reset,
      input  => val12,
      output => val1);
  
  round_4: entity work.round
    generic map (
      inp_bits        => lut_bits,
      outp_bits       => bits,
      signed_arith    => '0')
    port map (
      clk    => clk,
      reset  => reset,
      input  => val22,
      output => val2);
  
  round_5: entity work.round
    generic map (
      inp_bits        => lut_bits,
      outp_bits       => bits,
      signed_arith    => '0')
    port map (
      clk    => clk,
      reset  => reset,
      input  => val32,
      output => val3);
  
  round_6: entity work.round
    generic map (
      inp_bits        => lut_bits,
      outp_bits       => bits,
      signed_arith    => '0')
    port map (
      clk    => clk,
      reset  => reset,
      input  => val42,
      output => val4);
  
  round_7: entity work.round
    generic map (
      inp_bits        => lut_bits,
      outp_bits       => bits,
      signed_arith    => '0')
    port map (
      clk    => clk,
      reset  => reset,
      input  => val52,
      output => val5);
  
  reg_3: entity work.reg
    generic map (
      bits => 2)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => phase2(lut_bits-1 downto lut_bits-2),
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
