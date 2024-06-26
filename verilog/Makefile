### VARIABLES ###
# Project Basename
PROJ_NAME=ee243_project
# Test Harnesses
TB_SRC=$(wildcard *_tb.sv)
# Testing Binaries
TB_BIN=$(subst _tb.sv,_tb,$(TB_SRC))
# Waveform Log Files
LOG=$(wildcard *.vcd)

# Verilog Source Files
SRC=$(wildcard *.v)
SRC_TB=$(wildcard src/*_tb.v)
SRC_SV=$(filter-out $(TB_SRC),$(wildcard *.sv))

# Synthesized Files
BLIF=$(PROJ_NAME).blif
JSON=$(PROJ_NAME).json
# Place and Route Files
ASC=$(PROJ_NAME).asc
# Bitsream Files
BIN=$(PROJ_NAME).bin

ifeq ($(BOARD),nano) # iCESugar Nano
	CON=nano.pcf
	FAMILY=ice40
	NEXTPNR_FLAGS=--lp1k --package cm36 --pcf $(CON) --blif $(BLIF)
else ifeq ($(BOARD),pro) # iCESugar Pro
	CON=pro.lpf
	FAMILY=ecp5
	NEXTPNR_FLAGS=--25k --package CABGA256 --lpf $(CON) --json $(JSON)
else # iCESugar Original
	CON=icesugar.pcf
	FAMILY=ice40
	NEXTPNR_FLAGS=--up5k --package sg48 --pcf icesugar.pcf --blif $(BLIF)
endif

ifeq ($(FAMILY),ice40)
	PNR=nextpnr-ice40
	SYNTH=synth_ice40 -blif $(BLIF)
	SYN=$(BLIF)
else ifeq ($(FAMILY),ecp5)
	PNR=nextpnr-ecp5
	SYNTH=synth_ecp5 -json $(JSON)
	SYN=$(JSON)
endif


### TARGETS ###
.PHONY: flash clean test
all: $(BIN)

# Create a testing binary with icarus verilog
$(PROJ_NAME): $(SRC) $(SRC_SV)
	iverilog -o $(PROJ_NAME) $(SRC)

# Synthesize
$(SYN): $(SRC) $(SRC_SV)
	yosys -p "plugin -i systemverilog; read_systemverilog $(SRC_SV); $(SYNTH) $(YOSYS_OUT)" $(SRC)

$(ASC): $(SYN) $(CON)
	$(PNR) $(NEXTPNR_FLAGS)

# Generate bitstream
$(BIN): $(ASC)
	icepack $(ASC) $(BIN)

# Upload the generated bitsream file to the board
flash: $(BIN)
	icesprog $(BIN)

# Remove all generated files
clean:
	rm -f $(PROJ_NAME) $(JSON) $(BLIF) $(ASC) $(BIN)

# Create testing binaries with icarus verilog
build_tests: $(TB_BIN)

test: build_tests
	$(foreach bin,$(TB_BIN),./$(bin);)
atree_tb: atree_tb.sv atree.sv atree_level.sv adder.v
	iverilog -g2005-sv -o $@ $^
proc_elem_tb: proc_elem_tb.sv proc_elem.sv atree.sv atree_level.sv adder.v
	iverilog -g2005-sv -o $@ $^
conv_layer_tb: conv_layer_tb.sv conv_layer.sv proc_elem.sv atree.sv atree_level.sv adder.v
	iverilog -g2005-sv -o $@ $^
mtree_tb: mtree_tb.sv mtree.sv mtree_level.sv max.v
	iverilog -g2005-sv -o $@ $^
minimobilenet_tb: minimobilenet_tb.sv minimobilenet.sv conv_layer.sv dwcv_layer.sv proc_elem.sv atree.sv atree_level.sv adder.v relu_layer.sv pool_layer.sv  mtree.sv mtree_level.sv max.v fc_layer.sv perceptron.sv
	iverilog -g2005-sv -o $@ $^
