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

entity delay_reg is
  generic (
    bits  : natural;
    delay : natural);
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    enable   : in  std_logic;
    data_in  : in  std_logic_vector(bits-1 downto 0);
    data_out : out std_logic_vector(bits-1 downto 0));
end entity delay_reg;

architecture behav of delay_reg is

  component reg is
    generic (
      bits : natural);
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      enable   : in  std_logic;
      data_in  : in  std_logic_vector(bits-1 downto 0);
      data_out : out std_logic_vector(bits-1 downto 0));
  end component reg;

  signal tmp : std_logic_vector((delay+1)*bits-1 downto 0) := (others => '0');
  
begin  -- architecture behav

  tmp(bits-1 downto 0) <= data_in;

  regs: for c in 0 to delay-1 generate
    some_reg: reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => enable,
        data_in  => tmp((c+1)*bits-1 downto c*bits),
        data_out => tmp((c+2)*bits-1 downto (c+1)*bits));
  end generate regs;

  control: process (reset, enable, tmp) is
  begin  -- process control
    if reset = '0' then
      data_out <= (others => '0');
    elsif enable = '1' then
      data_out <= tmp((delay+1)*bits-1 downto delay*bits);    
    end if;
  end process control;
  
end architecture behav;
