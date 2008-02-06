# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More tests => 12;

{
    package ReadonlyProperty;
    use Class::Dot2;

    property readonly  => (is => 'ro', isa => 'Str', default => "only read");
    property -implicit => (isa => 'Str', default => 'preficed by minus');
}

my $ro = ReadonlyProperty->new();

# ## test property: readonly

test_a_readonly_property($ro, 'readonly', 'only read');


# ## test property: implicit
test_a_readonly_property($ro, 'implicit', 'preficed by minus');

sub test_a_readonly_property {
    my ($obj, $prop, $defval) = @_;
    my $meta = $obj->__meta__($prop);

    ok( $obj->can($prop), 
        "$prop has get accessor"
    );

    ok(!$obj->can("set_$prop"),
        "$prop has not set accessor"
    );

    is($obj->$prop, $defval,
        "$prop has default value intact"
    );

    is( $meta->privacy, 'readonly',
        "privacy for $prop is readonly"
    );

    ok( $meta->privacy_rule->{has_getter},
        "$prop has privacy rule: has_getter capability"
    );
    
    ok(!$meta->privacy_rule->{has_setter},
        "$prop has no privacy rule: has_setter capability"
    );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
