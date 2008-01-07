# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package TestComplete::SubSubBase;
use Class::Dot qw(:new);

property subsub => isa_String('SubSub Value');

sub subsub_base {
    return 'subsub_base';
}

1;
