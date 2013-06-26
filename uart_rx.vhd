-- Copyright (c) 2013, Nils Christopher Brause
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
use work.log2.all;

entity uart_rx is
  generic (
    bits : natural;
    baud : natural;
    freq : natural);
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    rxd       : in  std_logic;
    rts       : out std_logic;
    data_recv : out std_logic_vector(bits-1 downto 0);
    notify    : out std_logic;
    okay      : out std_logic);
end entity uart_rx;

architecture behav of uart_rx is

  constant state_bits : natural := 4;
  subtype state_t is std_logic_vector(state_bits-1 downto 0);
  constant idle : state_t := x"0";
  constant rdy : state_t := x"1";
  constant start1 : state_t := x"2";
  constant start2 : state_t := x"3";
  constant bit1 : state_t := x"4";
  constant bit2 : state_t := x"5";
  constant par1 : state_t := x"6";
  constant par2 : state_t := x"7";
  constant stop1 : state_t := x"8";
  constant stop2 : state_t := x"9";
  signal state : state_t;
  signal next_state : state_t;
  
  constant ratio : natural := freq/baud-1;
  constant bd_cnt_bits : natural := log2ceil(ratio)+1;
  constant bd_cnt_max : std_logic_vector(bd_cnt_bits-1 downto 0)
    := std_logic_vector(to_unsigned(ratio, bd_cnt_bits));
  constant bd_cnt_half : std_logic_vector(bd_cnt_bits-1 downto 0)
    := std_logic_vector(to_unsigned(ratio/2, bd_cnt_bits));
  signal bd_cnt : std_logic_vector(bd_cnt_bits-1 downto 0);
  signal bd_cnt_reset : std_logic;

  signal bit_cnt : std_logic_vector(3 downto 0);
  signal bit_cnt_reset : std_logic;
  signal bit_cnt_enable : std_logic;

  signal new_data : std_logic_vector(bits downto 0);
  signal data : std_logic_vector(bits downto 0);
  signal data_reg_enable : std_logic;
  
  signal data2 : std_logic_vector(bits downto 0);
  signal data3 : std_logic_vector(bits downto 0);
  signal output_reg_enable : std_logic;
  signal notify_tmp : std_logic;
  signal epar : std_logic;

  signal rxd_tmp : std_logic;

begin  -- architecture behav

  -----------------------------------------------------------------------------
  -- state machine
  -----------------------------------------------------------------------------
  
  state_reg: entity work.reg
    generic map (
      bits => state_bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => next_state,
      data_out => state);

  next_state <= idle when reset = '0' else
                rdy when state = idle or (state = stop2 and rxd = '1') else
                start1 when state = rdy and rxd = '0' else
                start2 when state = start1 else
                bit1 when bd_cnt = bd_cnt_max
                and (state = start2 or (state = bit2 and unsigned(bit_cnt)
                                        < bits-1)) else
                bit2 when state = bit1 else
                par1 when bd_cnt = bd_cnt_max and state = bit2
                and unsigned(bit_cnt) = bits-1 else
                par2 when state = par1 else
                stop1 when bd_cnt = bd_cnt_max and state = par2 else
                stop2 when state = stop1 else  -- notify should onyl last 1
                                               -- clock cycle
                state;

  loopy: for c in 0 to bits-1 generate  -- sample in the middle of the bit
    new_data(c) <= rxd when unsigned(bit_cnt) = c and state = bit2
                   and bd_cnt = bd_cnt_half else
                   data(c);
  end generate loopy;

  new_data(bits) <= rxd when unsigned(bit_cnt) = bits and state = par2
                    and bd_cnt = bd_cnt_half else
                    data(bits);
  
  bd_cnt_reset <= '0' when reset = '0' or state = start1 or state = bit1
                  or state = par1 or state = stop1 else
                  '1';

  bit_cnt_reset <= '0' when reset = '0' or state = rdy else
                   '1';
  
  bit_cnt_enable <= '1' when state = bit2 and bd_cnt = bd_cnt_max else
                    '0';

  data_reg_enable <= '1' when state = bit2 and bd_cnt = bd_cnt_half else
                     '0';

  output_reg_enable <= '1' when state = stop1 else
                       '0';

  -----------------------------------------------------------------------------
  -- counters and data reg
  -----------------------------------------------------------------------------

  baud_counter: entity work.counter
    generic map (
      bits            => bd_cnt_bits,
      direction       => '1',
      use_kogge_stone => '0')
    port map (
      clk    => clk,
      reset  => bd_cnt_reset,
      enable => '1',
      output => bd_cnt);
  
  bit_counter: entity work.counter
    generic map (
      bits            => 4,
      direction       => '1',
      use_kogge_stone => '0')
    port map (
      clk    => clk,
      reset  => bit_cnt_reset,
      enable => bit_cnt_enable,
      output => bit_cnt);

  data_reg: entity work.reg
    generic map (
      bits => bits+1)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => data_reg_enable,
      data_in  => new_data,
      data_out => data);

  -----------------------------------------------------------------------------
  -- calculate parity and sync input/output
  -----------------------------------------------------------------------------

  data2(bits-1 downto 0) <= data(bits-1 downto 0);
  
  even_parity_1: entity work.even_parity
    generic map (
      bits => bits+1)
    port map (
      data   => data,
      parity => epar);

  data2(bits) <= not epar;
  
  output_reg: entity work.reg
    generic map (
      bits => bits+1)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => output_reg_enable,
      data_in  => data2,
      data_out => data3);

  data_recv <= data3(bits-1 downto 0);
  okay <= data3(bits);

  notify_reg1: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => output_reg_enable,
      data_out => notify_tmp);

  -- just to be sure
  notify_reg2: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => notify_tmp,
      data_out => notify);

  rts <= '0'; -- always ready

  -- sync input
  rxd_reg: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => rxd,
      data_out => rxd_tmp);
  
end architecture behav;
