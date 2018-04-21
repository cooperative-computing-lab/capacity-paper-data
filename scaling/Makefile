CC=gcc
CFLAGS=-Wall -g
IQUOTE = -iquote../cctools_source/dttools/src -iquote../cctools_source/work_queue/src -iquote../cctools_source/batch_job/src
L = -L../cctools_source/dttools/src -L../cctools_source/work_queue/src -L../cctools_source/batch_job/src
l = -lbatch_job -lwork_queue -ldttools -lz
LDDFLAGS = $(IQUOTE) $(L) $(l) -lm

LOGS = ./wq_capacity_*.*
LIB = ../cctools_source/dttools/src/libdttools.a ../cctools_source/work_queue/src/libwork_queue.a
PROG = ./run_tasks
PERL = ./run_scaling.pl ./capacity_yank.pl
INPUT = ./in.dat

DATA = scaling_lo.debug \
	   scaling_hi.debug

all: $(PROG) $(DATA) scaling.complete

$(PROG): $(LIB)
	$(CC) $(CFLAGS) ./run_tasks.c $(LDDFLAGS) -o $@

$(INPUT): /usr/bin/dd
	dd if=/dev/zero of=in.dat bs=4096 count=25000

scaling_lo.debug: /usr/bin/perl $(PROG) $(INPUT)
	cp ../hi.conf .
	cp ../cap.conf .
	perl run_scaling.pl --cores 1 --memory 1024 --disk 2048 --workers 1 --mode 1

scaling_hi.debug: /usr/bin/perl $(PROG) $(INPUT)
	cp ../hi.conf .
	cp ../cap.conf .
	perl run_scaling.pl --cores 1 --memory 1024 --disk 2048 --workers 50 --mode 2

scaling_lo.dat: /usr/bin/perl $(PERL) $(DATA)
	perl capacity_yank.pl --cores 1 --cap 25 --file ./scaling_lo.debug > ./scaling_lo.dat

scaling_hi.dat: /usr/bin/perl $(PERL) $(DATA)
	perl capacity_yank.pl --cores 1 --cap 25 --file ./scaling_hi.debug > ./scaling_hi.dat

scaling.complete: $(DATA) scaling_hi.dat scaling_lo.dat
	touch scaling.complete

data: $(DATA)

build: $(PROG)

clean:
	rm -rf $(DATA) $(MODEL) $(INPUT) $(PROG) $(LOGS) wq-pool* hi.conf cap.conf scaling_*.factory* *.wqlog scaling_lo.dat scaling_hi.dat scaling_hi_plot.pdf scaling_lo_plot.pdf scaling.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
