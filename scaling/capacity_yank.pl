#! /usr/bin/env perl

use 5.10.0;
use strict; 
use Math::Complex;
use Scalar::Util qw(looks_like_number);
use Error qw(:try);
use Error::Simple;
use Getopt::Long qw(:config no_ignore_case);

my $usage = "Debug Log Capacity Yank Options:

Required:
    --cores    <integer>        Sets the number of cores per worker.
    --workers  <integer>        Sets the number of workers.
    --cap      <integer>        Sets the a priori capacity value.
    --file     <path>	        Sets the path to the debug log to be read.

Optional:
    --terse                     Shorten the output to a non-human-readable summary.
    --help                      Display this message.

Example Usage:

    perl capacity_yank.pl --cores 1 --file ./bwa/bwa_capacity.debug

";

my %OPT;
try {
    GetOptions(
        "cores=s" => \$OPT{cores},
        "workers=s" => \$OPT{workers},
        "cap=s" => \$OPT{cap},
        "file=s" => \$OPT{file},
        "terse|?" => \$OPT{terse},
        "help|?" => sub {print $usage; exit(0)}
    );
}
catch Error::Simple with {
    my $E = shift;
    print STDERR $E->{-text};
    die "Failed to parse command line options.\n";
};

my $cores = $OPT{cores};
my $total_workers = $OPT{workers};
my $cap = $OPT{cap};
my $file = $OPT{file};
my $terse = $OPT{terse};
my $err = 0;

if(!$cores) { print(STDERR "Missing --cores option.\n"); $err++; }
if(!$total_workers) { print(STDERR "Missing --workers option.\n"); $err++; }
if(!$file) { print(STDERR "Missing --file option.\n"); $err++; }
if($err) {
    print(STDERR "Could not find $err required arguments.\n");
    print_help();
}

my @alphas = (0.0001, 0.001, 0.01, 0.05, 0.1);
my %caps;

for my $alpha (@alphas) {
    $caps{$alpha} = 0;
}

my $exec_c = 0;
my $io_c   = 0;
my $master_c   = 0;
my $count  = 0;
my $accum  = 0;
my $mod_cap = 0;
my $tasks = 0;
my $waiting = 0;
my $workers = 0;
my $timestamp = 0;
my $inst = 0;

my $start = 0;

my $n = 1000;
my @exec_last_n;
my @io_last_n;

if(!$terse) {
    print(STDERR join(' ', map { sprintf("%6s", $_) } (qw(time count tasks wait worker c-inst c-cum c-cumm c-cumn c-avg), @alphas)) . "\n");
}
open(INPUT, $file);
while(my $line = <INPUT>) {
    if($line =~ m/ENGAGE:\s+(?<start_time>\d+)/) {
        $start = $+{start_time};
    }
    next unless $line =~ m/CAPACITY:\s+(?<timestamp>\d+)\s+(?<exe>\d+)\s+(?<io>\d+)\s+(?<master>\d+)\s+(?<tasks>\d+)\s+(?<waiting>\d+)\s+(?<workers>\d+)*/;

    $inst = ($+{exe}/(($+{io} + $+{master}) * 1.0) / ($cores * 1.0));
    $timestamp = $+{timestamp} - $start;
    $exec_c += $+{exe};
    $io_c   += $+{io};
    $master_c += $+{master};
    $tasks = $+{tasks};
    $waiting = $+{waiting};
    $workers = $+{workers};

    push @exec_last_n, $+{exe};
    push @io_last_n,   $+{io};

    if(@exec_last_n > $n) {
        shift @exec_last_n;
        shift @io_last_n;
    }

    $count++;
    $accum += $inst;

    for my $alpha (@alphas) {
        if($caps{$alpha} eq 0) {
            $caps{$alpha} = $inst;
        }
        else {
            $caps{$alpha} = $alpha * $inst + (1 - $alpha) * $caps{$alpha};
        }
    }

    if(!$terse) {
        say join(' ', map { sprintf("%6d", $_) } ($timestamp, $count, $tasks, $waiting, $workers, $inst, $exec_c/$io_c, $exec_c/($io_c + $master_c), sum(@exec_last_n)/sum(@io_last_n), $accum/$count, map { $caps{$_} } @alphas));
    }
}
close(INPUT);

if($terse) {
        say join(' ', map { sprintf("%6d", $_) } ($total_workers, $cap, $timestamp, $count, $tasks, $waiting, $workers, $inst, $exec_c/$io_c, $exec_c/($io_c + $master_c), sum(@exec_last_n)/sum(@io_last_n), $accum/$count, map { $caps{$_} } @alphas));
}

exit 0;

sub sum {
    my @lst = @_;

    my $result = 0;
    for my $i (@lst) {
        $result += $i;
    }

    return $result;
}

sub print_help {

    print $usage;
    exit 1;
}
# vim: tabstop=8 shiftwidth=4 softtabstop=4 expandtab shiftround autoindent
