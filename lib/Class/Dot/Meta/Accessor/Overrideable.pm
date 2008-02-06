# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Accessor::Overrideable;
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
        name    => 'Overrideable',
        class   => __PACKAGE__,
    },
};

sub create_get_accessor {
    my ($self, $caller_class, $property, $isa, $options) = @_;
    my $property_key = $property;

    return subname "${caller_class}::$property" => sub {
        my $self = shift;

        if (@_) {
            my $setter_name = $self->__meta__($property)->setter_name;
            croak "You tried to set a value with $property(). " .
                  "Did you mean $setter_name() ?"
        };

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
        return;
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

=begin wikidoc

= NAME

Class::Dot::Meta::Accessor::Overrideable - The default accessor type

= VERSION

This document describes {Class::Dot} version %%VERSION%%

= SYNOPSIS

See [Class::Dot::Meta::Accessor] for usage information.

= DESCRIPTION

These are the default accessors when no {-accessor_type} option is set. They
are called {Overrideable} because they are easily overrided when the
{-override} option is set.

To override a semi-affordance attribute just do this:

    use Class::Dot2 qw(-override);

    property name => (isa => 'Str', default => 'George Louis Constanza');

    sub name {
        my ($self) = @_;

        my $name   = $self->__getattr__('name');
        carp "Someone requested the name of: $name ($self)";

        return $name;
    }

    sub set_name {
        my ($self, $new_name) = @_;

        my $name = $self->__getattr__('name');
        carp "Someone changed $name's name to $new_name ($self)";
        $self->__setattr__('name', $new_name);

        return;
    }

If you define your property in a {BEGIN}, {INIT} or {CHECK} block, however,
you have to do it a bit differently:


    BEGIN {
        use Class::Dot2 qw(-override);
        property name => (isa => 'Str', default => 'George Louis Constanza');
       
        after_property_get name => sub {
            my ($self) = @_;

            my $name   = $self->__getattr__('name');
            carp "Someone requested the name of: $name ($self)";
    
            return $name;
        }; # << NOTE: the semicolon is required

        after_property_set set_name => {
            my ($self, $new_name) = @_;
    
            my $name = $self->__getattr__('name');
            carp "Someone changed $name's name to $new_name ($self)";
            $self->__setattr__('name', $new_name);
    
            return;
        }; # << NOTE: the semicolon is required
        

= SUBROUTINES/METHODS

== INSTANCE METHODS

=== {create_get_accessor($caller_class, $attribute_name, $attribute_type, $options, $privacy_settings)}

The prototype for this function is defined in [Class::Dot::Meta::Accessor::Base]
and this overridden method behaves accordingly.

=== {create_set_accessor($caller_class, $attribute_name, $attribute_type, $options, $privacy_settings)}

The prototype for this function is defined in [Class::Dot::Meta::Accessor::Base]
and this overridden method behaves accordingly.

=== {create_mutator($caller_class, $attribute_name, $attribute_type, $options, $privacy_settings)}

The prototype for this function is defined in [Class::Dot::Meta::Accessor::Base]
and this overridden method behaves accordingly.

== PRIVATE CLASS METHODS

=== {register_plugin()}

Private metadata for [Class::Plugin::Util].

= DIAGNOSTICS

== {You tried to set a value with %s(). Did you mean %s() ?}

You tried to set a value via an accessor that is a get accessor, not a
mutator. You should probably follow the error message advice.

== {Can't set value with %s(). It's read only!}

The attribute you tried to set is {readonly} and can't be set like this,
if you feel otherwise, declare it as {public}, or set the value via
{$self->__setattr__($attribute_name, $value)}.

== {Can only set value with %s(), it's write only!}

You tried to get the value from a {writeonly} attribute. If you feel the
attribute shouldn't be {writeonly} you should declare it as public, or you can
get the value via {$self->__getattr__($attribute_name)}.

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [version]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
[bug-class-dot@rt.cpan.org|mailto:bug-class-dot@rt.cpan.org], or through the
web interface at [CPAN Bug tracker|http://rt.cpan.org].

= SEE ALSO

== [Class::Dot::Accessor]

== [Class::Dot::Accessor::Base]

== [Class::Dot]

== [Class::Dot::Manual]

= AUTHOR

Ask Solem, [asksh@cpan.org].

= LICENSE AND COPYRIGHT

Copyright (c), 2007 Ask Solem [ask@0x61736b.net|mailto:ask@0x61736b.net].

{Class::Dot} is distributed under the Modified BSD License.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. The name of the author may not be used to endorse or promote products
derived
from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED                        
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF                                
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO                          
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,                              
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,                        
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR                      
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER                       
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)                          
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                          
POSSIBILITY OF SUCH DAMAGE.

= DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE
SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE
STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY
COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE
SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER
SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

=end wikidoc

=for stopwords expandtab shiftround

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
