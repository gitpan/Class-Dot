# $Id: Type2.pm 57 2007-12-18 13:19:53Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/t/TestComplete/Type2.pm $
# $Revision: 57 $
# $Date: 2007-12-18 14:19:53 +0100 (Tue, 18 Dec 2007) $
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
