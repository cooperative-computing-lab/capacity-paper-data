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

my $usage = "HECIL Factory Options:

Required:
    --cores   <integer>        Sets the number of cores per worker.
    --memory  <integer>	       Sets the amount of memory in bytes per worker.
    --disk    <integer>	       Sets the amount of disk in bytes per worker.

Optional:
    --help                     Display this message.

Example Usage:

    perl hecil_test.pl --cores 1 --memory 4096 --disk 8192

";

my %OPT;
try {
    GetOptions(
        "cores=s" => \$OPT{cores},
        "memory=s" => \$OPT{memory},
        "disk=s" => \$OPT{disk},
        "help|?" => sub {print $usage; exit(0)}
    );
}
catch Error::Simple with {
    my $E = shift;
    print STDERR $E->{-text};
    die "Failed to parse command line options.\n";
};

my $cores = $OPT{cores};
my $memory = $OPT{memory};
my $disk = $OPT{disk};
my $err = 0;

if(!$cores) { print(STDERR "Missing --cores option.\n"); $err++; }
if(!$memory) { print(STDERR "Missing --memory option.\n"); $err++; }
if(!$disk) { print(STDERR "Missing --disk option.\n"); $err++; }
if($err) {
    print(STDERR "Could not find $err required arguments.\n");
    print_help();
}

my $usr = $ENV{USER};
my $result = 0;

$result = system("work_queue_factory -T condor -N hecil_capacity -c --cores $cores --memory $memory --disk $disk -t 90 --factory-timeout 90 --workers-per-cycle 0 -C ./hi.conf -d all -o ./hecil.factory.debug & ( sleep 900 && cp ./cap.conf ./hi.conf ) &");

$result = system("makeflow -T wq -N hecil_capacity ./hecil.makeflow --debug-rotate-max 0 -d all -o ./hecil_run.debug");

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
