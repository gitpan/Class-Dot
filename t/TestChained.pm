# $Id: TestChained.pm 57 2007-12-18 13:19:53Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/t/TestChained.pm $
# $Revision: 57 $
# $Date: 2007-12-18 14:19:53 +0100 (Tue, 18 Dec 2007) $
package TestChained;

use strict;
use warnings;

use Class::Dot qw(-new -chained -rebuild :std);

property name           => isa_String;
property email          => isa_String;
property address        => isa_String;
property birthdate_year => isa_Int;


property with_default   => isa_String("hello world!");
property reg            => "hello universe!";
property reglazy        => sub { return "hello lazy!" };

# -rebuild to fill coverage for using rebuild when $new is not true.
sub BUILD {
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
