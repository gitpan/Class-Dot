use strict;
use warnings;
# ^^^^^ Must not be moved. The first line is used in a test of isa_File!

# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$

use Test::More;
use FindBin qw($Bin);
use English qw( -no_match_vars );
use lib 'lib';
use lib $Bin;
use lib 't';
use lib "$Bin/../lib";
use Scalar::Util qw(refaddr);
use TestProperties;
use Cat;

$ENV{TESTING_CLASS_DOT} = 1;

our $THIS_TEST_HAS_TESTS = 120;

plan( tests => $THIS_TEST_HAS_TESTS );

use_ok('Class::Dot');

ok(! Class::Dot::property( ), 
    'property without property'
);

my $testo  = TestProperties->new( );
my $cat    = Cat->new( );
my $testo2 = TestProperties->new({ obj => $cat });

my $testo3 = TestProperties->new({ obj => $cat });
is( $testo3->obj, $cat, 'defaults ok after second instance' );

for my $property (qw(foo set_foo bar set_bar obj set_obj defval set_defval
    digit set_digit hash set_hash array set_array compoze
    nodefault set_nodefault intnoval set_intnoval string set_string)) {
    can_ok($testo, $property);
}
isa_ok( $testo->obj,  'Cat',
   'isa_Object creates a new object of the type it is by default'
);
is(refaddr($testo2->obj), refaddr($cat),
   'isa_Object doesn\'t create new object if object already set.'
);
ok( ! defined $testo->mystery_object, 'isa_Object with no default class' );
ok( ! defined $testo->another_object, 'isa_Object with no default class' );
ok(! $testo->foo, 'isa_Data has no default value' );
$testo->set_foo('foofoo', 'set a value');
is($testo->foo, 'foofoo', 'retrieve a value');
$testo->set_bar('barbar', 'set another value');
is($testo->bar, 'barbar', 'retrieve another value');
is_deeply($testo->array, [qw(the quick brown fox ...)],
    'array with default_values'
);
is_deeply($testo->hash, {
        hello => 'world',
        goobye => 'wonderful',
    },
    'isa_Hash default value',
);

# Composition with composite().
isa_ok( $testo->compoze, 'Composite', 'Composition with composite(): ');
ok( $testo->compoze->can('name'),      'Object created at composition: ');
is( $testo->compoze->name, 'The quick brown fox jumps over the lazy dog.',
    'Can get/call composited objects properties'
);

is( $testo->reglazy, 'hello lazy!', 'OLDSCHOOL tyoe');
isa_ok($testo->blessed, 'Some::XXX::Class', 'no type but blessed object');
is( $testo->xyzzy, 3.141592, 'isa_Data with default value');

is( $testo->digit, 303, 'isa_Int default value' );

is( $testo->nofunc, 'This does not use isa_*',
    'property that does not use isa_*'
);

ok(! $testo->intnoval, 'int with no default value is not true' );

ok(! defined $testo->intnoval, 'int with no default is not defined' );

ok(! $testo->nodefault, 'property with no type set is not true' );

ok(! defined $testo->nodefault, 'property with no type set is not defined' );

ok(! $testo->string, 'string with no default value is not true' );

ok(! defined $testo->string, 'string with no default value is not defined' );

is($testo->defval, 'la liberation', 'default value for isa_String');

eval '$testo->bar("this should croak")';
like($EVAL_ERROR,
    qr/You tried to set a value with bar\(\)\. Did you mean set_bar\(\) \?/,
    'croak on bar("value")'
);

isa_ok($testo->code,    'CODE', 'return value of isa_Code w/o default');
isa_ok($testo->codedef, 'CODE', 'return value of isa_Code w/  default');
is($testo->codedef->(), 10, 'isa_Code property is callable');
isa_ok($testo->filehandle, 'FileHandle',
    'return value of isa_File w/o default'
);
isa_ok($testo->myself, 'GLOB',
    'return value of isa_File w/ default'
);
my $fh = $testo->myself;
my $line = <$fh>;
like($line, qr/use strict/, 'read from a isa_File');

