#!/usr/bin/perl

use strict; 
use Scalar::Util qw(looks_like_number);
use Error qw(:try);
use Error::Simple;
use Getopt::Long qw(:config no_ignore_case);
use POSIX qw/ceil/;

my $usage = "Varied Application Test Options:

Required:
	--config <string>	Sets the configuration of varying tasks (either full or ab).
	--tasks  <integer>	Sets the total number of tasks to run (half of type a, half of type b).
	--alpha  <number>	Sets the alpha value for the capacity model.
Optional:
	--help			Display this message.

Example Usage:

	perl varied_test.pl --config full --tasks 100 --alpha 0.05

";

my %OPT;
try {
    GetOptions(
		"config=s" => \$OPT{config},
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


my $config = $OPT{config};
my $tasks = $OPT{tasks};
my $alpha = $OPT{alpha};
my $err = 0;

if(!$config) { print(STDERR "Missing --config option.\n"); $err++; }
if(!$tasks) { print(STDERR "Missing --tasks option.\n"); $err++; }
if(!$alpha) { print(STDERR "Missing --alpha option.\n"); $err++; }
if($err) {
	print(STDERR "Could not find $err required arguments.\n");
	print_help();
}

my $capacity = 1;
my $cap_a = 10;
my $cap_b = 20;
my $cumulative_capacity = 1;
my $i = 1;

if($config eq "full") {
	while($i < ceil($tasks / 2)) {

		$capacity = $cap_a;
		calculate_capacity();
		$i++;
		print(STDOUT "$i $capacity $cumulative_capacity\n");
	}

	while($i < $tasks) {

		$capacity = $cap_b;
		calculate_capacity();
		$i++;
		print(STDOUT "$i $capacity $cumulative_capacity\n");
	}
}

if($config eq "ab") {
	while($i < $tasks) {

		if($i % 2 == 1) {
			$capacity = $cap_a;
		}
		else {
			$capacity = $cap_b;
		}

		calculate_capacity();
		$i++;
		print(STDOUT "$i $capacity $cumulative_capacity\n");
	}
}

exit 0;

sub print_help {

	print $usage;
	exit 1;
}

sub calculate_capacity {

	$cumulative_capacity = ($alpha * (1 + $capacity)) + ((1 - $alpha) * $cumulative_capacity);
}
