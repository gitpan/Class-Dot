#!/usr/local/bin/perl


package Dotter;
use strict;
use warnings;
use Class::Dot2 qw(-override);

has name => (isa => 'String', default => 'Ask');

package main;

use strict;
use warnings;



for (1..100_000) {
        my $normal1 = Dotter->new({
            name => "daddy",
        });
        my $normal2 = Dotter->new();
        $normal1->set_name("mommy");
        $normal1->name;
        $normal2->set_name("mommy");
        $normal2->name;
}





