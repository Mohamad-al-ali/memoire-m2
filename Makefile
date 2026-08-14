#===============================================================================
# Makefile - Mémoire de Stage Master 2 Informatique
#===============================================================================
# The targets are phony on purpose: latexmk does its own dependency tracking
# (it reads main.fls / main.fdb_latexmk and knows about every \input, image and
# .bib file), so make must never second-guess it with timestamp comparisons.
#===============================================================================

MAIN      := main
TEX       := $(MAIN).tex
PDF       := $(MAIN).pdf

# minted and svg require shell escape (pygmentize / inkscape)
LATEXMK       := latexmk
LATEXMKFLAGS  := -pdf -bibtex -shell-escape \
                 -interaction=nonstopmode -halt-on-error -file-line-error

VIEWER    := xdg-open

.PHONY: all pdf force watch view clean distclean check help

all: pdf

## pdf: build main.pdf (recompiles only what latexmk considers out of date)
pdf:
	$(LATEXMK) $(LATEXMKFLAGS) $(TEX)

## force: rebuild main.pdf from scratch, ignoring any cached state
force:
	$(LATEXMK) $(LATEXMKFLAGS) -g $(TEX)

## watch: rebuild automatically on every save
watch:
	$(LATEXMK) $(LATEXMKFLAGS) -pvc $(TEX)

## view: open the compiled PDF
view: pdf
	$(VIEWER) $(PDF) >/dev/null 2>&1 &

## check: report missing external tools
check:
	@for t in latexmk pdflatex bibtex pygmentize inkscape; do \
	    if command -v $$t >/dev/null 2>&1; then \
	        echo "ok      $$t"; \
	    else \
	        echo "MISSING $$t"; \
	    fi; \
	done

## clean: remove auxiliary files, keep the PDF
clean:
	$(LATEXMK) -c $(TEX)
	$(RM) -r _minted-$(MAIN) svg-inkscape
	$(RM) $(MAIN).bbl $(MAIN).run.xml $(MAIN).synctex.gz

## distclean: remove auxiliary files and the PDF
distclean: clean
	$(RM) $(PDF)

## help: list available targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  make /'
