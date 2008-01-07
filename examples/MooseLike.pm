# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package MooseLike::Mammal::Human;

use Class::Dot 2.0 qw(:fast);

extends 'MooseLike::Mammal';

# Random gender if no gender set.
my @genders = qw(male female);

has 'name'   => (is => 'rw', isa => 'Str');
has 'gender' => (is => 'rw', isa => 'Str', 
                default => $genders[rand $#genders],
);

package MooseLike::Mammal;

use Class::Dot 2.0 qw(:fast);

has 'DNA'   => (is => 'rw', isa => 'Str');


1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
