#!/usr/bin/perl -w

use lib 't/lib';
use Test::More tests => 2;

{
    package Dog;
    sub new { bless {}, shift }
}

eval q{
    package Dog::Small;
    use Class::Dot2;
    extends qw(Dog);
    mixin_with qw(Dog::CompileError);
};
isnt($@, "");

eval q{
    package Dog::Small;
    use Class::Dot2;
    extends qw(Dog);
    mixin_with qw(Does::Not::Exist);
};
isnt($@, "");
