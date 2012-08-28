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

entity add is
  generic (
    bits : natural;
    use_registers   : bit := '0';
    use_kogge_stone : bit := '0');
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    input1    : in  std_logic_vector(bits-1 downto 0);
    input2    : in  std_logic_vector(bits-1 downto 0);
    output    : out std_logic_vector(bits-1 downto 0);
    carry_in  : in  std_logic;
    carry_out : out std_logic;
    overflow  : out std_logic);
end entity add;

architecture behav of add is

  signal input1_tmp : std_logic_vector(bits+1 downto 0) := (others => '0');
  signal input2_tmp : std_logic_vector(bits+1 downto 0) := (others => '0');
  signal output_tmp : std_logic_vector(bits+1 downto 0) := (others => '0');
  signal overflow_tmp : std_logic;

begin  -- architecture behav

  input1_tmp(bits+1) <= '0';
  input1_tmp(bits downto 1) <= input1;
  input1_tmp(0) <= carry_in;

  input2_tmp(bits+1) <= '0';
  input2_tmp(bits downto 1) <= input2;
  input2_tmp(0) <= carry_in;

  kogge_stone_no: if use_kogge_stone = '0' generate
    output_tmp <= std_logic_vector(unsigned(input1_tmp) + unsigned(input2_tmp));
  end generate kogge_stone_no;

  kogge_stone_yes: if use_kogge_stone = '1' generate
    kogge_stone_1: entity work.kogge_stone
      generic map (
        bits => bits+1)
      port map (
        A => input1_tmp(bits downto 0),
        B => input2_tmp(bits downto 0),
        S => output_tmp);
  end generate kogge_stone_yes;

    -- signed overflow
  overflow_tmp <= (input1(bits-1) xnor input2(bits-1))
                  and (input1(bits-1) xor output_tmp(bits));

  use_registers_yes: if use_registers = '1' generate
    reg_1: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => output_tmp(bits downto 1),
        data_out => output);
    
    reg1_1: entity work.reg1
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => output_tmp(bits+1),
        data_out => carry_out);

    reg1_2: entity work.reg1
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => overflow_tmp,
        data_out => overflow);
end generate use_registers_yes;

  use_registers_no: if use_registers = '0' generate
    carry_out <= output_tmp(bits+1);
    output <= output_tmp(bits downto 1);
    overflow <= overflow_tmp;
  end generate use_registers_no;
  
end architecture behav;
