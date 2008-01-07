# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package devel::Generator::Typemap;

use strict;
use warnings;
use version;
use 5.00600;

use Carp    qw(carp croak);
use English qw(-no_match_vars);

our $AUTHORITY = 'cpan:ASKSH';
our $VERSION   = qv('2.0.0_10');

my @ALWAYS_EXPORT = qw(typedef class stdtypes output type alias WRITE_TYPES);

my %TYPES;
my %ALIASES;
my @STDTYPES;
my $OUTPUT;
my $CLASS;

sub class {
    ($CLASS)  = @_;
    return;
}

sub output {
    ($OUTPUT) = @_;
    return;     
}

sub stdtypes (@) {
    @STDTYPES = @_;
    return;
}

sub import {
    my ($this_class, @tags) = @_;
    my $caller_class = caller 0;

    no strict 'refs'; ## no critic

    for my $sub (@ALWAYS_EXPORT) {
        *{ "$caller_class\::$sub" } = *{ "$this_class\::$sub" };
    }

    return;
}
    
sub type (&;) { ## no critic
    my ($code_ref) = @_;
    return $code_ref;
}    

sub typedef {
    my ($type_name, $type_data) = @_;

    my %type_data = $type_data->();

    $TYPES{$type_name} = \%type_data;

    return;
} 

sub alias {
    my ($alias, $points_to) = @_;

    $ALIASES{$alias} = $points_to;    

    return;
}

sub _get_linear_isa_for_type {
    my ($first_type) = @_;
    my $type = $first_type;

    my @state;

    my %seen;
    while ('Infinity') {
        last if not defined $type;
        last if not exists $TYPES{$type};
        last if not ref $TYPES{$type} && ref $TYPES{$type} eq 'HASH';

        push @state, $type;

        last if not exists $TYPES{$type}{isa};
       
        $type = $TYPES{$type}{isa};
        if ($seen{$type}++) {
            croak "Recursive ISA not allowed for type: $first_type";
        }
    }
         
    return @state;
}

sub _isa_lookup {
    my ($type, $field) = @_;

    my @isa = _get_linear_isa_for_type($type);

    for my $item (@isa) {
        if ($type eq 'String') {
            print "Considering $item\n";
        }
        next if not defined $item;
        print "is defined $item\n" if $type eq 'String';
        next if not exists $TYPES{$item};
        print "is a type $item\n" if $type eq 'String';
        next if not ref $TYPES{$item} && ref $TYPES{$item} eq 'HASH';
        print "is a hash $item $TYPES{$item}{$field}\n" if $type eq 'String';
        next if not exists $TYPES{$item}{$field};

        if ($type eq 'String') {
        print "FOUND field [$field] for type [$type] in parent [$item]\n";
        }
        return $TYPES{$item}{$field};
    }
        
}

sub _pexpr_require_module {
    my ($require_module) = @_;
    (my $filename = $require_module . q{.pm} ) =~ s{::}{/}xmsg;
    return qq/ if (!\$INC{'$filename'}) { require $require_module };\n/;
}

