# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More tests => 18;

BEGIN { use_ok('Class::Dot2') or die };
BEGIN { use_ok('Class::Dot::Registry') or die };

my $REGISTRY = Class::Dot::Registry->new();
my $options;

# ### Import Class::Dot2 from main does not dotify main.

{
    package main;
    use Class::Dot2;
}

ok( !main->can('new'), 'import Class::Dot2 from main does not create new');
ok( !scalar keys %{$REGISTRY->get_options_for('main')},
    'main has no registered options in registry'
);

# ### Default Class::Dot2 settings.


{
    package Foo;
    use Class::Dot2;
}

ok( Foo->can('new'), 'Foo can new');
ok( Foo->isa('Class::Dot::Object'), 'Foo isa Class::Dot::Object');
ok( $REGISTRY->is_class_registered('Foo'), 'Foo is a registered class' );
my $foo = Foo->new();
isa_ok($foo, 'Foo');

$options = $REGISTRY->get_options_for('Foo');
ok(!$options->{'-no_constructor'}, 'Foo does not have -no_constructor');
ok( $options->{'-optimized'}, 'Foo is -optimized');
ok( $options->{'-new'},       'Foo is -new');

$options = $REGISTRY->get_options_for($foo);
ok(!$options->{'-no_constructor'}, '$Foo does not have -no_constructor');
ok( $options->{'-optimized'}, '$Foo is -optimized');
ok( $options->{'-new'},       '$Foo is -new');

# ### Class::Dot2 with -override.

{
    package Bar;
    use Class::Dot2 qw(-override);
}

my $bar = Bar->new();
isa_ok($bar, 'Bar');
ok( $REGISTRY->is_class_registered($bar), '$Bar is a registered class' );

$options = $REGISTRY->get_options_for($bar);
ok(!$options->{'-optimized'}, '-override means no -optimized');
ok( $options->{'-override'},  'Bar has -override');
