-- Copyright (c) 2012-2017, Nils Christopher Brause
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

-- used internally

entity div_int is
  generic (
    bits          : natural;
    use_registers : boolean := false;
    c             : natural);
  port (
    clk   : in std_logic;
    reset : in std_logic;
    D     : in  std_logic_vector(bits-1 downto 0);
    Nin   : in  std_logic_vector(bits-1 downto 0);
    Nout  : out std_logic_vector(bits-1 downto 0);
    Qin   : in  std_logic_vector(bits-1 downto 0);
    Qout  : out std_logic_vector(bits-1 downto 0));
end entity div_int;

architecture behav of div_int is

  subtype bits_t is std_logic_vector(bits-1 downto 0);

  constant zero : bits_t := (others => '0');

  signal Ds        : bits_t;
  signal NmDs      : bits_t;
  signal borrow    : std_logic;
  signal divides   : boolean;
  signal N2        : bits_t;
  signal Q2        : bits_t;

begin  -- architecture behav

  -- (D << c)
  Ds(bits-1 downto c) <= D(bits-1-c downto 0);
  Ds(c-1 downto 0) <= (others => '0');

  -- N -= (D << c);
  sub_1: entity work.sub
    generic map (
      bits          => bits,
      use_registers => false)
    port map (
      clk        => clk,
      reset      => reset,
      input1     => Nin,
      input2     => Ds,
      output     => NmDs,
      borrow_in  => '0',
      borrow_out => borrow,
      underflow  => open);

  -- N >= (D << c) && D >> (31-c) == 0
  divides <= borrow = '0' and D(bits-1 downto bits-c-1) = zero(bits-1 downto bits-c-1);  

  Q2(bits-1 downto c+1) <= Qin(bits-1 downto c+1);
  Q2(c) <= '1' when divides else '0';
  Q2(c-1 downto 0) <= Qin(c-1 downto 0);
  N2 <= NmDs when divides else Nin;

  use_registers_yes: if use_registers generate
    reg_1: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => Q2,
        data_out => Qout);

    reg_2: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => N2,
        data_out => Nout);
  end generate use_registers_yes;

  use_registers_no: if not use_registers generate
    Qout <= Q2;
    Nout <= Nin;
  end generate use_registers_no;

end architecture behav;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Divider

entity div is
  generic (
    bits          : natural;            --! width of input/output
    signed_arith  : boolean := true;    --! use signed arithmetic
    use_registers : boolean := false);  --! use additional registers on slow FPGAs
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    divident  : in  std_logic_vector(bits-1 downto 0);   --! nominator
    divisor   : in  std_logic_vector(bits-1 downto 0);   --! denominator
    quotient  : out std_logic_vector(bits-1 downto 0);   --! quotient
    remainder : out std_logic_vector(bits-1 downto 0));  --! rest
end entity div;

architecture behav of div is

  subtype bits_t is std_logic_vector(bits-1 downto 0);
  type bits_vector is array (natural range <>) of bits_t;

  signal dividentisneg : std_logic;
  signal divisorisneg : std_logic;
  signal dividentisneg2 : std_logic;
  signal divisorisneg2 : std_logic;
  signal ndivident : bits_t;
  signal ndivisor : bits_t;
  signal nom_tmp : bits_t;
  signal denom_tmp : bits_t;
  signal nom : bits_t;
  signal denom : bits_t;
  signal N : bits_vector(0 to bits);
  signal Q : bits_vector(0 to bits);
  signal quot : bits_t;
  signal nquot : bits_t;
  signal rest : bits_t;
  signal nrest : bits_t;
  signal quot_tmp : bits_t;
  signal rest_tmp : bits_t;

