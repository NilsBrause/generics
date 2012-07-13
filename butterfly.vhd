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

entity butterfly is
  generic (
    bits       : natural;
    phase_bits : natural;
    add_regs   : natural := 0);
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    phase        : in  std_logic_vector(phase_bits-1 downto 0);
    input1_real  : in  std_logic_vector(bits-1 downto 0);
    input1_imag  : in  std_logic_vector(bits-1 downto 0);
    input2_real  : in  std_logic_vector(bits-1 downto 0);
    input2_imag  : in  std_logic_vector(bits-1 downto 0);
    output1_real : out std_logic_vector(bits-1 downto 0);
    output1_imag : out std_logic_vector(bits-1 downto 0);
    output2_real : out std_logic_vector(bits-1 downto 0);
    output2_imag : out std_logic_vector(bits-1 downto 0));
end entity butterfly;

architecture behav of butterfly is

  signal sin : std_logic_vector(bits-1 downto 0);
  signal cos : std_logic_vector(bits-1 downto 0);

  signal input1_real_tmp : std_logic_vector(bits-1 downto 0);
  signal input1_imag_tmp : std_logic_vector(bits-1 downto 0);
  signal input2_real_tmp : std_logic_vector(bits-1 downto 0);
  signal input2_imag_tmp : std_logic_vector(bits-1 downto 0);

  signal input2_real_sin2 : std_logic_vector(2*bits-1 downto 0);
  signal input2_real_cos2 : std_logic_vector(2*bits-1 downto 0);
  signal input2_imag_sin2 : std_logic_vector(2*bits-1 downto 0);
  signal input2_imag_cos2 : std_logic_vector(2*bits-1 downto 0);

  signal input2_real_sin : std_logic_vector(bits-1 downto 0);
  signal input2_real_cos : std_logic_vector(bits-1 downto 0);
  signal input2_imag_sin : std_logic_vector(bits-1 downto 0);
  signal input2_imag_cos : std_logic_vector(bits-1 downto 0);

  signal input2_twiddle_real : std_logic_vector(bits-1 downto 0);
  signal input2_twiddle_imag : std_logic_vector(bits-1 downto 0);
  
  signal input1_real2 : std_logic_vector(bits-1 downto 0);
  signal input1_imag2 : std_logic_vector(bits-1 downto 0);
  signal input2_twiddle_real2 : std_logic_vector(bits-1 downto 0);
  signal input2_twiddle_imag2 : std_logic_vector(bits-1 downto 0);
  signal input1_real3 : std_logic_vector(bits-1 downto 0);
  signal input1_imag3 : std_logic_vector(bits-1 downto 0);
  signal input2_twiddle_real3 : std_logic_vector(bits-1 downto 0);
  signal input2_twiddle_imag3 : std_logic_vector(bits-1 downto 0);

