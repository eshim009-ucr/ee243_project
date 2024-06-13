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
SRC=$(wildcard *.v) $(wildcard *.sv)
# Lattice Constraint Files
PCF=$(PROJ_NAME).pcf

# Synthesized Files
BLIF=$(PROJ_NAME).blif
# Place and Route Files
ASC=$(PROJ_NAME).asc
# Bitstream Files
BIN=$(PROJ_NAME).bin

# For iCE40-LP1k-CM36
NEXTPNR_FLAGS=-lp1k -package cm36
ARACHNEPNR_FLAGS=-d 1k -P cm36
ICETIME_FLAGS=-d lp1k


### TARGETS ###
.PHONY: flash clean test
all: $(BIN)

# Create a testing binary with icarus verilog
$(PROJ_NAME): $(SRC)
	iverilog -o $(PROJ_NAME) $(SRC)

$(BLIF): $(SRC)
	yosys -p "synth_ice40 -blif $(BLIF)" $(SRC)

$(ASC): $(BLIF) $(PCF)
	arachne-pnr $(ARACHNEPNR_FLAGS) -p $(PCF) $(BLIF) -o $(ASC)

# Generate bitstream
$(BIN): $(ASC)
	icepack $(ASC) $(BIN)

# Upload the generated bitsream file to the board
flash: $(BIN)
	icesprog $(BIN)

# Remove all generated files
clean:
	rm -f $(PROJ_NAME) $(BLIF) $(ASC) $(BIN)

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
