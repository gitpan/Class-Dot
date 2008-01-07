# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Typemap;
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

# ------ TYPES REQUIRE MODULES ----- #
 if (!$INC{'Scalar/Util.pm'}) { require Scalar::Util };


# --------- STANDARD TYPES --------- #
our @STD_TYPES = qw(
    isa_String isa_Int isa_Array isa_Hash isa_Data isa_Object isa_Code isa_File isa_Bool isa_Regex
);
my @EXPORT_OK = @STD_TYPES;
my %EXPORT_CLASS = (
    ':std'  => [@EXPORT_OK],
);


# ------------ ALIASES ------------- #
our %__TYPEALIASES__ = (
    'Num' => 'Number',
    'Regex' => 'Regexp',
    'RegexRef' => 'RegexpRef',
    'FileHandle' => 'File',
    'Str' => 'String',
);

# ------------ COMPAT -------------- #
our %__COMPAT_TYPESUBS__ = (
       'isa_ScalarRef' => sub  {
            my $real_sub = $__TYPEDICT__{'ScalarRef'};
            goto &{ $real_sub };
        },
       'isa_Any' => sub  {
            my $real_sub = $__TYPEDICT__{'Any'};
            goto &{ $real_sub };
        },
       'isa_Regexp' => sub  {
            my $real_sub = $__TYPEDICT__{'Regexp'};
            goto &{ $real_sub };
        },
       'isa_Item' => sub  {
            my $real_sub = $__TYPEDICT__{'Item'};
            goto &{ $real_sub };
        },
       'isa_Number' => sub  {
            my $real_sub = $__TYPEDICT__{'Number'};
            goto &{ $real_sub };
        },
       'isa_Object' => sub  {
            my $real_sub = $__TYPEDICT__{'Object'};
            goto &{ $real_sub };
        },
       'isa_GlobRef' => sub  {
            my $real_sub = $__TYPEDICT__{'GlobRef'};
            goto &{ $real_sub };
        },
       'isa_Data' => sub  {
            my $real_sub = $__TYPEDICT__{'Data'};
            goto &{ $real_sub };
        },
       'isa_ClassName' => sub  {
            my $real_sub = $__TYPEDICT__{'ClassName'};
            goto &{ $real_sub };
        },
       'isa_Defined' => sub  {
            my $real_sub = $__TYPEDICT__{'Defined'};
            goto &{ $real_sub };
        },
       'isa_Bool' => sub  {
            my $real_sub = $__TYPEDICT__{'Bool'};
            goto &{ $real_sub };
        },
       'isa_Undef' => sub  {
            my $real_sub = $__TYPEDICT__{'Undef'};
            goto &{ $real_sub };
        },
       'isa_Array' => sub  {
            my $real_sub = $__TYPEDICT__{'Array'};
            goto &{ $real_sub };
        },
       'isa_Ref' => sub  {
            my $real_sub = $__TYPEDICT__{'Ref'};
            goto &{ $real_sub };
        },
       'isa_String' => sub  {
            my $real_sub = $__TYPEDICT__{'String'};
            goto &{ $real_sub };
        },
       'isa_Code' => sub (;&;) {
            my $real_sub = $__TYPEDICT__{'Code'};
            goto &{ $real_sub };
        },
       'isa_CodeRef' => sub  {
            my $real_sub = $__TYPEDICT__{'CodeRef'};
            goto &{ $real_sub };
        },
       'isa_RegexpRef' => sub  {
            my $real_sub = $__TYPEDICT__{'RegexpRef'};
            goto &{ $real_sub };
        },
       'isa_Value' => sub  {
            my $real_sub = $__TYPEDICT__{'Value'};
            goto &{ $real_sub };
        },
       'isa_Int' => sub  {
            my $real_sub = $__TYPEDICT__{'Int'};
            goto &{ $real_sub };
        },
       'isa_HashRef' => sub  {
            my $real_sub = $__TYPEDICT__{'HashRef'};
            goto &{ $real_sub };
        },
       'isa_ArrayRef' => sub  {
            my $real_sub = $__TYPEDICT__{'ArrayRef'};
            goto &{ $real_sub };
        },
       'isa_File' => sub  {
            my $real_sub = $__TYPEDICT__{'File'};
            goto &{ $real_sub };
        },
       'isa_Hash' => sub  {
            my $real_sub = $__TYPEDICT__{'Hash'};
            goto &{ $real_sub };
        },
       'isa_Role' => sub  {
            my $real_sub = $__TYPEDICT__{'Role'};
            goto &{ $real_sub };
        },
);

