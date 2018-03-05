# fountainhead.mk: include this file from you Makefile to process
# Fountain.io screenplays

# Paths to DTDs and stylesheets are relative to this file; to help
# make(1) find them, include this file like so from your own makefile:
#
# FOUNTAINHEADDIR=path/to/fountainhead
# include $(FOUNTAINHEADDIR)/fountainhead.mk


# DEPENDENCIES

PYTHON=python
# https://pypi.python.org/pypi/Markdown
# http://xmlsoft.org/xmllint.html
XMLLINT=xmllint
# http://pandoc.org/
PANDOC=pandoc
# http://weasyprint.org/
WEASYPRINT=weasyprint
ASPELL=aspell
GREP=grep

# SPELLCHECK: verifies .fountain and .md files. Projects can add local
# dictionary terms in $(DICT_FILE). aspell(1) requires that the
# filename be absolute or start with `./' (the value below would need
# refinement in case of recursive make(1) invocations)
DICT_FILE=./aspell.en.pws

.SUFFIXES: .fountain .ftx .pdf .md .html

# FOUNTAIN toolchain: .fountain.ftx.pdf

# XML from fountain
.fountain.ftx:
	$(PYTHON) $(FOUNTAINHEADDIR)/fountainhead.py -s -c $(FOUNTAINHEADDIR)/ftx.css $< > $@
	$(XMLLINT) --noout --dtdvalid $(FOUNTAINHEADDIR)/ftx.dtd $@

# FTX+CSS can render directly in browsers and to PDF, without HTML
# intermediary
.ftx.pdf:
# <note> is where clip information lives now; if this changes, --add-html-skip=note needs to change as well
# this rule spell-checks the XML so it can skip over some elements, but greps the .fountain to show errors at the source
	$(ASPELL) list -H --add-html-skip=note -p $(DICT_FILE) < $< | $(GREP) -nFf - --color=auto $*.fountain; \
		[ $$? -eq 1 ]
	$(WEASYPRINT) -s $(FOUNTAINHEADDIR)/ftx.css $< $@


# markdown toolchain: .md.html.pdf

# markdown renders through HTML intermediary (with TW-style CSS)
.md.html:
	$(ASPELL) list -p $(DICT_FILE) < $< | $(GREP) -nFf - --color=auto $<; \
		[ $$? -eq 1 ]
	$(PANDOC) -H $(FOUNTAINHEADDIR)/typewriter_css.inc -o $@ $<

# weasyprint PDF from HTML
.html.pdf:
	$(WEASYPRINT) $< $@
