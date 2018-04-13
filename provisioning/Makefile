PERL = ./provisioning_test.pl
MODEL = model_run.dat

all: $(MODEL)

$(MODEL): $(PERL)
	perl provisioning_test.pl --exec 100 --tran 1 --man 1 --tasks 100 --alpha 0.05 > ./model_run.dat
	touch ./provisioning.complete

clean:
	rm -rf $(MODEL) provisioning_model_plot.pdf provisioning.complete

.PHONY: all clean

# vim: set noexpandtab tabstop=4:
