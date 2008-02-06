# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package dot::meta;

use strict;
use warnings;

use Carp         qw(confess);
use Scalar::Util qw(blessed reftype);
use Class::Dot::Registry;

my $REGISTRY = Class::Dot::Registry->new();

sub for {
    goto &with;
}

sub with {
    my ($self, $the_other_class) = @_;

    confess 'dot::meta::for needs class instance or class name'
        if not defined $the_other_class;

    my $other_class = ref $the_other_class
        ? ref $the_other_class
        : $the_other_class;

    return $REGISTRY->get_metaclass_for($other_class);
}

sub incompatible  {
    my ($class) = @_;
    
    confess 'Must be instance to check compatibility, not class name'
        if not blessed $class;

    my $name = ref $class;

    my $type = reftype $class;

    return "Instance must be HASH-based, but $name is $type-based"
        if $type ne 'HASH';

    return;
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
#                           Attribute Related.
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #

sub has {
    my ($class, @args) = @_;
    with($class)->add_attribute(@args);
}

sub hasattr {
    my ($class, @args) = @_;
    with($class)->has_attribute(@args);

}

sub getattr {
    my ($class, @args) = @_;
    with($class)->get_attribute(@args);
}

sub setattr {
    my ($class, @args) = @_;
    with($class)->set_attribute(@args);

}

sub delattr {
    # NOT YET IMPLEMENTED
}


1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
