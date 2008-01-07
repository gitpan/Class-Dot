use strict;
use warnings;
use Benchmark qw(cmpthese);

cmpthese(-1, {
    'dot'   => q
    {
        package Dotter;
        require Class::Dot;
        Class::Dot->import(":new");
        property('name', isa_String("hello world"));
    },
    'dot-finalized' => q
    {
        package DotFinalized;
        require Class::Dot;
        Class::Dot->import(":new");
            property('name', isa_String("hello world"));
        if (! DotFinalized->__is_finalized__()) {
            DotFinalized->__finalize__();
        }
    },
    'moose' => q
    {
        package Mooser;
        require Moose;
        Moose->import();
        has('name', (is => 'rw', isa => 'Str', default => "hello world"));
    },
    'moose-finalized' => q
    {
        package Mooser;
        require Moose;
        Moose->import();
            has('name', (is => 'rw', isa => 'Str', default => "hello world"));
        if (!Mooser->meta->is_immutable()) {
            Mooser->meta->make_immutable();
        }
    },
    'class-accessor' => q
    {
        package Accessorer;
        require Class::Accessor;
        Class::Accessor->import();
        our @ISA = qw(Class::Accessor);
        Accessorer->mk_accessors(qw(name));
    },
    'class-accessor-fast' => q
    {
        package AccessorerFaster;
        require Class::Accessor::Fast;
        Class::Accessor::Fast->import();
        our @ISA = qw(Class::Accessor::Fast);
        Accessorer->mk_accessors(qw(name));
    },
});


