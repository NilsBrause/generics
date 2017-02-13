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

--! Bidirectional interface

--! The bidir component can be used to easily interface an inout port.
entity bidir is
  generic (
    bits : natural);                    --! port width
  port (
    pins   : inout std_logic_vector(bits-1 downto 0);  --! connect to inout port
    output : in    std_logic_vector(bits-1 downto 0);  --! output to port
    input  : out   std_logic_vector(bits-1 downto 0);  --! input from port
    dir    : in    std_logic);          --! '1' = in, '0' = out
end entity bidir;

architecture behav of bidir is

begin  -- architecture behav

  pins <= output when dir = '0' else (others => 'Z');
  input <= pins when dir = '1' else output;

end architecture behav;
