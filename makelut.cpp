#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <cmath>
#include <string>

unsigned int powui(unsigned int x, unsigned int y)
{
  unsigned int z = 1;
  for(unsigned int c = 0; c < y; c++) z *= x;
  return z;
}

std::string int2bin(unsigned int x, unsigned int bits)
{
  std::string result;
  for(unsigned int c = bits; c > 0; c--)
    result += (x & powui(2, c-1)) != 0 ? "1" : "0";
  return result;
}

int main(int argc, char* argv[])
{
  if(argc < 3)
    {
      std::cout << "Usage: " << argv[0] << " in_bits out_bits" << std::endl;
      return 1;
    }
   
  unsigned int in_bits = atoi(argv[1]);
  unsigned int out_bits = atoi(argv[2]);

  unsigned int length = powui(2, in_bits);
  unsigned int max = powui(2, out_bits-1);

  std::cout << "library ieee;" << std::endl
	    << "use ieee.std_logic_1164.all;" << std::endl
	    << std::endl
	    << "package lut is" << std::endl
	    << "  constant lut_in_bits : natural := "
	    << in_bits << ";" << std::endl
	    << "  constant lut_out_bits : natural := "
	    << out_bits << ";" << std::endl
	    << "  type romu is array(0 to 2**lut_in_bits-1)"
	    << " of std_logic_vector(lut_out_bits-1 downto 0);" << std::endl
	    << "  constant rom : romu :=(" << std::endl;

  for(unsigned int c = 0; c < length; c++)
    {
      float x = static_cast<float>(c)/static_cast<float>(length)*M_PI/2;
      unsigned int y = static_cast<unsigned int>(cos(x)*max) - 1;
      if(c % 4 == 0) std::cout << "    ";
      std::cout << "\"" << int2bin(y, out_bits) << "\"";
      if(c < length-1) std::cout << ", ";
      if((c + 1) % 4 == 0) std::cout << std::endl;
    }

  std::cout << "  );" << std::endl
	    << "end lut;" << std::endl;

  return 0;
}
