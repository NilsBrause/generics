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

# Default values ##############################################################

# main
HDLFILES = main.vhd
TOPENTITY = main

# simulation only
TESTBENCH = testbench
TBHDLFILES = testbench.vhd
DOFILE = testbench.do
FUSEFLAGS = 
TBFLAGS = 

# synthesis only
DEVICE = xc6vlx240t-ff1156-1
UCFILE = main.ucf
URFILE = main.urf
XSTFLAGS = 
MAPFLAGS = 
PARFLAGS = 
BITFLAGS = 
TRCFLAGS = -a -v

# Main targets ################################################################

all: sim trace tsim bit

include config.mk

sim: $(TESTBENCH).wdb

syn: $(TOPENTITY).ngc

trans: $(TOPENTITY).ngd

map: $(TOPENTITY).ncd

par: $(TOPENTITY)_par.ncd

bit: $(TOPENTITY).bit

trace: $(TOPENTITY).twr

tsim: $(TESTBENCH)_t.wdb

ghdl: $(TESTBENCH).ghw

# Help ########################################################################

help:
	@echo ""
	@echo "Available Targets:"
	@echo "  sim:   Functional simulation"
	@echo "  syn:   Synthesis"
	@echo "  trans: Translation"
	@echo "  map:   Mapping"
	@echo "  par:   Place and Route"
	@echo "  bit:   Bitfile generation"
	@echo "  trace: Timing Report"
	@echo "  tsim:  Timing Simulation"
	@echo "  ghdl:  GHDL simulation"
	@echo "  help:  This help text"
	@echo "  all:   sim, trace, tsim and bit (Default)"
	@echo ""
	@echo "Configuration variables:"
	@echo "  (Put them into your config.mk)"
	@echo "  HDLFILES:   VHDL Source Files (Default: main.vhd)"
	@echo "  TOPENTITY:  The topmost entity name (Default: main)"
	@echo "  TESTBENCH:  Testbench entity name (Default: testbench)"
	@echo "  TBHDLFILES: Testbench HDL files (Default: testbench.vhd)"
	@echo "  DOFILE:     Simulation batch file (Default: testbench.do)"
	@echo "  FUSEFLAGS:  Command line arguments for FUSE (Default empty)"
	@echo "  TBFLAGS:    Command line arguments for the testbench (Default empty)"
	@echo "  DEVICE:     Your device (Default: xc6vlx240t-ff1156-1)"
	@echo "  UCFILE:     User constraints file (Default: main.ucf)"
	@echo "  URFILE:     User rules file (Default: main.urf)"
	@echo "  XSTFLAGS:   Command line arguments for XST (Default empty)"
	@echo "  MAPFLAGS:   Command line arguments for MAP (Default empty)"
	@echo "  PARFLAGS:   Command line arguments for PAR (Default empty)"
	@echo "  BITFLAGS:   Command line arguments for BITGEN (Default empty)"
	@echo "  TRCFLAGS:   Command line arguments for TRCE (Default '-a -v')"
	@echo ""
	@echo "About IP cores:"
	@echo "  Just put the generated .ngc files into the same directory"
	@echo "  as this Makefile. They will be loaded automaticcally."
	@echo ""
	@echo "If you need additional rules (e.g. for dynamic VHDL code"
	@echo "generation), you can add them to your config.mk."
	@echo ""

# GHDL Simulation #############################################################

$(TESTBENCH).ghw: $(patsubst %.vhd,%.o,$(HDLFILES))  $(patsubst %.vhd,%.o,$(TBHDLFILES)) Makefile config.mk
	ghdl -a -Wc,-g $(TESTBENCH).vhd
	ghdl -e -Wc,-g $(TESTBENCH)
	ghdl -r $(TESTBENCH) --stop-time=5000ms --wave=$@

%.o: %.vhd Makefile
	ghdl -a -Wc,-g $<

# Timing Simulation ###########################################################

$(TESTBENCH)_t.wdb: $(TESTBENCH)_t $(TOPENTITY)_par.sdf $(DOFILE) Makefile\
 config.mk
	./$< $(TBFLAGS) -tclbatch $(DOFILE) -wdb $@ #-sdftyp $(TOPENTITY)_par.sdf

$(TESTBENCH)_t: $(TOPENTITY)_tsim.prj Makefile config.mk
	fuse $(FUSEFLAGS) $(TESTBENCH) --prj $< -o $@

$(TOPENTITY)_tsim.prj: $(TOPENTITY)_par.vhd $(TBHDLFILES) Makefile config.mk
	rm -rf $@
	for i in $< $(TBHDLFILES) ; do \
		echo "vhdl work $$i" >> $@ ; \
	done

$(TOPENTITY)_par.sdf: $(TOPENTITY)_par.vhd

$(TOPENTITY)_par.vhd: $(TOPENTITY).pcf $(TOPENTITY)_par.ncd
	netgen -sim -ofmt vhdl -w -pcf $+

# Timing Reporter And Circuit Evaluator #######################################

