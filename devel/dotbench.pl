#!/usr/local/bin/perl

package Accessorer;
use strict;
use warnings;
use base 'Class::Accessor';
__PACKAGE__->mk_accessors(qw(name));
sub new {
    my ($class, $options_ref) = @_;
    $options_ref ||= { };
    $options_ref->{name} ||= 'Ask';

    my $self = bless { }, $class;
    
    while (my ($option, $value) = each %{ $options_ref }) {
        my $setter = "set_$option";
        if ($self->can($setter)) {
            $self->$setter($value);
        }
    }

    return $self;
}

package AccessorerFaster;
use strict;
use warnings;
use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw(name));
sub new {
    my ($class, $options_ref) = @_;
    $options_ref ||= { };
    $options_ref->{name} ||= 'Ask';

    my $self = bless { }, $class;
    
    while (my ($option, $value) = each %{ $options_ref }) {
        my $setter = "set_$option";
        if ($self->can($setter)) {
            $self->$setter($value);
        }
    }

    return $self;
}

package Dotter;
use strict;
use warnings;
use Class::Dot2;

has 'name' => (isa => 'String', default => 'Ask');

package DotterFinalized;
use strict;
use warnings;
use Class::Dot2 (-override);

has 'name' => (isa => 'String', default => 'Ask');
finalize_class();

package Normal;
use strict;
use warnings;

my $DEFAULT_NAME = 'Ask';

sub new {
    my ($class, $options_ref) = @_;
    $options_ref ||= { };
    $options_ref->{name} ||= 'Ask';

    my $self = bless { }, $class;
    
    while (my ($option, $value) = each %{ $options_ref }) {
        my $setter = "set_$option";
        if ($self->can($setter)) {
            $self->$setter($value);
        }
    }

    return $self;
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub set_name {
    my ($self, $value) = @_;
    $self->{name} = $value;
    return;
}

package NormalFaster;
use strict;
use warnings;


sub new {
    my ($class, $options_ref) = @_;
    $options_ref = { } unless defined $options_ref;
    $options_ref->{name} ||= 'Ask';

    my $self = bless {%{ $options_ref }}, $class;
    
    return $self;
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

sub set_name {
    my ($self, $value) = @_;
    $self->{name} = $value;
    return;
}

package MooseBench;
use Moose;

has name => (is => 'rw', isa => 'Str', default => 'Ask');

package MooseBenchFinalized;
use Moose;

has name => (is => 'rw', isa => 'Str', default => 'Ask');

MooseBenchFinalized->meta->make_immutable();

package main;

use strict;
use warnings;
use Benchmark qw(cmpthese);



cmpthese(100_000, {
    'pureperl-OO'  => '
        my $normal = Normal->new({
            name => "daddy",
        });
        $normal->set_name("mommy");
        $normal->name;
        $normal = Normal->new();
        $normal->set_name("mommy");
        $normal->name;
    ',
    'class::dot'  => '
        my $normal = Dotter->new({
            name => "daddy",
        });
        $normal->set_name("mommy");
        $normal->name;
        $normal = Dotter->new();
        $normal->set_name("mommy");
        $normal->name;
    ',
    'class::dot-finalized'  => '
        my $normal = DotterFinalized->new({
            name => "daddy",
        });
        $normal->set_name("mommy");
        $normal->name;
        $normal = DotterFinalized->new();
        $normal->set_name("mommy");
        $normal->name;
    ',
    'moose'  => '
        my $normal = MooseBench->new({
            name => "daddy",
        });
        $normal->name("mommy");
        $normal->name;
        $normal = MooseBench->new();
        $normal->name("mommy");
        $normal->name;
    ',
    'moose-finalized'  => '
        my $normal = MooseBenchFinalized->new({
            name => "daddy",
        });
        $normal->name("mommy");
        $normal->name;
        $normal = MooseBenchFinalized->new();
        $normal->name("mommy");
        $normal->name;
    ',
    'accessor'  => '
        my $normal = Accessorer->new({
            name => "daddy",
        });
        $normal->name("mommy");
        $normal->name;
        $normal = Accessorer->new();
        $normal->name("mommy");
        $normal->name;
    ',
    'accessorfast'  => '
        my $normal = AccessorerFaster->new({
            name => "daddy",
        });
        $normal->name("mommy");
        $normal->name;
        $normal = AccessorerFaster->new();

        $normal->name("mommy");
        $normal->name;
    ',
    'standardfaster'  => '
        my $normal = NormalFaster->new({
            name => "daddy",
        });
        $normal->set_name("mommy");
        $normal->name;
        $normal = NormalFaster->new();
        $normal->set_name("mommy");
        $normal->name;
    ',
});
    





