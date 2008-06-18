#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 528;
use Sort::Packed qw(radixsort_packed mergesort_packed);

my $len = 10000;

sub no_neg_zero { map { $_ || 0 } @_ }

sub test_sort_packed {
    my ($sorter, $format, $rep, $data) = @_;
    my $packed = pack "$format*", ((@$data) x $rep);
    my @data = unpack "$format*", $packed;
    my @sorted = no_neg_zero sort { $a <=> $b } @data;
    $sorter->($format, $packed);
    my @unpacked = no_neg_zero unpack "$format*", $packed;
    my $r = is_deeply(\@unpacked, \@sorted,
                      "$format ".scalar(@data)." x $rep");

    unless ($r) {
        if (open my $out, '>>', '/tmp/sort-packed.data') {
            print $out "\$format='$format';\n";
            print $out "\@data=(", join(',', @data), ");\n";
            print $out "test(\$format, \@data);\n\n";
        }
    }
}

for my $len (1, 2, 4, 10, 20, 100, 200, 1000) {
    my @int = map { (2 ** 32) * rand } 1..$len;

    my @double = map {
        my $m = sprintf "%f", 1 - 2 * rand;
        my $e = int(300 - 600 * rand);
        my $v1 = "${m}E${e}";
        0 + $v1
    } 1..$len;

    for my $sorter (\&radixsort_packed, \&mergesort_packed) {
        for my $rep (1, 3, 7) {
            test_sort_packed $sorter, n => $rep, \@int;
            test_sort_packed $sorter, v => $rep, \@int;
            test_sort_packed $sorter, N => $rep, \@int;
            test_sort_packed $sorter, V => $rep, \@int;
            test_sort_packed $sorter, i => $rep, \@int;
            test_sort_packed $sorter, I => $rep, \@int;
            test_sort_packed $sorter, j => $rep, \@int;
            test_sort_packed $sorter, J => $rep, \@int;
            test_sort_packed $sorter, f => $rep, \@double;
            test_sort_packed $sorter, d => $rep, \@double;
            test_sort_packed $sorter, F => $rep, \@double;
        }
    }
}
