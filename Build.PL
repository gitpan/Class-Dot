# $Id: Build.PL 13 2007-10-28 16:43:56Z asksol $
# $Source: /opt/CVS/Getopt-LL/Build.PL,v $
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/class-dot/Build.PL $
# $Revision: 13 $
# $Date: 2007-10-28 17:43:56 +0100 (Sun, 28 Oct 2007) $
use strict;
use warnings;

sub BEGIN {
    use File::Spec;
    use FindBin qw($Bin);
    my $inc = File::Spec->catdir($Bin, 'inc');
    unshift @INC, $inc;
}

use Module::Build::Class::Dot;

# ##########################################################



sub YES { 1 };
sub NO  { 0 };

$ENV{DEVEL_COVER_OPTIONS} = '-ignore,blib/Class/InsideOut/Policy/Modwheel.pm';
my $builder = Module::Build::Class::Dot->new(
    module_name          => 'Class::Dot',
    dist_version        => '2.0.0_01',
    license              => 'perl',
    dist_author          => 'Ask Solem <ASKSH@cpan.org>',
    dh_make_perl         => '/opt/local/bin/xsaaaa',
    all_from             => 'lib/Class/Dot/Model.pm',
    dynamic_config       => NO,
    sign                 => NO, # asksh: have to find out why my signature fails.
    create_makefile_pl   => 'traditional',
    create_readme        => YES,
    recursive_test_files => YES,
    requires             => {
        'version'                               => 0,
    },
    recommends           => {
        'Test::Exception'       => 0.25,
        'IO::Capture::Stderr'   => 0,
    },
    build_requires       => {
     'Test::Simple'            => 0.42,    # 
    },
    add_to_cleanup       => [ qw(
        a.out
        test.pl
        test.c
        test.cpp
        test.m
        *.swp
        .gdb_history
        install.cache
        t/cache
        cache/
    ) ],
    meta_merge => {
        distribution_type   => 'Module',
    },
);

$builder->create_build_script( );

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
