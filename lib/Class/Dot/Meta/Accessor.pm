# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Meta::Accessor;

use strict;
use warnings;
use version;
use 5.00600;

our $VERSION   = qv('2.0.0_10');
our $AUTHORITY = 'cpan:ASKSH';

use Carp qw(croak);
use Class::Plugin::Util qw(load_plugins get_plugins);

load_plugins(__PACKAGE__, [qw(Base)]);

sub new {
    my ($class, $options_ref) = @_;

    my $wanted_type = ucfirst lc $options_ref->{type};
    croak 'Missing accessor type'
        if not defined $wanted_type;

    my $accessor_classes = get_plugins();

    if (! exists $accessor_classes->{$wanted_type}) {
        croak "No such accessor type: $wanted_type";
    }
    
    my $accessor_class = $accessor_classes->{$wanted_type};

    return $accessor_class->new($options_ref);
}

1;

__END__


=begin wikidoc

= NAME

Class::Dot::Meta::Accessor - Automatic generation of accessor methods

= VERSION

This document describes {Class::Dot} version %%VERSION%%

= SYNOPSIS

    use Class::Dot::Meta::Accessor;
  
    my $accessor_gen = Class::Dot::Meta::Accessor->new({
        type => 'Overrideable'
    }); 

    my $get_accessor = $accessor_gen->create_get_accessor(
        $caller_class, $attribute_name, $attribute_type, $options, $privacy
    );

    my $set_accessor = $accessor_gen->create_set_accessor(
        $caller_class, $attribute_name, $attribute_type, $options, $privacy
    );

    my $mutator = $accessor_gen->create_mutator(
        $caller_class, $attribute_name, $attribute_type, $options, $privacy
    );
    

= DESCRIPTION

This class provides automatic generation of accessor methods.
It is a factory class that delegates the construction to the proper acessor
type, which is provided with the {new()} constructors {type} option.

Common accessor types include:

* Overrideable

See [Class::Dot::Meta::Accessor::Overrideable]

* Chained

See [Class::Dot::Meta::Accessor::Chained]

* Constrained

See [Class::Dot::Meta::Accessor::Constrained]


All accessor types uses the base class [Class::Dot::Accessor::Base], which
defines their interface.

= SUBROUTINES/METHODS

== CLASS CONSTRUCTOR

=== {new({type => $accessor_type})}

Create a new accessor generator with type {$accessor_type}.

= DIAGNOSTICS

== {Missing accessor type}

You forgot to provide the accessor type.

== {No such accessor type: %s}

Could not find the class for the accessor type you provided.

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [version]

* [Class::Plugin::Util]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
[bug-class-dot@rt.cpan.org|mailto:bug-class-dot@rt.cpan.org], or through the
web interface at [CPAN Bug tracker|http://rt.cpan.org].

= SEE ALSO

== [Class::Dot::Meta::Accessor::Base]

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