$(TOPENTITY).twr: $(TOPENTITY)_par.ncd $(TOPENTITY).pcf Makefile config.mk
	trce $(TRCFLAGS) -o $@ $< $(TOPENTITY).pcf

# Bitstream Generation ########################################################

$(TOPENTITY).bit: $(TOPENTITY)_par.ncd $(TOPENTITY).pcf Makefile config.mk
	bitgen $(BITFLAGS) -w $< $@ $(TOPENTITY).pcf

# Place and Route #############################################################

$(TOPENTITY)_par.ncd: $(TOPENTITY).ncd $(TOPENTITY).pcf Makefile config.mk
	par $(PARFLAGS) -w $< $@ $(TOPENTITY).pcf

# Mapping #####################################################################

$(TOPENTITY).pcf: $(TOPENTITY).ncd

$(TOPENTITY).ncd: $(TOPENTITY).ngd Makefile config.mk
	map $(MAPFLAGS) -p $(DEVICE) -w -o $@ $<

# Translation #################################################################

$(TOPENTITY).ngd: $(TOPENTITY).ngc $(UCFILE) $(URFILE) Makefile config.mk
	ngdbuild -p $(DEVICE) -uc $(UCFILE) -ur $(URFILE) -dd . $< $@

# Synthesis ###################################################################

$(TOPENTITY).ngc: $(TOPENTITY)_syn.prj $(HDLFILES) Makefile config.mk
	echo "run -ifn $< -ofn $@  -p $(DEVICE) -top $(TOPENTITY) $(XSTFLAGS)"\
	| xst

$(TOPENTITY)_syn.prj: $(HDLFILES) Makefile config.mk
	rm -rf $@
	for i in $(HDLFILES) ; do \
		echo "vhdl work $$i" >> $@ ; \
	done

# Simulation ##################################################################

$(TESTBENCH).wdb: $(TESTBENCH) $(DOFILE) Makefile config.mk
	./$< $(TBFLAGS) -tclbatch $(DOFILE) -wdb $@

$(TESTBENCH): $(TOPENTITY)_sim.prj Makefile config.mk
	fuse $(FUSEFLAGS) work.$(TESTBENCH) --prj $< -o $@

$(TOPENTITY)_sim.prj: $(HDLFILES) $(TBHDLFILES) Makefile config.mk
	rm -rf $@
	for i in $(HDLFILES) $(TBHDLFILES) ; do \
		echo "vhdl work $$i" >> $@ ; \
	done

# Clean ######################################################################

clean:
#	sim
	rm -rf  fuse.log fuseRelaunch.cmd fuse.xmsgs webtalk.log isim isim.log
#	syn
	rm -rf $(TOPENTITY).bld $(TOPENTITY).lso
	rm -rf $(TOPENTITY).ngc_xst.xrpt $(TOPENTITY)_ngdbuild.xrpt netlist.lst
	rm -rf xst _xmsgs xlnx_auto_0_xdb 
#	map
	rm -rf $(TOPENTITY).map $(TOPENTITY).mrp $(TOPENTITY)_map.xrpt 
	rm -rf $(TOPENTITY).ngm $(TOPENTITY)_usage.xml
	rm -rf $(TOPENTITY)_summary.xml
#	par
	rm -rf $(TOPENTITY)_par.pad $(TOPENTITY)_par_pad.*
	rm -rf $(TOPENTITY)_par.par $(TOPENTITY)_par.ptwx
	rm -rf $(TOPENTITY)_par.unroutes $(TOPENTITY)_par.xpi
	rm -rf $(TOPENTITY)_par.xrpt par_usage_statistics.html
#	bit
	rm -rf $(TOPENTITY).bgn $(TOPENTITY).drc $(TOPENTITY)_bitgen.xwbt
	rm -rf usage_statistics_webtalk.html
#	trace
	rm -rf $(TOPENTITY).twx
#       tsim
	rm -rf $(TOPENTITY)_par.nlf
#	impact
	rm -rf *auto_project* *impact*
#	misc
	rm -rf *~

realclean: clean
#	sim
	rm -rf $(TOPENTITY)_sim.prj $(TOPENTITY)_tsim.prj *.vdb $(TESTBENCH) 
#	syn
	rm -rf $(TOPENTITY)_syn.prj $(TOPENTITY).ngc $(TOPENTITY).ngd
#	map
	rm -rf $(TOPENTITY).ncd $(TOPENTITY).pcf
#	par
	rm -rf $(TOPENTITY)_par.ncd
#	tsim
	rm -rf $(TESTBENCH)_t
	rm -rf $(TOPENTITY)_par.sdf $(TOPENTITY)_par.vhd
#	ghdl
	rm -rf *.o work-obj93.cf

mrproper: realclean
#	sim
	rm -rf $(TESTBENCH).wdb $(TESTBENCH)_t.wdb
#	bit
	rm -rf $(TOPENTITY).bit
#	trace
	rm -rf $(TOPENTITY).twr
#	ghdl
	rm -rf $(TESTBENCH).ghw
