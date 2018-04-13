PERL = ./ratios_test.pl
INPUT = ./in.dat
MODEL = model_run.dat

all: $(MODEL)

$(MODEL): $(PERL)
	perl ratios_test.pl --tasks 100 --alpha 0.05 > ./model_run.dat
	touch ./ratios.complete

clean:
	rm -rf $(MODEL) ratios_plot.pdf ratios.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
