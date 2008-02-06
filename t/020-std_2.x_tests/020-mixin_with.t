# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use Test::More tests => 9;
use Test::Exception;

{
    package SomeRole;
    use Class::Dot2;

    has name => (isa => 'Str',  default => "George Constanza");
    has hash => (isa => 'Hash', default => {foo => "bar"});

    my $P = __PACKAGE__;

    ::ok( $P->can('name'),      'has name()');
    ::ok( $P->can('hash'),      'has hash()');
    ::ok( $P->can('set_name'),   'has set_name()');
    ::ok( $P->can('set_hash'),   'has set_hash()');
}

{
    package SomeClass;
    use Class::Dot2 qw(isa_String);
    use Class::Dot::Meta::Role;

    Class::Dot::Meta::Role->mixin_with(__PACKAGE__, SomeRole->new());
    Class::Dot::Meta::Role->mixin_with(__PACKAGE__, SomeRole->new());

    my $M = Class::Dot::Registry->new->get_metaclass_for(__PACKAGE__);
    $M->property->define_property('foobar', isa_String('barfoo'), __PACKAGE__);

    my $P = __PACKAGE__;

    ::ok( $P->can('name'),      'has name()');
    ::ok( $P->can('hash'),      'has hash()');
    ::ok( $P->can('set_name'),   'has set_name()');
    ::ok( $P->can('set_hash'),   'has set_hash()');

    ::ok( $P->can('foobar'), 'HAS FOOBAR');
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
