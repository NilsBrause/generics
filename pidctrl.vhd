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
use work.log2.all;

entity pidctrl is
  generic (
    bits            : natural;
    int_bits        : natural;
    signed_arith    : bit := '1';
    use_diff        : bit := '0';
    use_registers   : bit := '0';
    use_kogge_stone : bit := '0');
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    input    : in  std_logic_vector(bits-1 downto 0);
    pgain    : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);
    igain    : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);
    dgain    : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);
    output   : out std_logic_vector(bits-1 downto 0));
end entity pidctrl;

architecture behav of pidctrl is

  signal input3 : std_logic_vector(int_bits-1 downto 0) := (others => '0');
  signal input4 : std_logic_vector(int_bits-1 downto 0) := (others => '0');

  signal pout : std_logic_vector(int_bits-1 downto 0) := (others => '0');
  signal aout : std_logic_vector(int_bits-1 downto 0) := (others => '0');
  signal iout : std_logic_vector(int_bits-1 downto 0) := (others => '0');
  signal dout : std_logic_vector(int_bits-1 downto 0) := (others => '0');
  signal dout2 : std_logic_vector(int_bits-1 downto 0) := (others => '0');

  signal data : std_logic_vector(3*int_bits-1 downto 0) := (others => '0');
  signal sum : std_logic_vector(int_bits+2-1 downto 0) := (others => '0');
  
begin  -- architecture behav

  -- pre gain

  signed_yes: if signed_arith = '1' generate
    input3(int_bits-1 downto bits) <= (others => input(bits-1));
  end generate signed_yes;
  signed_no: if signed_arith = '0' generate
    input3(int_bits-1 downto bits) <= (others => '0');
  end generate signed_no;
  input3(bits-1 downto 0) <= input;

  -- proportional

  reg_1: entity work.reg
    generic map (
      bits => int_bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input3,
      data_out => input4);

  barrel_shift_2: entity work.barrel_shift
    generic map (
      bits         => int_bits,
      signed_arith => signed_arith)
    port map (
      input  => input4,
      amount => pgain,
      output => pout);

  -- integral

  accumulator_1: entity work.accumulator
    generic map (
      bits            => int_bits,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk    => clk,
      reset  => reset,
      enable => '1',
      input  => input3,
      output => aout);
  
  barrel_shift_3: entity work.barrel_shift
    generic map (
      bits         => int_bits,
      signed_arith => signed_arith)
    port map (
      input  => aout,
      amount => igain,
      output => iout);

  -- differential

  use_diff_yes: if use_diff = '1' generate
    
    differentiator_1: entity work.differentiator
      generic map (
        bits            => int_bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => '1',
        input  => input3,
        output => dout);
    
    barrel_shift_4: entity work.barrel_shift
      generic map (
        bits         => int_bits,
        signed_arith => signed_arith)
      port map (
        input  => dout,
        amount => dgain,
        output => dout2);
    
    -- sum
    
    data(3*int_bits-1 downto 2*int_bits) <= dout2;
    data(2*int_bits-1 downto int_bits) <= iout;
    data(int_bits-1 downto 0) <= pout;
    
    array_adder_1: entity work.array_adder
      generic map (
        bits            => int_bits,
        width           => 3,
        signed_arith    => signed_arith,
        use_registers   => use_registers,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk   => clk,
        reset => reset,
        data  => data,
        sum   => sum);

  end generate use_diff_yes;

  use_diff_no: if use_diff = '0' generate
    
  add_1: entity work.add
    generic map (
      bits            => int_bits,
      use_kogge_stone => use_kogge_stone)
    port map (
      input1    => iout,
      input2    => pout,
      output    => sum(int_bits-1 downto 0),
      carry_in  => '0',
      carry_out => open,
      overflow  => open);
  
  end generate use_diff_no;

  round_2: entity work.round
    generic map (
      inp_bits        => int_bits,
      outp_bits       => bits,
      signed_arith    => signed_arith,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk   => clk,
      reset => reset,
      input  => sum(int_bits-1 downto 0),
      output => output);

end architecture behav;
