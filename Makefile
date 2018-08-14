REPO = nkremerh/cctools
BRANCH = workers_capacity

RATIOS = ./ratios/ratios.complete
STEPPED = ./stepped/stepped.complete
VARIED = ./varied/varied.complete
PROVISIONING = ./provisioning/provisioning.complete
ISOLATION = ./isolation/isolation.complete
SCALING = ./scaling/scaling.complete
BWA = ./bwa/bwa.complete
HECIL = ./hecil/hecil.complete
SHADHO = ./shadho/shadho.complete

DATA = $(RATIOS) $(STEPPED) $(VARIED) $(PROVISIONING) $(SCALING) $(ISOLATION) $(BWA) $(SHADHO)

BINS = ~/cctools
CCTOOLS = ./cctools_source
LIB = ./cctools_source/dttools/src/libdttools.a ./cctools_source/work_queue/src/libwork_queue.a

PDF = ./ratios/ratios_plot.pdf \
	  ./stepped/stepped_plot.pdf \
	  ./varied/varied_full_plot.pdf \
	  ./varied/varied_full_big_plot.pdf \
	  ./varied/varied_ab_plot.pdf \
	  ./provisioning/provisioning_model_plot.pdf \
	  ./isolation/isolation_plot.pdf \
	  ./scaling/scaling_lo_plot.pdf \
	  ./scaling/scaling_hi_plot.pdf \
	  ./bwa/bwa_plot.pdf \
	  ./hecil/hecil_plot.pdf \
	  ./shadho/shadho_plot.pdf

all: $(CCTOOLS) $(DATA) $(PDF)

$(CCTOOLS) $(LIB): /usr/bin/git
	git clone git://github.com/$(REPO)
	cd ./cctools && git checkout $(BRANCH)
	mv ./cctools ./cctools_source
	cd ./cctools_source && ./configure --strict --tcp-low-port 9000 --tcp-high-port 9500 && make && make install

#I/O ratio script
$(RATIOS): $(CCTOOLS) $(LIB) /usr/bin/make ./ratios/Makefile
	cd ./ratios && make

#Stepped application script
$(STEPPED): $(CCTOOLS) $(LIB) /usr/bin/make ./stepped/Makefile
	cd ./stepped && make

#Varied application script
$(VARIED): $(CCTOOLS) $(LIB) /usr/bin/make ./varied/Makefile
	cd ./varied && make

#Provisioning test
$(PROVISIONING): $(CCTOOLS) $(LIB) /usr/bin/make ./provisioning/Makefile
	cd ./provisioning && make

#Isolation test
$(ISOLATION): $(CCTOOLS) $(LIB) /usr/bin/make ./isolation/Makefile
	cd ./isolation && make

#Scaling test
$(SCALING): $(CCTOOLS) $(LIB) /usr/bin/make ./scaling/Makefile
	cd ./scaling && make

#BWA
$(BWA): $(CCTOOLS) $(LIB) /usr/bin/make ./bwa/Makefile
	cd ./bwa && make

#HECIL
$(HECIL) : $(CCTOOLS) $(LIB) /usr/bin/make ./hecil/Makefile
	cd ./hecil && make

#SHADHO
$(SHADHO): $(CCTOOLS) $(LIB) /usr/bin/make ./shadho/Makefile
	cd ./shadho && make

#Plots
ratios/ratios_plot.pdf: /usr/bin/gnuplot $(RATIOS)
	gnuplot ./plots/plot_ratios.plg > ./ratios/ratios_plot.pdf

stepped/stepped_plot.pdf: /usr/bin/gnuplot $(STEPPED)
	gnuplot ./plots/plot_stepped.plg > ./stepped/stepped_plot.pdf

varied/varied_full_plot.pdf: /usr/bin/gnuplot $(VARIED)
	gnuplot ./plots/plot_varied_full.plg > ./varied/varied_full_plot.pdf

varied/varied_ab_plot.pdf: /usr/bin/gnuplot $(VARIED)
	gnuplot ./plots/plot_varied_ab.plg > ./varied/varied_ab_plot.pdf

provisioning/provisioning_model_plot.pdf: /usr/bin/gnuplot $(PROVISIONING)
	gnuplot ./plots/plot_provisioning_model.plg > ./provisioning/provisioning_model_plot.pdf

scaling/scaling_lo_plot.pdf: /usr/bin/gnuplot $(SCALING)
	gnuplot ./plots/plot_scaling_lo.plg > ./scaling/scaling_lo_plot.pdf

scaling_hi_plot.pdf: /usr/bin/gnuplot $(SCALING)
	gnuplot ./plots/plot_scaling_hi.plg > ./scaling/scaling_hi_plot.pdf

isolation/isolation_plot.pdf: /usr/bin/gnuplot $(ISOLATION)
	gnuplot ./plots/plot_isolation.plg > ./isolation/isolation_plot.pdf

shadho/shadho_plot.pdf: /usr/bin/gnuplot $(SHADHO)
	gnuplot ./plots/plot_shadho.plg > ./shadho/shadho_plot.pdf

hecil/hecil_plot.pdf: /usr/bin/gnuplot $(HECIL)
	gnuplot ./plots/plot_hecil.plg > ./hecil/hecil_plot.pdf

hecil/hecil_plot_nocap.pdf: /usr/bin/gnuplot $(HECIL)
	gnuplot ./plots/plot_hecil_nocap.plg > ./hecil/hecil_plot_nocap.pdf

bwa/bwa_plot.pdf: /usr/bin/gnuplot $(BWA)
	gnuplot ./plots/plot_bwa.plg > ./bwa/bwa_plot.pdf

bwa/bwa_plot_nocap.pdf: /usr/bin/gnuplot $(BWA)
	gnuplot ./plots/plot_bwa_nocap.plg > ./bwa/bwa_plot_nocap.pdf

data: $(DATA)

graph: $(PDF)

ratios: ratios/ratios_plot.pdf

stepped: stepped/stepped_plot.pdf

provisioning: provisioning/provisioning_model_plot.pdf

varied: varied/varied_full_plot.pdf varied/varied_ab_plot.pdf

isolation: isolation/isolation_plot.pdf

scaling: $(SCALING)

bwa: bwa/bwa_plot.pdf bwa/bwa_plot_nocap.pdf

shadho: shadho/shadho_plot.pdf

hecil: hecil/hecil_plot.pdf

build: $(CCTOOLS) $(LIB)

clean:
	cd ./bwa && make clean
	cd ./hecil && make clean
	cd ./shadho && make clean
	cd ./isolation && make clean
	cd ./provisioning && make clean
	cd ./scaling && make clean
	cd ./ratios && make clean
	cd ./stepped && make clean
	cd ./varied && make clean
	rm -rf $(BINS) $(CCTOOLS)

lean:
	rm -rf $(PDF)

.PHONY: all clean lean celan

# vim: set noexpandtab tabstop=4:
