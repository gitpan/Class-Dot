# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Property;

use strict;
use warnings;
use version;
use 5.00600;

use Carp qw(carp croak confess);
use Params::Util qw(_ARRAYLIKE _HASHLIKE);
use Class::Plugin::Util qw(require_class);
use Scalar::Util qw(blessed);

use Class::Dot::Registry;
our $REGISTRY = Class::Dot::Registry->new();

use Class::Dot::Meta::Type qw(
    _NEWSCHOOL_TYPE
    _OLDSCHOOL_TYPE
);
use Class::Dot::Meta::Method qw(
    install_sub_from_coderef
    install_sub_from_class
);
use Class::Dot::Meta::Accessor;

use Class::Dot::Devel::Sub::Name;

our $VERSION   = qv('2.0.0_10');
our $AUTHORITY = 'cpan:ASKSH';

my $ATTR_EXISTS         = 1;
my $ATTR_EXISTS_CACHED  = 2;

my $DEFAULT_ACCESSOR_TYPE = 'Overrideable';

my $TYPE_PRIVACY_DEFAULT  = 'public';

my %TYPE_PRIVACY_ALIASES  = (
    'rw'    => 'public',
    'ro'    => 'private',
    'wo'    => 'writeonly',
);

my %TYPE_PRIVACY_RULES   = (
    public  => {
        has_getter => 1,
        has_setter => 1,
    },
    private => {
        has_getter => 1,
    },
    writeonly => {
        has_setter => 1,
    },
);

# ------------------------------ CONSTRUCTOR  ----------------------------- #
sub new {
    my ($class, $options_ref) = @_;
    $options_ref ||= { };

    return bless { %{$options_ref} }, $class;
}

# ------------------------------ METHODS --------------------------------- #

sub traverse_isa_for_property {
    my ($self, $the_class, $attr) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;
    my $metaclass = $REGISTRY->get_metaclass_for($class);

    my $has_property;
    my $all_properties = { };

    my $isa = $metaclass->get_linear_isa($class);

    if (scalar @{ $isa } > 1) {
        ISA:
        for my $isa (@{ $isa }) {
            my $class_meta = $REGISTRY->get_meta_for($isa);
            if (defined $attr) {
                if (exists $class_meta->{$attr}) {
                    $has_property = $class_meta->{$attr};
                    last ISA;
                }
            }
            else {
                PROPERTY:
                while (my ($name, $val) = each %{ $class_meta }) {
                    # we always use the first property we get, since that
                    # matches the method resolution order, so we skip the
                    # property if we already have it.
                    if (!exists $all_properties->{$name}) {
                        $all_properties->{$name} = $val;
                    }
                }
            }
        }
    }
    else {
        my $class_meta = $REGISTRY->get_meta_for($class);
        if (defined $attr) {
            $has_property = exists $class_meta->{$attr};
        }
        else {
            $all_properties = {%{ $class_meta }};
        }
    }

    return defined $attr ? $has_property
        : $all_properties;
}

sub properties_for_class {
    my ($self, $the_class) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;

    my $isa_cache = $REGISTRY->get_isa_cache_for($class);
    if ($isa_cache) {
        if ($ENV{TESTING_CLASS_DOT}) {
            $isa_cache->{__is_retrieved_cached__}++;
        }
        return $isa_cache;
    }

    return $self->traverse_isa_for_property($class);
}

sub composites_for {
    my ($self, $class, $name, $composite) = @_;
   
    if (!require_class($composite)) {
        croak "Couldn't load composite class '$composite'\n";
    }

    my $object_init = Class::Dot::Typemap->get_type('Object');
    return $self->define_property(
        $name, $object_init->($composite, auto => 1)
            => $class
    );
}

sub _merge_hash_left_precedent {
    my ($left_side, $right_side) = @_;
    $left_side  ||= { };
    $right_side ||= { };

    my $res = {%{ $left_side }};
    while (my ($key, $value) = each %{ $right_side }) {
        if (!exists $left_side->{$key}) {
            $res->{$key} = $value;
        }
    }

    return $res;
}

