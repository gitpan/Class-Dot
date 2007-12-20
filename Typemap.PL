# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;

use devel::Generator::Typemap;

alias 'Str'     => 'String';
alias 'Any'     => 'Data';
alias 'Item'    => 'Data';
alias 'Value'   => 'Data';

type 'String' => sub {

    isa => 'Value',

    default_value => q
    {
        my ($default_value) = @args;
        return $default_value;
    },

    constraint => q
    {
        defined( $_[0] ) && !ref( $_[0] );
    },
};

WRITE_TYPES;
