#!/usr/bin/perl

use strict; 
use Scalar::Util qw(looks_like_number);
use Error qw(:try);
use Error::Simple;
use Getopt::Long qw(:config no_ignore_case);
use POSIX qw/ceil/;

my $usage = "Steppped Application Test Options:

Required:
	--step  <integer>	Sets the amount by which to increase between each step.
	--tasks <integer>	Sets the total number of tasks to run.
	--type  <string>	Sets the type of step (must be either + or x).
	--alpha <number>	Sets the alpha value for the capacity model.
Optional:
	--help			Display this message.

Example Usage:

	perl step_test.pl --step 2 --tasks 10 --type x --alpha 0.05

";

my %OPT;
try {
    GetOptions(
		"step=s" => \$OPT{step},
	   	"tasks=s" => \$OPT{tasks},
	   	"type=s" => \$OPT{type},
	   	"alpha=s" => \$OPT{alpha},
	   	"help|?" => sub {print $usage; exit(0)}
	);
} 
catch Error::Simple with {
    my $E = shift;
    print STDERR $E->{-text};
    die "Failed to parse command line options.\n";
};


my $step = $OPT{step};
my $tasks = $OPT{tasks};
my $type = $OPT{type};
my $alpha = $OPT{alpha};
my $err = 0;

if(!$step) { print(STDERR "Missing --step option.\n"); $err++; }
if(!$tasks) { print(STDERR "Missing --tasks option.\n"); $err++; }
if(!$type) { print(STDERR "Missing --type option.\n"); $err++; }
if(!$alpha) { print(STDERR "Missing --alpha option.\n"); $err++; }
if($err) {
	print(STDERR "Could not find $err required arguments.\n");
	print_help();
}

my $capacity = 1;
my $cumulative_capacity = 1;
my $i = 0;

while($i < ceil($tasks / 2)) {

	calculate_capacity();

	if($i == 0 or $i == 1 or $i == 10 or $i == 100 or $i == 300 or $i == 500 or $i == 700 or $i == 900 or $i == 990 or $i == 999) {
		print(STDOUT "$i $capacity $cumulative_capacity\n");
	}

	if($type eq '+') {
		$capacity += $step;
	}
	else {
		$capacity *= $step;
	}
	$i++;
}

while($i < $tasks) {

	calculate_capacity();

	if($i == 0 or $i == 1 or $i == 10 or $i == 100 or $i == 300 or $i == 500 or $i == 700 or $i == 900 or $i == 990 or $i == 999) {
		print(STDOUT "$i $capacity $cumulative_capacity\n");
	}

	if($type eq '+') {
		$capacity -= $step;
	}
	else {
		$capacity /= $step;
	}
	$i++;
}

print(STDOUT "$i $capacity $cumulative_capacity\n");

exit 0;

sub print_help {

	print $usage;
	exit 1;
}

sub calculate_capacity {

	$cumulative_capacity = ($alpha * (1 + $capacity)) + ((1 - $alpha) * $cumulative_capacity);
}
