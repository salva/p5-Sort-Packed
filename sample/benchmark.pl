#!/usr/bin/perl

use strict;
use warnings;

my $size = $ARGV[0] || 10000;

use Sort::Packed qw(sort_packed);

use Benchmark qw(cmpthese);

sub bm {
    my ($format, @data) = @_;
    my $packed = pack "$format*" => @data;

    print "format $format\n";
    cmpthese(-1,
             { native => sub { my @out = sort { $a <=> $b } @data },
               packed => sub { my $in = pack "$format*" => @data;
                               sort_packed $format => $in;
                               my @out = unpack "$format*" => $in
                           },
               packed2 => sub { my $cp = $packed;
                                sort_packed $format => $cp
                            },
             }
            );
}

my @data = map { 2**31 - 2**32 * rand } 1..$size;
bm(F => @data);



my @int = map { int $_ } @data;
bm(j => @data);

my @uint = map { int abs $_ } @data;
bm(J => @data);
bm(N => @data);
bm(V => @data);
