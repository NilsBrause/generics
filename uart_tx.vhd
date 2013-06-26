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

entity uart_tx is
  generic (
    bits : natural;
    baud : natural;
    freq : natural);
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    txd       : out std_logic;
    cts       : in  std_logic;
    data_send : in  std_logic_vector(bits-1 downto 0);
    request   : in  std_logic;
    ready     : out std_logic);
end entity uart_tx;

architecture behav of uart_tx is
  
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
  constant wait1 : state_t := x"A";
  constant wait2 : state_t := x"B";
  signal state : state_t;
  signal next_state : state_t;

  constant ratio : natural := freq/baud-1;
  constant bd_cnt_bits : natural := log2ceil(ratio)+1;
  signal bd_cnt_max : std_logic_vector(bd_cnt_bits-1 downto 0)
    := std_logic_vector(to_unsigned(ratio, bd_cnt_bits));
  signal bd_cnt : std_logic_vector(bd_cnt_bits-1 downto 0);
  signal bd_cnt_reset : std_logic;

  signal bit_cnt : std_logic_vector(3 downto 0);
  signal bit_cnt_reset : std_logic;
  signal bit_cnt_enable : std_logic;

  signal data : std_logic_vector(bits-1 downto 0);
  signal reg_enable : std_logic;
  signal epar : std_logic;

  signal txd_tmp : std_logic;
  signal cts_tmp : std_logic;

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
                rdy when state = idle or (bd_cnt = bd_cnt_max and state = wait2) else
                start1 when state = rdy and request = '1' and cts_tmp = '0' else
                start2 when state = start1 else
                bit1 when bd_cnt = bd_cnt_max and (state = start2 or (state = bit2 and unsigned(bit_cnt) < bits-1)) else
                bit2 when state = bit1 else
                par1 when bd_cnt = bd_cnt_max and state = bit2 and unsigned(bit_cnt) = bits-1 else
                par2 when state = par1 else
                stop1 when bd_cnt = bd_cnt_max and state = par2 else
                stop2 when state = stop1 else
                wait1 when bd_cnt = bd_cnt_max and state = stop2 else
                wait2 when state = wait1 else
                state;

  txd_tmp <= '1' when state = rdy else
             '0' when state = start1 or state = start2 else                                 -- start bit
             data(to_integer(unsigned(bit_cnt))) when state = bit1 or state = bit2 else     -- data bits
             epar when state = par1 or state = par2 else                                    -- paritiy bit
             '1' when state = stop1 or state = stop2
             or state = wait1 or state = wait2 else
             '0';
  
  ready <= '1' when state = rdy else
           '0';

  bd_cnt_reset <= '0' when reset = '0' or state = start1 or state = bit1
                  or state = par1 or state = stop1 or state = wait1 else
                  '1';

  bit_cnt_reset <= '0' when reset = '0' or state = rdy else
                   '1';
  
  bit_cnt_enable <= '1' when state = bit2 and bd_cnt = bd_cnt_max else
                    '0';

  reg_enable <= '1' when state = start1 else
                '0';

  -----------------------------------------------------------------------------
  -- counters
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

  -----------------------------------------------------------------------------
  -- input/output
  -----------------------------------------------------------------------------

  input_reg: entity work.reg
    generic map (
      bits => bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => reg_enable,
      data_in  => data_send,
      data_out => data);

  -- sync output
  txd_reg: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => txd_tmp,
      data_out => txd);
  
  cts_reg: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => cts,
      data_out => cts_tmp);
  
  -----------------------------------------------------------------------------
  -- parity
  -----------------------------------------------------------------------------

  even_parity_1: entity work.even_parity
    generic map (
      bits => bits)
    port map (
      data   => data,
      parity => epar);

end architecture behav;
