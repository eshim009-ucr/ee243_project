### DEFINITIONS ###
# LaTeX source files #
MAIN_TEX=main.tex

# Output PDF files #
MAIN_PDF=ee243_project_proposal.pdf

# pdflatex build logs #
LOG=$(subst .pdf,.log,$(MAIN_PDF))

# pdflatex temp files #
AUX=$(subst .pdf,.aux,$(MAIN_PDF))
OUT=$(subst .pdf,.out,$(MAIN_PDF))

# Spellcheck backup files #
BAK=$(wildcard *.tex.bak)

# Citation source
BIB=$(wildcard *.bib)
# Citation temp files
BIB_TMP=$(wildcard *.bbl) $(wildcard *.bcf) $(wildcard *.blg) $(wildcard *.run.xml)

### TARGETS ###
.PHONY: all, check, new, clean, clean-tmp
all: $(MAIN_PDF)

# Build PDF #
$(MAIN_PDF): $(wildcard *.tex) $(BIB)
	pdflatex --halt-on-error --jobname $(basename $(MAIN_PDF)) $(basename $(MAIN_TEX))
	biber $(basename $(MAIN_PDF))
	pdflatex --halt-on-error --jobname $(basename $(MAIN_PDF)) $(basename $(MAIN_TEX))
	pdflatex --halt-on-error --jobname $(basename $(MAIN_PDF)) $(basename $(MAIN_TEX))

# Spellcheck source files #
check:
	find . -type f -name '*.tex' -exec \
		aspell --extra-dicts ./local-dict.pws check -t {} \
	\;

# Remove all output files #
clean: clean-tmp
	rm -f $(MAIN_PDF)

# Remove temporary files #
clean-tmp:
	rm -f $(BAK) $(AUX) $(LOG) $(OUT) $(BIB_TMP)
