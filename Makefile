#===============================================================================
# Makefile - Mémoire de Stage Master 2 Informatique
#===============================================================================

MAIN      := main
TEX       := $(MAIN).tex
PDF       := $(MAIN).pdf

SOURCES   := $(TEX) preamble.sty References.bib \
             $(wildcard chapters/*.tex) $(wildcard annexes/*.tex)

# minted and svg require shell escape (pygmentize / inkscape)
LATEXMK       := latexmk
LATEXMKFLAGS  := -pdf -bibtex -shell-escape -interaction=nonstopmode -file-line-error

VIEWER    := xdg-open

.PHONY: all pdf watch view clean distclean check help

all: pdf

## pdf: build $(PDF)
pdf: $(PDF)

$(PDF): $(SOURCES)
	$(LATEXMK) $(LATEXMKFLAGS) $(TEX)

## watch: rebuild automatically on every save
watch:
	$(LATEXMK) $(LATEXMKFLAGS) -pvc $(TEX)

## view: open the compiled PDF
view: $(PDF)
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
