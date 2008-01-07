# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More tests => 98;
use Test::Exception;
use English qw(-no_match_vars);

{
    package MutatorProperty;
    use Class::Dot2 qw(-getter_prefix= -setter_prefix=);
   
    # Overridable 
    property mutator => (isa => 'Str', default => 'teenage mutants!');
    property mutato2 => (isa => 'Str', default => 'grownup mutants!',
                         is => 'ro');
    property mutato3 => (isa => 'Str', default => 'writeme mutants!',
                         is => 'wo');

    # Chained
    property Cutator => (isa => 'Str', default => 'teenage mutants!',
                         -accessor_type => 'Chained');
    property Cutato2 => (isa => 'Str', default => 'grownup mutants!',
                         is => 'ro', -accessor_type => 'Chained');
    property Cutato3 => (isa => 'Str', default => 'writeme mutants!',
                         is => 'wo', -accessor_type => 'Chained');
    
    # Constrained
    property Xutator => (isa => 'Str', default => 'teenage mutants!',
                         -accessor_type => 'Constrained');
    property Xutato2 => (isa => 'Str', default => 'grownup mutants!',
                         is => 'ro', -accessor_type => 'Constrained');
    property Xutato3 => (isa => 'Str', default => 'writeme mutants!',
                         is => 'wo', -accessor_type => 'Constrained');
}

{
    package MutatorPropertyPolicy;
    use Class::Dot::Policy::Mutator;
    property Putator => (isa => 'Str', default => 'teenage mutants!');
    property Putato2 => (isa => 'Str', default => 'grownup mutants!',
                         is => 'ro');
    property Putato3 => (isa => 'Str', default => 'writeme mutants!',
                         is => 'wo');
}

my $mutate  = MutatorProperty->new();
my $mpolicy = MutatorPropertyPolicy->new();
isa_ok($mutate,  'Class::Dot::Object');
isa_ok($mpolicy, 'Class::Dot::Object');

# Test Overridable mutators.
test_mutator_property($mutate, 'mutator', 'teenage mutants!');
test_mutator_property($mutate, 'mutato2', 'grownup mutants!');
test_mutator_property($mutate, 'mutato3', 'writeme mutants!');

# Test Chained mutators.
test_mutator_property($mutate, 'Cutator', 'teenage mutants!', 'Chained');
test_mutator_property($mutate, 'Cutato2', 'grownup mutants!', 'Chained');
test_mutator_property($mutate, 'Cutato3', 'writeme mutants!', 'Chained');

# Test Constrained mutators.
test_mutator_property($mutate, 'Xutator', 'teenage mutants!', 'Constrained');
test_mutator_property($mutate, 'Xutato2', 'grownup mutants!', 'Constrained');
test_mutator_property($mutate, 'Xutato3', 'writeme mutants!', 'Constrained');

# Test Class::Dot::Policy::Mutator
test_mutator_property($mpolicy, 'Putator', 'teenage mutants!');
test_mutator_property($mpolicy, 'Putato2', 'grownup mutants!');
test_mutator_property($mpolicy, 'Putato3', 'writeme mutants!');

sub test_mutator_property {
    my ($obj, $prop, $defval, $attr_type) = @_;
    $attr_type ||= 'Overrideable';
    my $meta = $obj->__meta__($prop);

    is( $meta->accessor_type, $attr_type,
        "is accessor type: $attr_type"
    );

    # Common.
    ok( $obj->can($prop), ref($obj)." can $prop" );
    ok(!$obj->can("set_$prop"), "$prop can't set_$prop");
    ok(!$obj->can("get_$prop"), "$prop can't get_$prop");

    if ($meta->privacy_rule->{has_getter}) {
        is( $obj->$prop, $defval, "$prop has default value intact");
    }
    else {
        is( $obj->__getattr__($prop), $defval,
            "$prop has default value intact"
        );
    }

    if ($meta->privacy_rule->{has_setter}) {
        lives_ok {
            $obj->$prop("mutate me");
        };
        ok(!$EVAL_ERROR, "set value with $prop(\$value) does not die");
        is( 
            ($meta->privacy_rule->{has_getter} ? $obj->$prop 
            : $obj->__getattr__($prop)),
           "mutate me", "can set value with $prop(\$value)"
        );
    }
    else {
        dies_ok( sub { $obj->$prop("mutate me") },
            "$prop is readonly, so dies if setting value"
        );
        like( $EVAL_ERROR, qr/Can't set value with $prop\(\). It's private!/,
            '... and got the error message we expected.'
        );
        isnt($obj->$prop, "mutate me", "$prop value was not set");
    }
        
}



# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
