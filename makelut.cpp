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

void makelut(unsigned int bits, unsigned int div)
{
  std::cout << "  type rom" << div << "_t is array(0 to 2**lut_bits/" << div
            << "-1)" << std::endl
	    << "    of std_logic_vector(lut_bits-1 downto 0);" << std::endl
	    << "  constant rom" << div << " : rom" << div << "_t :=("
            << std::endl;

  unsigned int length = powui(2, bits)/div;
  unsigned int max = powui(2, bits-1)-1;

  for(unsigned int c = 0; c < length; c++)
    {
      float x = static_cast<float>(c)/static_cast<float>(length)*2.*M_PI
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
      std::cout << "Usage: " << argv[0] << " bits" << std::endl;
      return 1;
    }
   
  unsigned int bits = atoi(argv[1]);

  std::cout << "library ieee;" << std::endl
	    << "use ieee.std_logic_1164.all;" << std::endl
	    << std::endl
	    << "package lut is" << std::endl
	    << "  constant lut_bits : natural := "
	    << bits << ";" << std::endl;

  makelut(bits, 4);
  makelut(bits, 2);
  makelut(bits, 1);

  std::cout << "end lut;" << std::endl;

  return 0;
}
