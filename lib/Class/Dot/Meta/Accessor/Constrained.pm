# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Accessor::Constrained;
use base 'Class::Dot::Meta::Accessor::Overrideable';

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION   = qv('2.0.0_10');
our $AUTHORITY = 'cpan:ASKSH';

use Carp qw(confess croak);
use Scalar::Util qw(blessed);
use overload ();

use Class::Dot::Devel::Sub::Name qw(subname);

use Class::Dot::Meta::Type qw(_NEWSCHOOL_TYPE _OLDSCHOOL_TYPE);

my $CONSTRAINT_CHECK_ERROR = <<'FORMATEOF'
Attribute (%s) does not pass the type constraint (%s) with '%s'.;
FORMATEOF
;

sub register_plugin {
    return {
        name    => 'Constrained',
        class   => __PACKAGE__,
    },
}

sub create_set_accessor {
    my ($self, $caller_class, $property, $isa, $options) = @_;
    my $property_key = $property;

    my $check_constraint = $isa->constraint();

    return subname "${caller_class}::set_$property" => sub {
        my ($self, $value) = @_;

        if (! $check_constraint->($value)) {
            confess sprintf($CONSTRAINT_CHECK_ERROR,
                $property, $isa->type, $value
            );
        }
        
        if ($options->{'-optimized'}) {
            $self->{$property_key} = $value;
        }
        else {
            $self->__setattr__($property, $value);
        }
        return;
    }
}

sub create_mutator {
    my ($self, $caller_class, $property, $isa, $options, $priv) = @_;
    my $property_key = $property;

    my $check_constraint = $isa->constraint();

    return subname "${caller_class}::$property" => sub {
        my ($self, $value) = @_;

        if (defined $value) {
            confess "Can't set value with $property(). It's private!"
                if not $priv->{has_setter}; 
            if (! $check_constraint->($value)) {
                confess sprintf($CONSTRAINT_CHECK_ERROR,
                    $property, $isa->type, $value
                );
            }
            if ($options->{'-optimized'}) {
                $self->{$property_key} = $value;
            }
            else {
                $self->__setattr__($property, $value);
            }
            return;
        }

        if (not $priv->{has_getter}) {
            confess "Can only set value with $property(), it's write only!";
        } 

        if (!exists $self->{$property_key}) {
            
            if (_NEWSCHOOL_TYPE($isa)) {
                $self->{$property_key} = $isa->default_value($self);
            }
            elsif (_OLDSCHOOL_TYPE($isa)) {
                $self->{$property_key} = $isa->($self);
            }
            else {
                $self->{$property_key} = $isa;
            }
        }

        return $options->{'-optimized'} ? $self->{$property_key}
            : $self->__getattr__($property);
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
