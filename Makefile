# Copyright (c) 2012, Nils Christopher Brause
# All rights reserved.
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# 
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of the Max Planck Institute for
# Gravitational Physics (Albert Einstein Institute).

TB = testbench
#TB = testbench_pll
OBJ = log2.o register1.o register.o shift_reg.o delay_reg.o kogge_stone.o add.o sub.o accumulator.o counter.o lut.o sincos.o nco.o array_adder.o mul.o round.o iqdemod.o cmp.o decode.o barrel_shift.o differentiator.o bidir.o cic.o lfsr.o pidctrl.o pwm.o clkdiv.o pll.o serializer.o demux.o butterfly.o multi_shift_reg.o

output.ghw: $(TB)
	ghdl -r $(TB) --stop-time=30us --wave=output.ghw

$(TB): $(OBJ) $(TB).vhd
	ghdl -a -Wc,-g $(TB).vhd
	ghdl -e -Wc,-g $(TB)

%.o: %.vhd Makefile
	ghdl -a -Wc,-g $<

lut.vhd: makelut Makefile
	./makelut 10 12 > lut.vhd

makelut: makelut.cpp Makefile
	g++ makelut.cpp -omakelut

clean:
	rm -f *.o *.cf $(TB) makelut lut.vhd output.ghw *~
