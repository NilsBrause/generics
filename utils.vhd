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
use ieee.math_real.all;

package utils is
  function log2ceil(x : natural) return natural;
  function swapbits(x : std_logic_vector; bit1 : integer; bit2 : integer)
    return std_logic_vector;
  function bitreverse(x : std_logic_vector) return std_logic_vector;
  function isin(k : integer; N : integer; bits : integer) return std_logic_vector;
  function icos(k : integer; N : integer; bits : integer) return std_logic_vector;
  function sel(condition : boolean; true_val : integer; false_val : natural)
    return natural;
end package utils;

package body utils is
  
  function log2ceil(x : natural) return natural is
  begin
    for i in 0 to 32 loop
      if 2**i >= x then
        return i;
      end if;
    end loop;
    return 32;
  end function;

  function swapbits(x : std_logic_vector; bit1 : integer; bit2 : integer)
    return std_logic_vector is
    variable result : std_logic_vector(x'range);
    variable tmp : std_logic;
  begin
    result := x;
    tmp := result(bit1);
    result(bit1) := result(bit2);
    result(bit2) := tmp;
    return result;
  end swapbits;

  -- radix2 only
  function bitreverse(x : std_logic_vector) return std_logic_vector is
    variable result : std_logic_vector(x'range);
  begin
    result := x;
    for c in 0 to x'length/2-1 loop
      result := swapbits(result, x'low+c, x'high-c);
    end loop;  -- c
    return result;
  end bitreverse;

  -- sin(2*pi*k/N)
  function isin(k : integer; N : integer; bits : integer) return std_logic_vector is
    variable tmp : real;
  begin
    tmp := sin(real(k)/real(N)*MATH_PI*real(2))*real(2**(bits-1)-1);
    return std_logic_vector(to_signed(integer(tmp), bits));
  end isin;
  
  -- cos(2*pi*k/N)
  function icos(k : integer; N : integer; bits : integer) return std_logic_vector is
    variable tmp : real;
  begin
    tmp := cos(real(k)/real(N)*MATH_PI*real(2))*real(2**(bits-1)-1);
    return std_logic_vector(to_signed(integer(tmp), bits));
  end icos;
  
  -- like ?: in C++
  function sel(condition : boolean; true_val : integer; false_val : natural) return natural is
  begin
    if condition then
      return true_val;
    else
      return false_val;
    end if;
  end function sel;

end package body utils;
