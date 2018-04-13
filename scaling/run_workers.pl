#!/usr/bin/perl
#
#Copyright (C) 2016- The University of Notre Dame
#This software is distributed under the GNU General Public License.
#

use strict; 
use Math::Complex;
use Scalar::Util qw(looks_like_number);
use Error qw(:try);
use Error::Simple;
use Getopt::Long qw(:config no_ignore_case);

my $usage = "Worker Start Options:

Required:
    --cores   <integer>        Sets the number of cores per worker.
    --memory  <integer>	       Sets the amount of memory in bytes per worker.
    --disk    <integer>	       Sets the amount of disk in bytes per worker.
    --timeout <seconds>        Sets the timeout per worker.
    --workers <integer>        Specify the number of workers to request.

Optional:
    --help                     Display this message.

Example Usage:

    perl task_factory.pl --cores 1 --memory 1024 --disk 2048 --timeout 3600 --workers 10

";

my %OPT;
try {
    GetOptions(
        "cores=s" => \$OPT{cores},
        "memory=s" => \$OPT{memory},
        "disk=s" => \$OPT{disk},
        "timeout=s" => \$OPT{timeout},
        "workers=s" => \$OPT{workers},
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
my $timeout = $OPT{timeout};
my $workers = $OPT{workers};
my $err = 0;

if(!$cores) { print(STDERR "Missing --cores option.\n"); $err++; }
if(!$memory) { print(STDERR "Missing --memory option.\n"); $err++; }
if(!$disk) { print(STDERR "Missing --disk option.\n"); $err++; }
if(!$timeout) { print(STDERR "Missing --timeout option.\n"); $err++; }
if(!$workers) { print(STDERR "Missing --workers option.\n"); $err++; }
if($err) {
    print(STDERR "Could not find $err required arguments.\n");
    print_help();
}


my $usr = $ENV{USER};
my $result = 1;
my $i = 0;

while($i < $workers - 1) {
	$result = system("work_queue_worker -N wq_capacity --cores $cores --memory $memory --disk $disk -t $timeout &");
	$i++;
}

$result = system("work_queue_worker -N wq_capacity --cores $cores --memory $memory --disk $disk -t $timeout");

system("ps -AF | grep \"$usr\" > ./worker_shutdown.txt");
$i = 0;
open(INPUT, "./worker_shutdown.txt");
while(my $line = <INPUT>) {
	chomp $line;
	my @parts = split(" ",$line);
	foreach my $part (@parts) {
		if($part =~ m/"work_queue_worker*"/) {
			kill("KILL", @parts[1]);
			last;
		}
		$i++;
	}
}
close(INPUT);

$result = system("rm ./worker_shutdown.txt");
exit $result;

sub print_help {

    print $usage;
    exit 1;
}
