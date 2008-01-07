# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Mammal;

use strict;
use warnings;

use Class::Dot qw( -new property isa_Data isa_Hash );

property brain  => isa_Hash;
property dna    => isa_Data;

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
