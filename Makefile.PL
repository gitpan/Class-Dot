# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;
require 5.00600;

use Carp qw(carp croak);
use English qw(-no_match_vars);

BEGIN {
    eval 'require version'; ## no critic
    if ($EVAL_ERROR) {
        croak <<'EOFHELP'

ERROR -------------------------------------------------

This module requires the 'version' module to install.
Please install it via CPAN or CPANPLUS.

To install via CPAN:

    $ cpan version

To install via CPANPLUS:

    $ cpanp i version

To install manually:

    Point your web browser or URL downloader to:
    http://search.cpan.org/dist/version/

    and download the latest version of 'version'.

    then to install you do:

    $ tar xvfz version-<version_number>.tar.gz
    $ cd version-<version_number>
    $ perl Makefile.PL
    $ make && make test
    $ sudo make install 

Try installing Class::Dot again when you have installed 'version'.

Thanks for your patience!

--------------------------------------------------------------------

EOFHELP
;

    }
}

eval 'require Class::Dot';
if (not $EVAL_ERROR) {
    eval 'use version';
    if (not $EVAL_ERROR) {
        my $prev_version = version->new(Class::Dot->VERSION)->numify;
        if ($prev_version lt '2.0') {
            print <<'EOF'
*** 
NOTE: Class::Dot version 2.0 has new API changes.
      Please see Changes for details.
***
EOF
;
        }
    }
}

my @extra_recommends;
if ($PERL_VERSION < 5.009005) {
    push @extra_recommends, 'Class::C3::XS';
    carp << 'EOFTIP'

    WARNING: ------------------------------------------------------
    I see you have a version of perl older than 5.10.0.
    It is strongly recommended to update to the latest version
    of perl (atleast 5.10.0), as this version includes optimizations
    that can speed up Class::Dot considerably.

    If you don't want to update your perl, you should install the
    Class::C3::XS module, which will help speed it up a bit.
    The Class::C3::XS module requires a C compiler, however.

    To install Class::C3::XS via CPAN:

        $ cpan Class::C3::XS

    To install Class::C3::XS via CPANPLUS:

        $ cpanp i Class::C3::XS

    To download and install manually, get the module from this URL:

        http://search.cpan.org/dist/Class-C3-XS/

    Thank you for your patience!
    ---------------------------------------------------------------

EOFTIP
;
}
    

use inc::Module::Install;

my $THIS_VERSION = '2.0.0_10';

name                'Class-Dot';
author              'Ask Solem <asksh@cpan.org>';
version             $THIS_VERSION;
license             'bsd';
all_from            'lib/Class/Dot.pm';

requires            'version'             => 0;
requires            'Class::Plugin::Util' => 0.007;
requires            'Params::Util'        => 0;

recommends          'Sub::Name'        => 0;
recommends          'IO::Capture'      => 0;

for my $contextual_recommendation (@extra_recommends) {
    recommends $contextual_recommendation => 0;
}


build_requires      'Test::Simple'     => 0.42;
build_requires      'Scalar::Util'     => 1.14;
build_requires      'Test::Exception'  => 0.25;

perl_version        5.006_000;

no_index            directory => 'examples';

no_index            directory => 'devel';

distribution_type   'module';

tests('t/*.t t/*/*.t');

        


#meta_spec 'homepage'    => 'http://search.cpan.org/dist/Class-Dot';
#meta_spec 'bugtracker'
#    => 'http://rt.cpan.org/Public/Dist/Display.html?Name=Class-Dot';

package ExtUtils::MakeMaker::_version;
    use strict;
    use warnings;
    
    use Carp;
    use English qw(-no_match_vars);

    eval 'use version qw(qv)';

package main;

    auto_install;
    sign();
    WriteAll;


