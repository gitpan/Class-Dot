# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Delegator;

use strict;
use warnings;
use version;
use dot::meta;

our $VERSION    = qv('2.0.0_15');
our $AUTHORITY  = 'cpan:ASKSH';

use Carp qw(confess);
use Class::Plugin::Util qw(require_class);

sub BUILD {
    my ($self, $options_ref) = @_;
    my ($using, $index)      = $self->dot::meta::delegation();
    confess "delegate: Using $using but no such attribute"
        if not defined $self->dot::meta::hasattr($using);

    my $to = $self->dot::meta::getattr($using)
        or confess "Needs argument: $using";

    exists $index->{$to} or confess "No such $using: $to";

    my $destination = $index->{$to};

    require_class ($destination);

    return $destination->new($options_ref);
}
