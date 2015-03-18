NAME     = Beschreibung_des_Vorhabens
AUXFILES = pub_list.tex
OTHERS   = Arbeitsplatzzusage.pdf 
TEX      = pdflatex
BIBTEX   = bibtex 
VPATH    = plots
OUT      = tmp
REF      = /Users/til/Documents/Papers/bibliography
ARGS     = -interaction=nonstopmode
RMSUF    = .aux .out .upa .upb .pax .log .blg Notes.bib .pdfsync .synctex.gz .bcf .run.xml -blx.bib
RMFILES  = texput.log bibtex.log Beschreibung_des_Vorhaben.synctex.gz
CWD      = $(CURDIR)
# can be more than one BBL file
BBL      = $(NAME).bbl 

all: others $(NAME).pdf

others: $(OTHERS)

# create the bbl file
%.bbl: $(REF).bib
	$(TEX) $(ARGS) $(@:.bbl=.tex) &> /dev/null
	-$(BIBTEX) $(@:.bbl=) &> bibtex.log

pub_list.tex: get_publist_from_bibcodes.py
	python get_publist_from_bibcodes.py

# create the main file: depends on bbl and AUXFILES
$(NAME).pdf : $(AUXFILES) $(NAME).tex $(BBL)
	while ($(TEX) $(ARGS) $(NAME) &> /dev/null ; \
	grep -q "Rerun to get" $(NAME).log ) do true ; \
	done

# generic pdf rule
%.pdf: %.tex
	while ($(TEX) $(ARGS) $< &> /dev/null ; \
	grep -q "Rerun to get" $(@:.pdf=.log) ) do true ; \
	done
	
clean:
	-rm -rf $(foreach s,$(RMSUF),$(NAME)$s) &> /dev/null
	#-rm -rf $(foreach s,$(RMSUF),$(foreach f,$(AUXFILES),$f$s)) &> /dev/null
	-rm -rf $(foreach s,$(RMSUF),$(foreach f,$(OTHERS:.pdf=),$f$s)) &> /dev/null
	-rm -rf $(RMFILES)
	-rm -rf $(BBL:bbl=aux) $(BBL:bbl=blg)
	
clobber: clean
	rm -rf $(NAME).pdf $(BBL) $(AUXFILES) $(OTHERS) &> /dev/null
	-rm -rf $(foreach f,$(OTHERS:.pdf=),$f.bbl) &> /dev/null

