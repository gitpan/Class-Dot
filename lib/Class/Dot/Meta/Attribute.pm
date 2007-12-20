# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Attribute;

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION   = qv('2.0.0_08');
our $AUTHORITY = 'cpan:ASKSH';

use Class::Dot::Meta::Method qw(
    install_sub_from_coderef
);

use Class::Dot::Devel::Sub::Name;

sub generate_set_attribute {
    my ($into_class, $attribute, $setter_name) = @_;
    
    return subname "$into_class\::$setter_name" => sub {
        my ($self, $value)  = @_;
        $self->{$attribute} = $value;
        return;
    }
}

1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