sub define_property {
    my ($self, $property, $isa, $caller_class, $options) = @_;
    my $accessors = { };

    # Can't add properties to finalized classes. 
    #confess "Can't add new properties to finalized class $caller_class!"
    #    if $REGISTRY->is_finalized($caller_class);

    # ### Merge context and class wide options.
    my $class_options = $REGISTRY->get_options_for(
        $caller_class
    );
    my $all_options   = _merge_hash_left_precedent($options, $class_options);

    # ## # Create a type instance for the type if it isn't one already.
    if (! _NEWSCHOOL_TYPE($isa)) {
        my $any_type = Class::Dot::Typemap->get_type('Any');
        # The current value becomes the default_value of the type.
        # e.g
        #   property who => "the quick brown fox"
        # becomes a type instance of type Any and a default
        # value of "the quick brown fox".
        $isa = $any_type->($isa);
    }

    # Decide the accessor type.
    my $accessor_type;
    if (exists $all_options->{'-accessor_type'}) {
        $accessor_type = $all_options->{'-accessor_type'};
    }
    elsif ($all_options->{'-chained'}) {
        $accessor_type = 'Chained';
    }
    elsif ($all_options->{'-constrained'}) {
        $accessor_type = 'Constrained';
    }
    else {
        $accessor_type  = $DEFAULT_ACCESSOR_TYPE;
    }
    $isa->{accessor_type} = $accessor_type;

    my $accessor_gen = Class::Dot::Meta::Accessor->new({
        type => $accessor_type
    });

    # Get the privacy rules for this privacy setting.
    my $privacy_rules;
    my $privacy_type  = $all_options->{privacy};
    ($privacy_rules, $privacy_type)
        = $self->get_privacy_rule($privacy_type);
    $isa->{privacy}      = $privacy_type;
    $isa->{privacy_rule} = $privacy_rules;

    my $is_mutator = (
        ! $all_options->{'-getter_prefix'}
     && ! $all_options->{'-setter_prefix'}
    );

    if ($is_mutator) {
        $accessors->{$property} = $accessor_gen->create_mutator(
            $caller_class, $property, $isa, $all_options, $privacy_rules
        );
    }

    # ### Create get accessor.
    if (!$is_mutator && $privacy_rules->{has_getter}) {
        my $get_property = $all_options->{'-getter_prefix'} . $property;
        $isa->{getter_name} = $get_property;
        $accessors->{$get_property} = $accessor_gen->create_get_accessor(
            $caller_class, $property, $isa, $all_options, $privacy_rules
        );
    }

    # ### Create set accessor.

    if (!$is_mutator && $privacy_rules->{has_setter}) {
        my $set_property = $all_options->{'-setter_prefix'} . $property;

        # Keep preceeding _'s. E.g __private becomes __set_private
        # instead of set__private.
        if ($property =~ /^(_+)/xms) {
            my $uscores   =  $1;
            $set_property =  $property;
            $set_property =~ s/^_+//xms;
            $set_property
                = $uscores.$all_options->{'-setter_prefix'}.$set_property;
        }

        # Store the names inside the type instance for later use.
        $isa->{setter_name} = $set_property;

        $accessors->{$set_property} = $accessor_gen->create_set_accessor(
            $caller_class, $property, $isa, $all_options, $privacy_rules
        );
    }

    # ### Install accessors
    no strict 'refs'; ## no critic
    while (my ($accessor_name, $accessor_coderef) = each %{ $accessors }) {
        if (not *{ "$caller_class\::$accessor_name" }{CODE}) {
            install_sub_from_coderef(
                $accessor_coderef => $caller_class, $accessor_name
            );
        }
    }

    # ### Save metadata.
    my $class_meta = $REGISTRY->get_meta_for($caller_class);
    $class_meta->{$property} = $isa;

    return;
}

sub get_privacy_rule {
    my ($self, $opt_privacy_type) = @_;
    my $privacy_type = defined $opt_privacy_type ? $opt_privacy_type
        : $TYPE_PRIVACY_DEFAULT;

    # Decide which accessors to create based on the privacy option.
    if (exists $TYPE_PRIVACY_ALIASES{$privacy_type}) {
        $privacy_type = $TYPE_PRIVACY_ALIASES{$privacy_type};
    }

    confess "Unknown attribute privacy type: $privacy_type"
        if not exists $TYPE_PRIVACY_RULES{$privacy_type};

    my $rules = $TYPE_PRIVACY_RULES{$privacy_type};

    return wantarray ? ($rules, $privacy_type)
        : $rules;
}

1;

__END__

=begin wikidoc

= NAME

Class::Dot::Meta::Property - Create and keep track of properties.

= VERSION

This document describes Class::Dot version v2.0.0 (beta 4).

= SYNOPSIS

    use Class::Dot::Typemap qw(:std);

    use Class::Dot::Typemap qw( isa_String isa_Int );


= DESCRIPTION

This module has the available types [Class::Dot] supports.

= SUBROUTINES/METHODS

== CLASS METHODS

=== {isa_String($default_value)}
=for apidoc CODEREF = Class::Dot::isa_String(data|CODEREF $default_value)

The property is a string.

=== {isa_Int($default_value)}
=for apidoc CODEREF = Class::Dot::isa_Int(int $default_value)

The property is a number.

=== {isa_Array(@default_values)}
=for apidoc CODEREF = Class::Dot::isa_Array(@default_values)

The property is an array.

=== {isa_Hash(%default_values)}
=for apidoc CODEREF = Class::Dot::isa_Hash(@default_values)

The property is an hash.

=== {isa_Object($kind)}
=for apidoc CODEREF = Class::Dot::isa_Object(string $kind)

The property is a object.
(Does not really set a default value.).

=== {isa_Data()}
=for apidoc CODEREF = Class::Dot::isa_Data($data)

The property is of a not yet defined data type.

=== {isa_Code()}
=for apidoc CODEREF = Class::Dot::isa_Code(CODEREF $code)

The property is a subroutine reference.

=== {isa_File()}
=for apidoc CODEREF = Class::Dot::isa_Code(FILEHANDLE $fh)


= DIAGNOSTICS

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [version]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
[bug-class-dot@rt.cpan.org|mailto:bug-class-dot@rt.cpan.org], or through the web interface at
[CPAN Bug tracker|http://rt.cpan.org].

= SEE ALSO

== [Class::Dot]

= AUTHOR

Ask Solem, [ask@0x61736b.net].

= LICENSE AND COPYRIGHT

Copyright (c), 2007 Ask Solem [ask@0x61736b.net|mailto:ask@0x61736b.net].

{Class::Dot} is distributed under the Modified BSD License.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. The name of the author may not be used to endorse or promote products derived
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

=for stopwords vim expandtab shiftround

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
