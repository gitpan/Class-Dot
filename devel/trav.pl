use strict;
use warnings;
use feature qw(say);

use Class::Dot;
use TestComplete::Type1;
use Benchmark qw(cmpthese);
use MRO::Compat ();


my $isa = mro::get_linear_isa('TestComplete::Type1');
my $isa2 = Class::Dot::_get_linear_isa_pureperl('TestComplete::Type1');
my $isa3 = Class::Dot::_get_linear_isa_pureperl_rec('TestComplete::Type1');
my $isa4 = MRO::Compat::__get_linear_isa_dfs('TestComplete::Type1');

say join q{, }, @{ $isa };
say join q{, }, @{ $isa2 };
say join q{, }, @{ $isa3 };
say join q{, }, @{ $isa4 };

cmpthese(-1, {
    'mro' => q
    {
        my $isa = mro::get_linear_isa('TestComplete::Type1');
    },
    'iterative' => q
    {
        my $isa2 = Class::Dot::_get_linear_isa_pureperl('TestComplete::Type1');
    },
    'recursive' => q
    {
        my $isa3 = Class::Dot::_get_linear_isa_pureperl_rec('TestComplete::Type1');
    },
    'mro_compat' => q
    {
        my $isa4 = MRO::Compat::__get_linear_isa_dfs('TestComplete::Type1');
    }
});
