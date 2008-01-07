# $Id$
# $Source: /opt/CVS/Getopt-LL/lib/Class/Dot.pm,v $
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot;

use strict;
use warnings;
use version qw(qv);
use 5.006000;

our $VERSION   = qv('2.0.0_10');
our $AUTHORITY = 'cpan:ASKSH';

# Set to true if Class::Dot::XS loads OK.
use vars qw($XSokay); ## no critic

use Carp                qw(carp croak confess);
use Scalar::Util        qw(blessed);
use Class::Plugin::Util qw(require_class);
use English             qw(-no_match_vars);
use Params::Util        qw(_HASHLIKE);

use Class::Dot::Typemap            qw(:std);

# The global registry.
use Class::Dot::Registry;
our $REGISTRY = Class::Dot::Registry->new();

use Class::Dot::Meta::Method     qw(
    install_sub_from_class
    install_sub_from_coderef
);
use Class::Dot::Meta::Type       qw(
    _NEWSCHOOL_TYPE _OLDSCHOOL_TYPE
);

use Class::Dot::Devel::Sub::Name qw(subname);

# Try to load the Class::Dot::XS speed-up module.
{
    no warnings 'all'; ## no critic
    $Class::Dot::XS::MAGIC_COOKIE = q{Knock. Knock. It's Class::Dot.};
    if (require_class('Class::Dot::XS')) {
        Class::Dot::XS->import();
    }
}

my @EXPORT_OK = qw(
    property after_property_set after_property_get
    extends composite has
);

push @EXPORT_OK, @Class::Dot::Typemap::STD_TYPES;

my %EXPORT_CLASS = (
    ':std'  => [@EXPORT_OK],
    ':new'  => [@EXPORT_OK, qw(-new)],
    ':fast' => [@EXPORT_OK, qw(-new -optimized)],
);

# The list of allowed option tags.
my %ALLOWED_CLASS_OPTIONS = map { $_ => 1 } qw(
    -new
    -rebuild
    -getter_prefix
    -setter_prefix
    -accessor_type
    -metaclass
    -constrained
    -chained
    -optimized
    -override
);

my %DEFAULT_OPTIONS = (
    '-getter_prefix' => q{},
    '-setter_prefix' => 'set_',
    '-metaclass'     => 'Class::Dot::Meta::Class',
    '-override'      => undef,
);

sub import { ## no critic
    my ($this_class, @args) = @_;
    my $caller_class        = caller;

    strict->import();
    warnings->import();

    return $this_class->_dotify_class($caller_class, @args);
}

sub _create_policy {
    my ($this_class, $push_policy_ref, @args) = @_;

    my %mapped_args = map { $_ => 1 } @args;
    for my $push_policy (@{ $push_policy_ref }) {
        $mapped_args{$push_policy} = 1;
    }
    @args = keys %mapped_args;

    return @args;
}

sub _dotify_class {
    my ($this_class, $caller_class, @args) = @_;

    my $export_class;
    my @subs;
    for my $arg (@args) {
        if ($arg =~ m/^:/xms) {
            croak(   'Only one export class can be used. '
                    ."(Used already: [$export_class] now: [$arg])")
                if $export_class;

            $export_class = $arg;
        }
        else {
            push @subs, $arg;
        }
    }

    my @subs_to_export
        = $export_class && $EXPORT_CLASS{$export_class}
        ? (@{ $EXPORT_CLASS{$export_class} }, @subs)
        : @subs;

    my $options = $REGISTRY->get_options_for(
        $caller_class, \%DEFAULT_OPTIONS
    );
    for my $sub_to_export (@subs_to_export) {
        if ($sub_to_export =~ m/^-/xms) {
            my $option = $sub_to_export;
            my $value = 1;
            # Can set values on the use-line with '=' assignment.
            if ($option =~ m/=/xms) {
                ($option, $value) = split m/=/xms, $option, 2;
            }
            croak __PACKAGE__.": Unknown class option: [$option]"
                if not exists $ALLOWED_CLASS_OPTIONS{$option};
            $options->{$option} = $value;
        }
        else {
            install_sub_from_class($this_class,
                $sub_to_export => $caller_class
            );
        }
    }

    # ### Register the class.
    $REGISTRY->register_class($caller_class);

    # ### Initialize metaclass for this class.
    if (! $options->{'-new'}) {
        $options->{'-no_constructor'} = 1;
    }

    my $metaclass = $REGISTRY->init_metaclass_for(
        $caller_class, $options->{'-metaclass'}, $options
    );

    return;
}

sub finalize_class {
    my ($opt_class) = @_;
    my $class = $opt_class ? $opt_class
        : caller 0;
    my $metaclass = $REGISTRY->get_metaclass_for($class);

    my $isa_cache =
        $metaclass->property->traverse_isa_for_property($class);

    return $REGISTRY->finalize_class($class, $isa_cache);
}

sub properties_for_class {
    my ($self, $class) = @_;
    my $metaclass = $REGISTRY->get_metaclass_for($class);
    
    return $metaclass->property->properties_for_class($class);
}

sub property (@) { ## no critic
    my ($property, @args) = @_;
    confess 'All properties needs a name!'
        if not defined $property;

    my $isa;

    # Decide what kind of args this is.
    # If it's a newschool type or it's only one arg it is
    # taken as the property's type.
    if (_NEWSCHOOL_TYPE($args[0]) || scalar @args == 1) {
        $isa = shift @args;
    }

    my %options;
    if (not scalar @args % 2) { # is even number.
        %options = @args;
    }
    elsif (_HASHLIKE($args[-1])) {
        %options    = %{$args[-1]};
    }

    if (defined $options{isa}) {
        $isa        = $options{isa};
        my $default = $options{default};
        if ($isa) {
            my $type_init = Class::Dot::Typemap->get_type($isa);
            confess "Unknown type constraint: $isa" if not $type_init;
            $isa = $type_init->($default);
        }
    }

    # Support Moose {is =>} syntax.
    $options{privacy} ||= $options{is};

    # Get privacy option
    if ($property =~ s/^-//xms) {
        $options{privacy}  = 'private';
    }

    my $caller_class = caller 0;
    my $metaclass    = $REGISTRY->get_metaclass_for($caller_class);

    return $metaclass->property->define_property(
        $property, $isa => $caller_class, {
            %options,
        }
    );
}

sub has ($;%) { ## no critic
    goto &property;
}

sub extends (@;) { ## no critic
    my (@superclasses) = @_;
    my $inheritor      = caller 0;
    my $meta_class     = $REGISTRY->get_metaclass_for($inheritor);

    return $meta_class->superclasses_for(
        $inheritor => @superclasses
    );
}

sub composite (@;) { ## no critic
    my ($name, $class) = @_;
    my $caller_class   = caller 0;
    my $metaclass      = $REGISTRY->get_metaclass_for($caller_class);

    return $metaclass->property->composites_for($caller_class, $name, $class);
};

sub after_property_get (@&) { ## no critic
    my ($property, $func_ref) = @_;
    my $caller_class = caller;

    my $class_meta  = $REGISTRY->get_meta_for($caller_class);
    my $getter_name = $class_meta->{$property}->getter_name();
    install_sub_from_coderef($func_ref => $caller_class, $getter_name);

    return;
}

sub after_property_set (@&) { ## no critic
    my ($property, $func_ref) = @_;
    my $caller_class = caller;

    my $class_meta  = $REGISTRY->get_meta_for($caller_class);
    my $setter_name = $class_meta->{$property}->setter_name();
    install_sub_from_coderef($func_ref => $caller_class, $setter_name);

    return;
}

1;

__END__

=begin wikidoc

= NAME

Class::Dot - Simple and fast properties for Perl 5.

= VERSION

This document describes Class::Dot version v2.0.0 (beta 4).

= SYNOPSIS

    package MyClass;
    # load standard types (:std) and install default constructor (-new).

    use Class::Dot qw(-new :std); # Automatically turns on strict and
                                  # warnings.

    # This class inherits from BaseClass.
    extends 'BaseClass';

    # This class has-a AnotherClass.
    composite another_class => 'AnotherClass'

    # Property without type.
    property 'attribute';

    # List of property types, doesn't need a default value.
    property string     => isa_String('default value');

    property integer    => isa_Int(256);

    property object     => isa_Object('MyApp::Controller');

    property hashref    => isa_Hash(foo => 1, bar => 2);
    
    property arrayref   => isa_Array(qw(the quick brown fox ...));

    property filehandle => isa_File()

    property code       => isa_Code { return 42 };

    property any_data   => isa_Data;

    # Object type that automatically creates new instance if it doesn't exist.
    property model      => isa_Object('MyApp::Model', auto => 1);

    # Initialize something at object construction.
    sub BUILD {
        my ($self, $options_ref) = @_;

        warn 'Creating a new object of type ', ref $self;

        return;
    }

    # Do something at object destruction.
    sub DEMOLISH {
        my ($self) = @_;

        warn 'Instance of class', ref $self, ' is going out of scope.';

        return;
    }

    # Re-bless instance at instance construction time. (option -rebuild)
    use Carp;
    use Class::Dot qw(-new -rebuild :std);
    use Class::Plugin::Util qw(require_class); # For dynamic loading of classes.

    sub BUILD {
        my ($self, $options_ref) = @_;

        if (exists $options_ref->{delegate_to}) {
            my $new_class    = $options_ref->{delegate_to};
            if (require_class($new_class)) {
                my $new_instance = $new_class->new();
                return $new_instance;
            }
            else {
                croak "Could not load class: $new_class"
            }
        }

        return;
    }

= DESCRIPTION

Simple and fast properties for Perl 5.

* Properties are fully overrideable (Even when set using {new({})}).

* Lets you define types for your properties, like Hash, String, Int, File, Code, Array and so on.

* Supports type constraints.

* Is not here to replace Moose, but can be used as a drop-in replacement for Moose to get
  better runtime performance. (does only support a small subset of Moose!)

All the types are populated with sane defaults, so you no longer have to
write code like this:

   sub make_healthy {
      my ($self) = @_;
      my $state  = $self->state;
      my $fur    = $self->fur;

      $state ||= { }; # <-- you don't have to do this with class dot.
          $fur   ||= [ ]; # <-- same with this.
   }

Class::Dot can also create a default constructor for you if you pass it the
{-new} option on the use line:

    use Class::Dot qw(-new :std);

If you pass a hashref to the constructor, it will use them as values for the
properties:

   my $cat = Animal::Mammal::Carnivorous::Cat->new({
        gender => 'male',
        fur    => ['black', 'white', 'short'],
   }


If you want to intialize something at object construction time you can! Just
define a method named {BUILD}. {Class::Dot} will pass on the instance and
all the arguments that was sent to {new}.

    sub BUILD {
        my ($self, $options_ref) = @_;

        warn 'Someone created a ', ref $self;

        return;
    }


The return value of the {BUILD} method doesn't mean anything, that is unleass
you have to {-rebuild} option on. When the {-rebuild} option is on,
{Class::Dot} uses the return value of BUILD as the new object, so you can
create a abstract factory or similar:

    use Class::Dot qw(-new -rebuild :std);

    sub BUILD {
        my ($self, $option_ref) = @_;

        if (exists $options_ref->{delegate_to}) {
            my $new_class = $options_ref->{delegate_to};
            my $new_instasnce = $new_class->new($options_ref);

            return $new_instance;
        }

        return;
    }

A big value of using properties is that you can override them at a later point
to make them support additional functionality, like setting a hardware flag,
logging, etc. In Class::Dot you override a property simply by defining their
accessors:

   property name => isa_String();

   sub name {   # <-- overrides the get accessor
       my ($self) = @_;

       warn 'Acessing the name property';

       return $self->__getattr__('name');
   }


    sub set_name { # <-- overrides the set accessor
        my ($self, $new_name) = @_;

        warn $self->__getattr__('name'), " changed name to $new_name!";

        $self->__setattr__('name', $new_name);

        return;
    }


There is one exception where this won't work, though. That is if you define a
property in a {BEGIN} block. If you do that you have to use the
{after_property_get()} and {after_property_set()} functions:

    BEGIN {
        use Class::Dot qw(-new :std);
        property name => isa_String();
    }

    after_property_get name => sub {
        my ($self) = @_;

        warn 'Acessing the name property';

        return $self->__getattr__('name');
    }; # <-- the semicolon is required here!

    after_property_set name => sub {
        my ($self, $new_name) = @_;

        warn $self->__getattr__('name'), " changed name to $new_name!";

        $self->__setattr__('name', $new_name);

        return;
    }; # <-- the semicolon is required here!

You can read more about {Class::Dot} in the [Class::Dot::Manual::Cookbook] and
[Class::Dot::Manual::FAQ]. (Not yet written for the 2.0 beta release).

Have a good time working with {Class::Dot}, and please report any bug you
might find, or send feature requests. (although {Class::Dot} is not meant to
be [Moose], it's meant to be simple and fast).


= SUBROUTINES/METHODS

== CLASS METHODS

=== {property($property_name, %options)}
=for apidoc VOID = Class::Dot::property(string $property, data $default_value)

Example:

    property foo => isa_String('hello world');

    property bar => isa_Int(303);

will create the methods:

    foo( )
    set_foo($value)

    bar( )
    set_bar($value)

with default return values -hello world- and -303-.

=== {has($property_name, %options)}

Alias to {property}.

=== {define_property($property_name, $default_value, $in_class, $options)}

Same as {property()} except you define which class to install the property
in.

=== {extends(@superclasses)}

Set superclasses for the current class. Same as {use base @superclasses}.

Example:
    package MyClass::Child;
    use Class::Dot qw(-new :std);
    extends 'MyClass';

=== {superclasses_for($class, @superclasses)}

Set the superclasses for another class.

Example:

    Class::Dot::superclasses_for('ThatClass' => qw(ThatClass::Base));

=== {composite($property_name, $composite_class)}

Denotes that the current class has a has-a relationship to another
class. The {$composite_class} will be loaded and a property with the name 
{$property_name} will be created. The class will be automatically created
if there is no instance constructed at object construction time.

    composite another_class => 'Another::Class'

is the same as:

    property another_class => isa_Object('Another::Class', auto => 1);

You can then override this property at another time if you like.

Example defining the instance at build time:

    class MyClass;

    composite another_class => 'Another::Class';

    sub BUILD {
        my ($self, $options_ref) = @_;

        my $another_class = Another::Class->new();
        $self->set_another_class( $another_class );

        return;
    }


    sub hello_from_another_class {
        my ($self) = @_;
        my $another_class = $self->another_class;

        return $another_class->hello();
    }

=== {composites_for($class, $property_name, $composite_class)}

Composite the class {$class} with {$composite_class} as a property
with the name {$property_name}.

=== {finalize_class($opt_class)}

This will finalize the class {$opt_class}. If {$opt_class} is not given, the
current class is used.

You can't add any new properties to the class after finalization.
So, why would you want to do this? Because it's an optimization.
All inheritance lookups are cached at the moment of finalization
and ISA will no longer be traversed at property lookups.

=== {after_property_get($attr_name, \&code)}

Override the get accessor method for a property.

Example:

   property name => isa_String;

   after_property_get name => sub {
      my ($self) = @_;
      
      warn 'Accessing the name property of ' . ref $self;
      
      return $self->__getattr__('name');
   }; # <- needs the semi-colon at the end!

=== {after_property_set($attr_name, \&code)}

Override the set accessor method for a property.

Example:

   property name => isa_String;
   
   after_property_set name => sub {
      my ($self, $new_name) = @_;

      warn $self->__getattr__('name') . " is canging name to $new_name";

      $self->__setattr__('name', $new_name);

      return;
   }; # <- needs the semi-colon at the end!

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

== INSTANCE METHODS

=== {->properties_for_class($class)}
=for apidoc HASHREF = Class::Dot->properties_for_class(_CLASS|BLESSED $class)

Return the list of properties for a class/object that uses the powers.

== PRIVATE CLASS METHODS

=== {_create_get_accessor($property, $default_value)}
=for apidoc CODEREF = Class::Dot::_create_get_accessor(string $property, data|CODEREF $default_value)

Create the set accessor for a property.
Returns a code reference to the new setter method.
It has to be installed into the callers package afterwards.

=== {_create_set_accessor($property)}
=for apidoc CODEREF = Class::Dot::_create_set_accessor(string $property)

Create the get accessor for a property.
Returns a code reference to the new getter method.
It has to be installed into the callers package afterwards.

= DIAGNOSTICS

== * You tried to set a value with {foo()}. Did you mean {set_foo()}

Self-explained?


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

= BENCHMARK

This is a benchmark to show an example of how {Class::Dot} performs over other
similar implementations. The source code for the benchmark can be found in
the {Class::Dot} distributions {devel/dotbench.pl} file.

                          Rate   moose class::dot class::dot-finalized pureperl-OO
    moose                 1186/s      --       -96%                 -96% -97%
    class::dot           27624/s   2229%         --                 -12% -28%
    class::dot-finalized 31546/s   2560%        14%                   -- -18%
    pureperl-OO          38610/s   3156%        40%                  22%

These are pretty simple programs that just creates an instance and sets+gets
some properties. Products may perform differently is other scenarios, after
all it's just a benchmark.

{class::dot-finalized} is the same program but where the class is finalized.
Finalizing the class is a simple operation, but after the class has been
finalized you can not add any new properties or base classes.

This is how you do it:

    __PACAKGE__->__finalize__();

Not that this should be done 'after' you have called the {Class::Dot}
functions you need.


--

= SEE ALSO

== [Moose]

A complete object system for Perl 5. It is much more complete than
{Class::Dot}, but it is also slower.

== [Class::Accessor]

== [Class::Accessor::Fast]

Simple generation of accessors (mutators). You can override the accessors
themselves, but if you use the default constructor, you can't intercept
the setting of values when you do:

    my $instance = Class->new({
        name => 'George Louis Constanza',
    });

To do that you would have to create a new constructor like this:

    sub new {
        my ($class, $options_ref) = @_;

        my $self = bless { }, $class;

        while (my ($attr_name, $attr_val) = each %{ $options_ref }) {
            if ($self->can($attr_name)) {
                $self->$attr_name($attr_val);
            }
        }

        return $self;
    }

Which is a hassle done automatically in {Class::Dot},
and, on a personal note, I really don't like
the syntax ({__PACKAGE__->mk_accessors} etc).

[Class::Accessor::Fast] is 'fast' however! 

== [Class::InsideOut]

For Inside-Out objects. Does not have types.

= CODE COVERAGE

    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    File                           stmt   bran   cond    sub    pod   time  total
    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    lib/Class/Dot.pm               99.0   98.8   64.3  100.0  100.0   79.0   98.2
    lib/Class/Dot/Types.pm         97.0   97.2  100.0  100.0  100.0   21.0   97.8
    Total                          98.4   98.4   70.6  100.0  100.0  100.0   98.1
    ---------------------------- ------ ------ ------ ------ ------ ------ ------

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
