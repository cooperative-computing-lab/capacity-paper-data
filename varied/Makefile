PERL = ./varied_test.pl

DATA = ./ab_run.dat \
	   ./ab_run_lo_alpha.dat \
	   ./ab_run_hi_alpha.dat \
	   ./full_run.dat \
	   ./full_run_lo_alpha.dat \
	   ./full_run_hi_alpha.dat

all: $(DATA) varied.complete

full_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config full --tasks 100 --alpha 0.05 > ./full_run.dat

full_run_lo_alpha.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config full --tasks 100 --alpha 0.01 > ./full_run_lo_alpha.dat

full_run_hi_alpha.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config full --tasks 100 --alpha 0.10 > ./full_run_hi_alpha.dat

ab_run.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config ab --tasks 100 --alpha 0.05 > ./ab_run.dat

ab_run_lo_alpha.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config ab --tasks 100 --alpha 0.01 > ./ab_run_lo_alpha.dat

ab_run_hi_alpha.dat: /usr/bin/perl $(PERL)
	perl $(PERL) --config ab --tasks 100 --alpha 0.10 > ./ab_run_hi_alpha.dat

varied.complete: $(DATA)
	touch varied.complete

clean:
	rm -rf $(DATA) varied_ab_plot.pdf varied_full_plot.pdf varied.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
