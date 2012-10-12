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

--! Array Adder

--! The most efficient way to add a large amaount of numbers is in a tree.
--! This array adder does exactly that. On slow FPGAs the use of registers
--! afer every adder can be enabled. In that case you have to supply a clock
--! and reset signal. Please note that there is no carry/overflow logic.
entity array_adder is
  generic (
    bits            : natural;          --! width of input signal
    width           : natural;          --! number of summands
    signed_arith    : bit := '1';       --! use signed aeithmetic
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk   : in  std_logic;              --! input clock
    reset : in  std_logic;              --! asynchronous reset (active low)
    data  : in  std_logic_vector(width*bits-1 downto 0);  --! summands
    sum   : out std_logic_vector(log2ceil(width)+bits-1 downto 0));  --! sum
end array_adder;

architecture tree_add of array_adder is

  constant stages : natural := log2ceil(width)+1;
  constant swidth : natural := 2**(stages-1);
  constant sum_bits : natural := stages+bits-1;

  type stage_t is array (0 to swidth-1) of std_logic_vector(sum_bits-1 downto 0);
  type tree_t is array (0 to stages-1) of stage_t;

  signal tree : tree_t := (others => (others => (others => '0')));
  
begin  -- tree_add

  summands: for i in 0 to width-1 generate
    tree(0)(i)(bits-1 downto 0) <= data(i*bits + bits-1 downto i*bits);
    signed_yes: if signed_arith = '1' generate
      tree(0)(i)(sum_bits-1 downto bits) <= (others => data(i*bits + bits-1));
    end generate signed_yes;
    signed_no: if signed_arith = '0' generate
      tree(0)(i)(sum_bits-1 downto bits) <= (others => '0');
    end generate signed_no;
  end generate summands;

  zeros: for i in width to swidth-1 generate
    tree(0)(i) <= (others => '0');
  end generate zeros;

  stage: for c in 1 to stages-1 generate
    adds: for i in 0 to 2**(stages-1-c)-1 generate
      add_1: entity work.add
        generic map (
          bits            => sum_bits,
          use_registers   => use_registers,
          use_kogge_stone => use_kogge_stone)
        port map (
          clk       => clk,
          reset     => reset,
          input1    => tree(c-1)(2*i),
          input2    => tree(c-1)(2*i+1),
          output    => tree(c)(i),
          carry_in  => '0',
          carry_out => open,
          overflow  => open);
    end generate adds;
  end generate stage;
  
  sum <= tree(stages-1)(0);

end tree_add;
