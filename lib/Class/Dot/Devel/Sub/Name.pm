# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Devel::Sub::Name;

use strict;
use warnings;
use version;
use 5.00600;

use English qw(-no_match_vars);
use Class::Dot::Meta::Method qw(
    install_sub_from_class
);

our $VERSION   = qv('2.0.0_08');
our $AUTHORITY = 'cpan:ASKSH';

BEGIN {
    eval 'require Sub::Name'; ## no critic
    if ($EVAL_ERROR) {
        *subname = sub {
            my ($sub_name, $sub_coderef) = @_;
            return $sub_coderef;
        };
    }
    else {
        Sub::Name->import('subname');
    }
}

my @ALWAYS_EXPORT = qw(subname);

sub import {
    my ($this_class) = @_;
    my $caller_class = caller 0;

    no strict 'refs'; ## no critic
    for my $sub (@ALWAYS_EXPORT) {
        install_sub_from_class($this_class, $sub => $caller_class);
    }

    return;
}

1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