begin  -- architecture behav

  -- y0 = x0 + x1 * wk
  -- y1 = x0 - x1 * wk
  --
  -- wk = exp(-2*pi*i*k)
  --    = cos(2*pi*k) - i*sin(2*pi*k)
  --
  -- (a + i*b)(c - i*s) = a*c + b*s + i*(b*c - a*s)

  -----------------------------------------------------------------------------
  -- Part I: calculate sine/cosine & delay input
  -----------------------------------------------------------------------------

  sincos_1: entity work.sincos
    generic map (
      phase_bits => phase_bits,
      bits       => bits)
    port map (
      clk   => clk,
      reset => reset,
      phase => phase,
      sin   => sin,
      cos   => cos);

  reg_1: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input1_real,
      data_out => input1_real_tmp);

  reg_2: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input1_imag,
      data_out => input1_imag_tmp);

  reg_3: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input2_real,
      data_out => input2_real_tmp);

  reg_4: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => input2_imag,
      data_out => input2_imag_tmp);

  -----------------------------------------------------------------------------
  -- Part II: Multiply sine/cosine with real/imaginary part of input2
  -----------------------------------------------------------------------------

  mul_real_sin: entity work.mul
    generic map (
      bits1        => bits,
      bits2        => bits,
      signed_arith => '1')
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input2_real_tmp,
      input2 => sin,
      output => input2_real_sin2);
  
  mul_real_cos: entity work.mul
    generic map (
      bits1        => bits,
      bits2        => bits,
      signed_arith => '1')
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input2_real_tmp,
      input2 => cos,
      output => input2_real_cos2);
  
  mul_imag_sin: entity work.mul
    generic map (
      bits1        => bits,
      bits2        => bits,
      signed_arith => '1')
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input2_imag_tmp,
      input2 => sin,
      output => input2_imag_sin2);
  
  mul_imag_cos: entity work.mul
    generic map (
      bits1        => bits,
      bits2        => bits,
      signed_arith => '1')
    port map (
      clk    => clk,
      reset  => reset,
      input1 => input2_imag_tmp,
      input2 => cos,
      output => input2_imag_cos2);

  -- shift only by bits-1 because of sign bit.
  
  add_regs_0: if add_regs > 0 generate
    reg_5: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_real_sin2(2*bits-2 downto bits-1),
        data_out => input2_real_sin);
    
    reg_6: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_imag_sin2(2*bits-2 downto bits-1),
        data_out => input2_imag_sin);
    
    reg_7: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_real_cos2(2*bits-2 downto bits-1),
        data_out => input2_real_cos);
    
    reg_8: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_imag_cos2(2*bits-2 downto bits-1),
        data_out => input2_imag_cos);
  end generate add_regs_0;

  add_regs_1: if add_regs < 1 generate
    input2_real_sin <= input2_real_sin2(2*bits-2 downto bits-1);
    input2_imag_sin <= input2_imag_sin2(2*bits-2 downto bits-1);
    input2_real_cos <= input2_real_cos2(2*bits-2 downto bits-1);
    input2_imag_cos <= input2_imag_cos2(2*bits-2 downto bits-1);
  end generate add_regs_1;
  

  -----------------------------------------------------------------------------
  -- Part III: Finish complex multiplication
  -----------------------------------------------------------------------------

  add_twiddle_real: entity work.add
    generic map (
      bits => bits)
    port map (
      input1    => input2_real_cos,
      input2    => input2_imag_sin,
      output    => input2_twiddle_real,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);
  
  sub_twiddle_imag: entity work.sub
    generic map (
      bits => bits)
    port map (
      input1     => input2_imag_cos,
      input2     => input2_real_sin,
      output     => input2_twiddle_imag,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);

  -----------------------------------------------------------------------------
  -- Part IV: Attenuation to prevent overflow
  -----------------------------------------------------------------------------

  add_regs_2: if add_regs > 1 generate
    input1_real3 <= input1_real(bits-1) & input1_real(bits-1 downto 1);
    input1_imag3 <= input1_imag(bits-1) & input1_imag(bits-1 downto 1);
    input2_twiddle_real3 <= input2_twiddle_real(bits-1) & input2_twiddle_real(bits-1 downto 1);
    input2_twiddle_imag3 <= input2_twiddle_imag(bits-1) & input2_twiddle_imag(bits-1 downto 1);
    
    reg_9: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input1_real3,
        data_out => input1_real2);
    
    reg_10: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input1_imag3,
        data_out => input1_imag2);
    
    reg_11: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_twiddle_real3,
        data_out => input2_twiddle_real2);
    
    reg_12: entity work.reg
      generic map (
        bits => bits)
      port map (
        clk      => clk,
        reset    => reset,
        enable   => '1',
        data_in  => input2_twiddle_imag3,
        data_out => input2_twiddle_imag2);
  end generate add_regs_2;

  add_regs_3: if add_regs < 2 generate
    input1_real2 <= input1_real(bits-1) & input1_real(bits-1 downto 1);
    input1_imag2 <= input1_imag(bits-1) & input1_imag(bits-1 downto 1);
    input2_twiddle_real2 <= input2_twiddle_real(bits-1) & input2_twiddle_real(bits-1 downto 1);
    input2_twiddle_imag2 <= input2_twiddle_imag(bits-1) & input2_twiddle_imag(bits-1 downto 1);
  end generate add_regs_3;

  -----------------------------------------------------------------------------
  -- Part V: Combile with input1
  -----------------------------------------------------------------------------
  
  add_real: entity work.add
    generic map (
      bits => bits)
    port map (
      input1    => input1_real2,
      input2    => input2_twiddle_real2,
      output    => output1_real,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);
  
  add_imag: entity work.add
    generic map (
      bits => bits)
    port map (
      input1    => input1_imag2,
      input2    => input2_twiddle_imag2,
      output    => output1_imag,
      carry_in  => '0',
      carry_out => open,
      overflow  => open);
  
  sub_real: entity work.sub
    generic map (
      bits => bits)
    port map (
      input1     => input1_real2,
      input2     => input2_twiddle_real2,
      output     => output2_real,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);
    
  sub_imag: entity work.sub
    generic map (
      bits => bits)
    port map (
      input1     => input1_imag2,
      input2     => input2_twiddle_imag2,
      output     => output2_imag,
      borrow_in  => '0',
      borrow_out => open,
      underflow  => open);
  
end architecture behav;
