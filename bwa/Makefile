PERL = ./bwa_test.pl ./fastq_generate.pl
PYTHON = ./make_bwa_workflow.py
DATA = ./bwa_run.dat ./bwa_run_nocap.dat
MAKEFLOW = ./bwa.makeflow
BWA = ./bwa \
	  ./bwa_src \
	  ./fastq_reduce \
	  ./cat_bwa \
	  ./bwa_run.*

INPUT = ./ref.fastq \
		./query.fastq

all: $(DATA) bwa.complete

bwa_src: /usr/bin/git
	git clone git@github.com:lh3/bwa bwa_src
	cd bwa_src && make && cp bwa ..

ref.fastq: /usr/bin/perl bwa_src
	perl fastq_generate.pl 1000000 1000 > ref.fastq

query.fastq: /usr/bin/perl bwa_src
	perl fastq_generate.pl 1000000 100 ref.fastq > query.fastq

$(MAKEFLOW): /usr/bin/python bwa_src $(INPUT)
	python $(PYTHON) --ref ref.fastq --query query.fastq --num_seq 1000 > bwa.makeflow

bwa_run.debug: /usr/bin/perl $(PERL) $(MAKEFLOW) $(INPUT)
	work_queue_factory -T condor -N bwa_capacity -c -t 90 --cores=1 --memory=8192 --disk=8192 --workers-per-cycle 0 &
	perl bwa_test.pl

bwa_run.dat: /usr/bin/perl $(PERL) bwa_run.debug
	perl ./capacity_yank.pl --cores 1 --file ./bwa_run.debug > ./bwa_run.dat

bwa_run_nocap.debug: /usr/bin/perl $(PERL) $(MAKEFLOW) $(INPUT) bwa_run.debug bwa_run.dat
	mv ./bwa_run.debug ./backup_bwa_run.debug
	makeflow -c $(MAKEFLOW) || true
	work_queue_factory -T condor -N bwa_capacity -t 90 --cores=1 --memory=8192 --disk=8192 --workers-per-cycle 0 &
	perl bwa_test.pl
	mv ./bwa_run.debug ./bwa_run_nocap.debug
	mv ./backup_bwa_run.debug ./bwa_run.debug

bwa_run_nocap.dat: /usr/bin/perl $(PERL) bwa_run_nocap.debug
	perl ./capacity_yank.pl --cores 1 --file ./bwa_run_nocap.debug > ./bwa_run_nocap.dat

bwa.complete: $(DATA)
	touch bwa.complete

data: $(DATA)

makeflow: $(MAKEFLOW)

clean:
	makeflow -c $(MAKEFLOW) || true
	rm -rf $(DATA) $(MAKEFLOW) $(BWA) $(INPUT) bwa_plot.pdf bwa.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
