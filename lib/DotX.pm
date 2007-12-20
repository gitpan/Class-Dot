# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package DotX;

use strict;
use warnings;
use version;
use 5.00600;

our $AUTHORITY = 'cpan:ASKSH';
our $VERSION   = qv('2.0.0_08');

sub new {
    my ($class, $options_ref) = @_;
    my $self = bless { %{$options_ref} }, $class;
    return $self;
}

sub type {
    my ($self) = @_;
    return $self->{type};
}

sub __isa__ {
    my ($self) = @_;
    return $self->{__isa__};
}

sub setter_name {
    my ($self) = @_;
    return $self->{setter_name};
}

sub getter_name {
    my ($self) = @_;
    return $self->{getter_name};
}

sub constraint {
    my ($self) = @_;
    return $self->{constraint};
}

1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
