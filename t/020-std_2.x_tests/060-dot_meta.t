# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More tests => 11;
use Test::Exception;
use English qw(-no_match_vars);

{
    package MyClass;
    use Class::Dot2;

    sub foo {
        my ($self, $artigartig) = @_;
        print "foo: ($self, \"$artigartig\")\n";
    }

}

{
    package OtherClass;
    use Class::Dot2;
}

my $m = MyClass->new();

dies_ok( sub {
    $m->dot::meta::for()
}, 'class->dot::meta::for(other) dies if no argument');

my $who_for_meta = $m->dot::meta::for('OtherClass');

ok( $who_for_meta, 'class->dot::meta::for(other) returns value');

isa_ok( $who_for_meta, 'Class::Dot::Meta::Class',
    'class->dot::meta::for(other) returns metaclass'
);

my $other = OtherClass->new();

ok( MyClass->dot::meta::for($other),
    'class->dot::meta::for(other): both arguments can be either instance or class'
);

MyClass->dot::meta::for('OtherClass')->property->define_property(
    ('fubar', "blablabla") => 'OtherClass'
);

ok( $other->can('fubar'),
    'Can define attribute with metaclass returned by dot::meta::for'
);

is( $other->fubar, 'blablabla',
    '... and the attribute works like it should'
);


{
    package NotDotClass;
    use strict;
    use warnings;

    sub new {
        my ($class) = @_;
        return bless [ ], $class;
    }
}

dies_ok( sub {
    Class->dot::meta::incompatible
}, 'testing dot::meta::incpatibility on class name dies');
like($EVAL_ERROR, qr/Must be instance to check compatibility, not class name/,
    '... and the error is what we expected'
);

ok (!$other->dot::meta::incompatible,
    'hash based class is not dot::meta::incompatible'
);

my $not_dot_class = NotDotClass->new();
ok( my $reason = $not_dot_class->dot::meta::incompatible,
    'ARRAY-based class is dot::meta::incompatible'
);

like( $reason,
    qr/Instance must be HASH-based, but NotDotClass is ARRAY-based/,
    '... and the reason is what we expected'
);

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
