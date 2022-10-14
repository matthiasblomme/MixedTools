#!/usr/bin/perl -w
#https://www.ibm.com/support/pages/node/283137

#
# Run this script and pri
#
use strict;
use warnings;
my %eyecatchers;

my $inputFile = $ARGV[0];
my $outputFile = $ARGV[1];

open (INPUT, "< $inputFile") or die $!;
	while (<INPUT>) {
		chomp;
		$eyecatchers{$_}++;
	}
close INPUT;

open(OUTPUT, "> $outputFile");
	print OUTPUT $_." ".$eyecatchers{$_}."\n" foreach sort keys %eyecatchers;
close OUTPUT;

__END__