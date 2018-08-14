PERL = ./hecil_test.pl ./fastq_generate.pl ./capacity_yank.pl
PYTHON = ./make_hecil_workflow.py
DATA = ./hecil_run.dat ./hecil_run_nocap.dat
MAKEFLOW = ./hecil.makeflow
BWA = ./bwa \
	  ./bwa_src \
	  ./cat_bwa \
	  ./bwa_run.*

INPUT = ./ref.fasta \
		./query.fastq

all: $(DATA) hecil.complete

bwa_src: /usr/bin/git
	git clone git@github.com:lh3/bwa bwa_src
	cd bwa_src && make && cp bwa ..

ref.fastq: /usr/bin/perl bwa_src
	perl fastq_generate.pl 1000000 1000 > ref.fastq
	
ref.fasta: /usr/bin/python ref.fastq convert_fastq.py
	python convert_fastq.py ref.fastq > ref.fasta

query.fastq: /usr/bin/perl bwa_src
	perl fastq_generate.pl 1000000 100 ref.fastq > query.fastq

$(MAKEFLOW): /usr/bin/python bwa_src $(INPUT) $(PYTHON)
	python $(PYTHON) -l ref.fasta -s query.fastq -len 100 -p 100 -ps 2 -rs 1000 -mf hecil.makeflow

index.err: /usr/bin/python /usr/bin/perl ref.fasta query.fastq $(MAKEFLOW)
	perl fastq_reduce query.fastq 100
	./bwa index ref.fasta 2> index.err

hecil_run.debug: /usr/bin/perl $(PERL) $(MAKEFLOW) $(INPUT) index.err
	cp ../hi.conf .
	cp ../cap.conf .
	perl ./hecil_test.pl --cores 1 --memory 8192 --disk 8192 --mode 1

hecil_run.dat: /usr/bin/perl $(PERL) hecil_run.debug
	perl ./capacity_yank.pl --cores 1 --file ./hecil_run.debug > ./hecil_run.dat

hecil_run_nocap.debug: /usr/bin/perl $(PERL) $(MAKEFLOW) $(INPUT) index.err hecil_run.debug hecil_run.dat
	cp ../hi.conf .
	cp ../cap.conf .
	mv ./hecil_run.debug ./backup_hecil_run.debug
	makeflow -c $(MAKEFLOW) || true
	perl ./hecil_test.pl --cores 1 --memory 8192 --disk 8192 --mode 0
	mv ./hecil_run.debug ./hecil_run_nocap.debug
	mv ./backup_hecil_run.debug ./hecil_run.debug

hecil_run_nocap.dat: /usr/bin/perl $(PERL) hecil_run_nocap.debug
	perl ./capacity_yank.pl --cores 1 --file ./hecil_run_nocap.debug > ./hecil_run_nocap.dat

hecil.complete: $(DATA)
	touch hecil.complete

build: $(INPUT)

data: $(DATA)

makeflow: $(MAKEFLOW)

clean:
	makeflow -c $(MAKEFLOW) || true
	rm -rf $(DATA) $(MAKEFLOW) $(BWA) $(INPUT) hi.conf cap.conf ref.* query.fastq* index.err hecil_plot.pdf hecil.factory* hecil.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
