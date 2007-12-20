# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Method;

use strict;
use warnings;
use version;
use 5.00600;

use Carp qw(croak);

our $VERSION   = qv('2.0.0_08');
our $AUTHORITY = 'cpan:ASKSH';

my %EXPORT_OK  = map { $_ => 1 } qw(
    install_sub_from_class
    install_sub_from_coderef
);

sub import {
    my ($this_class, @subs) = @_;
    my $caller_class = caller 0;

    for my $sub (@subs) {
        if (! exists $EXPORT_OK{$sub}) {
            croak "$sub is not exported by " . __PACKAGE__;
        }
        install_sub_from_class($this_class, $sub => $caller_class);
    }

    return;
}

sub install_sub_from_class {
    my ($pkg_from, $sub_name, $pkg_to) = @_;
    my $from = join q{::}, ($pkg_from, $sub_name);
    my $to   = join q{::}, ($pkg_to,   $sub_name);

    no strict 'refs'; ## no critic
    *{$to} = *{$from};

    return;
}

sub install_sub_from_coderef {
    my ($coderef, $pkg_to, $sub_name) = @_;
    my $to = join q{::}, ($pkg_to, $sub_name);

    no strict   'refs';     ## no critic
    no warnings 'redefine'; ## no critic
    *{$to} = $coderef;

    return;
}

1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
