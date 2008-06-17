#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 264;
use Sort::Packed qw(sort_packed);

my $len = 10000;

sub no_neg_zero { map { $_ || 0 } @_ }

sub test_sort_packed {
    my ($format, $rep, $data) = @_;
    my $packed = pack "$format*", ((@$data) x $rep);
    my @data = unpack "$format*", $packed;
    my @sorted = no_neg_zero sort { $a <=> $b } @data;
    sort_packed $format, $packed;
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

    for my $rep (1, 3, 7) {
        test_sort_packed n => $rep, \@int;
        test_sort_packed v => $rep, \@int;
        test_sort_packed N => $rep, \@int;
        test_sort_packed V => $rep, \@int;
        test_sort_packed i => $rep, \@int;
        test_sort_packed I => $rep, \@int;
        test_sort_packed j => $rep, \@int;
        test_sort_packed J => $rep, \@int;
        test_sort_packed f => $rep, \@double;
        test_sort_packed d => $rep, \@double;
        test_sort_packed F => $rep, \@double;
    }
}
