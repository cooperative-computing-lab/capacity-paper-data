CC=gcc
CFLAGS=-Wall -g
IQUOTE = -iquote../cctools_source/dttools/src -iquote../cctools_source/work_queue/src -iquote../cctools_source/batch_job/src
L = -L../cctools_source/dttools/src -L../cctools_source/work_queue/src -L../cctools_source/batch_job/src
l = -lbatch_job -lwork_queue -ldttools -lz
LDDFLAGS = $(IQUOTE) $(L) $(l) -lm

LOGS = ./wq_capacity_*.*
LIB = ../cctools_source/dttools/src/libdttools.a ../cctools_source/work_queue/src/libwork_queue.a
PROG = ./run_tasks ./run_heavy_tasks
PERL = ./isolation_test.pl ./capacity_yank.pl
INPUT = ./in.dat ./in_2.dat

DATA = wq_capacity.debug \
	   wq_capacity_heavy.debug

OUTPUT = wq_test.dat wq_heavy.dat

all: $(PROG) $(DATA) isolation.complete

$(PROG): $(LIB)
	$(CC) $(CFLAGS) ./$@.c $(LDDFLAGS) -o $@

in.dat: /usr/bin/dd
	dd if=/dev/zero of=./in.dat bs=4096 count=25000

in_2.dat: /usr/bin/dd
	dd if=/dev/zero of=./in_2.dat bs=4096 count=2500000

wq_capacity_heavy.debug wq_capacity.debug: $(PROG) $(INPUT)
	work_queue_factory -T condor -N wq_capacity -c --factory-timeout 90 --cores=1 --memory=2048 --disk=2048 --workers-per-cycle 0 &
	work_queue_factory -T condor -N wq_capacity_heavy -w 1 -W 1 --factory-timeout 90 --cores=1 --memory=2048 --disk=2048 --workers-per-cycle 0 &
	./run_heavy_tasks 200 wq_capacity_heavy &
	./run_tasks 100 25 wq_capacity
	perl shutdown.pl

wq_test.dat wq_heavy.dat: /usr/bin/perl $(PERL) $(DATA)
	perl capacity_yank.pl --cores 1 --workers 1 --cap 25 --file ./wq_capacity.debug > ./wq_test.dat
	perl capacity_yank.pl --cores 1 --workers 1 --cap 25 --file ./wq_capacity_heavy.debug > ./wq_heavy.dat

isolation.complete: $(OUTPUT)
	touch ./isolation.complete

data: $(DATA)

model: $(MODEL)

build: $(PROG)

clean:
	rm -rf $(DATA) $(MODEL) $(INPUT) $(OUTPUT) $(PROG) $(LOGS) *.wqlog isolation_plot.pdf isolation.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
