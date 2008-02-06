# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Accessor::Chained;
use base 'Class::Dot::Meta::Accessor::Base';

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION   = qv('2.0.0_15');
our $AUTHORITY = 'cpan:ASKSH';

use Carp qw(croak confess);

use Class::Dot::Devel::Sub::Name qw(subname);

use Class::Dot::Meta::Type qw(_NEWSCHOOL_TYPE _OLDSCHOOL_TYPE);

sub register_plugin {
    return {
        name    => 'Chained',
        class   => __PACKAGE__,
    },
};

sub create_get_accessor {
    my ($self, @args) = @_;
    return $self->create_mutator(@args);
}

sub create_set_accessor {
    my ($self, $caller_class, $property, $isa, $options) = @_;
    my $property_key = $property;

    return subname "${caller_class}::set_$property" => sub {
        my ($self, $value) = @_;
        
        if ($options->{'-optimized'}) {
            $self->{$property_key} = $value;
        }
        else {
            $self->__setattr__($property, $value);
        }
        return $self; # <-- this is the chained part.
    }
}

sub create_mutator {
    my ($self, $caller_class, $property, $isa, $options, $priv) = @_;
    my $property_key = $property;

    return subname "${caller_class}::$property" => sub {
        my ($self, $value) = @_;

        if (defined $value) {
            confess "Can't set value with $property(). It's read only!"
                if not $priv->{has_setter};
            if ($options->{'-optimized'}) {
                $self->{$property_key} = $value;
            }
            else {
                $self->__setattr__($property, $value);
            }
            return $self; # <-- this is the chained part.
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
