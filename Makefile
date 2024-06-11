### VARIABLES ###
# Project Basename
PROJ_NAME=ee243_project

# Verilog Source Files
SRC=$(wildcard solovyev/verilog/*.v) $(wildcard solovyev/verilog/*/*.v) $(wildcard solovyev/verilog/*/*/*.v)
SRC_SV=$(wildcard solovyev/verilog/*/*.sv)
# Lattice Constraint Files

# Synthesized Files
BLIF=$(PROJ_NAME).blif
JSON=$(PROJ_NAME).json
# Place and Route Files
ASC=$(PROJ_NAME).asc
# Bitsream Files
BIN=$(PROJ_NAME).bin


ifeq ($(TARGET),nano) # iCESugar Nano
	NEXTPNR_FLAGS=--lp1k --package cm36 --pcf nano.pcf
	PNR=nextpnr-ice40
	SYN=synth_ice40
else ifeq ($(TARGET),pro) # iCESugar Pro
	NEXTPNR_FLAGS=--25k --package CABGA256 --lpf pro.lpf
	SYN=synth_ecp5
	PNR=nextpnr-ecp5
else # iCESugar Original
	PNR=nextpnr-ice40
	SYN=synth_ice40
	NEXTPNR_FLAGS=--up5k --package sg48 --pcf icesugar.pcf --pcf-allow-unconstrained
endif




### TARGETS ###
.PHONY: flash clean
all: $(BIN)

# Create a testing binary with icarus verilog
$(PROJ_NAME): $(SRC) $(SRC_SV)
	iverilog -o $(PROJ_NAME) $(SRC)

$(JSON): $(SRC) $(SRC_SV)
	yosys -p "plugin -i systemverilog; read_systemverilog $(SRC_SV); $(SYN) -top GENERAL -json $(JSON)" $(SRC)

$(ASC): $(JSON) $(PCF)
	$(PNR) $(NEXTPNR_FLAGS) --json $(JSON)

# Generate bitstream
$(BIN): $(ASC)
	icepack $(ASC) $(BIN)

# Upload the generated bitsream file to the board
flash: $(BIN)
	icesprog $(BIN)

# Remove all generated files
clean:
	rm -f $(JSON) $(BLIF) $(ASC) $(BIN)
