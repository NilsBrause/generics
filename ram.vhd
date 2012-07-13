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
use ieee.numeric_std.all;
use work.log2.all;

entity ram is
  generic (
    bits  : natural;
    bytes : natural);
  port (
    clk1      : in  std_logic;
    clk2      : in  std_logic;
    we1       : in  std_logic;
    we2       : in  std_logic;
    addr1     : in  std_logic_vector(log2ceil(bytes)-1 downto 0);
    addr2     : in  std_logic_vector(log2ceil(bytes)-1 downto 0);
    data1_in  : in  std_logic_vector(bits-1 downto 0);
    data1_out : out std_logic_vector(bits-1 downto 0);
    data2_in  : in  std_logic_vector(bits-1 downto 0);
    data2_out : out std_logic_vector(bits-1 downto 0));
end entity ram;

architecture behav of ram is

  subtype byte is std_logic_vector(bits-1 downto 0);
  type byte_vector is array (natural range <>) of byte;
  shared variable mem : byte_vector(bytes-1 downto 0) := (others => (others => '0'));
  
begin  -- architecture behav

  port1: process is
  begin
    if rising_edge(clk1) then
      data1_out <= mem(to_integer(unsigned(addr1)));
      if we1 = '1' then
        mem(to_integer(unsigned(addr1))) := data1_in;
      end if;
    end if;
  end process port1;

  port2: process is
  begin
    if rising_edge(clk2) then
      data2_out <= mem(to_integer(unsigned(addr2)));
      if we2 = '1' then
        mem(to_integer(unsigned(addr2))) := data2_in;
      end if;
    end if;
  end process port2;

end architecture behav;
