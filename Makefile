NAMES     = Beschreibung_des_Vorhabens 
NAMES_PDF = $(NAMES:=.pdf)
AUX_TEX   = pub_list.tex
AUX_PDF	  = Arbeitsplatzzusage.pdf
OTHERS    = pub_list.tex
TEX       = pdflatex
BIBTEX    = bibtex 
VPATH     = figures
OUTDIR    = tmp
RELREF    = bibliography
ARGS      = -interaction=nonstopmode -output-directory $(OUTDIR)
RMSUF     = .aux .out .upa .upb .pax .log .blg Notes.bib .pdfsync .synctex.gz .bcf .run.xml -blx.bib # all un-needed extensions
RMFILES   = texput.log bibtex.log $(OUTDIR)/bibtex.log # files that can be "cleaned"
CWD       = $(CURDIR)
# can be more than one BBL file
BBL        = $(foreach N,$(NAMES),$(OUTDIR)/$N.bbl)

#
# get full path to bibliography
#
REF = $(realpath $(RELREF))

all: others $(NAMES_PDF) 

others: $(OTHERS)

pub_list.tex: get_publist_from_bibcodes.py
	./get_publist_from_bibcodes.py

# create the bbl file
%.bbl: $(REF)
	$(TEX) $(ARGS) $(basename $(notdir $@)).tex &> /dev/null
	$(BIBTEX) $(basename $@) &> $(OUTDIR)/bibtex.log
	-cp $(notdir $@) $@

# create the main file: depends on bbl and AUXFILES
$(NAMES_PDF) : %.pdf: $(AUX_PDF) $(AUX_TEX) %.tex $(OUTDIR)/%.bbl
	while ($(TEX) $(ARGS) $(@:.pdf=.tex)  &> /dev/null ; \
		grep -q "Rerun to get" $(OUTDIR)/$(@:.pdf=.log) ) do true ; \
	done
	mv $(OUTDIR)/$@ .

# generic pdf rule
%.pdf: %.tex
	while ($(TEX) $(ARGS) $< &> /dev/null ; \
	grep -q "Rerun to get" $(OUTDIR)/$(@:.pdf=.log) ) do true ; \
	done
	mv $(OUTDIR)/$@ .
	
clean:
	-rm -rf $(foreach n,$(NAMES),$(foreach s,$(RMSUF),$(OUTDIR)/$n$s)) &> /dev/null
	-rm -rf $(foreach n,$(NAMES),$(foreach s,$(RMSUF),$n$s)) &> /dev/null
	-rm -rf $(foreach s,$(RMSUF),$(foreach f,$(AUX_PDF:.pdf=),$(OUTDIR)/$f$s)) &> /dev/null
	-rm -rf $(foreach s,$(RMSUF),$(foreach f,$(basename $(OTHERS)),$(OUTDIR)/$f$s)) &> /dev/null
	-rm -rf $(foreach s,$(RMFILES),$s) &> /dev/null
	-rm -rf $(foreach s,$(BBL),$(s:bbl=aux)) &> /dev/null
	-rm -rf $(foreach s,$(BBL),$(s:bbl=blg)) &> /dev/null
	
clobber: clean
	rm -rf $(AUX_PDF) $(NAMES_PDF) $(BBL) $(OTHERS) &> /dev/null
