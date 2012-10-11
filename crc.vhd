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

entity crc is
  generic (
    in_bits   : natural := 8;
    crc_width : natural := 32);
  port (
    clk     : in  std_logic;
    reset   : in  std_logic;
    enable  : in  std_logic;
    input   : in  std_logic_vector(in_bits-1 downto 0);
    polynom : in  std_logic_vector(crc_width-1 downto 0);
    output  : out std_logic_vector(crc_width-1 downto 0));
end entity crc;

architecture behav of crc is

  function f (
    input : std_logic_vector (in_bits-1 downto 0);
    old_crc : std_logic_vector(crc_width-1 downto 0);
    polynom : std_logic_vector(crc_width-1 downto 0))
    return std_logic_vector is
    variable tmp: std_logic_vector(crc_width-1 downto 0);
  begin
    tmp := old_crc;
    for k in 0 to 7 loop 
      if tmp(0) /= input(k) then
        tmp := ('0'& tmp(crc_width-1 downto 1)) xor polynom;
      else
        tmp := ('0'& tmp(crc_width-1 downto 1));
      end if;
    end loop;
    return tmp;
  end f;

  signal crc_out : std_logic_vector(crc_width-1 downto 0);
  signal crc_in : std_logic_vector(crc_width-1 downto 0);
  
begin  -- architecture behav

  crc_in <= f(input, crc_out, polynom);

  reg_1: entity work.reg
    generic map (
      bits => crc_width )
    port map (
      clk      => clk,
      reset    => reset,
      enable   => enable,
      data_in  => crc_in,
      data_out => crc_out);

  output <= crc_out;

end architecture behav;