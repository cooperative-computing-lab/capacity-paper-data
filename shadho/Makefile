PERL = ./capacity_yank.pl

DATA = ./shadho_run.dat
DEBUG = ./results/shadho_master.debug
JUNK = ./results/shadho_master.wqlog \
	   ./results/shadho_master.json \
	   ./results/shadho_master.log \
	   ./results/shadho_factory.debug \
	   ./results/shadho.json

all: $(DATA) shadho.complete

shadho: /usr/bin/git setup.py
	git clone git@github.com:jeffkinnison/shadho.git ./shadho
	cp ./setup.py ./shadho/
	cd ./shadho && pip install --user .
	cp ~/cctools/lib/python2.7/site-packages/work_queue.py ~/cctools/lib/python2.7/site-packages/_work_queue.so ~/.local/lib/python2.7/site-packages/

$(DEBUG): shadho
	work_queue_factory -T condor -N shadho_master -c --factory-timeout 90 -W 1000 --cores=16 --memory=16384 --disk=8192 --tasks-per-worker 2 --workers-per-cycle 0 -d all -o ./shadho_factory.debug -O 0 &
	./run_shadho.sh

$(DATA): /usr/bin/perl $(PERL) $(DEBUG)
	perl capacity_yank.pl --cores 16 --file $(DEBUG) > ./shadho_run.dat

shadho.complete: $(DATA)
	touch shadho.complete

data: $(DATA)

build: shadho

clean:
	rm -rf $(DATA) $(DEBUG) $(JUNK) shadho shadho_plot.pdf shadho.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
