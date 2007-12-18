# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
use strict;
use warnings;
require 5.00600;

use English qw(-no_match_vars);
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
    

use inc::Module::Install;

my $THIS_VERSION = '2.0.0_07';

name                'Class-Dot';
author              'Ask Solem <asksh@cpan.org>';
version             $THIS_VERSION;
license             'bsd';
all_from            'lib/Class/Dot.pm';

requires            'version'             => 0;
requires            'Class::Plugin::Util' => 0.007;
requires            'Params::Util'        => 0;

recommends          'Sub::Name'        => 0;
recommends          'Test::Exception'  => 0.25;
recommends          'IO::Capture'      => 0;


build_requires      'Test::Simple'     => 0.42;
build_requires      'Scalar::Util'     => 1.14;

perl_version        5.006_000;

no_index            directory => 'examples';

no_index            directory => 'devel';

distribution_type   'module';

        


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


