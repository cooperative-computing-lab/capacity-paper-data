PERL = ./step_test.pl

DATA = ./2mul_run.dat \
	   ./2add_run.dat \
	   ./10mul_run.dat \
	   ./10add_run.dat

all: $(DATA) stepped.complete

2mul_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --step 2 --tasks 100 --type x --alpha 0.05 > ./2mul_run.dat

2add_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --step 2 --tasks 1000 --type + --alpha 0.05 > ./2add_run.dat

10mul_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --step 10 --tasks 100 --type x --alpha 0.05 > ./10mul_run.dat

10add_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --step 10 --tasks 1000 --type + --alpha 0.05 > ./10add_run.dat

stepped.complete: $(DATA)
	touch stepped.complete

clean:
	rm -rf $(DATA) stepped_plot.pdf stepped.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
