package Class::Dot::design::RFC;

my $doc = q
{

# Class matching should be implemented by Class::Plugin::Util
# and should return the matches it finds (as well as loading them).

my @matching = Class::Plugin::Util::require_matching($pattern).

package MyApp;
has model       => (isa => '~Model');       # Becomes MyApp::Model
has view        => (isa => '~View');        # Becomes MyApp::View
has controller  => (isa => '~Controller');  # Becomes MyApp::Controller

# type yada yada yada (not yet decided or not important)
has factory     => (isa => '...'); 

extends 'Catalyst::';


# ### Match relative classes by regex

# Loads all relative modules except MyApp::Base;
extends '~/[^Base]$/';


# In the future when creating new types will be much easier                                                              
# it will probably be sane to categorize them by '.' (dot),                                                              
# since double colon is already taken.                                                                                   
has special_hash => (isa => 'Hash.Special', default => {a => 'b', c => 'd'});


sub opts_flat {
    my @opts = @_;
   
    my $i; 
    my %args;
    my @defaults;
    while (@opts) {
        my $opt = shift @opts;
        if ($opt eq '-default') {
            @defaults = @opts[$i + 1, -1];
            last;
        }
        $args{$opt} = shift @opts;
        $i++;
    }

    # If no list flattened defaults, try the regular one.
    if (! scalar @defaults && exists $args{default}) {
        @defaults = $args{default};
    }

    return { defaults => \@defaults, args => \%args };
}
             
package XWA::UserStorage;
#use Dot::Delegation '-constrained';
use Class::Dot2;
sub delegates ($) { };
sub to (@;)   { };
sub using (@;) { };
has 'storage_type' => (isa => 'ClassName', default => 'Local');
delegates to '~*', using 'storage_type';

package Dot::Delegation;
use Class::Plugin::Util qw(modules_matching);

# syntactic sugar.
sub to (@;)     { @_ }
sub using (@;)  { @_ }

sub delegates ($) {
    my ($to, $using) = @_;
    my $class = caller 0;

    my @mods;
    for my $alternative (@{ $using }) {
        push @mods, modules_matching($_);
    }

    $class->dot::meta::is_delegator($using, @mods);

    return;
}

package Dot::Delegation::Base;
use Class::Plugin::Util qw(require_class);

sub BUILD {
    my ($self, $options_ref) = @_;
    my ($using, $index)      = $self->dot::meta::delegation();
    confess "delegate: Using $using but no such attribute"
        if not defined $self->dot::meta::hasattr($using);

    my $to = $self->dot::meta::getattr($using)
        or confess "Needs argument: $using";

    exists $index->{$to} or confess "No such $using: $to";

    my $destination = $index->{$to};

    require_class ($destination);

    return $destination->new($options_ref);
}


# ---------------------------------
};
