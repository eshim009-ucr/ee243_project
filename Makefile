### DEFINITIONS ###
# LaTeX source files #
MAIN_TEX=main.tex

# Output PDF files #
PDF=ee243_project_proposal.pdf

# pdflatex build logs #
LOG=$(subst .pdf,.log,$(PDF))

# pdflatex temp files #
AUX=$(subst .pdf,.aux,$(PDF))
OUT=$(subst .pdf,.out,$(PDF))

# Spellcheck backup files #
BAK=$(wildcard *.tex.bak)


### TARGETS ###
.PHONY: all, check, new, clean, clean-tmp
all: $(PDF)

# Build PDF #
$(PDF): *.tex
	pdflatex --halt-on-error \
		--jobname $(basename $(PDF)) \
		$(basename $(MAIN_TEX))

# Spellcheck source files #
check:
	find . -type f -name '*.tex' -exec \
		aspell --extra-dicts ./local-dict.pws check -t {} \
	\;

# Remove all output files #
clean: clean-tmp
	rm -f $(PDF)

# Remove temporary files #
clean-tmp:
	rm -f $(BAK) $(AUX) $(LOG) $(OUT)
