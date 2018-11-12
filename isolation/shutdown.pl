#!/usr/bin/perl
#
#Copyright (C) 2016- The University of Notre Dame
#This software is distributed under the GNU General Public License.
#

use strict; 

my $usr = $ENV{"USER"};
my $result = system("ps -AF | grep \"$usr\" > ./worker_shutdown.txt");
my $i = 0;
open(INPUT, "./worker_shutdown.txt");
while(my $line = <INPUT>) {
	chomp $line;
	my @parts = split(" ",$line);
	foreach my $part (@parts) {
		if($part =~ m/"work_queue_factory"/) {
			kill("KILL", @parts[1]);
			last;
		}
		$i++;
	}
}
close(INPUT);
#unlink("rm ./worker_shutdown.txt");
exit $result;
