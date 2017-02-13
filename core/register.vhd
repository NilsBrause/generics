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

--! N bit register

--! This is a N bit D-type Flipflip/Regsiter.
--! A N bit register can store N bit of information.
--! It works exactly as the 1 bit register but with N bits.
entity reg is
  generic (
    bits : natural);                    --! number of bits to be stored
  port (
    clk      : in  std_logic;           --! clock input
    reset    : in  std_logic;           --! asynchronous reset (active low)
    enable   : in  std_logic;           --! enable pin
    data_in  : in  std_logic_vector(bits-1 downto 0);  --! data input
    data_out : out std_logic_vector(bits-1 downto 0)); --! data output
end reg;

architecture behav of reg is
  
begin  -- behav

  regs: for c in 0 to bits-1 generate
    my_reg : entity work.reg1
      port map (
        clk      => clk,
        reset    => reset,
        enable   => enable,
        data_in  => data_in(c),
        data_out => data_out(c));
  end generate regs;

end behav;