can_ok($testo, '__setattr__');
can_ok($testo, '__getattr__');
can_ok($testo, '__hasattr__');
ok( $testo->__hasattr__('string'),    '->__hasattr__() existing' );
ok( TestProperties->__hasattr__('string'),
    '->__hasattr__() as class method'
);
ok(!$testo->__hasattr__('stringnot'), '->__hasattr__() nonexisting' );
ok( $testo->__setattr__('string', 'the blob jumps high over the flob'),
	'->__setattr__() with existing attr'
);
ok(!$testo->__setattr__('stringnot', 'the blob jumps high over the flob'),
	'->__setattr__() with nonexisting attr'
);
is( $testo->__getattr__('string'), 'the blob jumps high over the flob',
	'->__getattr()__ set after ->__setattr__()'
);
is( $testo->string, 'the blob jumps high over the flob',
	'->$property() set after ->__setattr__()'
);

isa_ok( $testo->regex_empty, 'Regexp', 'isa_Regexp default value');
my $match_against = 'The quick brown fox jumps over the lazy dog.';
ok( $match_against =~ $testo->regex_def, 'Can match against isa_Regex');
is( $testo->bool, 1, 'isa_Bool default value of 0xffff becomes 1');

my $propz = Class::Dot->properties_for_class($testo);
my $THIS_BLOCK_HAS_TESTS = 4;
if ($propz->{defval}->can('type')) {
    is( $propz->{defval}->type(), 'String');
    is( $propz->{defval}->default_value, 'la liberation');
    my $defval_meta = $testo->__meta__('defval');
    is( $defval_meta->type, 'String', '__meta__->type is String');
    is( $defval_meta->default_value, 'la liberation', 
        '__meta__->default_value is defined'
    );
}
else {
    for my $i (1 ... $THIS_BLOCK_HAS_TESTS) {
        ok ($i, 'this feature does not exist anymore. and it is ok');
    }
}

ok(!$testo->__getattr__('stringnot'), '__getattr__() nonexisting' );

is( $testo->override, 'not modified', 'override with after_property_set');

$testo->set_override('modified');
is( $testo->override, 'modified',     'override with after_property_get');

is( $testo->override2, 'xxx not modified', 'override with sub set_xxx {...}');

$testo->set_override('xxx modified');
is( $testo->override, 'xxx modified',     'override with sub xxx {...}');


# Property names starting with _ is special, in that the set accessor
# is named _set_property instead of set__property
ok($testo->can('__set_private'),
    '__private becomes __set_private not set___private'
);
ok($testo->can('_set_private'),
    '_private becomes _set_private not set__private'
);
ok($testo->can('__set_private__'),
    '__private__ becomes __set_private__ not set___private__'
);
$testo->_set_private('Private contents 1');
is($testo->_private, 'Private contents 1',
    'set with _set_private',
);
$testo->__set_private('Private contents 2');
is($testo->__private, 'Private contents 2',
    'set with __set_private',
);
is($testo->_private, 'Private contents 1',
    '_private not affected by __set_private',
);
$testo->__set_private__('Private contents 3');
is($testo->__private__, 'Private contents 3',
    'set with __set_private__',
);
is($testo->_private, 'Private contents 1',
    '_private not affected by __set_private__'
);

ok( $testo->__hasattr__('_private'),    'hasattr _private');
ok( $testo->__hasattr__('__private'),   'hasattr __private');
ok( $testo->__hasattr__('__private__'), 'hasattr __private__');


my $props_unfinalized = Class::Dot->properties_for_class(ref $testo);
ok(!$props_unfinalized->{__is_retrieved_cached__},
    'non-finalized class does not cache properties_for_class()'
);

is( $testo->__hasattr__('obj'), 1,
    '__hasattr_ not cached before finalization'
);

# Class finalization. SHOULD BE TESTED LAST.
ok( ! $testo->__is_finalized__, 'not finalized before finalize_class()');
ok( $testo->__finalize__, 'finalize class with $self->__finalize__()');
ok( TestProperties->__finalize__,
    'finalize class with Class->__finalize__()'
);
ok( $testo->__is_finalized__,  'is finalized after finalize_class()');
ok( $testo2->__is_finalized__, 'other instance also finalized');
ok( Class::Dot::finalize_class(ref $testo), 'finalize class again');
ok( Class::Dot::finalize_class(), 'finalize class with caller');

my $props_finalized = Class::Dot->properties_for_class(ref $testo);
is( $props_finalized->{__is_retrieved_cached__}, 1,
    'finalized class caches properties_for_class()'
);

ok( $testo->__hasattr__('obj'), '__hasattr__ works after finalization');
is( $testo->__hasattr__('obj'), 2, '__hashattr__ cached after finalization');
ok(!$testo->__hasattr__('stringnot'), '__hasattr__ false on nonexisting');

