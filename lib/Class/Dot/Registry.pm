# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Registry;

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION   = qv('2.0.0_15');
our $AUTHORITY = 'cpan:ASKSH';

use Carp qw(croak);
use Class::Plugin::Util qw(require_class);

my $DEFAULT_METACLASS = 'Class::Dot::Meta::Class';

STATE: {
    my $THE_REGISTRY; # << This is a singleton object.

    my $scalar_ref = do { my $scalar; \$scalar };

    sub new {
        my ($class) = @_;

        if (! defined $THE_REGISTRY) {
            $THE_REGISTRY = bless $scalar_ref, $class;
        }

        return $THE_REGISTRY;
    }
}

PRIVATE: {
    my %METACLASS_FOR;
    my %IS_FINALIZED;
    my %ISA_CACHE_FOR;
    my %CLASS_META_FOR;
    my %OPTIONS_FOR;
    my %REGISTERED_CLASSES;

    sub _get_metaclasses {
        return \%METACLASS_FOR;
    }

    sub _get_finalized {
        return \%IS_FINALIZED;
    }

    sub _get_isa_cache {
        return \%ISA_CACHE_FOR;
    }

    sub _get_class_meta {
        return \%CLASS_META_FOR;
    }

    sub _get_options {
        return \%OPTIONS_FOR;
    }

    sub _get_registered_classes {
        return \%REGISTERED_CLASSES;
    }
}

sub register_class {
    my ($self, $the_class) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;

    my $class_register = _get_registered_classes();
    $class_register->{$class} = 1;
    return;
}

sub is_class_registered {
    my ($self, $the_class) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;

    return _get_registered_classes()->{$class};
}

sub finalize_class {
    my ($self, $the_class, $isa_cache) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;
    return if not defined $class;

    my $is_finalized = _get_finalized();

    return 1 if $is_finalized->{$class};

    if ($isa_cache) {
        $self->update_isa_cache_for($class, $isa_cache);
    }

    $is_finalized->{$class} = 1;

    return 1;
}

sub is_finalized {
    my ($self, $the_class) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;

    return _get_finalized()->{$class} ? 1 : 0;
}

sub get_isa_cache_for {
    my ($self, $the_class) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;
    my $isa_cache_for = _get_isa_cache();
    return if not exists $isa_cache_for->{$class};

    # Can be undef. If it is, the class is probably not finalized.
    return $isa_cache_for->{$class};
}

sub update_isa_cache_for {
    my ($self, $class, $isa_cache) = @_;

    my $isa_cache_for = _get_isa_cache(); 
    $isa_cache_for->{$class} = $isa_cache;
    return;
}

sub get_meta_for {
    my ($self, $class) = @_;
    my $class_meta_for = _get_class_meta();

    $class_meta_for->{$class} ||= { };
    return $class_meta_for->{$class};
}

sub get_options_for {
    my ($self, $the_class, $initial_options) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;
    my $options_for = _get_options();
    
    $initial_options ||= { };

    # Must be a copy of the options because it probably
    # comes from %Class::Dot::Policy::DEFAULT_OPTIONS, so if we
    # just use that reference all class options will be
    # the same as the last class initialized.
    $options_for->{$class} ||= { %{$initial_options} };

    return $options_for->{$class};
}

sub set_options_for {
    my ($self, $class, $options_ref) = @_;
    return if not ref $options_ref;
    return if not ref $options_ref eq 'HASH';
    my $options_for = _get_options();

    $options_for->{$class} = $options_ref;
    return;
}

sub get_metaclass_for {
    my ($self, $the_class) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;
    my $metaclass_for = _get_metaclasses();

    if (! exists $metaclass_for->{$class}) {
        $self->init_metaclass_for($class);
    }

    return $metaclass_for->{$class};
}

sub init_metaclass_for {
    my ($self, $the_class, $metaclass, $options_ref) = @_;
    my $class = ref $the_class ? ref $the_class
        : $the_class;
    my $metaclass_for = _get_metaclasses();

    if (not defined $metaclass) {
        $metaclass = $DEFAULT_METACLASS;
    }

    if (! require_class($metaclass)) {
        croak "!!! COULD NOT LOAD METACLASS $metaclass FOR CLASS $class !!!";
    }

    # -override gets priority over -optimized.
    if ($options_ref->{'-override'}) {
        $options_ref->{'-optimized'} = 0;
    };

    my %metaclass_options  = %{ $options_ref };
    $metaclass_options{for_class} = $class;
    
    my $metaclass_instance = $metaclass->new(\%metaclass_options);
    $metaclass_for->{$class} = $metaclass_instance;

    return $metaclass_instance;
}

1;

__END__

=begin wikidoc

= NAME

Class::Dot::Registry - Class registry.

= VERSION

This document describes Class::Dot version %%VERSION%%

