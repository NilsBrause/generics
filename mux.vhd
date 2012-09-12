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

--! multiplexer

--! A multiplexer multiplexes a signal into a stream of multiple signals.
entity multiplex is
  generic (
    bits      : natural;                -- width of input
    code_bits : natural);               -- 2^code_bits is the number of signals in the multiplex
  port (
    basein : in  std_logic_vector(2**code_bits*bits-1 downto 0);  --! signal, where the input will be multiplexed into
    input  : in  std_logic_vector(bits-1 downto 0);  --! to be multiplexed signal
    code   : in  std_logic_vector(code_bits-1 downto 0);  --! signal destination 
    output : out std_logic_vector(2**code_bits*bits-1 downto 0));  --! multiplexed output
end entity multiplex;

architecture behav of multiplex is
  
  signal decode : std_logic_vector(2**code_bits-1 downto 0);
  type demux_inp is array (0 to 2**code_bits-1)
    of std_logic_vector(2*bits-1 downto 0);
  signal demux_input : demux_inp;
  
begin  -- architecture behav

  decoder_1: entity work.decoder
    generic map (
      bits => code_bits)
    port map (
      input  => code,
      output => decode);

  cmps: for c in 0 to 2**code_bits-1 generate
    demux_input(c)(bits-1 downto 0) <= basein((c+1)*bits-1 downto c*bits);
    demux_input(c)(2*bits-1 downto bits) <= input;
    
    demultiplex_1: entity work.demultiplex
      generic map (
        bits      => bits,
        code_bits => 1)
      port map (
        code   => decode(c downto c),
        input  => demux_input(c),
        output => output((c+1)*bits-1 downto c*bits));
  end generate cmps;

end architecture behav;
