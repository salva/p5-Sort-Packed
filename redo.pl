#!/usr/bin/perl

use strict;
use warnings;

use blib;
use Sort::Packed qw(mergesort_packed);

warn "set a breakpoint for sort_radix now\n";

sub test {
    my ($format, @data) = @_;
    my $pack = pack "$format*", @data;
    mergesort_packed $format, $pack;
    my @unpack = unpack "$format*", $pack;
    my @sorted = sort { $a <=> $b } @data;
    my @resorted = sort { $a <=> $b } @unpack;

    print (("@resorted" eq "@sorted" ? 'same' : 'different'), " data\n");
    print (("@unpack" eq "@sorted" ? 'same' : 'different'), " order\n");
    # print "n: @sorted\np: @unpack\n\n";
}

do "/tmp/sort-packed.data";
