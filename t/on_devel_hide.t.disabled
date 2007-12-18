# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use English qw(-no_match_vars);

use Test::More;
eval 'require Devel::Hide'; ## no critic
if ($EVAL_ERROR) {
    plan( skip_all => 'This test requires Devel::Hide' );
}

use Devel::Hide qw(Sub::Name);

plan( tests => 1 );


require Class::Dot;
Class::Dot->import();

    my $sub = Class::Dot::subname('XXXRememberMe', sub {
        require Carp;
        Carp::croak("hello");
    });

    eval { $sub->() };
    like($EVAL_ERROR, qr/__ANON__/,
        'C::D: anonsubs named __ANON__ without Sub::Name'
    );