# ------------ TYPES -------------- #
our %__TYPEDICT__ = (

    'ScalarRef' => (subname '${PKG}::create_type_ScalarRef' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_ScalarRef_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_ScalarRef_check" => sub {

            ref $_[0] eq "SCALAR";
        
        };

        return create_type_instance(
            'ScalarRef', $generator, $constraint,
            [qw(ScalarRef Ref Defined Item)],
        );
    }),

    'Any' => (subname '${PKG}::create_type_Any' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Any_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Any_check" => sub {

        1
    
        };

        return create_type_instance(
            'Any', $generator, $constraint,
            [qw(Any)],
        );
    }),

    'Regexp' => (subname '${PKG}::create_type_Regexp' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Regexp_defval" => sub {

        my ($default_regex) = @args;
        return defined $default_regex && ref $default_regex eq 'Regexp'
            ? $default_regex
            : qr{\A\z}xms
    
        };

        my $constraint = subname "${PKG}::isa_Regexp_check" => sub {

            ref $_[0] eq "Regexp";
        
        };

        return create_type_instance(
            'Regexp', $generator, $constraint,
            [qw(Regexp RegexpRef Ref Defined Item)],
        );
    }),

    'Item' => (subname '${PKG}::create_type_Item' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Item_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Item_check" => sub {

        1
    
        };

        return create_type_instance(
            'Item', $generator, $constraint,
            [qw(Item)],
        );
    }),

    'Number' => (subname '${PKG}::create_type_Number' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Number_defval" => sub {

        my ($default_value) = @args;
        return $default_value
            if defined $default_value;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Number_check" => sub {

        !ref $_[0] && Scalar::Util::looks_like_number( $_[0] );
    
        };

        return create_type_instance(
            'Number', $generator, $constraint,
            [qw(Number Value Defined Item)],
        );
    }),

    'Object' => (subname '${PKG}::create_type_Object' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Object_defval" => sub {

        my $class = shift @args;
        return if not defined $class;

        my %opts;
        if (!scalar @args % 2) {
            %opts = @args;
        }

        if (delete $opts{auto}) {
            return $class->new({%opts});
        }

        return;
    
        };

        my $constraint = subname "${PKG}::isa_Object_check" => sub {

        my $blessed = Scalar::Util::blessed($_[0]);
        $blessed && $blessed ne 'Regexp';
    
        };

        return create_type_instance(
            'Object', $generator, $constraint,
            [qw(Object Ref Defined Item)],
        );
    }),

    'GlobRef' => (subname '${PKG}::create_type_GlobRef' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_GlobRef_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_GlobRef_check" => sub {

            ref $_[0] eq "GLOB";
        
        };

        return create_type_instance(
            'GlobRef', $generator, $constraint,
            [qw(GlobRef Ref Defined Item)],
        );
    }),

    'Data' => (subname '${PKG}::create_type_Data' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Data_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Data_check" => sub {

        1
    
        };

        return create_type_instance(
            'Data', $generator, $constraint,
            [qw(Data)],
        );
    }),

    'ClassName' => (subname '${PKG}::create_type_ClassName' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_ClassName_defval" => sub {

        };

        my $constraint = subname "${PKG}::isa_ClassName_check" => sub {

        _is_valid_class_name($_[0]);
    
        };

        return create_type_instance(
            'ClassName', $generator, $constraint,
            [qw(ClassName)],
        );
    }),

    'Defined' => (subname '${PKG}::create_type_Defined' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Defined_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Defined_check" => sub {

        defined $_[0];
    
        };

        return create_type_instance(
            'Defined', $generator, $constraint,
            [qw(Defined Item)],
        );
    }),

    'Bool' => (subname '${PKG}::create_type_Bool' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Bool_defval" => sub {

        my ($default_value) = @args;
        return $default_value ? 1 : 0
    
        };

        my $constraint = subname "${PKG}::isa_Bool_check" => sub {

        !defined $_[0] || $_[0] eq q{} || "$_[0]" eq '1' || "$_[0]" eq '0';

    
        };

        return create_type_instance(
            'Bool', $generator, $constraint,
            [qw(Bool Item)],
        );
    }),

    'Undef' => (subname '${PKG}::create_type_Undef' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Undef_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Undef_check" => sub {

        !defined $_[0];
    
        };

        return create_type_instance(
            'Undef', $generator, $constraint,
            [qw(Undef Item)],
        );
    }),

    'Array' => (subname '${PKG}::create_type_Array' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Array_defval" => sub {

        my @default_values = @args;
        return scalar @default_values ? \@default_values
            : [ ];
    
        };

        my $constraint = subname "${PKG}::isa_Array_check" => sub {

            ref $_[0] eq "ARRAY";
        
        };

        return create_type_instance(
            'Array', $generator, $constraint,
            [qw(Array ArrayRef Ref Defined Item)],
        );
    }),

    'Ref' => (subname '${PKG}::create_type_Ref' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Ref_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Ref_check" => sub {

        ref $_[0];
    
        };

        return create_type_instance(
            'Ref', $generator, $constraint,
            [qw(Ref Defined Item)],
        );
    }),

    'String' => (subname '${PKG}::create_type_String' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_String_defval" => sub {

        my ($default_value) = @args;
        return $default_value
            if defined $default_value;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_String_check" => sub {

        defined($_[0]) && !ref($_[0]);
    
        };

        return create_type_instance(
            'String', $generator, $constraint,
            [qw(String Value Defined Item)],
        );
    }),

    'Code' => (subname '${PKG}::create_type_Code' => sub (;&;) { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Code_defval" => sub {

        my ($default_coderef) = @args;
        return defined $default_coderef ? $default_coderef
            : subname 'lambda-nil' => sub { };
    
        };

        my $constraint = subname "${PKG}::isa_Code_check" => sub {

            ref $_[0] eq "CODE";
        
        };

        return create_type_instance(
            'Code', $generator, $constraint,
            [qw(Code CodeRef Ref Defined Item)],
        );
    }),

    'CodeRef' => (subname '${PKG}::create_type_CodeRef' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_CodeRef_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_CodeRef_check" => sub {

            ref $_[0] eq "CODE";
        
        };

        return create_type_instance(
            'CodeRef', $generator, $constraint,
            [qw(CodeRef Ref Defined Item)],
        );
    }),

    'RegexpRef' => (subname '${PKG}::create_type_RegexpRef' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_RegexpRef_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_RegexpRef_check" => sub {

            ref $_[0] eq "Regexp";
        
        };

        return create_type_instance(
            'RegexpRef', $generator, $constraint,
            [qw(RegexpRef Ref Defined Item)],
        );
    }),

    'Value' => (subname '${PKG}::create_type_Value' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Value_defval" => sub {

        my ($default_value) = @args;
        return $default_value
            if defined $default_value;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Value_check" => sub {

        defined $_[0] && !ref $_[0];
    
        };

        return create_type_instance(
            'Value', $generator, $constraint,
            [qw(Value Defined Item)],
        );
    }),

    'Int' => (subname '${PKG}::create_type_Int' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Int_defval" => sub {

        my ($default_value) = @args;
        return $default_value
            if defined $default_value;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_Int_check" => sub {

        defined $_[0] && !ref $_[0] && $_[0] =~ m/^-?[0-9]+$/xms;
    
        };

        return create_type_instance(
            'Int', $generator, $constraint,
            [qw(Int Number Value Defined Item)],
        );
    }),

    'HashRef' => (subname '${PKG}::create_type_HashRef' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_HashRef_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_HashRef_check" => sub {

            ref $_[0] eq "HASH";
        
        };

        return create_type_instance(
            'HashRef', $generator, $constraint,
            [qw(HashRef Ref Defined Item)],
        );
    }),

    'ArrayRef' => (subname '${PKG}::create_type_ArrayRef' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_ArrayRef_defval" => sub {

        return wantarray ? @args : $args[0]
            if scalar @args;
        return;
    
        };

        my $constraint = subname "${PKG}::isa_ArrayRef_check" => sub {

            ref $_[0] eq "ARRAY";
        
        };

        return create_type_instance(
            'ArrayRef', $generator, $constraint,
            [qw(ArrayRef Ref Defined Item)],
        );
    }),

    'File' => (subname '${PKG}::create_type_File' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_File_defval" => sub {

        my ($default_value) = @args;

        return $default_value
            if defined $default_value;

        if (! $INC{'FileHandle.pm'}) {
            require FileHandle;
        }
        return FileHandle->new();
    
        };

        my $constraint = subname "${PKG}::isa_File_check" => sub {

        ref $_[0] eq 'GLOB' && Scalar::Util::openhandle($_[0]);
    
        };

        return create_type_instance(
            'File', $generator, $constraint,
            [qw(File GlobRef Ref Defined Item)],
        );
    }),

    'Hash' => (subname '${PKG}::create_type_Hash' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Hash_defval" => sub {

        my %default_values = @args;
        return scalar keys %default_values ? \%default_values
            : { };

        # have to test if there are any entries in the hash
        # so we return a new anonymous hash if it ain't.
    
        };

        my $constraint = subname "${PKG}::isa_Hash_check" => sub {

            ref $_[0] eq "HASH";
        
        };

        return create_type_instance(
            'Hash', $generator, $constraint,
            [qw(Hash HashRef Ref Defined Item)],
        );
    }),

    'Role' => (subname '${PKG}::create_type_Role' => sub  { ## no critic
        my (@args) = @_;

        my $generator = subname "${PKG}::isa_Role_defval" => sub {

        my $class = shift @args;
        return if not defined $class;

        my %opts;
        if (!scalar @args % 2) {
            %opts = @args;
        }

        if (delete $opts{auto}) {
            return $class->new({%opts});
        }

        return;
    
        };

        my $constraint = subname "${PKG}::isa_Role_check" => sub {

        Scalar::Util::blessed($_[0]) && $_[0]->can('does')
    
        };

        return create_type_instance(
            'Role', $generator, $constraint,
            [qw(Role Object Ref Defined Item)],
        );
    }),
);


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


sub find_type_constraint {
    my ($type_name, @defaults) = @_;
    my $self = __PACKAGE__;

    my $lazy_type_init = $self->get_type($type_name);
    my $type = $lazy_type_init->(@defaults);

    return $type;
}


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
    
    


1;
__END__


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