# I'm a sucker for coverage :-)
{
    no warnings 'uninitialized'; ## no critic
    undef $ENV{TESTING_CLASS_DOT};
    ok( Class::Dot->properties_for_class($testo), 'properties for class' );
}

# Test that inheriting from yourself gives a warning.
{
    no strict   'refs';     ## no critic
    no warnings 'redefine'; ## no critic
    my $orig_carp = \&Class::Dot::carp;

    my $carp_contents;
    *{ "Class::Dot::carp" } = sub {
        $carp_contents = join q{ }, @_;
    };

    Class::Dot::carp('This carp is overridden');
    is($carp_contents, 'This carp is overridden', 'carp overrideable');

    Class::Dot::superclasses_for('NonExisting' => 'NonExisting');
    is($carp_contents, "Class 'NonExisting' tried to inherit from itself.", 
        'superclasses_for: Inheriting from yourself yields warnings'
    );

    # Ineherit from non-existing module.
    no warnings 'Class::Plugin::Util'; ## no critic
    my $old_warn_sig = $SIG{__WARN__};
    $SIG{__WARN__} = sub { };
    eval { Class::Dot::superclasses_for(
        'NonExisting' => 'Non::ExistingModule'
    ) };
    ok( $EVAL_ERROR, 'Cannot inherit from non-existing module' );
    $SIG{__WARN__} = $old_warn_sig;
    *{ "Class::Dot::carp" } = $orig_carp;
}

# Create class
my $class_name    = 'Hope::This::Class::Does::Not::Exist';
my $class_methods = {
    new => sub {
        my ($self, $options_ref) = @_;
        $options_ref ||= { };
        return bless {%{ $options_ref }}, $class_name;
    },
    hello => sub {
        return 'world',
    },
};
my $class_isa;
my $class_version = 3.141592;
ok(! Class::Dot::Types::_create_class(
        $class_name, $class_methods, $class_isa, $class_version
    ),
    '_create_class'
);
ok(! Class::Dot::Types::_create_class($class_name),
    '_create_class same class again'
);
is( $class_name->VERSION, $class_version, 'VERSION is set in created class');
is( $class_name->hello, 'world', 'predefined method is defined');
my $class_instance = $class_name->new({foo => 'xyzzy'});
isa_ok($class_instance, $class_name);
is( $class_instance->{foo}, 'xyzzy', 'options_ref parsed');

my $subclass_name    = 'XXX::HTCDNE';
my $subclass_methods = {
    new => sub {
        my ($self, $options_ref) = @_;
        $options_ref ||= { };
        return bless {%{ $options_ref }}, $subclass_name;
    },
    goodbye => sub {
        return 'universe',
    },
};
my $subclass_isa    = [$class_name];
Class::Dot::Types::_create_class(
    $subclass_name, $subclass_methods, $subclass_isa
);
is( int $subclass_name->VERSION, 1, 'default class version is 1');
my $subclass_instance = $subclass_name->new({bar => 'xazzA'});
is( $subclass_instance->hello, 'world',
    'subclass inherits from parent'
);
is( $subclass_instance->goodbye, 'universe',
    'subclass has methods',
);
is( $subclass_instance->{bar}, 'xazzA',
    'subclass is a hash',
);
Class::Dot::Types::_create_class(
    'XXX::XXX::XXX::YYYY::YYYY::CCCC', undef, undef, 2.48
);
is( sprintf("%.2f", XXX::XXX::XXX::YYYY::YYYY::CCCC->VERSION), 2.48,
    'create class without methods',
);

eval { Class::Dot::Types->import(':std', ':nonstd') };
like( $EVAL_ERROR, qr/Only one export class can be used/,
    'C::D::Types: only one export class can be used at a time'
);
ok(! Class::Dot::Types->import('ThisSubDoesNotExist'),
    'C::D::Types: import nonexisting'
);

eval { Class::Dot::Types->import(':nonstd') };
ok(! $EVAL_ERROR, 'import nonexisting export class');


# Test that invalid type for has() croaks.
eval {
    use Class::Dot qw(has);
    has 'foormpxxxxpltttooooh' => (
        is => 'rw', isa => 'NonExistingTypeXXXRopmpmasdsd'
    );
};
like($EVAL_ERROR, qr/Unknown type constraint/,
    'invalid type for has() croaks'
);


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
