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

--! random access memory

--! This is synthesizable true dual port RAM.
entity ram is
  generic (
    bits  : natural;                    --! width if one byte
    bytes : natural);                   --! number of bytes
  port (
    clk1      : in  std_logic;          --! clock input of first port
    clk2      : in  std_logic;          --! clock input of second port
    we1       : in  std_logic;          --! write enable of first port
    we2       : in  std_logic;          --! write enable of second port
    addr1     : in  std_logic_vector(log2ceil(bytes)-1 downto 0);  --! address input of first port
    addr2     : in  std_logic_vector(log2ceil(bytes)-1 downto 0);  --! address input of second port
    data1_in  : in  std_logic_vector(bits-1 downto 0);  --! data input of first port
    data2_in  : in  std_logic_vector(bits-1 downto 0);  --! data input of second port
    data1_out : out std_logic_vector(bits-1 downto 0);  --! data output of first port
    data2_out : out std_logic_vector(bits-1 downto 0));  --! data output of second port
end entity ram;

architecture behav of ram is

  subtype byte is std_logic_vector(bits-1 downto 0);
  type byte_vector is array (natural range <>) of byte;
  shared variable mem : byte_vector(bytes-1 downto 0) := (others => (others => '0'));
  
begin  -- architecture behav

  port1: process(clk1) is
  begin
    if rising_edge(clk1) then
      data1_out <= mem(to_integer(unsigned(addr1)));
      if we1 = '1' then
        mem(to_integer(unsigned(addr1))) := data1_in;
      end if;
    end if;
  end process port1;

  port2: process(clk2) is
  begin
    if rising_edge(clk2) then
      data2_out <= mem(to_integer(unsigned(addr2)));
      if we2 = '1' then
        mem(to_integer(unsigned(addr2))) := data2_in;
      end if;
    end if;
  end process port2;

end architecture behav;
