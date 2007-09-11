use strict;
use warnings;
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

our $THIS_TEST_HAS_TESTS = 34;

plan( tests => $THIS_TEST_HAS_TESTS );

use_ok('Class::Dot');

ok(! Class::Dot::property( ), 
    'property without property'
);

my $testo  = TestProperties->new( );
my $cat    = Cat->new( );
my $testo2 = TestProperties->new({ obj => $cat });

for my $property (qw(foo set_foo bar set_bar obj set_obj defval set_defval
    digit set_digit hash set_hash array set_array
    nodefault set_nodefault string set_string)) {
    can_ok($testo, $property);
}
isa_ok( $testo->obj,  'Cat',
   'isa_Object creates a new object of the type it is by default'
);
is(refaddr($testo2->obj), refaddr($cat),
   'isa_Object doesn\'t creat new object if object already set.'
);
ok( ! defined $testo->mystery_object, 'isa_Object with no default class' );
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

is( $testo->digit, 303, 'isa_Int default value' );

is( $testo->nofunc, 'This does not use isa_*',
    'property that does not use isa_*'
);

ok(! $testo->nodefault );

ok(! $testo->string );


is($testo->defval, 'la liberation', 'default value for isa_String');

eval '$testo->bar("this should croak")';
like($EVAL_ERROR,
    qr/You tried to set a value with bar\(\)\. Did you mean set_bar\(\) \?/,
    'croak on bar("value")'
);
