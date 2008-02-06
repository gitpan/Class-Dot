# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Role;

use strict;
use warnings;
use version;
use 5.006;

our $VERSION    = qv('2.0.0_15');
our $AUTHORITY  = 'CPAN:asksh';

use Carp qw(confess);

use Class::Dot::Registry;
my  $REGISTRY = Class::Dot::Registry->new();

sub mixin_with {
    my ($self, $the_class, $with) = @_;
    my $class = ref $the_class ? $the_class
        : $the_class->new();

    return _apply_attributes($with, $class);
}
     

sub _apply_attributes {
    my ($self, $other) = @_;

    my $self_metaclass  = $self->__metaclass__();
    my $other_metaclass = $other->__metaclass__();

    my %self_meta = %{ $self->__meta__() };
    while (my ($attr_name, $attr_isa) = each %self_meta) {
        
        if ($other->__hasattr__($attr_name) && 
            ($other->__meta__($attr_name)->__isa__ != $attr_isa))
        {
            if ($other->isa('Class::Meta::Role')) {
                confess "Fatal error: Role [" . ref $self . "] has en" . #-
                        "countered an attribute conflict during composition."
                ;
            }
            else {
                next; # pass
            }
        }
        else {
            $other_metaclass->property->define_property(
                ($attr_name, $attr_isa) => ref $other
            );
        }
    }

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

     
    


    

    
