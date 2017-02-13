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
library work;
use work.log2.all;

--! Serial Peripheral Interface

--! SPI is a synchronous serial bus, which is used to communicate with all
--! sorts of devices. The standard allows four operation modes which cn be
--! choosen via cpol and cpha (see wikipedia for more infos).
entity spi is
  generic (
    bits : natural := 32);              --! bits per transfer
  port (
    clk      : in  std_logic;           --! clock input
    reset    : in  std_logic;           --! asynchronous reset (active low)
    data_out : in  std_logic_vector(bits-1 downto 0);  --! data to send
    data_in  : out std_logic_vector(bits-1 downto 0);  --! received data
    ready    : out std_logic;           --! indicates no running transfer
    enable   : in  std_logic;           --! enable pin
    cs       : out std_logic;           --! client select output
    sck      : out std_logic;           --! synchronous clock output
    mosi     : out std_logic;           --! serial data output
    miso     : in  std_logic;           --! serial data input
    cpol     : in  std_logic;           --! clock polarization
    cpha     : in  std_logic);          --! clock phase
end entity spi;

architecture behav of spi is

  signal shift_enable : std_logic;
  signal shift_load : std_logic;
  signal sift_out : std_logic;

  constant count_bits : natural := log2ceil(bits);
  constant count_max : std_logic_vector(count_bits-1 downto 0)
    := std_logic_vector(to_unsigned(bits-1, count_bits));
  signal count_reset : std_logic;
  signal count_enable : std_logic;
  signal count_out : std_logic_vector(count_bits-1 downto 0);

  signal spi_clk : std_logic;
  signal spi_out : std_logic;
  signal spi_out2 : std_logic;

  constant state_bits : natural := 4;
  subtype state_t is std_logic_vector(state_bits-1 downto 0);
  signal state : state_t;
  signal next_state : state_t;
  constant idle : state_t := x"0";
  constant load : state_t := x"1";
  constant low  : state_t := x"2";
  constant high : state_t := x"3";
  constant done : state_t := x"4";
  
begin  -- architecture behav

  -- shift register
  
  shift_reg_1: entity work.shift_reg
    generic map (
      bits => bits)
    port map (
      clk          => clk,
      reset        => reset,
      load         => shift_load,
      serial_in    => miso,
      serial_out   => spi_out,
      parallel_in  => data_out,
      parallel_out => data_in,
      enable       => shift_enable);

  reg1_1: entity work.reg1
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => spi_out,
      data_out => spi_out2);

  -- bit counter

  counter_1: entity work.counter
    generic map (
      bits         => count_bits,
      direction_up => true)
    port map (
      clk    => clk,
      reset  => count_reset,
      enable => count_enable,
      output => count_out);

  -- state machine

  state_reg: entity work.reg
    generic map (
      bits => state_bits)
    port map (
      clk      => clk,
      reset    => reset,
      enable   => '1',
      data_in  => next_state,
      data_out => state);

  next_state <= idle when reset = '0' or state = done else
                load when enable = '1' and state = idle else
                low  when state = load or (state = high and count_out /= count_max) else
                high when state = low else
                done when state = high and count_out = count_max else
                state;

  ready <= '1' when state = idle and reset = '1' else
           '0';
  
  shift_load <= '1' when state = load else
                '0';

  shift_enable <= '1' when state = load or state = high else
                  '0';

  count_reset <= '0' when reset = '0' or state = idle else
                 '1';

  count_enable <= '1' when state = high else
                  '0';

  cs <= '0' when state /= idle else
        '1';

  spi_clk <= '1' when state = high else
             '0';

  sck <= spi_clk xor cpol;

  mosi <= spi_out when cpha = '0' else
          spi_out2;

end architecture behav;
