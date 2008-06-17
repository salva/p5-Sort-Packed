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

1;
__END__

=head1 NAME

Sort::Packed - Sort records packed in a vector

=head1 SYNOPSIS

  use Sort::Packed sort_packed;
  my $vector = pack l => 12, 435, 34, 56, 43, 7;
  sort_packed $vector, 'l';
  print join(', ', unpack(l => $vector)), "\n";
  
  

=head1 DESCRIPTION

Stub documentation for Sort::Packed, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

salva, E<lt>salva@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by salva

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
