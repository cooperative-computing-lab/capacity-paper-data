#!/usr/bin/perl

use strict; 
use Scalar::Util qw(looks_like_number);
use Error qw(:try);
use Error::Simple;
use Getopt::Long qw(:config no_ignore_case);
use POSIX qw/ceil/;

my $usage = "I/O Ratios Test Options:

Required:
	--tasks   <integer>	Sets the total number of tasks to run.
	--alpha   <number>	Sets the alpha value for the capacity model.

Optional:
	--help			Display this message.

Example Usage:

	perl ratios_test.pl --tasks 100 --alpha 0.05

";

my %OPT;
try {
    GetOptions(
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


my $tasks = $OPT{tasks};
my $alpha = $OPT{alpha};
my $err = 0;

if(!$tasks) { print(STDERR "Missing --tasks option.\n"); $err++; }
if(!$alpha) { print(STDERR "Missing --alpha option.\n"); $err++; }
if($err) {
	print(STDERR "Could not find $err required arguments.\n");
	print_help();
}

my $capacity = 0;
my $cumulative_capacity = 1;

#my @ios = (50000, 10000, 5000, 2500, 1000, 100, 10, 4, 2, .1, .02);
my @ios = (500, 100, 50, 25, 10, 1, 0.1, 0.04, 0.02, 0.01, 0.002);
foreach my $io (@ios) {

	$io = $io * 100.0;	
	$cumulative_capacity = 1;
	$capacity = 100.0 / $io;
	my $i = 0;

	while($i < $tasks) {

		update();
		$i++;
	}

	print(STDOUT "100 $io $i $capacity $cumulative_capacity\n");
}

exit 0;

sub print_help {

	print $usage;
	exit 1;
}

sub update {

	$cumulative_capacity = ($alpha * (1 + $capacity)) + ((1 - $alpha) * $cumulative_capacity);
}
