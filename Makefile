RVERSION=R-3.4.3
RSUM=7a3cb831de5b4151e1f890113ed207527b7d4b16df9ec6b35e0964170007f426
TOOLS=$(HOME)/opt/r
R=$(TOOLS)/bin/R
RLIBS=$(addprefix .r-, rmarkdown HSAUR3 ggplot2 GGally lattice data.table)
RSCRIPT=$(TOOLS)/bin/Rscript

rstuff.pdf: deps $(TOOLS)/bin/R rstuff.rmd 
	$(RSCRIPT) --latex-engine=xelatex -e "rmarkdown::render('rstuff.rmd')"

rstuff.html: deps $(TOOLS)/bin/R rstuff.rmd 
	$(RSCRIPT) --latex-engine=xelatex -e "rmarkdown::render('rstuff.rmd', output_format='html_document')"

deps: Makefile $(R) $(RLIBS)
	sudo apt-get install texlive-xetex curl -y
	touch deps

$(RLIBS): $(R)
	# Installing R library $(subst .r-,,$@) 
	$(RSCRIPT) -e "install.packages('$(subst .r-,,$@)', repos='http://cran.us.r-project.org')"
	touch $(@)

tmp/$(RVERSION).tar.gz:
	# fetching R suorces for installation to $(TOOLS)
	mkdir -p tmp
	curl https://cran.r-project.org/src/base/R-3/$(RVERSION).tar.gz > tmp/out
	sha256sum tmp/out | grep $(RSUM)
	mv tmp/out tmp/$(RVERSION).tar.gz

tmp/$(RVERSION): tmp/$(RVERSION).tar.gz
	cd tmp && tar -zxf $(RVERSION).tar.gz

$(TOOLS)/bin/R: tmp/$(RVERSION)
	# configuring and installing R to $(TOOLS)
	cd tmp/$(RVERSION) && ./configure --prefix=$(TOOLS) && make -j2 && make install

