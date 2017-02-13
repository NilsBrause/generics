-- Copyright (c) 2013-2017, Nils Christopher Brause
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

entity uart is
  generic (
    bits : natural;
    baud : natural;
    freq : natural);
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    txd       : out std_logic;
    rxd       : in  std_logic;
    cts       : in  std_logic;
    rts       : out std_logic;
    data_send : in  std_logic_vector(bits-1 downto 0);
    request   : in  std_logic;
    ready     : out std_logic;
    data_recv : out std_logic_vector(bits-1 downto 0);
    notify    : out std_logic;
    okay      : out std_logic);
end entity uart;

architecture behav of uart is

begin  -- architecture behav

  uart_tx_1: entity work.uart_tx
    generic map (
      bits => bits,
      baud => baud,
      freq => freq)
    port map (
      clk       => clk,
      reset     => reset,
      txd       => txd,
      cts       => cts,
      data_send => data_send,
      request   => request,
      ready     => ready);

  uart_rx_1: entity work.uart_rx
    generic map (
      bits => bits,
      baud => baud,
      freq => freq)
    port map (
      clk       => clk,
      reset     => reset,
      rxd       => rxd,
      rts       => rts,
      data_recv => data_recv,
      notify    => notify,
      okay      => okay);
  
end architecture behav;
