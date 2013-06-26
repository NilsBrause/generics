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

--! proportional integral differential controller

--! This is a Proportional Integral Differential (PID) controller.
--! You can adjust each gain (P, I and D) separatly. An pre-gain of
--! 2^(bits-int_bits) is applied to prevent overflows.
entity pidctrl is
  generic (
    bits            : natural;          --! width of input
    int_bits        : natural;          --! internal signal width
    signed_arith    : bit := '1';       --! assume input is signed
    gains_first     : bit := '1';       --! apply gains before integrator/differentiator
    use_prop        : bit := '1';       --! use proportional
    use_int         : bit := '1';       --! use integrator
    use_diff        : bit := '0';       --! use differentiator
    use_registers   : bit := '0';       --! use additional registers on alow fpgas
    use_kogge_stone : bit := '0');      --! use an optimized Kogge Stone adder
  port (
    clk      : in  std_logic;           --! clock input
    reset    : in  std_logic;           --! asynchronous reset (active low)
    enable   : in  std_logic;           --! enable pin
    input    : in  std_logic_vector(bits-1 downto 0);  --! input signal
    pgain    : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);  --! proportial gain
    igain    : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);  --! integral gain
    dgain    : in  std_logic_vector(log2ceil(int_bits)-1 downto 0);  --! differential gain
    output   : out std_logic_vector(int_bits-1 downto 0));  --! output signal
end entity pidctrl;

architecture behav of pidctrl is

  signal input3 : std_logic_vector(int_bits-1 downto 0) := (others => '0');

  signal pout : std_logic_vector(int_bits-1 downto 0) := (others => '0');
  signal pout2 : std_logic_vector(int_bits-1 downto 0) := (others => '0');
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
      enable   => enable,
      data_in  => input3,
      data_out => pout2);

  barrel_shift_2: entity work.barrel_shift
    generic map (
      bits         => int_bits,
      signed_arith => signed_arith)
    port map (
      input  => pout2,
      amount => pgain,
      output => pout);

  -- integral

  int_gains_first_no: if gains_first = '0' generate
    
    accumulator_1: entity work.accumulator
      generic map (
        bits            => int_bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => enable,
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
    
  end generate int_gains_first_no;

  int_gains_first_yes: if gains_first = '1' generate

    barrel_shift_3: entity work.barrel_shift
      generic map (
        bits         => int_bits,
        signed_arith => signed_arith)
      port map (
        input  => input3,
        amount => igain,
        output => aout);
    
    accumulator_1: entity work.accumulator
      generic map (
        bits            => int_bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => enable,
        input  => aout,
        output => iout);
    
  end generate int_gains_first_yes;

  -- differential

  diff_gains_first_no: if gains_first = '0' generate
    
    differentiator_1: entity work.differentiator
      generic map (
        bits            => int_bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => enable,
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
    
  end generate diff_gains_first_no;
  
  diff_gains_first_yes: if gains_first = '1' generate
    
    barrel_shift_4: entity work.barrel_shift
      generic map (
        bits         => int_bits,
        signed_arith => signed_arith)
      port map (
        input  => input3,
        amount => dgain,
        output => dout);
    
    differentiator_1: entity work.differentiator
      generic map (
        bits            => int_bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk    => clk,
        reset  => reset,
        enable => enable,
        input  => dout,
        output => dout2);
    
  end generate diff_gains_first_yes;
    
  -- sum

  pid: if use_diff = '1' and use_int = '1' and use_prop = '1' generate
    
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

  end generate pid;
    
  pi: if use_diff = '0' and use_int = '1' and use_prop = '1' generate
    
    add_1: entity work.add
      generic map (
        bits            => int_bits,
        use_registers   => use_registers,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk       => clk,
        reset     => reset,
        input1    => iout,
        input2    => pout,
        output    => sum(int_bits-1 downto 0),
        carry_in  => '0',
        carry_out => open,
        overflow  => open);
    
  end generate pi;

  pd: if use_diff = '1' and use_int = '0' and use_prop = '1' generate
    
    add_1: entity work.add
      generic map (
        bits            => int_bits,
        use_registers   => use_registers,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk       => clk,
        reset     => reset,
        input1    => dout,
        input2    => pout,
        output    => sum(int_bits-1 downto 0),
        carry_in  => '0',
        carry_out => open,
        overflow  => open);
    
  end generate pd;

  id: if use_diff = '1' and use_int = '1' and use_prop = '0' generate
    
    add_1: entity work.add
      generic map (
        bits            => int_bits,
        use_registers   => use_registers,
        use_kogge_stone => use_kogge_stone)
      port map (
        clk       => clk,
        reset     => reset,
        input1    => dout,
        input2    => iout,
        output    => sum(int_bits-1 downto 0),
        carry_in  => '0',
        carry_out => open,
        overflow  => open);
    
  end generate id;

  p: if use_diff = '0' and use_int = '0' and use_prop = '1' generate
    sum(int_bits-1 downto 0) <= pout;
  end generate p;

  i: if use_diff = '0' and use_int = '1' and use_prop = '0' generate
    sum(int_bits-1 downto 0) <= iout;
  end generate i;

  d: if use_diff = '1' and use_int = '0' and use_prop = '0' generate
    sum(int_bits-1 downto 0) <= dout;
  end generate d;

  output <= sum(int_bits-1 downto 0);

end architecture behav;
