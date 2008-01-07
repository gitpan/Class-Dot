# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Accessor::Base;

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION   = qv('2.0.0_10');
our $AUTHORITY = 'cpan:ASKSH';

my $THIS_PKG = __PACKAGE__;

use Carp qw(croak confess);

sub new {
    my ($class, $options_ref) = @_;

    return bless { %{$options_ref} }, $class;
}

sub register_plugin {
    confess 'All accessor type plugins must have the register_plugin method!';
}

sub create_get_accessor {
    return _does_not_define_prototyped_method('create_get_accessor');
}

sub create_set_accessor {
    return _does_not_define_prototyped_method('create_set_accessor');
}

sub create_mutator {
    return _does_not_define_prototyped_method('create_mutator');
}

sub _does_not_define_prototyped_method {
    my ($self, $method_name) = @_;
    my $class  = ref $self ? ref $self
        : $self;
    confess <<"EOFTEXT"
$class does not define the $method_name() method, or you are using
base class $THIS_PKG directly.
EOFTEXT
;
}
1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
