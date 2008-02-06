#!/usr/bin/perl -w

use Test::More tests => 3;

{
    package Parent;

    sub foo { "Parent"; }
}

{
    package Middle;
    use Class::Dot2;
    mixin_with "Parent";

    sub foo {
        my $self = shift;
        return $self->SUPER::foo(), "Middle";
    }
}

{
    package Child;
    use Class::Dot2;
    extends qw(Parent);
    mixin_with "Middle";

    sub foo {
        my $self = shift;
        return $self->SUPER::foo(), "Child";
    }
}

is_deeply [Child->foo], [qw(Parent Middle Child)];

ok( Child->isa("Parent") );
ok( !Child->isa("Middle") );
