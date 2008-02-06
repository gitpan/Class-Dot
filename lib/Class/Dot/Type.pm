# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Type;

use strict;
use warnings;
use version;
use 5.00600;

our $AUTHORITY = 'cpan:ASKSH';
our $VERSION   = qv('2.0.0_15');

sub new {
    my ($class, $options_ref) = @_;
    my $self = bless { %{$options_ref} }, $class;
    return $self;
}

sub type {
    my ($self) = @_;
    return $self->{type};
}

sub accessor_type {
    my ($self) = @_;
    return $self->{accessor_type};
}

sub linear_isa {
    my ($self) = @_;
    return $self->{linear_isa};
}

sub privacy {
    my ($self) = @_;
    return $self->{privacy};
}

sub privacy_rule {
    my ($self) = @_;
    return $self->{privacy_rule};
}

sub __isa__ {
    my ($self) = @_;
    return $self->{__isa__};
}

sub setter_name {
    my ($self) = @_;
    return $self->{setter_name};
}

sub getter_name {
    my ($self) = @_;
    return $self->{getter_name};
}

sub constraint {
    my ($self) = @_;
    return $self->{constraint};
}

1;

__END__

=begin wikidoc

= NAME

Class::Dot::Type - Base class for type constraints.

= VERSION

This document describes {Class::Dot} version %%VERSION%%

= SYNOPSIS

    # You probably want to get this information from your instance's __meta__
    # attriute.

    package MyClass;
    use Class::Dot2;

    property 'name' => (isa => 'Str', default => 'Mr. Fox Quick Brown');

    sub play_with_attribute_meta {
        my ($self) = @_;

        my $name_meta = $self->__meta__('name');

        # Get the name of the type for attribute name.
        my $type = $name_meta->type;

        # Find out what kind of accessor this is. (default: Overridable)
        my $accessor_type = $name_meta->accessor_type;

        # Get a subroutine ref to the constraint check for this type.
        my $check_constraint = $name_meta->constraint;

        my $current_value = $self->name;
        if (! $check_constraint->($current_value)) {
            croak "Value of name does not pass the constraint check for $type"
        }
            

        # Get the getter and setter name.
        my $getter_name   = $name_meta->getter_name;
        my $setter_name   = $name_meta->setter_name;

        # get the value by calling name():
        $current_value = $self->$getter_name;

        # set the value by calling set_name($value)
        $self->$setter_name('new value');
      
        # Get the list of parents for this type.
        my @isa_for_type = $meta->linear_isa; 

        # Get the privacy option for this type (default: public (rw)).
        my $privacy_type = $meta->privacy;

        # Get the privacy rules for this privacy type.
        my $privacy_rules = $meta->privacy_rule;

        print $privacy_rules->{has_getter};
        print $privacy_rules->{has_setter};

        return;
    }

= DESCRIPTION

This is the base class for all [Class::Dot] type constraints.

It ensures easy access to type metadata.

= SUBROUTINES/METHODS

== CLASS CONSTRUCTOR

=== {new($options_ref)}

Create a new type instance.

== ATTRIBUTES

=== {type()}

Get the name of this attributes type.

=== {accessor_type()}

Get the type of accessor this attribute has.
Common types include: {Overrideable}, {Chained} or {Constrained}.

See the manual for the given type:

* [Class::Dot::Meta::Accessor::Overrideable]

This is the default type. It is easy to override in many ways
as long as the {-override} class/attribute option is set.

* [Class::Dot::Meta::Accessor::Chained]

This accessor type always returns the instance itself when you
set a value. This makes it possible to write code like this:

    my $person = Person->new
                    ->name('George Constanza')
                    ->address('Foo foo foo')
                    ->birthday(19720512);

* [Class::Dot::Meta::Accessor::Constrained]

Is the same as {Overrideable} except it will check if the values given 
conforms to the type constraint, if it doesn't it will die with an error.

=== {constraint()}

This is a subroutine reference to a function that checks wether a value
conforms to the type constraint or not. It will return 1 if the value do, and
undef otherwise.

Example:

    my $tyoe_meta        = $self->__meta__($attr);
    my $check_constraint = $type_meta->constraint();

    if (not $check_constraint->($value)) {
        croak "The value is not a valid " . $type_meta->type;
    }

=== {getter_name()}

The name of the get accessor for this attribute.

=== {setter_name()}

The name of the set accessor for this attribute.

=== {linear_isa()}

The list of parent types this type inherits from.

=== {privacy()}

The attributes privacy setting.

Common privacy types:

* public (alias: {rw})

The public can both read and write from this attribute.

* readonly (alias: {ro})

The public can only read from this attribute.

(You can still read the value with {$self->__getattr__($attr_name)}).

* writeonly (alias: {wo})

The public can only write to this attribute.

(You can still write to this attribute with ({$self->__setattr__($attr_name, $value)}).

* private (alias: {xx})

The attribute is private and has no autogenerated accessors.
You can still set a value with {__setattr__} and {__getattr__} (see:
[Class::Dot::Object]).




=== {privacy_rule()}

Get the privacy rules for this type instance.

Common rules include:

* has_getter

Is true if the attribute is public, or readonly ({rw} or {ro}),
but not true if the attribute is writeonly ({wo}).

* has_setter

Is true if the attribute is public or writeonly ({rw} or {wo}),
but not if the attribute is readonly ({ro}).

= DIAGNOSTICS

This module has no error messages.

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

== [Class::Dot::Typemap]

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
