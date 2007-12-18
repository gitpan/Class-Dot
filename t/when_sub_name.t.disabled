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
eval 'require Sub::Name'; ## no critic
if ($EVAL_ERROR) {
    plan( skip_all => 'This test requires Sub::Name' );
}

plan( tests => 1 );


require Class::Dot;
Class::Dot->import();

    my $sub = Class::Dot::subname('XXXRememberMe', sub {
        require Carp;
        Carp::croak("hello");
    });

    eval { $sub->() };
    like($EVAL_ERROR, qr/XXXRememberMe/,
        'C::D: anonsubs is named when Sub::Name installed'
    );


