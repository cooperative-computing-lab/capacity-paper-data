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

my $usage = "Worker Start Options:

Required:
    --cores   <integer>        Sets the number of cores per worker.
    --memory  <integer>	       Sets the amount of memory in bytes per worker.
    --disk    <integer>	       Sets the amount of disk in bytes per worker.
    --workers <integer>        Specify the number of workers to request.
    --mode    <integer>	       Specify the scaling mode (1 = lo, 2 = hi).

Optional:
    --help                     Display this message.

Example Usage:

    perl run_scaling.pl --cores 1 --memory 1024 --disk 2048 --workers 50 --mode 1

";

my %OPT;
try {
    GetOptions(
        "cores=s" => \$OPT{cores},
        "memory=s" => \$OPT{memory},
        "disk=s" => \$OPT{disk},
        "workers=s" => \$OPT{workers},
        "mode=s" => \$OPT{mode},
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
my $workers = $OPT{workers};
my $mode = $OPT{mode};
my $err = 0;

if(!$cores) { print(STDERR "Missing --cores option.\n"); $err++; }
if(!$memory) { print(STDERR "Missing --memory option.\n"); $err++; }
if(!$disk) { print(STDERR "Missing --disk option.\n"); $err++; }
if(!$workers) { print(STDERR "Missing --workers option.\n"); $err++; }
if(!$mode) { print(STDERR "Missing --mode option.\n"); $err++; }
if($err) {
    print(STDERR "Could not find $err required arguments.\n");
    print_help();
}

my $usr = $ENV{USER};
my $result = 0;
my $prev_workers_connected = 0;

if($mode == 2) {
	$result = system("work_queue_factory -T condor -N wq_capacity -c --cores $cores --memory $memory --disk $disk -t 90 --workers-per-cycle 0 -C ./hi.conf -d all -o ./scaling_$mode.factory.debug & ( sleep 300 && cp ./cap.conf ./hi.conf ) &");
}

else {
	$result = system("work_queue_factory -T condor -N wq_capacity -c --cores $cores --memory $memory --disk $disk -t 90 --workers-per-cycle 0 -d all -o ./scaling_$mode.factory.debug &");
}

print(STDERR "$result\n");

if($mode == 1) {
	$result = system("./run_tasks 1000 100 scaling_lo");
}
else {
	$result = system("./run_tasks 1000 100 scaling_hi");
}

print(STDERR "$result\n");

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
