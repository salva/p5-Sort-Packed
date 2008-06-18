#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1188;
use Sort::Packed qw(radixsort_packed mergesort_packed);

my $len = 10000;

sub no_neg_zero { map { $_ || 0 } @_ }

sub test_sort_packed {
    my ($sorter, $dir, $format, $rep, $data) = @_;
    my $packed = pack "$format*", ((@$data) x $rep);
    my @data = unpack "$format*", $packed;
    my @sorted = ( $dir eq '-'
                   ? no_neg_zero(sort { $b <=> $a } @data)
                   : no_neg_zero(sort { $a <=> $b } @data) );
    $sorter->("$dir$format", $packed);
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

for my $len (1, 2, 4, 10, 20, 200) {
    my @int = map { (2 ** 32) * rand } 1..$len;

    my @double = map {
        my $m = sprintf "%f", 1 - 2 * rand;
        my $e = int(300 - 600 * rand);
        my $v1 = "${m}E${e}";
        0 + $v1
    } 1..$len;

    for my $sorter (\&radixsort_packed, \&mergesort_packed) {
        for my $rep (1, 3, 5) {
            for my $dir ('', '+', '-') {
                test_sort_packed $sorter, $dir, n => $rep, \@int;
                test_sort_packed $sorter, $dir, v => $rep, \@int;
                test_sort_packed $sorter, $dir, N => $rep, \@int;
                test_sort_packed $sorter, $dir, V => $rep, \@int;
                test_sort_packed $sorter, $dir, i => $rep, \@int;
                test_sort_packed $sorter, $dir, I => $rep, \@int;
                test_sort_packed $sorter, $dir, j => $rep, \@int;
                test_sort_packed $sorter, $dir, J => $rep, \@int;
                test_sort_packed $sorter, $dir, f => $rep, \@double;
                test_sort_packed $sorter, $dir, d => $rep, \@double;
                test_sort_packed $sorter, $dir, F => $rep, \@double;
            }
        }
    }
}
