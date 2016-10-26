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

--! D-type Flipflop/Register

--! This is a 1 bit D-type Flipflop/Register
--! A 1 bit register can store 1 bit of information.
--! It can be used for e.g. reset synchronization.
entity reg1 is
  port (
    clk      : in  std_logic;           --! clock input
    reset    : in  std_logic;           --! asynchronous reset (active low)
    enable   : in  std_logic;           --! enable pin
    data_in  : in  std_logic;           --! data input
    data_out : out std_logic);          --! data output
end reg1;

architecture behav of reg1 is
begin  -- behav

  reg: process (clk, reset)
  begin
    if reset = '0' then
      data_out <= '0';
    elsif enable = '1' then
      if rising_edge(clk) then
        data_out <= data_in;
      end if;
    end if;
  end process reg;

end behav;
