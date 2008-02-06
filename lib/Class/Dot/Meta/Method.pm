# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Method;

use strict;
use warnings;
use version;
use 5.00600;

use Carp qw(croak);

our $VERSION   = qv('2.0.0_15');
our $AUTHORITY = 'cpan:ASKSH';

my %EXPORT_OK  = map { $_ => 1 } qw(
    install_sub_from_class
    install_sub_from_coderef
);

sub import {
    my ($this_class, @subs) = @_;
    my $caller_class = caller 0;

    for my $sub (@subs) {
        if (! exists $EXPORT_OK{$sub}) {
            croak "$sub is not exported by " . __PACKAGE__;
        }
        install_sub_from_class(($this_class, $sub) => $caller_class);
    }

    return;
}

sub install_sub_from_class {
    my ($pkg_from, $sub_name, $pkg_to) = @_;
    my $from = join q{::}, ($pkg_from, $sub_name);
    my $to   = join q{::}, ($pkg_to,   $sub_name);

    no strict 'refs';   ## no critic
    no warnings 'once'; ## no critic
    *{$to} = *{$from};

    return;
}

sub install_sub_from_coderef {
    my ($coderef, $pkg_to, $sub_name) = @_;
    my $to = join q{::}, ($pkg_to, $sub_name);

    no strict   'refs';     ## no critic
    no warnings 'redefine'; ## no critic
    no warnings 'once';     ## no critic
    *{$to} = $coderef;

    return;
}

1;

__END__

=begin wikidoc

= NAME

Class::Dot::Meta::Method - Method Utilities

= VERSION

This document describes MyClass version %%VERSION%%

= SYNOPSIS

    use Class::Dot::Meta::Method;

    # ### Install a method from the current class.

    use Class::Dot::Meta::Method qw(
        install_sub_from_class
    );

    # The local method
    sub meaning_of_life {
        return 42;
    }
    
    sub import_my_method {
        my ($this_class) = @_;
        my $caller_class = caller 0;

        install_sub_from_class(
            ($this_class, 'meaning_of_life') => $caller_class
        );

        return;
    }

    
    # ### Install a method by code reference.

    use Class::Dot::Meta::Method qw(
        install_sub_from_coderef
    );
   
    sub import_my_methodref {
        my ($this_class) = @_;
        my $caller_class = caller 0;

        my $the_sub = sub {
            return 42;
        };

        install_sub_from_coderef(
            $the_sub => ($caller_class, 'meaning_of_life');
        }

        return;
    }
            
    

= DESCRIPTION

This module does not really contain much. For now it's just a set of utilities
for exporting methods.

= SUBROUTINES/METHODS

== CLASS METHODS

=== {install_sub_from_class(($class_from, $method_name) => $class_to)}

Installs a method from a class into another class.

=== {install_sub_from_coderef($coderef => ($class_to, $method_name))};

Installs a code reference in a class as a method.

= DIAGNOSTICS

This class has no error messages.

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [version]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
[bug-class-dot@rt.cpan.org|mailto:bug-class-dot@rt.cpan.org], or through the
web interface at [CPAN Bug tracker|http://rt.cpan.org].

= SEE ALSO

== [Class::Dot]

= AUTHOR

Ask Solem, [asksh@cpan.org].

= LICENSE AND COPYRIGHT

Copyright (c), 2007 Ask Solem [ask@0x61736b.net|mailto:ask@0x61736b.net].

{Class::Dot} is distributed under the Modified BSD License.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. The name of the author may not be used to endorse or promote products
derived
from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED                        
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF                                
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO                          
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,                              
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,                        
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR                      
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER                       
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)                          
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                          
POSSIBILITY OF SUCH DAMAGE.

= DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE
SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE
STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY
COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE
SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER
SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

=end wikidoc

=for stopwords expandtab shiftround

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
