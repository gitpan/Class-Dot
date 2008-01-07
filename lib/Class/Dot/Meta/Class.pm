# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Class;

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION   = qv('2.0.0_10');
our $AUTHORITY = 'cpan:ASKSH';

use Carp qw(carp croak);
use Params::Util qw(_ARRAYLIKE _HASHLIKE);
use Class::Plugin::Util qw(require_class);
use Scalar::Util qw(blessed);

use Class::Dot::Registry;
our $REGISTRY = Class::Dot::Registry->new();

use Class::Dot::Meta::Method qw(
    install_sub_from_coderef
    install_sub_from_class
);
use Class::Dot::Meta::Property;

use Class::Dot::Devel::Sub::Name;

# Try to load the mro module available in recent perl's.
if (!defined $INC{'mro.pm'}) {
    no warnings 'all';      ## no critic
    eval 'require mro';     ## no critic
}

my $COMMON_BASE_CLASS = 'Class::Dot::Object';

# ------------------------------ CONSTRUCTOR  --------------------------- #
sub new {
    my ($class, $options_ref) = @_;
    $options_ref ||= { };
    
    if (! $options_ref->{property}) {
        $options_ref->{property} = Class::Dot::Meta::Property->new();
    }

    my $self = bless { %{$options_ref} }, $class;

    if (exists $options_ref->{for_class}) {
        my %init_methods; # initial class methods to be installed.

        # Make the class inherit from the common object base class.
        my $for_class = $options_ref->{for_class};
        $self->append_superclasses_for($for_class, $COMMON_BASE_CLASS);

        # Create constructor and destructor methods.

        if (not $options_ref->{'-no_constructor'}) {
            $init_methods{new} = $self->create_constructor($for_class);
        }
        $init_methods{DESTROY} = $self->create_destructor($for_class);

        # Install default methods to the new class.
        while (my ($method_name, $method_ref) = each %init_methods) {
            install_sub_from_coderef(
                $method_ref => $for_class, $method_name
            );
        }
    }
       
    return $self;
}

# ------------------------------ ATTRIBUTES ----------------------------- #

sub property {
    my ($self) = @_;
    return $self->{property};
}

sub set_property {
    my ($self, $property_obj) = @_;
    $self->{property} = $property_obj;
    return;
}

# ------------------------------ METHODS  ------------------------------- #
sub subclass_name {
    my ($self, $parent_class, $subclass_name) = @_;
    return join q{::}, $parent_class, $subclass_name;
}

my $created_classes = { };
sub create_class {
    my ($self, $class_name, $methods_ref, $append_isa_ref, $version) = @_;
    return if exists $created_classes->{$class_name};

    $version = defined $version ? $version
        : 1.0;

    no strict   'refs';     ## no critic
    no warnings 'redefine'; ## no critic

    if (_ARRAYLIKE($append_isa_ref)) {
        my $isa_ref = \@{ "${class_name}::ISA" };
        push @{ $isa_ref }, @{ $append_isa_ref };
    }

    if (_HASHLIKE($methods_ref)) {
        while (my ($method_name, $method_code) = each %{ $methods_ref }) {
            *{ "${class_name}::$method_name" } = $method_code;
        }
    }

    ${ "${class_name}::VERSION" } = $version;

    $created_classes->{$class_name} = 1;

    return;
}

sub append_superclasses_for {
    my ($self, $inheritor, @superclasses) = @_;

    my $options_ref;
    if (_HASHLIKE($superclasses[-1])) {
        $options_ref = pop @superclasses;
    }

    $options_ref->{append} = 1;

    return $self->superclasses_for(
        $inheritor, @superclasses, $options_ref
    );
}

sub superclasses_for {
    my ($self, $inheritor, @superclasses) = @_;
    my @final_isa;

    # If the last element of @superclasses is a hashref
    # it is considered options for this method.
    my $options_ref = { };
    if (_HASHLIKE($superclasses[-1])) {
        $options_ref = pop @superclasses;
    }

    no strict 'refs'; ## no critic

    SUPERCLASS:
    for my $base (@superclasses) {
        if ($inheritor eq $base) {
            carp "Class '$inheritor' tried to inherit from itself.";
            next SUPERCLASS;
        }

        next SUPERCLASS if $inheritor->isa($base);

        if (!require_class($base)) {
            croak "Couldn't load base class '$base'\n";
        }

        push @final_isa, $base;
    }

    # Append to the existing ISA if the "append" option is set
    # (this is used by the {append_superclasses_for()} method).
    if($options_ref->{append}) {
        push @final_isa, @{ "$inheritor\::ISA" };
    }

    # Setting all base classes as one is an optimization
    # over pushing them one for one, atleast in perl > 5.9.5.
    # see `perldoc mro` for more information.
    @{ "$inheritor\::ISA" } = @final_isa;

    return;
}

sub _get_linear_isa_pureperl {
    my ($self, $class) = @_;

    my @stream = $class;
    my @final;
    my %seen;

    no strict 'refs'; ## no critic
    STREAM:
    while (defined (my $atom = shift @stream)) {
        my @isa = @{ "$atom\::ISA" };
        my @keep;

        ISA:
        for my $isa_class (@isa) {
            next ISA if exists $seen{$isa_class};
            $seen{$isa_class} = 1;
            push @final, $isa_class;
            push @stream, $isa_class;
        }
    }

    unshift @final, $class;
    return \@final;
}

sub get_linear_isa {
    my ($self, $class) = @_;
    my $isa = defined $mro::VERSION ? mro::get_linear_isa($class)
            : $self->_get_linear_isa_pureperl($class);

    return $isa;
}

sub create_constructor {
    my ($self, $caller_class) = @_;
    my $options = $REGISTRY->get_options_for($caller_class);

    return subname "${caller_class}::new" => sub { ## no critic
        my ($class, $options_ref) = @_;

        if (!defined $options_ref) {
            $options_ref = { };
        }

        my $self;
        if ($options->{'-optimized'}) {
            $self = bless {%{ $options_ref }}, $class;
        }
        else {
            $self = bless { }, $class; 
            OPTION:
            while (my ($opt_key, $opt_value) = each %{$options_ref}) {
                #my $attr_meta = $self->__meta__($opt_key);
                #next OPTION if not $attr_meta;
                #my $set_attr  = $attr_meta->setter_name;
                #$set_attr   ||= "set_$opt_key";
                    
                #if ($self->can($set_attr)) {
                #    $self->$set_attr($opt_value);
                #}
                $self->__setattr__($opt_key, $opt_value);
            }
        }

        if ($self->can('BUILD')) {
            my $ret = $self->BUILD($options_ref); 
            if ($options->{'-rebuild'}) {
                if (ref $ret) {
                    $self = $ret;
                }
            }
        }

        return $self;
    }
}

sub create_destructor {
    my ($self, $caller_class) = @_;

    return subname "${caller_class}::DESTROY" => sub {
        my ($self) = @_;

        if ($self->can('DEMOLISH')) {
            $self->DEMOLISH();
        }

        return;
    }
}

1;

__END__

=begin wikidoc

= NAME

Class::Dot::Meta::Class - Create Perl classes dynamically.

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
