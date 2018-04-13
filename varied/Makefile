PERL = ./varied_test.pl

DATA = ./ab_run.dat \
	   ./full_run.dat

all: $(DATA) varied.complete

full_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config full --tasks 100 --alpha 0.05 > ./full_run.dat

ab_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config ab --tasks 100 --alpha 0.05 > ./ab_run.dat

varied.complete: $(DATA)
	touch varied.complete

clean:
	rm -rf $(DATA) varied_ab_plot.pdf varied_full_plot.pdf varied.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
