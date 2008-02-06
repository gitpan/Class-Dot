# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More tests => 6;

{
    package WriteonlyProperty;
    use Class::Dot2;

    property writeonly  => (is => 'wo', isa => 'Str', default => "only read");
}

my $wo = WriteonlyProperty->new();

# ## test property: writeonly

test_a_writeonly_property($wo, 'writeonly', 'only read');



sub test_a_writeonly_property {
    my ($obj, $prop, $defval) = @_;
    my $meta = $obj->__meta__($prop);

    ok(!$obj->can($prop), 
        "$prop has not get accessor"
    );

    ok( $obj->can("set_$prop"),
        "$prop has set accessor"
    );

    is($obj->__getattr__($prop), $defval,
        "$prop has default value intact (fetch with __getattr__)"
    );

    is( $meta->privacy, 'writeonly',
        "privacy for $prop is writeonly"
    );

    ok(!$meta->privacy_rule->{has_getter},
        "$prop has no privacy rule: has_getter capability"
    );
    
    ok( $meta->privacy_rule->{has_setter},
        "$prop has privacy rule: has_setter capability"
    );
}


# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
