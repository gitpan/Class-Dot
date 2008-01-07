# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More tests => 10;

{
    package UseLineOptionAssignment;
    use Class::Dot2 qw(-getter_prefix=get_);
    
    property 'some_attr' => (isa => 'Str', default => 'someAttr');
}

my $thing = UseLineOptionAssignment->new();
isa_ok($thing, 'Class::Dot::Object');


# Verify get accessor.
ok(!$thing->can('some_attr'), 'getter_prefix does not create $property');
ok( $thing->can('get_some_attr'), 'getter_prefix get_');
is( $thing->get_some_attr, 'someAttr', 'default value OK');

my $attr_meta = $thing->__meta__('some_attr');
is( $attr_meta->accessor_type, 'Overrideable', 'some_attr is Overrideable');
is( $attr_meta->privacy, 'public', 'some_attr is public');
ok( $attr_meta->privacy_rule->{has_getter}, 'some_attr has_getter');
ok( $attr_meta->privacy_rule->{has_setter}, 'some_attr has_setter');

# type has linear_isa
ok( $attr_meta->linear_isa, 'type has linear isa');

# Verify that it has a set accessor.

ok($thing->can('set_some_attr'), 'still has set accessor');



# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