sub WRITE_TYPES {

    my $out;

    my %sections;
    my $cur_section;
    LINE:
    while (my $line = <DATA> ) {
        chomp $line;
        if ($line =~ m/^_+\[(.+?)\]_+\s*$/xms) {
            $cur_section = $1;
            next LINE;
        }
        if ($cur_section) {
            $sections{$cur_section} .= $line . "\n";
        }
    }

    my $rcs_keywords =  $sections{'rcs_keywords'};
    $rcs_keywords    =~ s{%%}{\$}xmsg;
    $out .= $rcs_keywords;
   
    $out .= qq{package $CLASS;\n}; 
    $out .= $sections{'preample'};

    
    
    $out .= q{# ------ TYPES REQUIRE MODULES ----- #} . "\n";
    my %required_seen;
    MODULE:
    for my $curtype (values %TYPES) {
        next MODULE if not exists $curtype->{requires};
        my $require_module = $curtype->{requires};
        next MODULE if exists $required_seen{$require_module};
        $required_seen{$require_module}++;
        $out .= _pexpr_require_module($require_module);
    }
    $out .= "\n\n";

    $out .= q{# --------- STANDARD TYPES --------- #} . "\n";
    $out .= q{our @STD_TYPES = qw(} . "\n";
    $out .= q{ } x 4 . join(q{ }, map { "isa_$_" } @STDTYPES) . "\n";
    $out .= q{);}.  "\n";
    $out .= q{my @EXPORT_OK = @STD_TYPES;}. "\n";
    $out .= <<'EOFCODE'
my %EXPORT_CLASS = (
    ':std'  => [@EXPORT_OK],
);
EOFCODE
;
    $out .= "\n\n";
    

    $out .= q{# ------------ ALIASES ------------- #} . "\n";
    $out .= q{our %__TYPEALIASES__ = (} . "\n";
    while (my ($pointer, $dest) = each %ALIASES) {
        $out .= qq{    '$pointer' => '$dest',\n};
    }
    $out .= qq{);\n\n};
    
    $out .= q{# ------------ COMPAT -------------- #} . "\n";
    $out .= q{our %__COMPAT_TYPESUBS__ = (} . "\n";
    while (my ($name, $data) = each %TYPES) {
        my $prototype = exists $data->{prototype} ? "($data->{prototype})"
            : q{};
        $out .= <<"EOFCODE"
       'isa_$name' => sub $prototype {
            my \$real_sub = \$__TYPEDICT__{'$name'};
            goto &{ \$real_sub };
        },
EOFCODE
;
    }
    $out .= qq{);\n\n};

    $out .= q{# ------------ TYPES -------------- #} . "\n";
    $out .= q{our %__TYPEDICT__ = (} . "\n";
    while (my ($name, $data) = each %TYPES) {
        my @lin_isa   = _get_linear_isa_for_type($name);
        my $isa_str   = q{qw(} . join(q{ }, @lin_isa) . q{)};
        my $prototype = exists $data->{prototype} ? "($data->{prototype})"
            : q{};
        my $constraint = _isa_lookup($name, 'constraint')    || q{};
        my $defval_gen = _isa_lookup($name, 'default_value') || q{};
        $out .= <<"EOFCODE"

    '$name' => (subname '\${PKG}::create_type_$name' => sub $prototype { ## no critic
        my (\@args) = \@_;

        my \$generator = subname "\${PKG}::isa_$name\_defval" => sub {
$defval_gen
        };

        my \$constraint = subname "\${PKG}::isa_$name\_check" => sub {
$constraint
        };

        return create_type_instance(
            '$name', \$generator, \$constraint,
            [$isa_str],
        );
    }),
EOFCODE
;
    }
    $out .= qq{);\n\n};

    $out .= $sections{'import'};
    $out .= $sections{'functions'};
    $out .= $sections{'instance_methods'};
    $out .= $sections{'postample'};
    $out .= $sections{'documentation'};

    my $out_fh;
    if (defined $OUTPUT) {
        open $out_fh, '>', $OUTPUT
            or croak "Couldn't open $OUTPUT for writing: $OS_ERROR\n";
    }
    else {
        $out_fh = \*STDERR;
    }

    print {$out_fh} $out;

    if (defined $OUTPUT) {
        close $out_fh
            or croak "Couldn't close $OUTPUT after writing: $OS_ERROR\n";
    }
}

1;

__DATA__
_________________________________[rcs_keywords]______________________________
# %%Id%%
# %%Source%%
# %%Author%%
# %%HeadURL%%
# %%Revision%%
# %%Date%%
________________________________[preample]___________________________________
# ##### !!!!! WARNING !!!!!! ################################################
# 
# This module is generated automatically by the Typemap program in the top
# of the Class::Dot distribution, so any changes to this file will be lost!
#
#############################################################################

use strict;
use warnings;
use version;
use 5.00600;
use vars qw(%__TYPEDICT__);

our $AUTHORITY = 'cpan:ASKSH';
our $VERSION   = qv('2.0.0_10');

use Carp        qw(confess carp croak);

use Class::Dot::Type;

use Class::Dot::Devel::Sub::Name;

use Class::Dot::Meta::Class;
use Class::Dot::Meta::Type   qw(create_type_instance);
use Class::Dot::Meta::Method qw(
    install_sub_from_class
    install_sub_from_coderef
);

my $PKG = __PACKAGE__;

__________________________________[import]___________________________________

my @ALWAYS_EXPORT = qw(
    find_type_constraint
);

sub import {
    my ($this_class, @tags) = @_;
    my $caller_class = caller 0;

    my $export_class;
    my @subs;
    for my $arg (@tags) {
        if ($arg =~ m/^:/xms) {
            croak('Only one export class can be used. ',
                "(Used already: [$export_class] now: [$arg])")
            if $export_class;

            $export_class = $arg;
        }
        else {
            push @subs, $arg;
        }
    }

    my @subs_to_export
        = $export_class && $EXPORT_CLASS{$export_class}
        ? (@{ $EXPORT_CLASS{$export_class}}, @subs)
        : @subs;

    no strict 'refs'; ## no critic
    for my $sub_to_export (@subs_to_export) {
        (my $type = $sub_to_export) =~ s/^isa_//xms;

        my $real_name = $sub_to_export;
        if (exists $__TYPEALIASES__{$type}) {
            $real_name = q{isa_} . $__TYPEALIASES__{$type};
        }

        my $the_subref = $__COMPAT_TYPESUBS__{$real_name};
        if (! defined $the_subref) {
            croak "There is no $sub_to_export for type $type";
        }

        install_sub_from_coderef($the_subref => $caller_class, $sub_to_export);
    }
    for my $sub_to_export (@ALWAYS_EXPORT) {
        install_sub_from_class($this_class, $sub_to_export => $caller_class);
    }

    return;
}

__________________________________[functions]________________________________

sub find_type_constraint {
    my ($type_name, @defaults) = @_;
    my $self = __PACKAGE__;

    my $lazy_type_init = $self->get_type($type_name);
    my $type = $lazy_type_init->(@defaults);

    return $type;
}

__________________________________[instance_methods]_________________________

sub get_type {
    my ($self, $type_name) = @_;

    if (exists $__TYPEALIASES__{$type_name}) {
        $type_name = $__TYPEALIASES__{$type_name};
    }

    return if not exists $__TYPEDICT__{$type_name};
    return $__TYPEDICT__{$type_name};
}

sub get_compiled_constraint {
    my ($self, $type_name) = @_;
    confess "Unknown type: $type_name"
        if not exists $__TYPEDICT__{$type_name};

    my $lazy_type_init = $__TYPEDICT__{$type_name};
    my $type       = $lazy_type_init->();
    my $constraint = $type->constraint();

    my $check_constraint = sub {
        return 1 if $constraint->(@_);
        return;
    };

    return $check_constraint;
}

sub get_types {
    return keys %__TYPEDICT__;
}

sub type_constraints {
    my ($self) = @_;

    my %constraints;
    for my $type_name ($self->get_types) {
        $constraints{$type_name} = $self->get_compiled_constraint($type_name);
    }

    while (my ($a_name, $a_dest) = each %__TYPEALIASES__) {
        $constraints{$a_name} = $self->get_compiled_constraint($a_dest);
    }

    return \%constraints;
}

sub export_type_constraints_as_functions {
    my ($self) = @_;
    my $caller_class = caller 0;

    no strict 'refs'; ## no critic
    my $type_constraints = $self->type_constraints;
    while (my ($type, $constraint) = each %{ $type_constraints }) {
        *{ "$caller_class\::$type" } = $constraint;
    }

    return;
}

sub _is_valid_class_name {
    my ($class) = @_;
    return if ref $class;
    return if !defined $class || !length $class;

    no strict 'refs'; ## no critic

    # check if the symbol entry exists at all.
    my $pack = \*::;
    for my $part (split q{::}, $class) {
        return if not exists ${$$pack}{"$part\::"};
        $pack = \*{ ${$$pack}{"$part\::"} };
    }

    # It's already loaded if $VERSION or @ISA is defined in the
    # class.
    return 1 if defined ${"${class}::VERSION"};
    return 1 if defined @{"${class}::ISA"};

    # It's also loaded if we find a function in that class.
    METHOD:
    for my $namespace_entry (keys %{"${class}::"}) {
        if (substr($namespace_entry, -2, 2) eq q{::}) {
            # It's a subclass, so skip it.
            next METHOD;
        }
        return 1 if defined &{"${class}::$namespace_entry"};
    }

    # fail
    return;
}
    
    

___________________________________[postample]_______________________________

1;
__END__

__________________________________[documentation]____________________________

=begin wikidoc

= NAME

Class::Dot::Typemap - Standard Type Constraints (Autogenerated)

= VERSION

This document describes {Class::Dot} version %%VERSION%%

= SYNOPSIS

   use Class::Dot::Typemap;

    # Get the type instance for a type
    my $type = find_type_constraint($type_name);

    # Resolve any aliases for a type name.
    $type_name = Class::Dot::Typemap->get_type($type_name)}

    # Get a subroutien ref to a function to check the type constraint. 
    my $check_constraint = Class::Dot::Typemap->get_compiled_constraint($type_name)
    my $is_valid_value   = 1 if $check_constraint->($value);

    # Get a list of the name for all standard types.
    my @std_types = Class::Dot::Typemap->get_types()

    # Get a hash of all type constraints.
    my %constraints = %{ Class::Dot::Typemap->type_constraints() };

    # Export all type constraints as functions to the current package.
    Class::Dot::Typemap->export_tyoe_constraints_as_functions();

    my $is_string  = String("hello");
    my $is_int     = Int(1000);
    my $is_not_int = Int(100.3);

= DESCRIPTION

This is the map of standard type constraints.

*WARNING* This file is generated automatically by the {Typemap} program in the top
of the Class::Dot distribution, so any changes to this file will be lost.

= SUBROUTINES/METHODS

== CLASS METHODS

=== {find_type_constraint($type_name, [@default_values])}

Get the type instance for a type by name.
(Will be initialized with {@default_value} if given.)

== INSTANCE METHODS

=== {get_type($type_name)}

Get the real type name for any type name..
(Resolve aliases).

=== {get_compiled_constraint($type_name})

Get a function that can check if a value conforms to the
type constraint {$type_name}.

Example:

    my $check_constraint = Class::Dot::Typemap->get_compiled_constraint('String');
    ok( $check_constraint->("hello world"), 'string is a string' );
    ok(not $check_constraint->([]), 'refernce to array is not a string');

=== {get_types()}

Get a list of names for all standard type constraints.

=== {type_constraints()}

Get a hash with all standard type constraints.
The key is the name and the value is the reference to the constraint checking
function.

=== {export_type_constraints_as_functions()}

Exports all type constraints as functions in the caller namespace with the
type name as the name of the function.

E.g: String becomes String(), Int becomes Int() etc.

Example:
    Class::Dot::Typemap->export_tyoe_constraints_as_functions();
    ok( String("hello world"), 'string is a string' );
    ok(not String([]), 'refernce to array is not a string');

= DIAGNOSTICS

== {Unknown type: %s}

There is no type with that name.

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [Class::Dot]

* [version]

* [Params::Util]

* [Scalar::Util]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
[bug-class-dot@rt.cpan.org|mailto:bug-class-dot@rt.cpan.org], or through the
web interface at [CPAN Bug tracker|http://rt.cpan.org].

= SEE ALSO

== [Class::Dot::Type]

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
{export_type_constraints_as_functions()}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
