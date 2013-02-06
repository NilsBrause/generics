-- Copyright (c) 2012, 1013 Nils Christopher Brause
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

entity div_int is
  generic (
    bits            : natural;
    i               : natural;
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk   : in  std_logic;          --! clock input
    reset : in  std_logic;          --! asynchronous reset (active low)
    N     : in  std_logic_vector(bits-1 downto 0);
    D     : in  std_logic_vector(bits-1 downto 0);
    R_in  : in  std_logic_vector(bits-1 downto 0);
    R_out : out std_logic_vector(bits-1 downto 0);
    Qi    : out std_logic);
end entity div_int;

architecture behav of div_int is

  signal Rsh : std_logic_vector(bits-1 downto 0);
  signal RshmD : std_logic_vector(bits-1 downto 0);
  signal borrow : std_logic;
  signal RgeD : std_logic;
  signal RmD : std_logic_vector(bits-1 downto 0);
  
begin  -- architecture behav

  Rsh(bits-1 downto 1) <= R_in(bits-2 downto 0);
  Rsh(0) <= N(i);
  
  sub_1: entity work.sub
    generic map (
      bits            => bits,
      use_registers   => use_registers,
      use_kogge_stone => use_kogge_stone)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => Rsh,
      input2     => D,
      output     => RshmD,
      borrow_in  => '0',
      borrow_out => borrow,
      underflow  => open);
  
  RgeD <= not borrow;
  R_out <= RshmD when RgeD = '1' else Rsh;
  Qi <= RgeD;

end architecture behav;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Division

--! This is a integer division with remainder support.
entity division is
  generic (
    bits            : natural;          --! width of signals
    use_registers   : bit := '0';       --! use additional registers on slow FPGAs
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk       : in  std_logic;          --! clock input
    reset     : in  std_logic;          --! asynchronous reset (active low)
    dividend  : in  std_logic_vector(bits-1 downto 0);  --! Dividend
    divisor   : in  std_logic_vector(bits-1 downto 0);  --! Divisor
    quotient  : out std_logic_vector(bits-1 downto 0);  --! Quotient
    remainder : out std_logic_vector(bits-1 downto 0));  --! Remainder
end entity division;

architecture behav of division is

  type R_array is array (natural range <>) of std_logic_vector(bits-1 downto 0);
  signal Rs : R_array(bits downto 0);

begin  -- architecture behav

  Rs(bits) <= (others => '0');

  bits_loop: for c in bits-1 downto 0 generate
    div_int_1: entity work.div_int
      generic map (
        bits            => bits,
        i               => c,
        use_registers   => use_registers,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk   => clk,
        reset => reset,
        N     => dividend,
        D     => divisor,
        R_in  => Rs(c+1),
        R_out => Rs(c),
        Qi    => quotient(c));
  end generate bits_loop;

  remainder <= Rs(0);

end architecture behav;
