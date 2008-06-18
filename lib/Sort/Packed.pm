package Sort::Packed;

our $VERSION = '0.01';

use strict;
use warnings;
use Carp;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(sort_packed reverse_packed);

# byte_order:
# 0 - big endian
# 1 - little endian

# type
# 0 - unsigned
# 1 - signed
# 2 - float
# 3 - float x86

my %nv_format = (
                 '5839b4c876bebf3f' => 'LE',
                 '3fbfbe76c8b43958' => 'BE',
                 '83c0caa145b6f3fdfb3f0000' => 'LE_x86',
		 '3ffbfbe76c8b4395810624dd2f1a9fbe' => 'BE',
		 'be9f1a2fdd24068195438b6ce7fbfb3f' => 'LE',
                 '83c0caa145b6f3fdfb3f000000000000' => 'LE_x86');

my $double_format = $nv_format{unpack 'H*' => pack d => 0.124} || 'LE';
my $double_byte_order = ($double_format =~ /^BE/ ? 0 : 1);
my $double_type = ($double_format =~ /x86/ ? 2 : 3);

require XSLoader;
XSLoader::load('Sort::Packed', $VERSION);

my %cache;
sub _template_props {
    my ($dir, $pattern, $rep) = $_[0] =~ /^([+\-]?)(\w!?)(\d*)$/
        or croak "invalid template '$_[0]'";

    $dir = ($dir eq '-' ? -1 : 1);
    $rep ||= 1;

    $pattern =~ /^[bBhHuUwxX]/
        and croak "unsupported pack format '$pattern'";

    my ($test1, $test2, $test3);
    eval {
        no warnings;
        $test1 = pack $pattern => 0x1;
        $test2 = unpack $pattern => pack $pattern => -1;
    };
    $@ and croak "invalid pack pattern '$pattern': $@";

    my $vsize = length $test1;
    my $ix = index $test1, chr 0x1;
    my $vtype = ($test2 eq '-1' ? 1 : 0);
    my $byte_order;
    if ($pattern =~ /^[fdFD]/) {
        $vtype = $double_type;
        $byte_order = $double_byte_order;
    }
    else {
        if ($vsize == 1 or $ix == $vsize - 1) {
            $byte_order = 0;
        }
        elsif ($ix == 0) {
            $byte_order = 1;
        }
        else {
            croak "unsupported pack format '$pattern'"
        }
    }

    $dir, $vsize, $vtype, $byte_order, $rep
}

sub sort_packed {
    @_ == 2 or croak 'Usage: sort_packed($format, $vector)';
    my ($dir, $vsize, $vtype, $byte_order, $rep) = @{$cache{$_[0]} ||= [_template_props($_[0])]};
    _sort_packed($_[1], $dir, $vsize, $vtype, $byte_order, $rep);
}

sub reverse_packed {
    @_ == 2 or croak 'Usage: reverse_packed($format, $vector)';
    my (undef, $vsize, undef, undef, $rep) = @{$cache{$_[0]} ||= [_template_props($_[0])]};
    _reverse_packed($_[1], $vsize * $rep);
}

1;
__END__

=head1 NAME

Sort::Packed - Sort records packed in a vector

=head1 SYNOPSIS

  use Sort::Packed qw(sort_packed);
  my $vector = pack 'l*' => 12, 435, 34, 56, 43, 7;
  sort_packed l => $vector;
  print join(', ', unpack('l*' => $vector)), "\n";

=head1 DESCRIPTION

This module allows to sort data packed in a perl scalar.

Internally it uses a radix sort algorithm that is very fast.


=head2 EXPORT

The following functions can be imported from this module:

=over 4

=item sort_packed $template => $data

sorts the records packed inside scalar C<$data>.

C<$template> is a simplified C<pack> template. It has to contain a
type indicator optionally followed by an exclamation mark and/or a
repetition count. For instance:

   "n" => unsigned short in big-endian order
   "l!" => native signed long
   "L!4" => records of four native unsigned longs
   "C256" => records of 256 unsigned characters

The template can be prefixed by a minus sign to indicate descending
order (for instance, C<-n4>).

Sub-byte size or variable length types can not be used (for instance,
bit C<b>, hexadecimal C<h>, unicode C<U> or BER C<w> types are
forbidden).

Currently, templates containing several types (as for instance "nL")
are not supported.

=item reverse_packed $template => $data

reverses the order of the records packed inside scalar C<$data>.

=back

=head1 SEE ALSO

Perl builtins L<perlfunc/pack> and L<perlfunc/sort>.

My other sorting modules L<Sort::Key> and L<Sort::Key::Radix>.

The Wikipedia article abour radix sort:
L<http://en.wikipedia.org/wiki/Radix_sort>.

=head1 BUGS AND SUPPORT

None known, but this is an early release!

Send bug reports via the CPAN bug tracking system at
L<http://rt.cpan.org> or just drop my an e-mail with any problem you
encounter while using this module.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Salvador FandiE<ntilde>o (sfandino@yahoo.com).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
