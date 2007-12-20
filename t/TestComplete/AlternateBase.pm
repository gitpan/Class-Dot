# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package TestComplete::AlternateBase;
use Class::Dot qw(:new);
extends 'TestComplete::SubSubBase';

property alternate => isa_String('Alternate Value');

sub alternatebase {
    return 'alternatebase';
}

1;
