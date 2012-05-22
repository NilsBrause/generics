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

entity round is
  generic (
    inp_bits        : natural;
    outp_bits       : natural;
    signed_arith    : bit := '1';
    use_kogge_stone : bit := '0');
  port (
    input  : in  std_logic_vector(inp_bits-1 downto 0);
    output : out std_logic_vector(outp_bits-1 downto 0));
end round;

architecture behav of round is

  signal roundup   : std_logic_vector(outp_bits-1 downto 0);
  
begin  -- behav

  do_round: if inp_bits > outp_bits generate
    
    add_1: entity work.add
      generic map (
        bits            => outp_bits,
        use_kogge_stone => use_kogge_stone)
      port map (
        input1    => input(inp_bits-1 downto inp_bits-outp_bits),
        input2    => (others => '0'),
        output    => roundup,
        carry_in  => '1',
        carry_out => open,
        overflow  => open);
    
    signed_yes: if signed_arith = '1' generate
      output <= roundup
                when ((input(inp_bits-1) = '0' -- positive sign
                       and input(inp_bits-outp_bits-1) = '1' -- .5
                       -- prevent overflow
                       and not (input(inp_bits-2 downto inp_bits-outp_bits)
                                = (inp_bits-2 downto
                                   inp_bits-outp_bits => '1')))
                      or (input(inp_bits-1) = '1' -- negative sign
                          and input(inp_bits-outp_bits-1) = '1')) -- .5
                else input(inp_bits-1 downto inp_bits-outp_bits);
    end generate signed_yes;
    
    signed_no: if signed_arith = '0' generate
      output <= roundup
                when ((input(inp_bits-1) = '0'
                       and input(inp_bits-outp_bits-1) = '1') -- .5
                      or (input(inp_bits-1) = '1'
                          and input(inp_bits-outp_bits-1) = '1' -- .5
                          -- prevent overflow
                          and not (input(inp_bits-2 downto inp_bits-outp_bits)
                                   = (inp_bits-2 downto
                                      inp_bits-outp_bits => '1'))))
                else input(inp_bits-1 downto inp_bits-outp_bits);
    end generate signed_no;
  
  end generate do_round;

  same_width: if inp_bits = outp_bits generate
    output <= input;
  end generate same_width;

  extend: if inp_bits < outp_bits generate
    output(outp_bits-1 downto outp_bits-inp_bits) <= input;
    output(outp_bits-inp_bits-1 downto 0) <= (others => '0');
  end generate extend;
  
end behav;
