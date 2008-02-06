# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More   tests => 12;
use Scalar::Util qw(reftype blessed);

{

    package TheCompositeClass;
    use Class::Dot2;

    has 'season' => (isa => 'Str', default => 'Spring');
    has 'period' => (isa => 'TheCompositeClass::Period');

}

{
    package TheCompositeClass::Period;
    use Class::Dot2;
   
    has 's'     => (isa => 'Int', default => '386713');
    has 'ms'    => (isa => 'Num', default => '11435147213.1234');
    has 'h'     => (isa => 'Int', default => '3886');
}

{
    package CompositingClass;
    use Class::Dot2;
    my $S = __PACKAGE__;

    has 'compoze' => (isa => 'TheCompositeClass::');

    has 'regtype' => (isa => 'Str');
    

    ::ok(!::reftype($S->new->regtype), 'string type not ref');
    ::ok(!::blessed($S->new->regtype), 'string type not instance');
    ::ok( ::reftype($S->new->compoze), 'composite is ref');
    ::ok( ::blessed($S->new->compoze), 'composite is instance');

    ::is( $S->__meta__('regtype')->type, 'String',
        'isa String is type String'
    );
    ::is( $S->__meta__('compoze')->type, 'Object',
        'composites are of type Object'
    );
}

my $c = CompositingClass->new();

isa_ok($c,                    'CompositingClass');
isa_ok($c->compoze,           'TheCompositeClass');
isa_ok($c->compoze->period,   'TheCompositeClass::Period');


is( $c->compoze->period->s,   '386713',             's is defval');
is( $c->compoze->period->ms,  '11435147213.1234',   'ms is defval');
is( $c->compoze->period->h,   '3886',               'h is defval');

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
