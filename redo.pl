#!/usr/bin/perl

use strict;
use warnings;

use blib;
use Sort::Packed qw(mergesort_packed_custom);

warn "set a breakpoint for sort_radix now\n";

$a = $b = 1;

sub test {
    my ($format, @data) = @_;
    my $pack = pack "$format*", @data;
    mergesort_packed_custom {
        my $an = unpack $format, $a;
        my $bn = unpack $format, $b;
        # print "format: $format, a: $an, b: $bn\n";
        $an <=> $bn
    } -$format, $pack;
    my @unpack = unpack "$format*", $pack;
    my @sorted = sort { $b <=> $a } @data;
    my @resorted = sort { $b <=> $a } @unpack;

    if ("@unpack" ne "@sorted") {
        printf "format: %s, data: %d\n", $format, scalar @unpack;
        print (("@resorted" eq "@sorted" ? 'same' : 'different'), " data\n");
        print (("@unpack" eq "@sorted" ? 'same' : 'different'), " order\n");
        print "n: @sorted\np: @unpack\n\n";
    }
}

do "/tmp/sort-packed.data";
print "$@\n" if $@;