= SYNOPSIS

    use Class::Dot::Registry;

    my $REGISTRY = Class::Dot::Registry->new();

= DESCRIPTION

*WARNING*:
This is a module used internally by [Class::Dot]. If you are not hacking on
any internals you are most likely better off using the interfaces that uses
this module than using it directly.

Please see [Class::Dot] and [Class::Dot::Manual].


Ok. Now that we got that out of the way; If you are still here you probably
wonder what this module do? This module keeps track of metadata for the
classes that is under [Class::Dot]'s control. Metadata include things like
class options, attribute settings, class finalization status, ISA caches and
so on. [Class::Dot] uses this module to store and manipulate this information

= SUBROUTINES/METHODS

== CLASS CONSTRUCTOR

=== {new()}

This will return the global class registry as the registry is a singleton

Example:

    my $REGISTRY = Class::Dot::Registry->new();

== INSTANCE METHODS

=== {is_class_registered($class})

Returns true if the class is a [Class::Dot] class.

=== {register_class($class)}

Register the class as a [Class::Dot] class.

=== {get_metaclass_for($class)}

Returns the metaclass instance for {$class}.

This is a instance of the class that was set with the
{-metaclass} class option.

If the class is not a {Class::Dot} class it will still return
an instance of the default metaclass, this is for interoperability with
other object systems (or no object system at all).

If you want to see if a class is a {Class::Dot} class first you can
do this:

    my $is_dotified = $REGISTRY->is_class_registered($class);

Examples:

    # Get the metaclass instance for $class
    my $metaclass = $REGISTRY->get_metaclass_for($class);

    # Get the class name of the metaclass for $class
    my $metaclass_name = ref $REGISTRY->get_metaclass_for($class);

=== {init_metaclass_for($class, $metaclass, $class_options)}

Init the metaclass for {$class} by creating a new instance of {$metaclass}
with options {$class_options}.

This is done when you import [Class::Dot] to your package, so unless
you are working on the internals of Class::Dot or (my god) changing
metaclasses at runtime, you should probably leave this alone.

=== {get_options_for($class)}

Get the global class options for {$class} as a hash reference.

Remember that attributes can overwrite these options in
{$self->__meta__($attribute_name)} to specify separate options
for a single attribute. These are just the class defaults.

Examples:

    my $class_options = $REGISTRY->get_options_for($class);
    
    my $is_constrained = $class_options->{'-constrained'};

=== {set_options_for($class, $options_ref)}

Set the options for {$class} to the new hash reference {$options_ref}.
This will not merge with the previous options, but *overwrite the previous
options with the new ones*.


=== {get_meta_for($class)}

Returns the data structure containing the meta data
for {$class}.

=== {get_isa_cache_for($class)}

Returns the current isa cache for {$class}, but *only if
the class is finalized*.

Returns nothing if {$class} is not finalized,
else it returns the isa cache as a hash reference.

=== {update_isa_cache_for($class, $isa_cache)}

Update the isa cache for {$class} with the new isa cache {$isa_cache}.
This will not fetch the isa cache, you will have to do that manually.
See {finalize_class($class, $isa_cache)}.

You probably want [Class::Dot|finalize_class($class)].

=== {is_finalized($class)}

Returns true if {$class} is finalized.

=== {finalize_class($class, $isa_cache)}

Finalizes the class. You must also give the isa cache, if not
there is not much point in finalizing the class.

You probably want [Class::Dot|finalize_class($class)] instead.

Example finalizing the class {$class}:

    my $REGISTRY  = Class::Dot::Registry->new();
    my $metaclass = $REGISTRY->get_metaclass_for($class);
    my $isa_cache = $metaclass->property->traverse_isa_for_property($class);
    $REGISTRY->finalize_class($class, $isa_cache);

== PRIVATE CLASS METHODS

These are very private methods, and are very likely to change
in the near future, so please stay away from these. They are
only used internally in this class, and it will violate
data privacy and coupling if any of these methods are used
outside of this class.

=== {_get_class_meta()}

Get direct access to the meta registry for all classes.

=== {_get_finalized()}

Get direct access to the status of which classes are finalized.

=== {_get_isa_cache()}

Get direct access to the isa cache for all classes.

=== {_get_metaclasses()}

Get direct access to the map of metaclasses.

=== {_get_options()}

Get direct access to all classes options.

=== {_get_registered_classes)}

Get direct access to the list of which classes are registered.

= DIAGNOSTICS

== {!!! COULD NOT LOAD METACLASS %s FOR CLASS %s !!!}

You have probably set a custom metaclass for the class with the {-metaclass}
option, but when we tried to load this class it could not be found.

Maybe you have a typo in the metaclass name? Or the class is not installed, or
is not in the path where perl looks for modules. ({@INC}).

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [version]

* [Class::Plugin::Util]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

= SEE ALSO

== [Class::Dot]

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
    
