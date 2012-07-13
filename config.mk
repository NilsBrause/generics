TESTBENCH = testbench
#TESTBENCH = testbench_pll
HDLFILES = log2.vhd register1.vhd register.vhd shift_reg.vhd delay_reg.vhd kogge_stone.vhd add.vhd sub.vhd accumulator.vhd counter.vhd lut.vhd sincos.vhd nco.vhd array_adder.vhd mul.vhd round.vhd iqdemod.vhd cmp.vhd decode.vhd barrel_shift.vhd differentiator.vhd bidir.vhd cic.vhd lfsr.vhd pidctrl.vhd pwm.vhd clkdiv.vhd pll.vhd serializer.vhd demux.vhd butterfly.vhd multi_shift_reg.vhd butterfly.vhd mux.vhd ram.vhd

lut.vhd: makelut Makefile
	./makelut 10 12 > lut.vhd

makelut: makelut.cpp Makefile
	g++ makelut.cpp -omakelut

allclean: mrproper
	rm -rf makelut lut.vhd
