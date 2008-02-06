#!/usr/bin/perl

# ### 
# This test was stolen from Moose 0.26
# #########

use strict;
use warnings;

use Test::More tests => 19;
use Test::Exception;

BEGIN {
    use_ok('Class::Dot::Meta::Class');
	use_ok('Class::Dot::Typemap');
}

foreach my $type_name (qw(
    Any
    Item 
        Bool
        Undef
        Defined
            Value
                Number
                  Int
                String
            Ref
                ScalarRef
                ArrayRef
                HashRef
                CodeRef
                RegexpRef
                Object	
                    Role
    )) {
    is(find_type_constraint($type_name)->type, 
       $type_name, 
       '... got the right name for ' . $type_name);
}

# TODO:
# add tests for is_subtype_of which confirm the hierarchy
