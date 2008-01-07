# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package TestComplete::Type2;
use Class::Dot qw(-new :std);
extends 'TestComplete::Base';

property in_type2 => isa_String();

my $CLOSURE;

sub BUILD {
    my ($self, $options_ref) = @_;

    $CLOSURE = 'built with Type2';

    return;
}

sub get_closure {
    return $CLOSURE;
}

1;

__END__


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
