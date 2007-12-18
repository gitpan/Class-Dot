# $Id: TestComplete.pm 50 2007-11-03 21:59:03Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/t/TestComplete.pm $
# $Revision: 50 $
# $Date: 2007-11-03 22:59:03 +0100 (Sat, 03 Nov 2007) $
package TestComplete;

use strict;
use warnings;

use Class::Dot qw(-new -rebuild :std);

use TestComplete::Type1;
use TestComplete::Type2;

sub BUILD {
    my ($class, $options_ref) = @_;
    $options_ref ||= @_;

    my $type = $options_ref->{type};

    $type    = "TestComplete::$type";

    my $delegated_to = $type->new($options_ref);

    return $delegated_to;
}

1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