begin  -- architecture behav

  signed_arith_no: if not signed_arith generate
    nom <= divident;
    denom <= divisor;
    quotient <= quot;
    remainder <= rest;
  end generate signed_arith_no;

  signed_arith_yes: if signed_arith generate

    dividentisneg <= '1' when divident(bits-1) = '1' else '0';
    divisorisneg <= '1' when divisor(bits-1) = '1' else '0';

    divident_neg: entity work.neg
      generic map (
        bits          => bits,
        use_registers => false)
      port map (
        clk       => clk,
        reset     => reset,
        input     => divident,
        output    => ndivident,
        underflow => open);

    divisor_neg: entity work.neg
      generic map (
        bits          => bits,
        use_registers => false)
      port map (
        clk       => clk,
        reset     => reset,
        input     => divisor,
        output    => ndivisor,
        underflow => open);

    nom_tmp <= ndivident when dividentisneg = '1' else divident;
    denom_tmp <= ndivisor when divisorisneg = '1' else divisor;

    use_registers_yes: if use_registers generate

      nom_reg: entity work.reg
        generic map (
          bits => bits)
        port map (
          clk      => clk,
          reset    => reset,
          enable   => '1',
          data_in  => nom_tmp,
          data_out => nom);
      
      denom_reg: entity work.reg
        generic map (
          bits => bits)
        port map (
          clk      => clk,
          reset    => reset,
          enable   => '1',
          data_in  => denom_tmp,
          data_out => denom);
      
      divisorisneg_delay_reg: entity work.delay_reg
        generic map (
          bits  => 1,
          delay => bits+1)
        port map (
          clk      => clk,
          reset    => reset,
          enable   => '1',
          data_in(0)  => divisorisneg,
          data_out(0) => divisorisneg2);

      dividentisneg_delay_reg: entity work.delay_reg
        generic map (
          bits  => 1,
          delay => bits+1)
        port map (
          clk      => clk,
          reset    => reset,
          enable   => '1',
          data_in(0)  => dividentisneg,
          data_out(0) => dividentisneg2);

      quot_reg: entity work.reg
        generic map (
          bits => bits)
        port map (
          clk      => clk,
          reset    => reset,
          enable   => '1',
          data_in  => quot_tmp,
          data_out => quotient);
      
      rest_reg: entity work.reg
        generic map (
          bits => bits)
        port map (
          clk      => clk,
          reset    => reset,
          enable   => '1',
          data_in  => rest_tmp,
          data_out => remainder);
      
    end generate use_registers_yes;

    use_registers_no: if not use_registers generate
      nom <= nom_tmp;
      denom <= denom_tmp;
      divisorisneg2 <= divisorisneg;
      dividentisneg2 <= dividentisneg;
      quotient <= quot_tmp;
      remainder <= rest_tmp;
    end generate use_registers_no;

    quot_neg: entity work.neg
      generic map (
        bits          => bits,
        use_registers => false)
      port map (
        clk       => clk,
        reset     => reset,
        input     => quot,
        output    => nquot,
        underflow => open);

    rest_neg: entity work.neg
      generic map (
        bits          => bits,
        use_registers => false)
      port map (
        clk       => clk,
        reset     => reset,
        input     => rest,
        output    => nrest,
        underflow => open);

    quot_tmp <= nquot when (dividentisneg2 = '1' and divisorisneg2 = '0')
                or (dividentisneg2 = '0' and divisorisneg2 = '1') else quot;

    rest_tmp <= nrest when dividentisneg2 = '1' else rest;

  end generate signed_arith_yes;

  Q(bits) <= (others => '0');
  N(bits) <= nom;

  loopy: for c in bits-1 downto 0 generate
    div_int_1: entity work.div_int
      generic map (
        bits          => bits,
        use_registers => use_registers,
        c             => c)
      port map (
        clk   => clk,
        reset => reset,
        D     => denom,
        Nin   => N(c+1),
        Nout  => N(c),
        Qin   => Q(c+1),
        Qout  => Q(c));
  end generate loopy;

  quot <= Q(0);
  rest <= N(0);

end architecture behav;
