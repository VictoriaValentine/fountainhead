# fountainhead.mk: include this file from you Makefile to process
# Fountain.io screenplays

# Paths to DTDs and stylesheets are relative to this file; to help
# make(1) find them, include this file like so from your own makefile:
#
# FOUNTAINHEADDIR=path/to/fountainhead
# include $(FOUNTAINHEADDIR)/fountainhead.mk


# DEPENDENCIES

# https://github.com/olivertaylor/Textplay (fountainhead includes this
# as a submodule)
TEXTPLAY=$(FOUNTAINHEADDIR)/Textplay/textplay
# http://xmlsoft.org/XSLT/xsltproc2.html
XSLTPROC=xsltproc
# http://xmlsoft.org/xmllint.html
XMLLINT=xmllint
# http://pandoc.org/
PANDOC=pandoc
# http://weasyprint.org/
WEASYPRINT=weasyprint
ASPELL=aspell
AWK=awk

# SPELLCHECK: verifies .fountain and .md files. Projects can add local
# dictionary terms in $(DICT_FILE). aspell(1) requires that the
# filename be absolute or start with `./' (the value below would need
# refinement in case of recursive make(1) invocations)
DICT_FILE=./aspell.en.pws
# aspell(1) always exits with status 0; this awk(1) script forces a
# non-zero status in case aspell(1) finds non-dictionary words in text
SPELL_STATUS='{print "not in dictionary:", $$0} END {if (NR) exit 1}'

.SUFFIXES: .fountain .tpx .ftx .pdf .md .html

# FOUNTAIN toolchain: .fountain.tpx.ftx.pdf

# textplay XML from fountain
.fountain.tpx:
	$(ASPELL) list -p $(DICT_FILE) < $< | $(AWK) $(SPELL_STATUS)
	$(TEXTPLAY) -x < $< > $@

# fountainhead XML (with structure, etc.)
.tpx.ftx:
	$(XSLTPROC) -o $@ $(FOUNTAINHEADDIR)/tpx2ftx.xslt $<
	$(XMLLINT) --noout --dtdvalid $(FOUNTAINHEADDIR)/ftx.dtd $@

# FTX+CSS can render directly in browsers and to PDF, without HTML
# intermediary
.ftx.pdf:
	$(WEASYPRINT) -s $(FOUNTAINHEADDIR)/ftx.css $< $@


# markdown toolchain: .md.html.pdf

# markdown renders through HTML intermediary (with TW-style CSS)
.md.html:
	$(ASPELL) list -p $(DICT_FILE) < $< | $(AWK) $(SPELL_STATUS)
	$(PANDOC) -H $(FOUNTAINHEADDIR)/typewriter_css.inc -o $@ $<

# weasyprint PDF from HTML
.html.pdf:
	$(WEASYPRINT) $< $@
