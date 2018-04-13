#!/usr/bin/perl

use strict; 
use Scalar::Util qw(looks_like_number);
use Error qw(:try);
use Error::Simple;
use Getopt::Long qw(:config no_ignore_case);
use POSIX qw/ceil/;

my $usage = "Provisioning Test Options:

Required:
	--exec    <seconds>	Sets the execution time per task.
	--tran    <seconds>	Sets the transfer time per task.
	--man	  <seconds>	Sets the management time per added resource.
	--tasks   <integer>	Sets the total number of tasks to run.
	--alpha   <number>	Sets the alpha value for the capacity model.

Optional:
	--help			Display this message.

Example Usage:

	perl provisioning_test.pl --exec 100 --tran 1 --man 1 --tasks 100 --workers 100 --alpha 0.05

";

my %OPT;
try {
    GetOptions(
		"exec=s" => \$OPT{exec},
		"tran=s" => \$OPT{tran},
		"man=s" => \$OPT{man},
	   	"tasks=s" => \$OPT{tasks},
	   	"alpha=s" => \$OPT{alpha},
	   	"help|?" => sub {print $usage; exit(0)}
	);
} 
catch Error::Simple with {
    my $E = shift;
    print STDERR $E->{-text};
    die "Failed to parse command line options.\n";
};


my $exec = $OPT{exec};
my $tran = $OPT{tran};
my $man = $OPT{man};
my $tasks = $OPT{tasks};
my $alpha = $OPT{alpha};
my $err = 0;

if(!$exec) { print(STDERR "Missing --exec option.\n"); $err++; }
if(!$tran) { print(STDERR "Missing --tran option.\n"); $err++; }
if(!$man) { print(STDERR "Missing --man option.\n"); $err++; }
if(!$tasks) { print(STDERR "Missing --tasks option.\n"); $err++; }
if(!$alpha) { print(STDERR "Missing --alpha option.\n"); $err++; }
if($err) {
	print(STDERR "Could not find $err required arguments.\n");
	print_help();
}

my $capacity = ceil($exec / $tran);
my $cumulative_capacity = 1;
my $runtime = 0;

my @workers = (1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
foreach my $w (@workers) {
	
	$cumulative_capacity = 1;
	$runtime = 0;
	my $i = 0;

	while($i < $tasks) {

		update();
		$i++;
	}

	my $execution_at_capacity = ($runtime / $capacity) + (100 * $man);

	if($w < $capacity) {
		$runtime = ($runtime / $w) + ($w * $man);
	}
	else {
		$runtime = ($runtime / $capacity) + ($w * $man);
	}

	print(STDOUT "$w $i $runtime $cumulative_capacity $execution_at_capacity\n");
}

exit 0;

sub print_help {

	print $usage;
	exit 1;
}

sub update {

	$cumulative_capacity = ($alpha * (1 + $capacity)) + ((1 - $alpha) * $cumulative_capacity);
	$runtime += ((1.0 * $exec) + (1.0 * $tran));
}
