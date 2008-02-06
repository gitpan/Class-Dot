# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;
use English qw(-no_match_vars);

use Test::More tests => 7;
use Test::Exception;
use Carp qw(confess);



sub Maybe (&) {
    my ($code_block) = @_;

    confess "Maybe requires code block or subroutine reference"
        if not ref $code_block eq 'CODE';

    my $return_value = eval { $code_block->() };

    if ($EVAL_ERROR) {
        $EVAL_ERROR =~ m{^Can't\ locate\ object\ method}xms
                       ? return
                       : confess "Maybe failed: $EVAL_ERROR";
    }

    return $return_value;

    
}

{
    package XXX::MyClass;
    use Class::Dot2;

    sub exists {
        my ($self, $argument) = @_;

        return $argument;
    }

    sub dies {
        my ($self, $exit_message) = @_;
        $exit_message ||= 'dies() default message';
        die $exit_message;
    }

    sub warns {
        my ($self, $warning_message) = @_;

        carp $warning_message;
        return;
    }

    # TODO : Not yet found a way to do this :(
    # I've tried overriding die, $SIG{__DIE__} etc but syntax errors
    # are not like regular dies, so I have no way to find where
    # the error is coming from (except the line number in the source code
    # where it is _written_ (not executed). I've even tried to manipulate
    # line numbers with #line :-)
    # -- asksh@cpan.org
    sub exists_but_calls_nonexistent {
        my ($self) = @_;
        return $self->some_nonexistent_method();
    }

}


my $x = XXX::MyClass->new();

dies_ok { $x->dies("hello") };
like($EVAL_ERROR, qr{hello}, 'test class->dies() really dies');

lives_ok(sub {
    Maybe { $x -> nonexistant };
}, 'Maybe on nonexistent method lives' );

my $return_value;
lives_ok( sub {
    $return_value = Maybe { $x->exists("The quick brown fox...") }
}, 'Maybe on existant method lives' );
is( $return_value, 'The quick brown fox...',
    '... and returns the correct value'
);

dies_ok(sub {
    Maybe { $x->dies() }
}, 'Maybe on existent method that dies fails' );

TODO: {
    local $TODO = "Must find a really smart way to do this";
    dies_ok(sub {
        Maybe { $x->exists_but_calls_nonexistent() }
    }, 'Maybe on existent method that calls another nonexistent method fails' );
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
