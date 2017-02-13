/* (C) Copyright 2012-2016 Nils christopher Brause
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <cassert>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <string>

// Unsigned integer only version of std::pow.
unsigned int powui(unsigned int x, unsigned int y)
{
  unsigned int z = 1;
  for(unsigned int c = 0; c < y; c++) z *= x;
  return z;
}

// Convert unsigned integers to its binary representation.
std::string int2bin(unsigned int x, unsigned int bits)
{
  assert(bits < 32);
  std::string result;
  for(unsigned int c = bits; c > 0; c--)
    result += (x & powui(2, c-1)) != 0 ? "1" : "0";
  return result;
}

void makelut(unsigned int bits, unsigned int div)
{
  assert(bits < 32);

  // header
  std::cout << "  type rom" << div << "_t is array(0 to 2**lut_bits/" << div
            << "-1)" << std::endl
	    << "    of std_logic_vector(lut_bits-1 downto 0);" << std::endl
	    << "  constant rom" << div << " : rom" << div << "_t :=("
            << std::endl;

  // length of the LUT
  unsigned int length = powui(2u, bits)/div;

  // maximum value of a signed integer of length bits.
  unsigned int max = powui(2u, bits-1)-1;

  // cake
  long double pi = std::acos(-1.l);

  // construct LUT
  for(unsigned int c = 0; c < length; c++)
    {
      long double x = static_cast<long double>(c)/static_cast<long double>(length)*2.l*pi
        /static_cast<float>(div);
      unsigned int y = static_cast<unsigned int>(cos(x)*max);
      if(c % 4 == 0) std::cout << "    ";
      std::cout << "\"" << int2bin(y, bits) << "\"";
      if(c < length-1) std::cout << ", ";
      if((c + 1) % 4 == 0) std::cout << std::endl;
    }

  std::cout << "  );" << std::endl;
}

int main(int argc, char* argv[])
{
  if(argc < 2)
    {
      std::cout << "Usage: " << argv[0] << " bits > lut.vhd" << std::endl;
      return 1;
    }

  unsigned int bits = atoi(argv[1]);

  if(bits > 31)
    {
      std::cerr << "Too much bits." << std::endl;
      return 2;
    }

  if(argc > 3)
    std::cerr << "Extra arguments ignored." << std::endl;

  std::cout << "library ieee;" << std::endl
	    << "use ieee.std_logic_1164.all;" << std::endl
	    << std::endl
	    << "package lut is" << std::endl
	    << "  constant lut_bits : natural := "
	    << bits << ";" << std::endl;

  makelut(bits, 1);
  makelut(bits, 2);
  makelut(bits, 4);

  std::cout << "end lut;" << std::endl;

  return 0;
}
