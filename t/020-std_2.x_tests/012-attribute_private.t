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
    package xxProperty;
    use Class::Dot2 qw(-override);

    property 'xx'  => (is => 'xx', isa => 'Str', default => "private");
    property '!implicit' => (isa => 'Str', default => 'preficed by !');
    
}

my $xx = xxProperty->new();

# ## test property: readonly

test_a_private_property($xx, 'xx', 'private');


# ## test property: implicit
test_a_private_property($xx, 'implicit', 'preficed by !');

sub test_a_private_property {
    my ($obj, $prop, $defval) = @_;
    my $meta = $obj->__meta__($prop);

    ok(! $obj->can($prop), 
        "$prop has not get accessor"
    );

    ok(!$obj->can("set_$prop"),
        "$prop has not set accessor"
    );

    is($obj->__getattr__($prop), $defval,
        "$prop has default value intact"
    );

    is( $meta->privacy, 'private',
        "privacy for $prop is private"
    );

    ok(!$meta->privacy_rule->{has_getter},
        "$prop has no privacy rule: has_getter capability"
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
