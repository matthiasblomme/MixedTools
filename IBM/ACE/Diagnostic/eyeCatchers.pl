#!/usr/bin/perl -w
#https://www.ibm.com/support/pages/node/283137
#strings - pull strings out of a binary file

use strict;
use warnings FATAL => 'all';
use open IO => ":raw";

$/ = "\0";
my $inputFile = $ARGV[0];

open (INPUT, "< $inputFile") or die $!;
while (<INPUT>)
{
    while (/([\040-\176\s]{4,})/g)
    {
        my $line = $1;
        print $1, "\n" if ($line =~ />(BIP\d{4})/) ;
        print $1, "\n" if ($line =~ />(BIP\w{4})/) ;
    }

}

__END__