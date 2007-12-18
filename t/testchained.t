# $Id: testchained.t 57 2007-12-18 13:19:53Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/t/testchained.t $
# $Revision: 57 $
# $Date: 2007-12-18 14:19:53 +0100 (Tue, 18 Dec 2007) $
use strict;
use warnings;

use Test::More;
use FindBin qw($Bin);
use English qw( -no_match_vars );
use lib 'lib';
use lib $Bin;
use lib 't';
use lib "$Bin/../lib";

our $THIS_TEST_HAS_TESTS = 15;

plan( tests => $THIS_TEST_HAS_TESTS );

use_ok('TestChained');

my $test_isa = TestChained->new();
isa_ok($test_isa, 'TestChained');

my $chained = TestChained->new->set_name('Ask Solem')
    ->set_email('askh@opera.com')
    ->set_address('Waldemar Tranes gt.')
    ->set_birthdate_year(1982);

isa_ok($chained, 'TestChained', 'chaining worked');

is( $chained->name, 'Ask Solem', 'name() chained');
is( $chained->email, 'askh@opera.com', 'email() chained');
is( $chained->address, 'Waldemar Tranes gt.', 'address() chained');
is( $chained->birthdate_year, 1982, 'birthdate_year() chained');

is( $chained->with_default, 'hello world!', 'with default var');
is( $chained->reg, 'hello universe!', 'with no type');
is( $chained->reglazy, 'hello lazy!', 'with lazy type');

$chained = TestChained->new->name('Ask Solem')
    ->email('askh@opera.com')
    ->address('Waldemar Tranes gt.')
    ->birthdate_year(1982);

isa_ok($chained, 'TestChained', 'chaining worked');

is( $chained->name, 'Ask Solem', 'name() chained');
is( $chained->email, 'askh@opera.com', 'email() chained');
is( $chained->address, 'Waldemar Tranes gt.', 'address() chained');
is( $chained->birthdate_year, 1982, 'birthdate_year() chained');

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
