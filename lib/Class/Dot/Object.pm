# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Object;

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION    = qv('2.0.0_10');
our $AUTHORITY  = 'cpan:ASKSH';

use Class::Dot::Registry;
my $REGISTRY = Class::Dot::Registry->new();

my $ATTR_EXISTS         = 1;
my $ATTR_EXISTS_CACHED  = 2;
my $ATTR_NO_SUCH_ATTR;        #<< must be undef.

sub __getattr__ {
    my ($self, $attribute) = @_;
    if (! exists $self->{$attribute}) {
        my $attr_meta = $self->__meta__($attribute);
        return if not defined $attr_meta;
        $self->{$attribute} = $attr_meta->default_value();
    }
    return $self->{$attribute};
}

sub __hasattr__ {
    my ($self, $attribute) = @_;

    my $is_finalized = $REGISTRY->is_finalized($self);
    my $isa_cache    = $REGISTRY->get_isa_cache_for($self);
    if ($is_finalized && $isa_cache) {
        return defined $isa_cache->{$attribute} ? $ATTR_EXISTS_CACHED
            : $ATTR_NO_SUCH_ATTR;
    }

    my $property_meta = $self->__metaclass__->property;
    return $property_meta->traverse_isa_for_property($self, $attribute)
        ? $ATTR_EXISTS
        : $ATTR_NO_SUCH_ATTR;
}

sub __setattr__ {
    my ($self, $attribute, $value) = @_;
    return if not $self->__hasattr__($attribute);

    $self->{$attribute} = $value;

    return 1;
}

sub __is_finalized__ {
    my ($self) = @_;

    return $REGISTRY->is_finalized($self);
}

sub __finalize__ {
    my ($self) = @_;
    return 1 if $self->__is_finalized__;
    
    my $metaclass = $self->__metaclass__;
    my $isa_cache = $metaclass->property->traverse_isa_for_property($self);

    return $REGISTRY->finalize_class($self, $isa_cache);
}

sub __meta__ {
    my ($self, $property_name) = @_;
    
    my $all_meta = $self->__metaclass__->property->properties_for_class($self);

    return defined $property_name ? $all_meta->{$property_name}
        : $all_meta
}

sub __metaclass__ {
    my ($self) = @_;
    return $REGISTRY->get_metaclass_for($self);
}

1;

__END__


=begin wikidoc

= NAME

Class::Dot::Object - The default base object for Class::Dot classes.

= VERSION

This document describes {Class::Dot} version %%VERSION%%

= DESCRIPTION

This is the default base class for [Class::Dot] classes. You don't have to
inherit from this class manually, it is done automaticly when you import
{Class::Dot} in your class.

Actually it is a bit more complex than that, it is the base class for
{Class::Dot}'s default metaclass, [Class::Dot::Meta::Class].
You can extend it's functionality by subclassing {Class::Dot::Meta::Class}
and then set that subclass as the metaclass with the {-metaclass} option,
via there you can decide which base class you want.

This class contain useful methods for introspection on your class's
attributes, metaclass and so on.

Notice how this base class has no constructor or destructor, these are built
dynamicly by the metaclass.

= SUBROUTINES/METHODS

== INSTANCE METHODS

=== {__hasattr__($attribute_name)}

Returns true if the class has the attribute {$attribute_name}.

=== {__getattr__($attribute_name)}

Get the value of an attribute.

=== {__setattr__($attribute_name, $value)}

Set the value of an attribute.

*NOTE* This will not check if the value conforms to the type constraint
even if the {-constrained} option is set. To do this dynamically you have to
do it like this:

    my $set_attr = $self->__meta__($attribute)->setter_name();
    $self->$set_attr($value);

=== {__meta__($attribute_name})

Return attribute metadata for an attribute by it's name.
This will return the attribute's type instance. See [Class::Dot::Type]
for the methods available.

=== {__metaclass__}

Return the instance of the metaclass for this class.

=== {__is_finalized__()}

Returns true if this class is finalized.

=== {__finalize__()}

Finalize the class.

= DIAGNOSTICS

This class has no error messages.

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

== [Class::Dot::Manual]

== [Class::Dot]

== [Class::Dot::Type]

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

