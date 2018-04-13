#!/usr/bin/perl
#
#Copyright (C) 2016- The University of Notre Dame
#This software is distributed under the GNU General Public License.
#

use strict; 
use Scalar::Util qw(looks_like_number);
use Error qw(:try);
use Error::Simple;
use Getopt::Long qw(:config no_ignore_case);
use POSIX qw/ceil/;

my $usage = "BWA Test Options:

Required:

Optional:
	--help			Display this message.

Example Usage:

	perl bwa_test.pl

";

my %OPT;
try {
    GetOptions(
	   	"help|?" => sub {print $usage; exit(0)}
	);
} 
catch Error::Simple with {
    my $E = shift;
    print STDERR $E->{-text};
    die "Failed to parse command line options.\n";
};

my $usr = $ENV{USER};

my $result = 1;
$result = system("makeflow ./bwa.makeflow -T wq -p 0 -N bwa_capacity -d all -o bwa_run.debug --debug-rotate-max=0 ; mv ./bwa.makeflow.wqlog ./bwa_run.wqlog");
if($result) {
	print(STDERR "Makeflow failed during Shrimp makeflow run.\nCleaning up.");
	$result = system("makeflow -c ./bwa.makeflow");
}

system("ps -AF | grep \"$usr\" > ./factory_shutdown.txt");
my $i = 0;
open(INPUT, "./factory_shutdown.txt");
while(my $line = <INPUT>) {
	chomp $line;
	my @parts = split(" ",$line);
	foreach my $part (@parts) {
		if($part eq "work_queue_factory") {
			kill("KILL", @parts[1]);
			last;
		}
		$i++;
	}
}
close(INPUT);
system("rm ./factory_shutdown.txt");
system("condor_rm $usr");
print(STDERR "Waiting 30 seconds for workers to clean up.\n");
sleep(30);

exit 0;

sub print_help {

	print $usage;
	exit 1;
}
