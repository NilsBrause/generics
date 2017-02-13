wave log -r testbench
vcd dumpfile testbench.vcd
vcd dumpvars -m /testbench -l 0
run 1 us
vcd dumpflush
exit
